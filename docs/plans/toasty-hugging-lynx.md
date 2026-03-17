# План: Минимальная GTA V Мультиплеер Платформа

## Контекст

Цель — создать собственную минимальную мультиплеер-платформу для GTA V на базе кодовой базы FiveM (гибридный подход). Конечный результат: сервер + лаунчер-клиент + возможность двум игрокам подключиться и играть вместе. Полная синхронизация: игроки, транспорт, оружие, NPC.

FiveM — это 116 компонентов, 80+ зависимостей, 2847 C++ файлов. Стратегия: хирургическое извлечение ядра (хуки, сеть, синхронизация), удаление всего лишнего (CEF UI, скриптинг, VOIP, лицензирование, мониторинг).

---

## Фаза 0: Настройка сборки (неделя 1-2)

**Цель**: Урезанный premake-проект, который компилируется без ошибок.

### Что оставить (сервер)
- `net:base`, `net:packet`, `net:tcp-server`, `net:http-server` — сетевой стек
- `citizen:server:net` — ENet игровая сеть
- `citizen:server:main`, `citizen:server:instance`, `citizen:server:impl` — ядро сервера
- `citizen:server:state:fivesv` — sync trees для GTA V
- `conhost:server` — консоль
- `vfs:core`, `vfs:impl:server` — виртуальная ФС

### Что оставить (клиент)
- `gta-net-five` — NetHook, CloneManager, netSyncTree, netBlender, netPlayerManager
- `net`, `net-base`, `net-packet` — NetLibrary, ENet транспорт
- `gta-core-five`, `gta-game-five` — игровые хуки
- `citizen-game-main` — главный цикл
- `gta-streaming-five` — стриминг сущностей

### Что удалить
- `citizen-scripting-*` (Lua, C#, JS рантаймы)
- `citizen-resources-*` (система ресурсов)
- `voip-server:mumble` (голосовой чат)
- `citizen-server-monitor` (txAdmin)
- `discord`, `citizen-devtools`, `conhost-v2` (CEF консоль)
- CEF/Chromium, V8/Node.js, bgfx, breakpad, protobuf, rocksdb

### Vendor-зависимости (оставить)
- `citizen_enet` — UDP сеть
- `boost` — используется повсеместно
- `fmtlib`, `rapidjson`, `msgpack-c/cpp` — форматирование/сериализация
- `lz4` — сжатие packed clones
- `libuv` — event loop сервера
- `tbb`, `eastl` — конкурентные контейнеры
- `minhook`, `jitasm` — хуки клиента
- `glm` — математика

### Действия
1. Создать `premake5_minimal.lua` на основе `/code/premake5.lua` с урезанным списком компонентов
2. Создать `/data/server/components_minimal.json`
3. Создать заглушки (stubs) для удалённых компонентов — пустые `Instance<T>::Get()` для каждого убранного интерфейса
4. Файлы: [premake5.lua](code/premake5.lua), [components.json](data/server/components.json)

---

## Фаза 1: Минимальный сервер (неделя 2-4)

**Цель**: server.exe стартует, слушает порт 30120, принимает ENet-подключение.

### Шаги

1. **Точка входа** — оставить [Main.cpp](code/server/launcher/src/Main.cpp) и [Server.cpp](code/server/launcher/src/Server.cpp) почти без изменений

2. **Убрать лицензирование** из [InitConnectMethod.cpp](code/components/citizen-server-impl/src/InitConnectMethod.cpp):
   - Удалить проверку cfxTicket через Botan RSA (строки ~213-249)
   - Удалить identity providers (Steam, License, Endpoint)
   - Заменить на: принять любой guid, сгенерировать токен, вернуть JSON

3. **Убрать heartbeat** из [GameServer.cpp](code/components/citizen-server-impl/src/GameServer.cpp):
   - Удалить обращения к `servers-frontend.fivem.net`
   - Занулить `m_nextHeartbeatTime` и master server логику

4. **Минимальный server.cfg**:
   ```
   sv_hostname "TestServer"
   sv_maxclients 4
   endpoint_add_tcp "0.0.0.0:30120"
   endpoint_add_udp "0.0.0.0:30120"
   onesync on
   gamename gta5
   ```

5. **Проверка**: `curl -X POST http://localhost:30120/client -d "method=initConnect&name=test&guid=1234&protocol=12&gameName=gta5&gameBuild=3095"` должен вернуть JSON с токеном

---

## Фаза 2: Минимальный клиент/лаунчер (неделя 4-8)

**Цель**: launcher.exe находит GTA V, инжектит код, подключается к серверу.

### Шаги

1. **Упростить лаунчер** [Main.cpp](code/client/launcher/Main.cpp):
   - Оставить: OS checks, DLL preloading
   - Удалить: `Bootstrap_RunInit()` (система обновлений FiveM)
   - Удалить: `InitializeExceptionServer()` (crash reporting)
   - Упростить: `UpdateGameCache()` → просто найти путь к GTA V

2. **Обнаружение GTA V** — реестр Windows:
   - Steam: `HKLM\SOFTWARE\WOW6432Node\Rockstar Games\Grand Theft Auto V` → InstallFolder
   - Или ручной ввод пути от пользователя

3. **Оставить** [CitizenGame.cpp](code/client/launcher/CitizenGame.cpp) и [ExecutableLoader.cpp](code/client/launcher/ExecutableLoader.cpp) — ядро инъекции

4. **Оставить** [Hooking.h](code/client/shared/Hooking.h) + minhook + jitasm — система хуков

5. **Упростить подключение** в [NetLibrary.cpp](code/components/net/src/NetLibrary.cpp):
   - Удалить резолв через Cfx.re
   - Принимать raw `ip:port` напрямую
   - Оставить: POST initConnect → получить токен → ENet connect

6. **Простой UI** — консольное приложение:
   ```
   Введите IP:порт сервера> 192.168.1.100:30120
   Подключение...
   ```
   Без CEF, без веб-интерфейса.

---

## Фаза 3: Синхронизация сущностей (неделя 8-14)

**Цель**: Два игрока видят друг друга, могут ездить на транспорте, стрелять.

### Как работает синхронизация (сохраняем целиком)

1. **Клиент→Сервер**: [NetHook.cpp](code/components/gta-net-five/src/NetHook.cpp) перехватывает winsock (`CfxSendTo/CfxRecvFrom`), GTA думает что общается по LAN, трафик идёт через наш сервер как `msgRoute`

2. **Сервер**: [ServerGameState.cpp](code/components/citizen-server-impl/src/state/ServerGameState.cpp) (8058 строк, OneSync движок) — парсит, управляет владением сущностей, формирует `msgPackedClones` для каждого клиента

3. **Сервер→Клиент**: [CloneManager.cpp](code/components/gta-net-five/src/CloneManager.cpp) (2519 строк) десериализует входящие данные в игровые сущности

### Ключевые сетевые сообщения
| Сообщение | Направление | Назначение |
|-----------|------------|------------|
| `msgRoute` | клиент→сервер | обновления состояния сущностей |
| `msgPackedClones` | сервер→клиент | трансляция сущностей другим клиентам |
| `msgPackedAcks` | сервер→клиент | подтверждения создания |
| `msgEnd` | keepalive | каждые 100мс |

### Синхронизируемые типы (из коробки с OneSync)
- Player (внешность, здоровье, оружие, анимации)
- Vehicle (позиция, скорость, повреждения, пассажиры)
- Ped/NPC (задачи, навигация)
- Object (статические и динамические объекты)

### Важные подсистемы (не трогать)
- [netTimeSync.cpp](code/components/gta-net-five/src/netTimeSync.cpp) — синхронизация часов
- [netBlender.cpp](code/components/gta-net-five/src/netBlender.cpp) — интерполяция позиций
- RequestObjectIdsPacketHandler — распределение ID сущностей

---

## Фаза 4: Упаковка и распространение (неделя 14-16)

### Серверный пакет (~50MB)
- `server.exe` + DLL зависимостей
- `server.cfg`
- Инструкция: "распакуй, пробрось порт 30120, запусти"

### Клиентский пакет (~100MB, без CEF это реально)
- `launcher.exe` + `CitizenGame.dll` + компонентные DLL
- `settings.ini` с IP сервера по умолчанию
- Инструкция: "распакуй, укажи путь к GTA V, запусти"

### Сценарий для двух друзей
1. Хост распаковывает сервер, запускает, пробрасывает порт (или Hamachi/ZeroTier)
2. Оба игрока распаковывают клиент
3. При первом запуске указывают путь к GTA V
4. Вводят IP сервера → подключаются → играют

---

## Риски

| Риск | Описание | Митигация |
|------|----------|-----------|
| **Версия GTA V** | Обновления ломают паттерны хуков | Зафиксировать конкретный game build, отключить автообновление |
| **Анти-чит** | Rockstar может обнаружить инъекцию | Играть в offline/story mode, блокировать сервисы R* |
| **Сложность сборки** | Даже урезанный проект — 20+ компонентов | Бюджетировать 2 недели только на борьбу с линкером |
| **Missing stubs** | `Instance<T>::Get()` крашит при обращении к удалённым компонентам | Аудит всех `GetComponent<>` в оставленных компонентах |

---

## Альтернативный ускоренный путь

Использовать **готовый FXServer** (бесплатно скачивается с сайта Cfx.re) и написать **только упрощённый клиент**. Это сокращает проект вдвое — не нужно компилировать сервер. Минус: зависимость от артефактов Cfx.re.

---

## Проверка результата

1. Запустить server.exe — убедиться что слушает порт 30120
2. curl к initConnect — убедиться что возвращает токен
3. Запустить launcher.exe — GTA V запускается с хуками
4. Подключить клиент 1 — спавн в мире
5. Подключить клиент 2 с другой машины — оба видят друг друга
6. Проверить: ходьба, транспорт, оружие синхронизируются
7. Упаковать в zip, отправить другу, проверить установку с нуля

# SolarProject — Инструкция по сборке и запуску

## Требования

### Для сборки (Windows)
- **Visual Studio 2022** (Community Edition — бесплатно)
  - Компоненты: "Desktop development with C++", "Windows 10/11 SDK"
- **Git** (для подмодулей)
- **Python 3.x** (для скриптов сборки)
- **Premake5** (уже в `code/tools/build/bin/`)

### Для игры
- **GTA V** (Steam или Epic Games версия)
- **Windows 10** версии 1703 или выше

---

## Шаг 1: Подготовка исходников

```bash
cd /path/to/fivem-master/code

# Инициализировать и скачать подмодули (vendor)
git submodule update --init --recursive
```

---

## Шаг 2: Генерация проекта (Premake)

### Сервер
```cmd
cd C:\Users\root\Desktop\fivem-master\code
tools\ci\premake5.exe vs2022 --game=server
```
Это создаст `build/server/CitizenMP.sln`.

### Клиент (GTA V)
```cmd
cd C:\Users\root\Desktop\fivem-master\code
tools\ci\premake5.exe vs2022 --game=five
```
Это создаст `build/five/CitizenMP.sln`.

---

## Шаг 3: Сборка

1. Открыть `.sln` файл в Visual Studio 2022
2. Выбрать конфигурацию **Release** / **x64**
3. Собрать решение (Build → Build Solution или Ctrl+Shift+B)

### Выходные файлы

**Сервер**: `build/server/bin/Release/` → `SolarServer.exe` + компонентные DLL

**Клиент**: `build/five/bin/Release/` → `SolarProject.exe` + компонентные DLL (`citizen-*.dll`, `gta-*.dll` и т.д.)

---

## Шаг 4: Упаковка сервера

Создать папку `SolarServer/` и скопировать туда:
```
SolarServer/
├── SolarServer.exe          (из build/server/bin/Release/)
├── *.dll                    (все DLL из той же папки)
├── components.json          (из data/server_minimal/)
├── server.cfg               (из data/server_minimal/)
├── launch_server.bat        (из data/server_minimal/)
└── citizen/                 (из data/server/citizen/ — системные файлы)
```

---

## Шаг 5: Упаковка клиента

Создать папку `SolarProject/` и скопировать туда:
```
SolarProject/
├── SolarProject.exe         (из build/five/bin/Release/)
├── SolarProject.exe.formaldev  (пустой файл — создаётся автоматически при сборке)
├── *.dll                    (все DLL из build/five/bin/Release/)
├── components.json          (из data/client_minimal/)
├── launch_client.bat        (из data/client_minimal/)
└── citizen/                 (из data/client/citizen/ — системные файлы)
```

---

## Шаг 6: Запуск сервера

1. Откройте `server.cfg` и настройте при необходимости:
   - `sv_hostname` — имя сервера
   - `sv_maxclients` — максимум игроков (по умолчанию 4)
   - `sv_enforceGameBuild` — версия GTA V (по умолчанию 3095)
2. Запустите `launch_server.bat` (или `SolarServer.exe +exec server.cfg`)
3. Сервер запустится на порте **30120**

### Проверка работы
```bash
curl -X POST http://localhost:30120/client -d "method=getInfo"
```
Должен вернуть JSON с информацией о сервере.

---

## Шаг 7: Запуск клиента

### Вариант A: Через скрипт
```
launch_client.bat 192.168.1.100:30120
```

### Вариант B: Напрямую
```
SolarProject.exe +connect 192.168.1.100:30120
```

### Первый запуск
1. При первом запуске клиент найдёт GTA V через реестр Windows (Steam/Epic)
2. Если не найдёт — появится диалог выбора папки
3. GTA V загрузится с хуками SolarProject
4. Произойдёт автоматическое подключение к серверу

---

## Шаг 8: Игра вдвоём

### Локальная сеть (LAN)
1. Хост запускает сервер → `launch_server.bat`
2. Оба игрока запускают клиент → `launch_client.bat <IP_хоста>:30120`

### Через интернет
1. Хост пробрасывает порт **30120** (TCP + UDP) на роутере
2. Или используйте **Hamachi / ZeroTier / Radmin VPN** для виртуальной LAN
3. Игроки подключаются по внешнему IP хоста

---

## Что было изменено (относительно оригинального FiveM)

### Удалённые функции
- Проверка лицензии/тикетов (Botan RSA верификация)
- Heartbeat к серверам Cfx.re (master server listing)
- Проверка `cfxTicket` при подключении

### Ребрендинг (FiveM → SolarProject)
- Заголовок окна игры: "SolarProject"
- Имя exe клиента: `SolarProject.exe`
- Имя exe сервера: `SolarServer.exe`
- Логи: `SolarProject.log`
- Конфиг: `SolarProject.ini`
- Реестр: `HKCU\SOFTWARE\SolarProject\`
- Меню паузы, тексты, диалоги — всё "SolarProject"

### Режим работы
- `sv_lan true` — сервер не требует аутентификации
- devMode (`.formaldev`) — клиент не скачивает обновления
- Прямое подключение по IP:порт без резолва через Cfx.re
- OneSync включён — полная серверная синхронизация сущностей

---

## Синхронизация (что работает из коробки)

- Позиция и движение игроков
- Транспорт (машины, мотоциклы, вертолёты, лодки)
- Оружие и стрельба
- Здоровье и повреждения
- NPC/пешеходы
- Динамические объекты
- Анимации
- Голосовой чат (VOIP через Mumble)

---

## Возможные проблемы

| Проблема | Решение |
|----------|---------|
| "Could not find component cache storage file" | Скопировать `components.json` рядом с exe |
| Краш при запуске клиента | Убедиться что GTA V установлена, проверить `SolarProject.log` |
| Не подключается к серверу | Проверить что порт 30120 открыт, firewall не блокирует |
| "Game build mismatch" | Установить правильный `sv_enforceGameBuild` в server.cfg |
| Линкер ошибки при сборке | `git submodule update --init --recursive` для vendor зависимостей |

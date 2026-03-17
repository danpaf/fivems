Глубокое изучение проекта FiveM. Проходишь по всему проекту, находишь ВСЕ тонкости, модели, архитектурные решения и сохраняешь в PostgreSQL.

## Порядок работы

### Фаза 1: Архитектура и сборка

1. Прочитай корневой `README.md` и `code/README.md`
2. Изучи систему сборки:
   - `code/Gruntfile.js`
   - Все `premake5.lua` файлы (glob `**/premake5.lua`)
   - `.gitlab-ci.yml`, `.github/workflows/`
3. Сохрани каждую находку в `project_knowledge` (категория `build` или `architecture`)

### Фаза 2: Ядро движка (citicore)

Изучи `code/client/citicore/`:
- `ComponentLoader.h`, `ComponentLoader.cpp` — как загружаются компоненты
- `console/Console.h` — консольная система
- `om/` — объектная модель (IBase, OMClass, OMPtr)
- `se/Security.h` — система безопасности
- Все `.h` файлы — найди все классы и структуры

Сохрани каждый класс/структуру в `project_models` с полями и описанием.
Сохрани архитектурные тонкости в `project_knowledge`.

### Фаза 3: Shared-слой

Изучи `code/client/shared/`:
- `Hooking.h`, `Hooking.Patterns.h` — система хуков (ВАЖНАЯ ТОНКОСТЬ)
- `EventCore.h` — система событий
- `Registry.h` — реестр компонентов
- `CrossBuildRuntime.h` — мультибилдовость
- `Utils.h` — утилиты
- `ICoreGameInit.h` — инициализация игры
- `Error.h` — обработка ошибок
- `atArray.h`, `atPool.h`, `atHashMap.h` — GTA-структуры данных

Все модели → `project_models`. Все паттерны → `project_knowledge`.

### Фаза 4: Компоненты

Пройди по КАЖДОЙ папке в `code/components/`:
1. Прочитай `component.json` — узнай имя, зависимости
2. Прочитай `component.lua` — узнай настройки сборки
3. Бегло просмотри `include/` и `src/` — узнай назначение

Сохрани КАЖДЫЙ компонент в `project_components` с типом и зависимостями.

### Фаза 5: .NET Runtime

Изучи `code/client/clrcore/`:
- `Native.cs` — система нативных вызовов
- `BaseScript.cs` — базовый класс скриптов
- `InternalManager.cs` — менеджер скриптов
- `ScriptContext.cs` — контекст выполнения
- `External/` — все враперы (Entity, Vehicle, Ped, Player, World...)
- `Math/` — математические типы

Каждый класс → `project_models`. Тонкости (как работает Native invoke, lifecycle скриптов) → `project_knowledge`.

### Фаза 6: CLR v2

Изучи `code/client/clrcore-v2/`:
- Чем отличается от v1
- `Interop/` — межпроцессное взаимодействие, MsgPack
- `Coroutine/` — система корутин
- `Native/` — новая система нативов

Сохрани отличия и модели.

### Фаза 7: Скриптинг

Изучи компоненты скриптинга:
- `citizen-scripting-core` — ядро (ScriptHost, Profiler, Invoker)
- `citizen-scripting-lua` — Lua runtime
- `citizen-scripting-mono` / `mono-v2` — .NET runtime

Сохрани в `project_knowledge` (категория `scripting`).

### Фаза 8: Ресурсная система

Изучи:
- `citizen-resources-core` — Resource, ResourceManager, StateBag, EventReassembly
- `citizen-resources-client` — ResourceCache, CachedResourceMounter
- `citizen-resources-gta` — GTA-специфичная логика

Все интерфейсы → `project_models`. Тонкости → `project_knowledge`.

### Фаза 9: Сеть

Изучи `citizen-legacy-net-resources`:
- NetEventPacketHandler
- ReassembledEventPacketHandler
- ResourceNetBindings

Сохрани в `project_knowledge` (категория `networking`).

### Фаза 10: Launcher

Изучи `code/client/launcher/`:
- Процесс запуска (Main.cpp, Bootstrap.cpp)
- Обновления (Updater.cpp)
- Кеширование игры (GameCache.cpp)
- Загрузка EXE (ExecutableLoader)
- MiniDump/crash handling

Тонкости → `project_knowledge`.

## Правила

- Используй UPSERT (ON CONFLICT DO UPDATE) для ВСЕХ вставок
- project = 'fivem' для всех записей
- Выводи прогресс: "Фаза X: ..." после каждой фазы
- В конце выведи общую статистику — сколько записей добавлено в каждую таблицу
- Работай параллельно где возможно (Agent tool)
- Не пропускай фазы, даже если контекст большой — сохраняй самое важное

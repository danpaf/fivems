Проведи глубокое сканирование проекта FiveM и сохрани все обнаруженные знания в PostgreSQL.

## Шаги

### 1. Структура проекта
Изучи корневую структуру и основные директории. Сохрани в `project_knowledge` с категорией `architecture`.

### 2. Система сборки
Найди и проанализируй файлы сборки (premake5.lua, CMakeLists, .csproj, Gruntfile.js). Сохрани в `project_knowledge` с категорией `build`.

### 3. Компоненты
Просканируй `code/components/` — каждый компонент имеет `component.json` и `component.lua`. Прочитай их и сохрани в `project_components`:
- имя компонента
- тип (client/server/shared)
- зависимости
- описание

### 4. Модели и структуры данных
Найди ключевые C++ классы и C# модели в:
- `code/client/citicore/` — ядро
- `code/client/clrcore/` — .NET runtime
- `code/client/shared/` — общие структуры

Сохрани в `project_models` с полями и связями.

### 5. Scripting API
Изучи скриптовые интерфейсы:
- `code/components/citizen-scripting-lua/` — Lua runtime
- `code/components/citizen-scripting-core/` — ядро скриптинга
- `code/client/clrcore/Native.cs` — нативные вызовы

Сохрани endpoints/natives в `project_apis`.

### 6. Конвенции
Проанализируй `.clang-format`, `.editorconfig`, стиль кода. Сохрани в `project_knowledge` с категорией `convention`.

### 7. Сетевая часть
Изучи `code/components/citizen-legacy-net-resources/` и связанные. Сохрани в `project_knowledge` с категорией `networking`.

Используй UPSERT (ON CONFLICT DO UPDATE) для всех вставок. Выводи прогресс по мере работы.

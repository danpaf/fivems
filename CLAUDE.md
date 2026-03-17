# Project Rules — FiveM

## Knowledge Persistence (MCP PostgreSQL)

При изучении проекта **обязательно сохраняй** обнаруженные знания в PostgreSQL через MCP (`mcp__postgres__execute_sql`).

### Что сохранять

**Модели и структуры данных** → таблица `project_models`:
```sql
INSERT INTO project_models (project, model_name, fields, relationships, file_path, notes)
VALUES ('fivem', 'ModelName', '[{"name":"field","type":"int"}]'::jsonb, '[]'::jsonb, 'path/to/file.cpp', 'описание')
ON CONFLICT (project, model_name) DO UPDATE SET
  fields = EXCLUDED.fields, relationships = EXCLUDED.relationships,
  file_path = EXCLUDED.file_path, notes = EXCLUDED.notes, updated_at = NOW();
```

**Компоненты и модули** → таблица `project_components`:
```sql
INSERT INTO project_components (project, component_name, component_type, dependencies, description, file_path)
VALUES ('fivem', 'component-name', 'type', '["dep1"]'::jsonb, 'описание', 'path/to/file')
ON CONFLICT (project, component_name) DO UPDATE SET
  component_type = EXCLUDED.component_type, dependencies = EXCLUDED.dependencies,
  description = EXCLUDED.description, file_path = EXCLUDED.file_path, updated_at = NOW();
```

**API и эндпоинты** → таблица `project_apis`:
```sql
INSERT INTO project_apis (project, endpoint, method, description, params, response_schema, file_path)
VALUES ('fivem', '/endpoint', 'GET', 'описание', '{}'::jsonb, '{}'::jsonb, 'path/to/file')
ON CONFLICT (project, endpoint, method) DO UPDATE SET
  description = EXCLUDED.description, params = EXCLUDED.params,
  response_schema = EXCLUDED.response_schema, file_path = EXCLUDED.file_path, updated_at = NOW();
```

**Общие знания** (архитектура, паттерны, конвенции) → таблица `project_knowledge`:
```sql
INSERT INTO project_knowledge (project, category, name, description, details, file_path)
VALUES ('fivem', 'category', 'name', 'описание', '{}'::jsonb, 'path/to/file')
ON CONFLICT (project, category, name) DO UPDATE SET
  description = EXCLUDED.description, details = EXCLUDED.details,
  file_path = EXCLUDED.file_path, updated_at = NOW();
```

### Категории для project_knowledge
- `architecture` — архитектурные решения, паттерны
- `build` — система сборки, зависимости, конфигурация
- `convention` — code style, naming conventions
- `config` — конфигурационные файлы и их назначение
- `native` — нативные функции GTA/RDR
- `scripting` — скриптинг (Lua, C#, JS)
- `networking` — сетевая часть, протоколы
- `security` — механизмы безопасности

### Когда сохранять
- При первом изучении файла или директории
- При обнаружении модели, структуры, компонента или API
- При выявлении архитектурных паттернов или конвенций
- При анализе зависимостей между компонентами

### Когда читать
В начале работы над задачей — проверь, что уже известно:
```sql
SELECT * FROM project_knowledge WHERE project = 'fivem' ORDER BY updated_at DESC LIMIT 20;
SELECT * FROM project_models WHERE project = 'fivem';
SELECT * FROM project_components WHERE project = 'fivem';
```

## Project Info

- **Repo**: FiveM — модифицированный клиент GTA V для мультиплеера
- **Languages**: C++, C#, Lua, JavaScript/TypeScript
- **Build**: Premake5 (C++), MSBuild (.NET)
- **Key dirs**:
  - `code/client/` — клиентская часть
  - `code/components/` — компоненты (основная логика)
  - `code/client/clrcore/` — .NET runtime
  - `code/client/citicore/` — ядро движка
  - `ext/` — внешние расширения и инструменты

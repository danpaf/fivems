Прочитай весь сохранённый контекст проекта из PostgreSQL и выведи краткую сводку.

Выполни следующие запросы через mcp__postgres__execute_sql:

1. Общие знания:
```sql
SELECT category, name, description FROM project_knowledge WHERE project = 'fivem' ORDER BY category, updated_at DESC;
```

2. Модели:
```sql
SELECT model_name, fields, file_path, notes FROM project_models WHERE project = 'fivem' ORDER BY updated_at DESC;
```

3. Компоненты:
```sql
SELECT component_name, component_type, description, dependencies FROM project_components WHERE project = 'fivem' ORDER BY updated_at DESC;
```

4. API:
```sql
SELECT endpoint, method, description, params FROM project_apis WHERE project = 'fivem' ORDER BY updated_at DESC;
```

Выведи результаты в структурированном виде. Если таблицы пусты — сообщи что контекст ещё не собран и предложи запустить /scan-project.

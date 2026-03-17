Покажи статистику базы знаний проекта.

```sql
SELECT 'Общие знания' as таблица, COUNT(*) as записей,
  COUNT(DISTINCT category) as категорий,
  MAX(updated_at)::text as последнее_обновление
FROM project_knowledge WHERE project = 'fivem'
UNION ALL
SELECT 'Модели', COUNT(*), 0, MAX(updated_at)::text FROM project_models WHERE project = 'fivem'
UNION ALL
SELECT 'Компоненты', COUNT(*), COUNT(DISTINCT component_type), MAX(updated_at)::text FROM project_components WHERE project = 'fivem'
UNION ALL
SELECT 'API', COUNT(*), COUNT(DISTINCT method), MAX(updated_at)::text FROM project_apis WHERE project = 'fivem';
```

Также покажи топ-5 категорий знаний:
```sql
SELECT category, COUNT(*) as count FROM project_knowledge
WHERE project = 'fivem' GROUP BY category ORDER BY count DESC LIMIT 5;
```

Выведи красивую сводку.

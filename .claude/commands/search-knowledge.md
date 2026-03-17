Поиск по базе знаний проекта.

Запрос: $ARGUMENTS

Выполни полнотекстовый поиск по всем таблицам:

```sql
SELECT 'knowledge' as source, category as type, name, description
FROM project_knowledge WHERE project = 'fivem'
  AND (name ILIKE '%$ARGUMENTS%' OR description ILIKE '%$ARGUMENTS%')
UNION ALL
SELECT 'model', 'model', model_name, notes
FROM project_models WHERE project = 'fivem'
  AND (model_name ILIKE '%$ARGUMENTS%' OR notes ILIKE '%$ARGUMENTS%')
UNION ALL
SELECT 'component', component_type, component_name, description
FROM project_components WHERE project = 'fivem'
  AND (component_name ILIKE '%$ARGUMENTS%' OR description ILIKE '%$ARGUMENTS%')
UNION ALL
SELECT 'api', method, endpoint, description
FROM project_apis WHERE project = 'fivem'
  AND (endpoint ILIKE '%$ARGUMENTS%' OR description ILIKE '%$ARGUMENTS%')
ORDER BY source;
```

Выведи результаты в удобном виде. Если ничего не найдено — предложи запустить /scan-project.

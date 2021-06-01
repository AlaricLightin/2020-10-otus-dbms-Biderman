## Разворачивание БД в докере

Создание контейнера:
```
docker run -d --name=doc-creation-pg -e POSTGRES_PASSWORD=password -e POSTGRES_DB=doc_creation -e PGDATA=/var/lib/postgresql/data/pgdata -v /D/postgres-data:/var/lib/postgresql/data postgres:13.3
```

Копирование внутрь схемы:
```
docker cp ./schema.sql doc-creation-pg:/schema.sql
```

Выполнение команд схемы:
```
docker exec -u postgres doc-creation-pg psql -d doc_creation -f /schema.sql
```
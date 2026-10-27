# Threaded comments in Postgres: `parent_id` + recursive CTE

## 1. Start Postgres

```bash
docker compose up -d
```

On the first start, `seed.sql` creates and fills the `comments` table.

GUI client (TablePlus, DBeaver, ...): `postgres://postgres:postgres@localhost:5434/demo`

## 2. Reset the data

```bash
docker compose exec -T db psql -U postgres -d demo < seed.sql
```

## 3. Open a psql shell

```bash
docker compose exec db psql -U postgres -d demo
```

## 4. Retrieve data

All comments:

```sql
SELECT * FROM comments ORDER BY id;
```

Full thread for video 5:

```sql
WITH RECURSIVE thread AS (
  SELECT id, comment, parent_id, 0 AS depth
  FROM comments
  WHERE parent_id IS NULL AND video_id = 5   -- start at top-level comments

  UNION ALL

  SELECT c.id, c.comment, c.parent_id, t.depth + 1
  FROM comments c
  JOIN thread t ON c.parent_id = t.id        -- then find their children, repeatedly
)
SELECT * FROM thread;
```

Run all the demo queries in `queries.sql`:

```bash
docker compose exec db psql -U postgres -d demo -f /queries.sql
```

## 5. Nested JSON for the client

**Option A: Postgres builds it.** `tree.sql` creates a recursive `comment_tree()` function:

```bash
docker compose exec -T db psql -U postgres -d demo -At < tree.sql
```

Your API then only needs `SELECT comment_tree(5);`.

**Option B: the app builds it.** Postgres returns flat rows and `build-tree.js` nests them:

```bash
docker compose exec -T db psql -U postgres -d demo -At -c "
WITH RECURSIVE thread AS (
  SELECT id, comment, user_id, parent_id, 0 AS depth
  FROM comments WHERE parent_id IS NULL AND video_id = 5
  UNION ALL
  SELECT c.id, c.comment, c.user_id, c.parent_id, t.depth + 1
  FROM comments c JOIN thread t ON c.parent_id = t.id
)
SELECT json_agg(thread ORDER BY id) FROM thread;" | node build-tree.js
```

## 6. Clean up

```bash
docker compose down -v   # -v deletes the data volume too
```

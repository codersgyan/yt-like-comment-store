-- 1. The raw table
SELECT * FROM comments ORDER BY id;

-- 2. A self-join only goes one level deep
SELECT c.id, c.comment, p.comment AS replying_to
FROM comments c
LEFT JOIN comments p ON c.parent_id = p.id
WHERE c.video_id = 5
ORDER BY c.id;

-- 3. Recursive CTE: the whole thread, any depth
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

-- 4. Same CTE, ordered by path and indented as a tree
WITH RECURSIVE thread AS (
  SELECT id, comment, parent_id, 0 AS depth, ARRAY[id] AS path
  FROM comments
  WHERE parent_id IS NULL AND video_id = 5

  UNION ALL

  SELECT c.id, c.comment, c.parent_id, t.depth + 1, t.path || c.id
  FROM comments c
  JOIN thread t ON c.parent_id = t.id
)
SELECT id, repeat('    ', depth) || comment AS tree, depth
FROM thread
ORDER BY path;

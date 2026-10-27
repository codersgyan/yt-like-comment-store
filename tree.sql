-- Option A: Postgres builds the nested JSON.
-- A recursive CTE can't do this because aggregates (jsonb_agg) aren't allowed
-- in its recursive part. So we use a function that calls itself for each reply.
CREATE OR REPLACE FUNCTION comment_tree(p_video_id INT, p_parent_id INT DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql STABLE AS $$
BEGIN
  RETURN (
    SELECT COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'id',      c.id,
          'comment', c.comment,
          'user_id', c.user_id,
          'replies', comment_tree(p_video_id, c.id)   -- recurse into children
        )
        ORDER BY c.id
      ),
      '[]'::jsonb
    )
    FROM comments c
    WHERE c.video_id = p_video_id
      AND c.parent_id IS NOT DISTINCT FROM p_parent_id  -- NULL = top-level
  );
END;
$$;

SELECT jsonb_pretty(comment_tree(5));

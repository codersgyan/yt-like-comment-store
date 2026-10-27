-- Safe to re-run: drops and recreates the table
DROP TABLE IF EXISTS comments;

CREATE TABLE comments (
  id        SERIAL PRIMARY KEY,
  comment   TEXT    NOT NULL,
  user_id   INT     NOT NULL,
  video_id  INT     NOT NULL,
  parent_id INT     REFERENCES comments(id) ON DELETE CASCADE  -- NULL = top-level comment
);

CREATE INDEX idx_comments_parent_id ON comments(parent_id);
CREATE INDEX idx_comments_video_id  ON comments(video_id);

INSERT INTO comments (id, comment, user_id, video_id, parent_id) VALUES
  -- Video 5, thread 1
  (1, 'Great videos',             3, 5, NULL),
  (2, 'agree!',                   4, 5, 1),
  (3, 'agree! me too!',           7, 5, 2),

  -- Video 5, thread 2
  (4, 'Can you cover indexes next?',     8, 5, NULL),
  (5, 'Yes please!',                     3, 5, 4),
  (6, 'Already on my list :)',           1, 5, 4),
  (7, 'Waiting for it',                  9, 5, 6),

  -- Another branch under thread 1
  (8, 'This channel is underrated',      10, 5, 1),
  (9, 'Facts',                           4, 5, 8),

  -- Video 6: must not appear in video 5 queries
  (10, 'Nice explanation of joins',      2, 6, NULL),
  (11, 'Helped me in my interview',      5, 6, 10);

-- We inserted explicit ids, so move the sequence past them
SELECT setval('comments_id_seq', (SELECT MAX(id) FROM comments));

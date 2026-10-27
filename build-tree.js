// Option B: Postgres returns flat rows, the app nests them.
// Two passes over a Map, so it's O(n) regardless of thread depth.
// Usage: see "Option B" in the README.

function buildTree(rows) {
  const byId = new Map();
  const roots = [];

  // Pass 1: index every row by id
  for (const row of rows) {
    byId.set(row.id, { ...row, replies: [] });
  }

  // Pass 2: attach each node to its parent
  for (const node of byId.values()) {
    if (node.parent_id === null) {
      roots.push(node);
    } else {
      byId.get(node.parent_id)?.replies.push(node);
    }
  }

  return roots;
}

let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  const rows = JSON.parse(input);
  console.log(JSON.stringify(buildTree(rows), null, 2));
});

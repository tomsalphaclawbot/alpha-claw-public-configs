const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

const snapshotsPath = path.join(__dirname, 'data', 'snapshots.json');

function loadSnapshots() {
  const raw = fs.readFileSync(snapshotsPath, 'utf8');
  return JSON.parse(raw).sort((a, b) => new Date(b.releasedAt) - new Date(a.releasedAt));
}

app.use(express.static(path.join(__dirname, 'public')));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'alpha-claw-public-configs' });
});

app.get('/api/snapshots', (_req, res) => {
  res.json({
    project: 'alpha-claw-public-configs',
    generatedAt: new Date().toISOString(),
    snapshots: loadSnapshots()
  });
});

app.listen(port, () => {
  console.log(`alpha-claw-public-configs listening on port ${port}`);
});

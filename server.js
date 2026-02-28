const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

const snapshotsRoot = path.join(__dirname, 'snapshots');

function safeReadJson(filePath) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (_err) {
    return null;
  }
}

function listSnapshots() {
  if (!fs.existsSync(snapshotsRoot)) return [];

  const dirs = fs
    .readdirSync(snapshotsRoot, { withFileTypes: true })
    .filter((d) => d.isDirectory() && d.name !== 'latest')
    .map((d) => d.name)
    .sort((a, b) => b.localeCompare(a));

  return dirs
    .map((id) => {
      const manifestPath = path.join(snapshotsRoot, id, 'manifest.json');
      const manifest = safeReadJson(manifestPath);
      if (!manifest) return null;

      return {
        snapshotId: id,
        generatedAt: manifest.generatedAt,
        fileCount: manifest.fileCount,
        sha256: manifest.sha256,
        manifestPath: `/snapshots/${id}/manifest.json`,
        browsePath: `/snapshots/${id}/`,
        policy: manifest.policy
      };
    })
    .filter(Boolean);
}

function latestManifest() {
  const latest = path.join(snapshotsRoot, 'latest', 'manifest.json');
  return safeReadJson(latest);
}

app.use(express.static(path.join(__dirname, 'public')));
app.use('/snapshots', express.static(path.join(__dirname, 'snapshots')));

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'alpha-claw-public-configs' });
});

app.get('/api/snapshots', (_req, res) => {
  res.json({
    project: 'alpha-claw-public-configs',
    generatedAt: new Date().toISOString(),
    snapshots: listSnapshots()
  });
});

app.get('/api/snapshots/latest', (_req, res) => {
  const manifest = latestManifest();
  if (!manifest) {
    return res.status(404).json({ error: 'No latest snapshot available' });
  }
  return res.json(manifest);
});

app.listen(port, () => {
  console.log(`alpha-claw-public-configs listening on port ${port}`);
});

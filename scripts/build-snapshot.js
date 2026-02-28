#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const WORKSPACE_ROOT = '/Users/openclaw/.openclaw/workspace';
const CONFIG_ROOT = '/Users/openclaw/.openclaw';
const PROJECT_ROOT = path.resolve(__dirname, '..');
const SNAPSHOTS_ROOT = path.join(PROJECT_ROOT, 'snapshots');

const BANNED_PATH_SEGMENTS = [
  '.git',
  'node_modules',
  'memory',
  'state',
  'logs',
  'transcripts',
  'sessions',
  'credentials',
  'delivery-queue',
  'tmp'
];

const WORKSPACE_FILE_ALLOWLIST = [
  'AGENTS.md',
  'SOUL.md',
  'IDENTITY.md',
  'USER.md',
  'TOOLS.md',
  'HEARTBEAT.md',
  'README.md',
  'ARCHITECTURE.md',
  'PROJECTS.md',
  'BEADS.md',
  'CONSTITUTION.md'
];

const WORKSPACE_SCRIPT_ALLOWLIST = [
  'scripts/heartbeat-enforce.sh',
  'scripts/heartbeat-holistic.sh',
  'scripts/subagent-dispatcher.sh',
  'scripts/subagent-stall-watch.sh',
  'scripts/subagent-global-status.sh',
  'scripts/subagent-status-read.sh',
  'scripts/proactive-notify-guard.sh',
  'scripts/proactive-thread-target.sh',
  'scripts/conversation-activity-refresh.sh',
  'scripts/gateway-selfheal.sh',
  'scripts/openclaw-watchdog.sh',
  'scripts/beads-ui-ensure.sh',
  'scripts/beads-viewer-refresh.sh',
  'scripts/beads-viewer-serve.sh',
  'scripts/daily-full-sync.sh'
];

const CONFIG_FILE_ALLOWLIST = [
  'README.md',
  'completions/openclaw.bash',
  'completions/openclaw.zsh',
  'completions/openclaw.fish',
  'completions/openclaw.ps1'
];

const CONFIG_WORKSPACE_DOCS = [
  'workspace-claude/AGENTS.md',
  'workspace-claude/SOUL.md',
  'workspace-claude/IDENTITY.md',
  'workspace-claude/USER.md',
  'workspace-claude/TOOLS.md',
  'workspace-codex/AGENTS.md',
  'workspace-codex/SOUL.md',
  'workspace-codex/IDENTITY.md',
  'workspace-codex/USER.md',
  'workspace-codex/TOOLS.md'
];

function ensureDir(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function exists(p) {
  return fs.existsSync(p);
}

function isBanned(relPath) {
  const normalized = relPath.split(path.sep).join('/').toLowerCase();
  return BANNED_PATH_SEGMENTS.some((seg) => normalized.includes(`/${seg}/`) || normalized.startsWith(`${seg}/`) || normalized === seg);
}

function walkFiles(baseDir) {
  const out = [];
  function walk(current, relPrefix = '') {
    const entries = fs.readdirSync(current, { withFileTypes: true });
    for (const entry of entries) {
      const abs = path.join(current, entry.name);
      const rel = relPrefix ? path.join(relPrefix, entry.name) : entry.name;
      if (entry.isDirectory()) {
        walk(abs, rel);
      } else if (entry.isFile()) {
        out.push(rel);
      }
    }
  }
  walk(baseDir);
  return out;
}

function isLikelyText(buffer) {
  const sample = buffer.subarray(0, Math.min(buffer.length, 2048));
  return !sample.includes(0);
}

function sanitizeText(text) {
  let out = text;
  const stats = {
    emails: 0,
    phones: 0,
    ids: 0,
    secrets: 0
  };

  out = out.replace(/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/gi, () => {
    stats.emails += 1;
    return '[REDACTED_EMAIL]';
  });

  out = out.replace(/(?<!\d)(?:\+?\d[\d\s().-]{7,}\d)(?!\d)/g, (m) => {
    const digits = m.replace(/\D/g, '');
    if (digits.length >= 10) {
      stats.phones += 1;
      return '[REDACTED_PHONE]';
    }
    return m;
  });

  out = out.replace(/(?<![A-Za-z0-9_])-?\d{9,}(?![A-Za-z0-9_])/g, () => {
    stats.ids += 1;
    return '[REDACTED_ID]';
  });

  out = out.replace(/(["']?(?:api[_-]?key|token|secret|password|passwd|client[_-]?secret|access[_-]?token|refresh[_-]?token|authorization)["']?\s*[:=]\s*)(["']?)([^\n"']+)(\2)/gi, (_m, p1, quote, _p3, p4) => {
    stats.secrets += 1;
    return `${p1}${quote}[REDACTED_SECRET]${p4}`;
  });

  return { out, stats };
}

function hashContent(buffer) {
  return crypto.createHash('sha256').update(buffer).digest('hex');
}

function copyAndSanitize({ sourceRoot, sourceLabel, relativePath, snapshotDir, manifest }) {
  const sourceAbs = path.resolve(sourceRoot, relativePath);
  if (!sourceAbs.startsWith(path.resolve(sourceRoot) + path.sep) && sourceAbs !== path.resolve(sourceRoot)) {
    return;
  }
  if (!exists(sourceAbs)) {
    return;
  }
  if (isBanned(relativePath)) {
    return;
  }

  const outputRelPath = path.join(sourceLabel, relativePath).split(path.sep).join('/');
  const outputAbs = path.join(snapshotDir, outputRelPath);
  ensureDir(path.dirname(outputAbs));

  const inputBuffer = fs.readFileSync(sourceAbs);
  if (!isLikelyText(inputBuffer)) {
    return;
  }

  const inputText = inputBuffer.toString('utf8');
  const { out, stats } = sanitizeText(inputText);
  fs.writeFileSync(outputAbs, out, 'utf8');

  const outputBuffer = Buffer.from(out, 'utf8');
  manifest.files.push({
    path: outputRelPath,
    source: sourceLabel,
    sha256: hashContent(outputBuffer),
    bytes: outputBuffer.length,
    redactions: stats
  });
}

function addIfFile(list, sourceRoot, sourceLabel, relPath, snapshotDir, manifest) {
  const abs = path.join(sourceRoot, relPath);
  if (exists(abs) && fs.statSync(abs).isFile()) {
    copyAndSanitize({ sourceRoot, sourceLabel, relativePath: relPath, snapshotDir, manifest });
    list.add(`${sourceLabel}:${relPath}`);
  }
}

function main() {
  ensureDir(SNAPSHOTS_ROOT);
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const snapshotDir = path.join(SNAPSHOTS_ROOT, stamp);
  ensureDir(snapshotDir);

  const manifest = {
    snapshotId: stamp,
    generatedAt: new Date().toISOString(),
    sourceRoots: {
      workspace: WORKSPACE_ROOT,
      config: CONFIG_ROOT
    },
    policy: {
      include: {
        workspaceFiles: WORKSPACE_FILE_ALLOWLIST,
        workspaceDirs: ['docs/**', 'instructions/**', 'skills/*/SKILL.md'],
        workspaceScripts: WORKSPACE_SCRIPT_ALLOWLIST,
        configFiles: CONFIG_FILE_ALLOWLIST,
        configWorkspaceDocs: CONFIG_WORKSPACE_DOCS
      },
      exclude: [
        'memory/**',
        'state/**',
        'logs/**',
        'transcripts/**',
        'sessions/**',
        '.git/**',
        'node_modules/**',
        'credentials/**'
      ],
      redaction: ['emails', 'phone-like numbers', 'chat/id-like long numbers', 'token/secret/password assignment values']
    },
    files: []
  };

  const dedupe = new Set();

  for (const rel of WORKSPACE_FILE_ALLOWLIST) {
    addIfFile(dedupe, WORKSPACE_ROOT, 'workspace', rel, snapshotDir, manifest);
  }

  for (const rel of WORKSPACE_SCRIPT_ALLOWLIST) {
    addIfFile(dedupe, WORKSPACE_ROOT, 'workspace', rel, snapshotDir, manifest);
  }

  const workspaceDocsDir = path.join(WORKSPACE_ROOT, 'docs');
  if (exists(workspaceDocsDir) && fs.statSync(workspaceDocsDir).isDirectory()) {
    for (const rel of walkFiles(workspaceDocsDir)) {
      const fullRel = path.join('docs', rel);
      if (!isBanned(fullRel)) {
        copyAndSanitize({ sourceRoot: WORKSPACE_ROOT, sourceLabel: 'workspace', relativePath: fullRel, snapshotDir, manifest });
      }
    }
  }

  const instructionsDir = path.join(WORKSPACE_ROOT, 'instructions');
  if (exists(instructionsDir) && fs.statSync(instructionsDir).isDirectory()) {
    for (const rel of walkFiles(instructionsDir)) {
      const fullRel = path.join('instructions', rel);
      if (!isBanned(fullRel)) {
        copyAndSanitize({ sourceRoot: WORKSPACE_ROOT, sourceLabel: 'workspace', relativePath: fullRel, snapshotDir, manifest });
      }
    }
  }

  const skillsDir = path.join(WORKSPACE_ROOT, 'skills');
  if (exists(skillsDir) && fs.statSync(skillsDir).isDirectory()) {
    const subdirs = fs.readdirSync(skillsDir, { withFileTypes: true }).filter((d) => d.isDirectory());
    for (const dirent of subdirs) {
      const rel = path.join('skills', dirent.name, 'SKILL.md');
      addIfFile(dedupe, WORKSPACE_ROOT, 'workspace', rel, snapshotDir, manifest);
    }
  }

  for (const rel of CONFIG_FILE_ALLOWLIST) {
    addIfFile(dedupe, CONFIG_ROOT, 'config', rel, snapshotDir, manifest);
  }

  for (const rel of CONFIG_WORKSPACE_DOCS) {
    addIfFile(dedupe, CONFIG_ROOT, 'config', rel, snapshotDir, manifest);
  }

  manifest.files.sort((a, b) => a.path.localeCompare(b.path));
  manifest.fileCount = manifest.files.length;
  manifest.sha256 = hashContent(Buffer.from(JSON.stringify(manifest.files), 'utf8'));

  const manifestPath = path.join(snapshotDir, 'manifest.json');
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n', 'utf8');

  const latestLink = path.join(SNAPSHOTS_ROOT, 'latest');
  try {
    fs.rmSync(latestLink, { recursive: true, force: true });
  } catch (_err) {
    // ignore
  }

  const relativeTarget = path.basename(snapshotDir);
  let latestMode = 'symlink';
  try {
    fs.symlinkSync(relativeTarget, latestLink, 'dir');
  } catch (_err) {
    latestMode = 'copy';
    ensureDir(latestLink);
    fs.cpSync(snapshotDir, latestLink, { recursive: true });
  }

  console.log(JSON.stringify({
    snapshotId: stamp,
    snapshotDir,
    manifestPath,
    fileCount: manifest.fileCount,
    latestMode,
    latestPath: latestLink
  }, null, 2));
}

main();

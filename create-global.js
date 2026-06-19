const fs = require('fs');
const path = require('path');

const BASE_DIR = __dirname;
const OUTPUT_FILE = path.join(BASE_DIR, 'global.sql');

const SECTIONS = [
  { label: 'TABLES',    dir: path.join(BASE_DIR, 'tables') },
  { label: 'FUNCTIONS', dir: path.join(BASE_DIR, 'functions') },
  { label: 'INSERTS',   dir: path.join(BASE_DIR, 'inserts') },
  { label: 'DB USER',   dir: path.join(BASE_DIR, 'db-user') },
];

function getSqlFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => f.endsWith('.sql'))
    .sort()
    .map((f) => path.join(dir, f));
}

function buildGlobal() {
  const parts = [];

  for (const section of SECTIONS) {
    const files = getSqlFiles(section.dir);

    parts.push(`-- ${'='.repeat(60)}`);
    parts.push(`-- ${section.label}`);
    parts.push(`-- ${'='.repeat(60)}\n`);

    if (files.length === 0) {
      parts.push(`-- (no .sql files found in ${path.relative(BASE_DIR, section.dir)})\n`);
      continue;
    }

    for (const file of files) {
      const relative = path.relative(BASE_DIR, file);
      parts.push(`-- File: ${relative}`);
      parts.push(fs.readFileSync(file, 'utf8').trimEnd());
      parts.push('\n');
    }
  }

  const output = parts.join('\n');
  fs.writeFileSync(OUTPUT_FILE, output, 'utf8');
  console.log(`global.sql generated successfully (${output.length} bytes)`);
}

buildGlobal();

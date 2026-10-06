#!/usr/bin/env bash
# Regenerate .claude-plugin/marketplace.json from skills/ (skips gitignored, unlicensed skills).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
mkdir -p .claude-plugin
paths=()
for d in skills/*/; do
  d=${d%/}
  git check-ignore -q "$d/" 2>/dev/null && continue
  grep -qxF "$d/" .gitignore 2>/dev/null && continue
  paths+=("\"./$d\"")
done
list=$(IFS=,; echo "${paths[*]}" | sed 's/,/,\n        /g')
cat > .claude-plugin/marketplace.json <<JSON
{
  "name": "ryan-agent-skills",
  "owner": { "name": "Ryan" },
  "metadata": { "description": "Personal agent skills: R, Rust, PostgreSQL, SQL Server, Docker" },
  "plugins": [
    {
      "name": "all-skills",
      "description": "Every committed skill in this repo",
      "source": "./",
      "strict": false,
      "skills": [
        $list
      ]
    }
  ]
}
JSON

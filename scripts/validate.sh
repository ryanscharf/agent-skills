#!/usr/bin/env bash
# Check every skill against the basics of the agentskills.io spec.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT/skills"
fail=0; declare -A seen=()
for d in */; do
  d=${d%/}; f="$d/SKILL.md"
  err(){ echo "FAIL $d: $1"; fail=1; }
  [[ -f "$f" ]] || { err "missing SKILL.md"; continue; }
  [[ $(head -1 "$f") == "---" ]] || err "no frontmatter"
  fm=$(awk 'NR==1{next} /^---/{exit} {print}' "$f")
  name=$(grep -m1 '^name:' <<<"$fm" | sed -E 's/^name:[[:space:]]*//; s/^["'\'']//; s/["'\'']$//')
  [[ "$name" == "$d" ]] || err "name '$name' != folder"
  [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ && ${#name} -le 64 ]] || err "name not lowercase-hyphen <=64 chars"
  grep -q '^description:' <<<"$fm" || err "no description"
  [[ -n "${seen[$name]:-}" ]] && err "duplicate name"; seen[$name]=1
done
(( fail )) && exit 1 || echo "All $(ls -d */ | wc -l | tr -d ' ') skills valid."

#!/usr/bin/env bash
# Symlink every skill in skills/ into each agent's user-level skills directory.
# Re-run after sync; `git pull && ./scripts/sync.sh && ./scripts/install.sh` keeps a machine current.
#   ./scripts/install.sh                       -> ~/.claude/skills and ~/.agents/skills
#   ./scripts/install.sh ~/some/other/dir ...  -> custom targets
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
targets=("$@"); (( ${#targets[@]} )) || targets=("$HOME/.claude/skills" "$HOME/.agents/skills")
for t in "${targets[@]}"; do
  mkdir -p "$t"
  # drop stale links that point back into this repo
  find "$t" -maxdepth 1 -type l -lname "$ROOT/skills/*" ! -exec test -e {} \; -delete
  for s in "$ROOT"/skills/*/; do
    s=${s%/}; n=$(basename "$s")
    if [[ -e "$t/$n" && ! -L "$t/$n" ]]; then echo "skip $t/$n (exists, not a symlink)"; continue; fi
    ln -sfn "$s" "$t/$n"
  done
  echo "linked $(ls "$ROOT/skills" | wc -l | tr -d ' ') skills into $t"
done

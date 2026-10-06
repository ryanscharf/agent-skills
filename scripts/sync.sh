#!/usr/bin/env bash
# Pull every skill listed in sources.tsv into skills/<name>/ at its pinned commit.
#   ./scripts/sync.sh            sync at pinned refs
#   ./scripts/sync.sh --update   move every pin to the upstream default branch HEAD, then sync
# Skills written by you (no entry in sources.tsv) are never touched.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MANIFEST="$ROOT/sources.tsv"
CACHE="${SKILLS_CACHE:-$ROOT/.cache/upstream}"
UPDATE=0; [[ "${1:-}" == "--update" ]] && UPDATE=1
mkdir -p "$CACHE" "$ROOT/skills"

fetch() { # repo ref -> prints checkout dir
  local repo=$1 ref=$2 dir="$CACHE/${1//\//__}"
  if [[ ! -d "$dir/.git" ]]; then
    git clone -q --filter=blob:none "https://github.com/$repo.git" "$dir" >&2
  fi
  if (( UPDATE )); then
    git -C "$dir" fetch -q origin >&2
    git -C "$dir" checkout -q --detach "origin/HEAD" >&2
  else
    git -C "$dir" cat-file -e "$ref^{commit}" 2>/dev/null || git -C "$dir" fetch -q origin >&2
    git -C "$dir" checkout -q --detach "$ref" >&2
  fi
  echo "$dir"
}

set_name() { # rewrite the name: field inside the frontmatter only
  awk -v n="$2" 'NR==1&&/^---/{fm=1;print;next} fm&&/^---/{fm=0} fm&&/^name:/&&!done{print "name: " n;done=1;next} {print}' \
    "$1" > "$1.tmp" && mv "$1.tmp" "$1"
}

patch_review_r() { # bundle the agent + rules review-r expects from its home repo
  local src=$1 dest=$2
  mkdir -p "$dest/references"
  cp "$src/.claude/agents/r-reviewer.md"      "$dest/references/r-reviewer-protocol.md"
  cp "$src/.claude/rules/r-code-conventions.md" "$dest/references/r-code-conventions.md"
  for f in "$dest/SKILL.md" "$dest/references/r-reviewer-protocol.md"; do
    sed -i.bak \
      -e 's#\.claude/rules/r-code-conventions\.md#references/r-code-conventions.md#g' \
      -e 's#launch the `r-reviewer` agent#follow `references/r-reviewer-protocol.md` (run it as a subagent if your agent supports that, otherwise follow it directly)#' \
      "$f" && rm -f "$f.bak"
  done
}

declare -A HEADS=()
NEW_MANIFEST="$(mktemp)"
GITIGNORE_LOCAL=()
count=0

while IFS= read -r line || [[ -n "$line" ]]; do
  if [[ -z "$line" || "$line" == \#* ]]; then echo "$line" >> "$NEW_MANIFEST"; continue; fi
  IFS=$'\t' read -r repo ref path name flags <<< "$line"
  dir=$(fetch "$repo" "$ref")
  head=$(git -C "$dir" rev-parse HEAD)
  src="$dir/$path"; dest="$ROOT/skills/$name"

  rm -rf "$dest"; mkdir -p "$dest"
  # copy the skill folder, minus VCS/repo plumbing when the skill is a whole repo
  ( cd "$src" && tar --exclude=.git --exclude=.github --exclude=README.md --exclude=LICENSE* -cf - . ) | ( cd "$dest" && tar -xf - )

  [[ " $flags " == *" fix-skillmd "* && -f "$dest/skill.md" ]] && mv "$dest/skill.md" "$dest/SKILL.md"
  [[ " $flags " == *" patch-review-r "* ]] && patch_review_r "$dir" "$dest"
  [[ -f "$dest/SKILL.md" ]] || { echo "!! $repo/$path has no SKILL.md" >&2; exit 1; }
  sed -i.bak 's/\r$//' "$dest/SKILL.md" && rm -f "$dest/SKILL.md.bak"   # normalize CRLF
  set_name "$dest/SKILL.md" "$name"

  lic=$(ls "$dir" | grep -i -m1 -E '^licen[cs]e' || true)
  [[ -n "$lic" ]] && cp "$dir/$lic" "$dest/LICENSE.upstream"
  cat > "$dest/UPSTREAM.md" <<EOF
Source: https://github.com/$repo/tree/$head/$path
License: ${lic:-none found — kept local only, not redistributed}
Synced by scripts/sync.sh; local edits here are overwritten. Change sources.tsv instead.
EOF
  [[ " $flags " == *" local "* ]] && GITIGNORE_LOCAL+=("skills/$name/")
  printf '%s\t%s\t%s\t%s\t%s\n' "$repo" "$head" "$path" "$name" "$flags" >> "$NEW_MANIFEST"
  count=$((count+1)); echo "  ok  $name"
done < "$MANIFEST"

(( UPDATE )) && mv "$NEW_MANIFEST" "$MANIFEST" || rm -f "$NEW_MANIFEST"

# keep unlicensed upstream skills out of git
{
  echo "# managed by scripts/sync.sh"
  echo ".cache/"
  printf '%s\n' "${GITIGNORE_LOCAL[@]}"
} > "$ROOT/.gitignore"

"$ROOT/scripts/build-marketplace.sh"
"$ROOT/scripts/build-index.sh"
echo "Synced $count upstream skills."

#!/usr/bin/env bash
set -euo pipefail

# Installs the skills in this repo into the current working directory,
# adapted to the format expected by the chosen agent.
#
# Usage: install-to-agent.sh <agent>
#   agent: claude | cursor | codex | antigravity
#
# Run this from inside the target repo (the one that will *use* the skills).

AGENT="${1:-}"
SKILLS_REPO="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$(pwd)"

if [ -z "$AGENT" ]; then
  cat >&2 <<EOF
usage: install-to-agent.sh <agent>

agents:
  claude       symlink skills into .claude/skills/ (project) or ~/.claude/skills (user)
  cursor       generate .cursor/rules/<name>.mdc files from each SKILL.md
  codex        append a "## Skills" block to AGENTS.md with skill summaries
  antigravity  generate .antigravity/skills/<name>.md files

Run this from the target repo, not the skills repo.
EOF
  exit 1
fi

if [ "$TARGET" = "$SKILLS_REPO" ]; then
  echo "error: run this from the target repo, not the skills repo." >&2
  exit 1
fi

skill_dirs() {
  find "$SKILLS_REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |
    xargs -0 -n1 dirname
}

# Strip YAML frontmatter from a SKILL.md, returning the body.
skill_body() {
  awk 'BEGIN{f=0} /^---$/{f++; next} f>=2{print}' "$1"
}

# Read a frontmatter field. Usage: fm <file> <field>
fm() {
  awk -v key="$2" '
    BEGIN{f=0}
    /^---$/{f++; if(f==2)exit; next}
    f==1 {
      if (match($0, "^"key":[[:space:]]*")) {
        print substr($0, RSTART+RLENGTH)
        exit
      }
    }
  ' "$1"
}

case "$AGENT" in
  claude)
    DEST="$TARGET/.claude/skills"
    mkdir -p "$DEST"
    skill_dirs | while IFS= read -r src; do
      name="$(basename "$src")"
      target="$DEST/$name"
      [ -e "$target" ] && [ ! -L "$target" ] && rm -rf "$target"
      ln -sfn "$src" "$target"
      echo "linked $name -> $src"
    done
    ;;

  cursor)
    DEST="$TARGET/.cursor/rules"
    mkdir -p "$DEST"
    skill_dirs | while IFS= read -r src; do
      name="$(basename "$src")"
      desc="$(fm "$src/SKILL.md" description)"
      out="$DEST/${name}.mdc"
      {
        echo "---"
        echo "description: ${desc}"
        echo "alwaysApply: false"
        echo "---"
        echo
        skill_body "$src/SKILL.md"
      } > "$out"
      echo "wrote $out"
    done
    echo
    echo "Cursor rules written. They are 'manual' rules — invoke with @<skill-name>."
    ;;

  codex)
    OUT="$TARGET/AGENTS.md"
    BLOCK_START="<!-- fernando-skills:start -->"
    BLOCK_END="<!-- fernando-skills:end -->"

    tmp_block="$(mktemp)"
    {
      echo "$BLOCK_START"
      echo "## Skills (fernando-skills)"
      echo
      echo "Installed from https://github.com/Klerith/fernando-skills. Each entry is a workflow you can invoke by reading the linked file and following its steps."
      echo
      skill_dirs | while IFS= read -r src; do
        name="$(basename "$src")"
        desc="$(fm "$src/SKILL.md" description)"
        rel=".codex/skills/${name}/SKILL.md"
        echo "- **${name}** — ${desc}"
        echo "  - Workflow: \`${rel}\`"
      done
      echo
      echo "$BLOCK_END"
    } > "$tmp_block"

    # Mirror skill bodies under .codex/skills/ for Codex to read.
    mkdir -p "$TARGET/.codex/skills"
    skill_dirs | while IFS= read -r src; do
      name="$(basename "$src")"
      cp -R "$src/." "$TARGET/.codex/skills/$name/"
    done

    if [ -f "$OUT" ] && grep -q "$BLOCK_START" "$OUT"; then
      awk -v start="$BLOCK_START" -v end="$BLOCK_END" -v repl="$tmp_block" '
        BEGIN { while ((getline line < repl) > 0) buf = buf line "\n" }
        $0 ~ start { skip=1; printf "%s", buf; next }
        $0 ~ end { skip=0; next }
        !skip { print }
      ' "$OUT" > "$OUT.tmp" && mv "$OUT.tmp" "$OUT"
    else
      [ -f "$OUT" ] && echo >> "$OUT"
      cat "$tmp_block" >> "$OUT"
    fi
    rm "$tmp_block"
    echo "updated $OUT and copied skills into .codex/skills/"
    ;;

  antigravity)
    DEST="$TARGET/.antigravity/skills"
    mkdir -p "$DEST"
    skill_dirs | while IFS= read -r src; do
      name="$(basename "$src")"
      cp -R "$src/." "$DEST/$name/"
      echo "copied $name -> $DEST/$name"
    done
    ;;

  *)
    echo "unknown agent: $AGENT" >&2
    exit 1
    ;;
esac

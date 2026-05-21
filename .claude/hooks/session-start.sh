#!/bin/bash
# Install the ui-ux-pro-max skill into the session's user-level skills dir
# so Claude can discover it via the Skill tool. Runs only on Claude Code
# remote (web) sessions, where the container is ephemeral.

set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SKILLS_DIR="${HOME}/.claude/skills"
SKILL_DIR="${SKILLS_DIR}/ui-ux-pro-max"
REPO_URL="https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git"

mkdir -p "${SKILLS_DIR}"

if [ -f "${SKILL_DIR}/SKILL.md" ]; then
  exit 0
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

git clone --depth 1 --quiet "${REPO_URL}" "${TMP_DIR}/repo"

SRC="${TMP_DIR}/repo/.claude/skills/ui-ux-pro-max"
if [ ! -d "${SRC}" ]; then
  echo "ui-ux-pro-max: source path not found in cloned repo" >&2
  exit 1
fi

rm -rf "${SKILL_DIR}"
cp -rL "${SRC}" "${SKILL_DIR}"

if [ -d "${SKILL_DIR}/scripts" ]; then
  find "${SKILL_DIR}/scripts" -type f -name '*.sh' -exec chmod +x {} +
  find "${SKILL_DIR}/scripts" -type f -name '*.py' -exec chmod +x {} +
fi

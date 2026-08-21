#!/usr/bin/env bash
set -euo pipefail

WHAT_IF=0
UNINSTALL=0
for arg in "$@"; do
  case "$arg" in
    --what-if) WHAT_IF=1 ;;
    --uninstall) UNINSTALL=1 ;;
    *) echo "未知参数：$arg" >&2; exit 2 ;;
  esac
done

REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SOURCE_ROOT="$REPO_ROOT/skills"
CURSOR_ROOT="${HOME}/.cursor"
DEST_ROOT="$CURSOR_ROOT/skills"
RECORD_PATH="$CURSOR_ROOT/lx-cursor-workflow.manifest"
SKILLS=(lx-workflow lx-bugfix lx-grill lx-brainstorm lx-writing-plan lx-tdd lx-subagent karpathy-guidelines ponytail)

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | awk '{print $1}'; else shasum -a 256 "$1" | awk '{print $1}'; fi
}

tree_hash() {
  local root="$1"
  local rows
  rows="$(find "$root" -type f -print0 | while IFS= read -r -d '' file; do
    rel="${file#"$root"/}"
    printf '%s\t%s\n' "$rel" "$(hash_file "$file")"
  done | LC_ALL=C sort)"
  if command -v sha256sum >/dev/null 2>&1; then printf '%s' "$rows" | sha256sum | awk '{print $1}'; else printf '%s' "$rows" | shasum -a 256 | awk '{print $1}'; fi
}

if [[ "$UNINSTALL" -eq 1 ]]; then
  if [[ ! -f "$RECORD_PATH" ]]; then echo "没有找到本安装器的记录：$RECORD_PATH"; exit 0; fi
  blocked=()
  while IFS='|' read -r name expected_hash; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    target="$DEST_ROOT/$name"
    [[ ! -d "$target" ]] && continue
    if [[ "$(tree_hash "$target")" == "$expected_hash" ]]; then
      rm -rf -- "$target"
      echo "已卸载 $name"
    else
      blocked+=("$name")
      echo "保留 $name：安装后内容已被修改。" >&2
    fi
  done < "$RECORD_PATH"
  if [[ "${#blocked[@]}" -eq 0 ]]; then rm -f -- "$RECORD_PATH"; echo '已删除安装记录。'; else echo "以下目录未删除：${blocked[*]}" >&2; fi
  exit 0
fi

conflicts=()
for name in "${SKILLS[@]}"; do
  source="$SOURCE_ROOT/$name"
  target="$DEST_ROOT/$name"
  [[ -f "$source/SKILL.md" ]] || { echo "源 Skill 不完整：$name" >&2; exit 2; }
  if [[ -d "$target" ]]; then
    if [[ "$(tree_hash "$source")" == "$(tree_hash "$target")" ]]; then echo "跳过（内容相同）：$name"; else conflicts+=("$name"); fi
  else
    echo "安装：$name"
  fi
done

if [[ "${#conflicts[@]}" -gt 0 ]]; then
  echo "检测到冲突，未安装任何 Skill：${conflicts[*]}" >&2
  echo '请先人工处理冲突目录；安装器不会覆盖已有内容。' >&2
  exit 2
fi

if [[ "$WHAT_IF" -eq 1 ]]; then echo '预览结束，未写入文件。'; exit 0; fi

mkdir -p "$DEST_ROOT"
: > "$RECORD_PATH.tmp"
printf '# lx-cursor-workflow 0.1.0\n' >> "$RECORD_PATH.tmp"
for name in "${SKILLS[@]}"; do
  source="$SOURCE_ROOT/$name"
  target="$DEST_ROOT/$name"
  if [[ ! -d "$target" ]]; then cp -R -- "$source" "$target"; echo "已安装 $name"; else echo "已存在且一致，跳过 $name"; fi
  printf '%s|%s\n' "$name" "$(tree_hash "$target")" >> "$RECORD_PATH.tmp"
done
mv -- "$RECORD_PATH.tmp" "$RECORD_PATH"
echo "安装完成：$RECORD_PATH"


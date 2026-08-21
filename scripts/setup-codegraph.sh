#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${1:?用法：setup-codegraph.sh <项目目录>}"
if [[ -d "$PROJECT_PATH/.codegraph" ]]; then
  echo "[CodeGraph] 已检测到项目索引：$PROJECT_PATH/.codegraph"
  exit 0
fi

echo
echo "[CodeGraph] 项目未检测到 .codegraph：$PROJECT_PATH"
echo 'CodeGraph 可以在本地建立代码结构、调用关系和影响范围索引，帮助 AI：'
echo '  - 先定位真实入口和调用方，再做手术刀式修改'
echo '  - 复用已有公共组件、工具和依赖，减少重复造轮子'
echo '  - 修 Bug 前看到影响范围，降低漏改和误改风险'
echo '索引保存在项目本地，CodeGraph CLI 不会替代项目测试。'
read -r -p '是否安装最新 CodeGraph CLI 到个人全局，并为此项目建立索引？(Y/N) ' answer
if [[ ! "$answer" =~ ^([Yy]|[Yy][Ee][Ss])$ ]]; then
  echo '[CodeGraph] 用户选择跳过，工作流安装继续完成。'
  exit 0
fi

if command -v codegraph >/dev/null 2>&1; then
  current="$(codegraph --version 2>/dev/null || true)"
else
  current=''
fi

if command -v npm >/dev/null 2>&1; then
  latest="$(npm view @colbymchenry/codegraph version 2>/dev/null || true)"
  if [[ -z "$current" || ( -n "$latest" && "$current" != "$latest" ) ]]; then
    echo '[CodeGraph] 正在安装最新 CLI 到 npm 个人全局目录...'
    npm install --global @colbymchenry/codegraph@latest --no-fund --no-audit
    npm_prefix="$(npm prefix --global 2>/dev/null || true)"
    [[ -n "$npm_prefix" ]] && export PATH="$npm_prefix:$PATH"
  fi
else
  echo '[CodeGraph] 未找到 npm，改用官方安装器...'
  curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
fi

command -v codegraph >/dev/null 2>&1 || {
  echo 'CodeGraph CLI 安装后不可用，请重新打开终端后再执行 codegraph init。' >&2
  exit 1
}
echo "[CodeGraph] CLI 已就绪：$(codegraph --version)"
echo '[CodeGraph] 正在为项目建立本地索引...'
codegraph init "$PROJECT_PATH"
echo '[CodeGraph] 项目索引完成。'

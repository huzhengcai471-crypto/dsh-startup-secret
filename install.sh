#!/usr/bin/env bash
# dsh-startup-secret 安装脚本（macOS / Linux）
# 作用：pnpm add 安装插件后，把插件名写入 dsh.profile.bundles，
#       否则 DSH 不会加载它的 cordis.patch.yml，插件完全无效果。
set -euo pipefail

echo "============================================"
echo "  dsh-startup-secret 安装脚本"
echo "============================================"
echo

# 1. 定位本目录下的 tgz 包
TGZ="$(ls dsh-startup-secret-*.tgz 2>/dev/null | head -1 || true)"
if [ -z "$TGZ" ]; then
  echo "[错误] 当前目录没有找到 dsh-startup-secret-*.tgz 安装包。"
  echo "       请把 tgz 和本脚本放在同一目录后重试。"
  exit 1
fi
echo "找到安装包: $TGZ"
echo

# 2. 定位 dsh 命令
if ! command -v dsh >/dev/null 2>&1; then
echo "[错误] 找不到 dsh 命令。请先安装 DSH，或把 dsh 加入 PATH。"
  exit 1
fi
echo "使用 dsh: $(command -v dsh)"
echo

# 3. 目标 profile
PROFILE="${1:-web}"
echo "目标 profile: $PROFILE（可传参覆盖，如 ./install.sh desktop）"
echo

# 4. desktop 提示
if [ "$PROFILE" = "desktop" ]; then
echo "[提示] 安装到 desktop profile 前，请先完全退出 DSH 桌面端"
  echo "       （含系统托盘图标右键退出），否则写入会被覆盖。"
  echo
fi

# 5. 执行安装（pnpm add）
echo "正在安装到 $PROFILE profile ..."
dsh plugin --profile "$PROFILE" add "$TGZ"

# 6. 关键步骤：把插件加入 dsh.profile.bundles
PROFILE_PKG="$HOME/.dsh/profiles/$PROFILE/package.json"
if [ -z "${DSH_HOME:-}" ]; then
  : # 使用默认 ~/.dsh
else
  PROFILE_PKG="$DSH_HOME/profiles/$PROFILE/package.json"
fi

if [ ! -f "$PROFILE_PKG" ]; then
  echo
  echo "[警告] 未找到 $PROFILE_PKG，跳过「写入 dsh.profile.bundles」。"
  echo "       请手工在该文件 dsh.profile.bundles 数组里加入 \"dsh-startup-secret\" 后重启 DSH。"
  exit 0
fi

if command -v node >/dev/null 2>&1; then
  node -e "const fs=require('fs');const p=process.argv[1];const j=JSON.parse(fs.readFileSync(p,'utf8'));j.dsh=j.dsh||{};j.dsh.profile=j.dsh.profile||{};j.dsh.profile.bundles=j.dsh.profile.bundles||[];if(!j.dsh.profile.bundles.includes('dsh-startup-secret')){j.dsh.profile.bundles.push('dsh-startup-secret');fs.writeFileSync(p,JSON.stringify(j,null,2)+'\n','utf8');console.log('已把 dsh-startup-secret 加入 dsh.profile.bundles');}else{console.log('dsh-startup-secret 已在 dsh.profile.bundles 中');}" "$PROFILE_PKG"
else
  echo
  echo "[警告] 未找到 node，请手工在 $PROFILE_PKG 的 dsh.profile.bundles 里加入 \"dsh-startup-secret\"。"
  exit 0
fi

echo
echo "============================================"
echo "  安装成功！已写入 dsh.profile.bundles"
echo "  请重启 DSH（$PROFILE）后刷新页面查看启动动画。"
echo "============================================"
echo

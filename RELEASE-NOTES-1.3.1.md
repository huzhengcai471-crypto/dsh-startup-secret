## 本版更新

### 终幕「黑框」改为透明底 + 金字

启动动画最后一幕（WELCOME 画面）中间那行原本是**黑底白字方块**，现在：

- **底色去掉**（`transparent`），黑场里不再压出一块方片
- **字色改为金色 `#FFDE00`**，与插件中心徽章在用的 `#fdd000` 同色系
- 加一层 18px 暖金外发光，纯黑终幕下像一块发亮的铭牌
- 结尾色散副本由红/蓝改为**同一支金的两侧色散**（`#ffb400` 偏橙 /
  `#fff59a` 偏浅黄）——红蓝加色混合会把金字洗成脏白
- 光晕峰值时刻这一行**保持纯金**，只有上下两行转青，金字留作视觉锚点

### 三张人物立绘换新

长征（中山装）、长征（J装）、长征（最美好的主唱）三款立绘更新为
红黑霓虹线稿风格，与第一款长征（水手服）统一。

### 修复：Windows 安装脚本在别的机器上可能失效

`安装.cmd` / `打开预览.cmd` 原先存为 UTF-8，而简体中文 Windows 控制台默认
码页是 **GBK(936)**。`cmd.exe` 是按**字节数**定位下一行的，编码不匹配时会丢失
同步，表现为：

- `echo` 被吞掉，下一行被当成外部命令执行
- 变量被吃掉（例如 `%PROFILE%` 直接消失）
- 中文提示被截断成乱码

**现已改为 GBK + CRLF**。本机用真实 `cmd.exe` 实测三个分支
（找不到安装包 / 找不到 dsh / 找不到预览页），中文提示均完整、无串行。
仓库另加 `.gitattributes` 锁定该约定，避免文件往返一趟被规范化回去。

> 另外提示：不要给这类脚本加 `chcp 65001`——实测反而更容易触发上述问题。

---

## 跨设备验收

本次发布前做了完整的「另一台机器」验收（干净目录、不装任何 npm 依赖）：

| 项目 | 结果 |
| --- | --- |
| 包内清单（`files` 声明 13 项） | 全部存在 ✓ |
| 第三方运行时依赖 | 0 个（仅 `node:` 内置；`react` 由 DSH 宿主 ModuleLoader 注入）✓ |
| Host 半侧可加载 | 导出 `name` / `inject` / `apply` 契约 ✓ |
| 浏览器半侧可解析 | bundle id 正确、factory 可执行 ✓ |
| 运行时资产 | 32 个 mp3 全部非空，`asset-data.js` 内联 32 条 ✓ |
| 三处 JS 语法 | `node --check` 全过 ✓ |
| `.cmd` 编码 | GBK 可解码 + 全 CRLF + 无非注释 `chcp` ✓ |
| `.sh` 换行 | 纯 LF，shebang 未被 CR 污染 ✓ |
| 硬编码本机路径 | 运行时 JS 中 0 处 ✓ |
| 真实 `dsh plugin add` 安装 | 成功，已写入 `dsh.profile.bundles` ✓ |
| 无头浏览器真实渲染 | 终幕底色 `rgba(0,0,0,0)`、字色 `rgb(255,222,0)` ✓ |
| 测试套件 | **198 通过 / 0 失败** ✓ |

---

## 安装

### 方式一：用安装脚本（推荐）

把 `dsh-startup-secret-1.3.1.tgz` 和 `安装.cmd` 放在同一目录，双击 `安装.cmd`。

脚本会自动：

1. 定位同目录下的 tgz
2. 定位 `dsh` 命令（PATH 优先，其次 DSH 内置 CLI）
3. 询问装到哪个 profile（`web` / `desktop`，默认 `web`）
4. 执行 `dsh plugin add`
5. 把 `dsh-startup-secret` 写入 `dsh.profile.bundles`（**这步不能少**，
   否则插件不会被加载）

装完重启 DSH 并刷新页面。

### 方式二：手动两步（缺一不可）

```bash
# 1. 安装
dsh plugin --profile web add ./dsh-startup-secret-1.3.1.tgz

# 2. 把包名写进 dsh.profile.bundles
#    编辑 ~/.dsh/profiles/web/package.json，在 dsh.profile.bundles 数组里加上：
#      "dsh-startup-secret"
```

> `dsh plugin add` 只是 `pnpm add` 的转发，只写 `dependencies`。
> 而 DSH 只有把插件列进 `dsh.profile.bundles` 才会加载它的
> `cordis.patch.yml`——**漏了第 2 步插件完全没效果**。

### 环境要求

- Node.js ≥ 20
- DSH（web profile 或 desktop profile 均可）

---

## 卸载

```bash
dsh plugin --profile web remove dsh-startup-secret
```

再从 `dsh.profile.bundles` 里删掉 `"dsh-startup-secret"`。

---

## 附件

| 文件 | 说明 |
| --- | --- |
| `dsh-startup-secret-1.3.1.tgz` | 插件包（npm 格式，含全部音频与立绘素材） |
| `安装.cmd` | Windows 一键安装脚本 |
| `打开预览.cmd` | Windows 离线预览脚本 |
| `install.sh` | Linux / macOS 安装脚本 |

---

> 本作品为二次创作，仅用于学习交流，没有任何商业用途。如有侵权，请联系移除。

# 安装说明

## 一、从 GitHub 在线安装

无需下载或解压发布包，直接运行：

```bash
dsh plugin --profile web add github:huzhengcai471-crypto/dsh-startup-secret
```

当前 DSH 会在 `plugin add` 后自动登记 bundle；安装完成后重启 DSH 即可。桌面端请把
`web` 替换为 `desktop`。

## 二、用本地脚本安装

脚本会自动完成「安装依赖」+「写入 dsh.profile.bundles」两步。

- **Windows**：解压后双击 `安装.cmd`
- **macOS / Linux**：`./install.sh`（可加参数 `./install.sh desktop`）

装完 **重启 dsh web**（关掉启动器窗口再重新双击）。刷新页面就能看到启动动画。

## 三、旧版 DSH 手动排查

### 关键：为什么装完没效果

较旧的 DSH 版本可能只把包写进 `dependencies`，没有自动登记
**`dsh.profile.bundles`**。

只有包名出现在 `dsh.profile.bundles` 里时，插件的 `cordis.patch.yml`
（里面的 `insert`）才会作为一层被 compose，插件的 Host 半侧和浏览器半侧
才会真正被加载。

如果安装后没有启动动画或设置入口，再手工补写 bundle：

### 第 1 步：安装依赖

```bash
dsh plugin --profile web add github:huzhengcai471-crypto/dsh-startup-secret
```

### 第 2 步：写入 bundles（关键）

打开 `~/.dsh/profiles/web/package.json`，在 `dsh.profile.bundles` 数组里加入
`"dsh-startup-secret"`：

```json
"dsh": {
  "profile": {
    "bundles": [
      "@deepseek-ai/dsh-base",
      "@deepseek-ai/dsh-web-app",
      "dsh-startup-secret"
    ]
  }
}
```

（desktop profile 同理，文件在 `~/.dsh/profiles/desktop/package.json`。）

### 装完请检查一次

如果你之前是手工在 profile 的 `cordis.patch.yml` 里加了这类条目：

```yaml
- insert:
    - id: dsh-startup-secret
      name: dsh-startup-secret
```

**必须删掉。** 否则插件被注册两次，`apply` 跑两遍，
`ctx.webServer.register()` 对同一路径重复注册会报错。

`安装.cmd` 会自动检测并提示。

---

## 四、手工安装（不用 pnpm）

1. 把 `plugin/` 目录解压到任意位置
2. 让 profile 能解析到它 —— 在 `~/.dsh/profiles/web/node_modules/` 下建目录联接：

   ```cmd
   mklink /J "%USERPROFILE%\.dsh\profiles\web\node_modules\dsh-startup-secret" "解压路径\plugin"
   ```

3. 在 `~/.dsh/profiles/web/cordis.patch.yml` 末尾追加：

   ```yaml
   - insert:
       - id: dsh-startup-secret
         name: dsh-startup-secret
   ```

4. 重启 dsh web

---

## 五、验证装好了

重启后，**没带 token** 访问插件路由：

- `/dsh-startup/splash.js` 返回 **401** → 路由已注册（401 是插件自己的信任栅栏，正常）
- 返回 **404** → 没装成功，或没重启

打开页面后应该看到：黑幕 → 徽章标识 → 过曝洗白 → 暖白底板 →
五步授权序列 → 揭幕。

---

## 六、卸载

```bash
dsh plugin --profile web remove dsh-startup-secret
```

走「二、手工安装」的，删掉目录联接和那两行 patch 条目即可。

---

## 七、配置项

设置页 → **启动动画**（order 26）：

| 分组 | 可调 |
|---|---|
| 播放 | 显示模式（每次打开都播放 / 每天一次）、速度、是否可跳过 |
| 身份资料 | 身份名称（默认 `Chunhua`）、编号、权限等级、身份密码 |
| 交互 | **自动播放三档**（见下） |
| 语音与音效 | 语音开关、**语音来源（真声素材 / 系统 TTS）**、音色、语速、音调、音量、播报前提示音、开口前留白；界面音效开关与音量 |
| 视觉 | 主题、**人物立绘（含「空」= 不显示）**、**降世事件窗口** |
| 文案 | 中文主字 / 英文副标题 / 日志行 / 按钮文字 |

配置落盘在 `$DSH_HOME/dsh-startup.json`（默认 `~/.dsh/dsh-startup.json`）。

### 自动播放（v1.4.0 起，替代旧的「需要人工确认」开关）

| 取值 | 设置页名称 | 行为 |
|---|---|---|
| `full` | 完全自动播放 | 五步全程不停，不需要任何操作，播完直接进主界面（不显示确认按钮） |
| `once` | 仅需点击一次进入 | 第一步停一次，点按钮 / 按 Enter 之后全自动（该档要求身份密码为空；若设了密码，密码照常拦截） |
| `off` | 不自动播放 | 第 1、2 步都停下来等确认，相当于原来的「需要人工确认」 |

旧配置只有 `requireInteraction`：`true` → `off`，`false` → `full`，升级不会打乱原有习惯；
非法/未知取值一律落到 `off`（不会擅自变成全自动）。

### 降世事件窗口

默认**关闭**。安装后的**首次启动**会弹一次（用 `localStorage` 的
`dsh-startup-screen:event-seen` 记一次性标记），之后不再出现；
勾选「降世事件窗口 · 每次播放都弹出」后，每次动画结束都会弹，Enter / 点击进入主界面。

### 人物立绘「空」

人物立绘下拉最后一项是「空（不显示立绘）」，对应配置值 `mascot: -1`，
选中后右下角不渲染任何立绘。

---

## 八、环境要求

| 项 | 要求 |
|---|---|
| Node | **>= 20** |
| 平台 | DSH **web** profile（`dsh.client.platform = "web"`） |
| 运行时依赖 | **零**（`dependencies` / `peerDependencies` 都是空的） |
| 语音 | 浏览器 Web Speech API；Edge 里能挑到 `... Online (Natural)` 神经网络音色 |
| 真声素材 | 已内置 `lib/assets/`；**取不到会自动回落 TTS**，不影响启动 |

---

## 九、包内容

```
lib/index.js          Host 半：路由 + index.html 注入
lib/splash.js         启动动画运行时
lib/splash.css        全部样式
lib/client.js         设置面板（浏览器半）
lib/assets/           真声台词 x5 + 终幕欢迎语 + 界面音效 x2
cordis.patch.yml      bundle 层声明
preview/index.html    离线预览页
test/                 五套冒烟测试（242 项断言，含 v1.4.0 新选项）
README.md             完整文档
AUDIO-FIELDS.md       需要音频的字段清单
```

跑测试：`npm test`

# 第9章 从原型到发布

> 你做了一个游戏，自己玩了几遍觉得不错。但只有你一个人玩，有什么意思？让全世界的人都能玩到。

## 发布流程总览

```
你的游戏代码
    │
    ├── 打包 → .love 文件（LÖVE原生格式）
    │       │
    │       ├── 直接分发 .love 文件
    │       │   （用户需要安装 LÖVE 才能玩）
    │       │
    │       └── 打包成独立可执行文件
    │           （用户无需安装任何东西，双击就能玩）
    │               │
    │               ├── Windows → .exe
    │               ├── macOS → .app
    │               └── Linux → AppImage
    │
    ├── 打包成移动端应用（难度较高，可选）
    │       │
    │       ├── Android → .apk / .aab（使用 love-android）
    │       └── iOS → .ipa（需要 Mac + Xcode）
    │
    └── 上传到平台
        ├── itch.io（免费、简单、推荐）
        ├── GitHub Releases（免费、面向技术用户）
        └── Steam（付费、专业、门槛高）
```

---

## 第一步：准备工作

在打包之前，确认以下事项：

### 1. 添加 conf.lua

每个 LÖVE 游戏都应该有一个 `conf.lua` 配置文件：

```lua
function love.conf(t)
    t.window.title = "我的贪吃蛇"       -- 游戏标题
    t.window.width = 800                -- 窗口宽度
    t.window.height = 600               -- 窗口高度
    t.window.icon = "assets/icon.png"   -- 游戏图标（可选）
    t.window.resizable = false           -- 是否允许调整大小
    t.version = "11.5"                  -- 使用的 LÖVE 版本
    t.author = "你的名字"               -- 作者信息
    t.description = "一个经典的贪吃蛇游戏" -- 描述
end
```

### 2. 整理项目文件

确保所有文件路径正确。建议在发布前用一个干净的环境测试：

```
my_game/
├── main.lua          ← 必须有
├── conf.lua          ← 推荐有
└── assets/           ← 所有素材
```

### 3. 删除调试代码

搜索并移除：
- `print()` 调试输出（对性能有微小影响）
- 注释掉的大段代码
- 开发用的快捷键（比如穿墙、无敌等）

### 4. 测试、测试、测试

- 完整玩一遍游戏，确认没有死循环
- 试试各种边界情况
- 让朋友试玩（他们能找到你找不到的Bug）

---

## 第二步：打包成 .love 文件

`.love` 文件本质是一个 ZIP 压缩包，只是扩展名不同。

### 手动打包

1. 进入你的游戏文件夹（确保 `main.lua` 在根目录）
2. 将所有文件压缩成 ZIP
3. 把 `.zip` 改名为 `.love`

**Windows PowerShell**：
```powershell
Compress-Archive -Path * -DestinationPath my_game.zip
Rename-Item my_game.zip my_game.love
```

**Mac/Linux 终端**：
```bash
cd my_game
zip -r ../my_game.love .
```

> **重要**：ZIP 文件里，`main.lua` 必须在根目录，不能是 `my_game/main.lua`。否则 LÖVE 找不到入口文件。

### 测试 .love 文件

```bash
love my_game.love
```

如果正常运行，打包成功。

---

## 第三步：打包成独立可执行文件

用户不需要安装 LÖVE 就能玩你的游戏。

### Windows

将 `love.exe` 和你的 `.love` 文件合并：

```powershell
# 方法：把 love.exe 和你的 .love 合并成一个 .exe
copy /b love.exe+my_game.love my_game.exe
```

但这只会生成一个 `my_game.exe`，还需要附带 LÖVE 的 DLL 文件。完整的发布文件夹包含：

```
my_game_win/
├── my_game.exe          ← 合并后的可执行文件
├── love.dll             ← LÖVE 运行时
├── lua51.dll
├── mp3.dll
├── ogg.dll
├── OpenAL32.dll
└── ...
```

> **简化方法**：下载 LÖVE 的免安装版（zipped version），把你的 `.love` 合并到 `love.exe` 中，再把 `love.exe` 改名，然后把所有 DLL 一起打包。

### macOS

同样用 `cat` 命令合并：

```bash
cat /Applications/love.app/Contents/MacOS/love my_game.love > my_game
chmod +x my_game
```

然后修改 `.app` 包的 `Info.plist`。

### 用工具自动打包

推荐使用开源打包工具，避免手动操作的繁琐：

| 工具 | 平台 | 说明 |
|------|------|------|
| love-packager | 跨平台 | 命令行工具，一键打包 |
| love-deploy | 跨平台 | 支持自动打包多平台 |
| LÖVE Distribution Tool | Windows | 图形界面，简单易用 |

> 在 Cursor 中输入：帮我写一个 LÖVE2D 游戏的打包脚本，能把游戏打包成 Windows 可执行文件。

---

## 第四步：移动端发布（Android / iOS）

> **先说结论**：移动端发布比桌面端复杂得多。如果你是零基础新手，建议先把游戏在桌面端（Windows/Mac）完全做好、测试充分，再来考虑移动端。移动端发布需要额外的工具链、签名、证书等知识，对新手来说门槛很高。但如果你有决心，下面的内容会帮你理清思路。

### 移动端发布可能性

LÖVE2D 官方提供了 Android 端口（love-android），可以打包成 APK 安装到安卓手机上。iOS 方面，虽然 LÖVE2D 的源代码支持 iOS 编译，但没有像 Android 那样的官方"一键打包"方案，你需要自己用 Xcode 编译整个 LÖVE 引擎加你的游戏。

简单对比：

| 平台 | 难度 | 需要什么 | 能不能上商店 |
|------|------|---------|-------------|
| Android | 中等 | Android Studio 或命令行工具 | 可以上 Google Play |
| iOS | 高 | Mac 电脑 + Xcode + 苹果开发者账号（$99/年） | 可以上 App Store |

### Android：使用 love-android

[love-android](https://github.com/love2d/love-android) 是 LÖVE2D 的官方 Android 端口。它的核心思路是：把你的游戏文件嵌入到一个 Android 项目中，然后编译成 APK。

#### 方法一：简单体验（不用编译，直接运行 .love 文件）

LÖVE2D 官方提供了预编译的 Android APK，你可以从 [LÖVE2D 发布页](https://github.com/love2d/love/releases/latest) 下载安装到手机。安装后，将你的 `.love` 文件放到手机的以下目录：

```
/sdcard/lovegame/
```

然后打开 LÖVE App 就能运行你的游戏了。这个方法适合**测试和自娱自乐**，不适合分发给其他玩家（因为你无法要求每个用户都安装 LÖVE App）。

> **注意**：从 Android 7（Nougat）起，直接点击 .love 文件用 LÖVE 打开的功能不稳定，可能需要用文件管理器手动关联。

#### 方法二：打包成独立 APK（推荐用于正式发布）

这是把你的游戏"内嵌"到 APK 中的方法，用户安装后直接就能玩，不需要额外安装 LÖVE。

**前置条件**：
- 安装 [Android Studio](https://developer.android.com/studio)（包含 Android SDK 和 Gradle）
- 安装 [Git](https://git-scm.com/)
- 基本的命令行操作能力

**步骤**：

1. **下载 love-android 源码**

   ```bash
   git clone --recurse-submodules https://github.com/love2d/love-android.git
   cd love-android
   ```

   > `--recurse-submodules` 很重要！不加的话会缺少依赖文件，编译时会报错。

2. **放入你的游戏文件**

   把你的游戏文件（不是 .love 包，而是原始文件）放入 `app/src/embed/assets/` 目录：

   ```
   love-android/
   └── app/
       └── src/
           └── embed/
               └── assets/
                   ├── main.lua      ← 你的游戏入口
                   ├── conf.lua
                   └── ...其他文件
   ```

3. **修改应用信息**

   编辑 `gradle.properties`，把默认值改成你自己的：

   ```properties
   app.name=我的游戏名               # 显示在手机启动器上的名字
   app.application_id=com.yourname.mygame  # 应用ID，必须全局唯一
   app.version_code=1                # 版本号，每次更新+1
   app.version_name=1.0              # 显示给用户的版本名
   app.orientation=landscape         # 横屏 landscape 或竖屏 portrait
   ```

4. **替换图标**

   把以下目录中的 `love.png` 替换成你的游戏图标（保持同样尺寸）：

   | 目录 | 尺寸 |
   |------|------|
   | `drawable-mdpi/love.png` | 48×48 |
   | `drawable-hdpi/love.png` | 72×72 |
   | `drawable-xhdpi/love.png` | 96×96 |
   | `drawable-xxhdpi/love.png` | 144×144 |
   | `drawable-xxxhdpi/love.png` | 192×192 |

5. **编译 APK**

   如果你的游戏**不需要麦克风**（大多数游戏不需要）：

   ```bash
   # Windows
   gradlew assembleEmbedNoRecordRelease

   # Mac/Linux
   ./gradlew assembleEmbedNoRecordRelease
   ```

   编译完成后，APK 文件在：
   ```
   app/build/outputs/apk/embedNoRecordRelease/
   ```

6. **签名 APK**

   生成的 Release APK 是未签名的，必须签名才能安装或上架。签名过程需要创建密钥库（keystore），这一步有点复杂，建议参考 [Android 官方签名文档](https://developer.android.com/studio/publish/app-signing)。

   > 简单来说：你需要用 `jarsigner` 或 `apksigner` 给 APK 签名。如果你只是想自己测试，可以先编译 Debug 版本（把命令里的 `Release` 换成 `Debug`），Debug 版本自动用调试密钥签名。

7. **上架 Google Play（可选）**

   如果要上架 Google Play 商店：
   - 注册 [Google Play 开发者账号](https://play.google.com/console/)（一次性费用 $25）
   - 生成 AAB 格式（而不是 APK）：把编译命令改为 `gradlew bundleEmbedNoRecordRelease`
   - 在 Google Play Console 上传 AAB 文件

#### 移动端适配注意事项

桌面游戏直接搬到手机上可能有很多问题，需要注意：

- **输入方式**：手机没有键盘和鼠标，需要使用 `love.touch` 处理触摸输入
- **屏幕尺寸**：手机屏幕小且比例多样，需要做自适应布局
- **横竖屏**：在 `conf.lua` 中设置 `t.window.width` 和 `t.window.height` 来控制方向（宽 > 高 = 横屏）
- **性能**：手机性能不如电脑，注意控制粒子数量和画面复杂度
- **返回键**：Android 有返回键，可以用 `love.keypressed` 捕获 `"back"` 键

### iOS：Xcode 打包

iOS 发布比 Android 更复杂，主要障碍是：

1. **必须有 Mac 电脑**：iOS 应用只能在 macOS 上用 Xcode 编译
2. **必须有苹果开发者账号**：上架 App Store 需要 $99/年的开发者账号
3. **必须用 Xcode 编译整个 LÖVE 引擎**：没有现成的"嵌入游戏"快捷方案

**大致流程**（仅作了解，不建议零基础尝试）：

1. 从 [LÖVE2D GitHub](https://github.com/love2d/love) 下载源码
2. 下载 [Apple 平台依赖库](https://github.com/love2d/love-apple-dependencies)，放到 `/Library/Frameworks/`
3. 用 Xcode 打开 `platform/xcode/love.xcodeproj`
4. 将你的 .love 文件作为资源添加到项目中
5. 配置签名证书和 Provisioning Profile
6. 编译并部署到设备

> **实话说**：如果你之前没有 iOS 开发经验，这条路会非常艰难。光是配置证书和 Provisioning Profile 就够劝退很多人了。如果不是非上 App Store 不可，建议先专注桌面端和 Android。

### 用自动化工具简化流程

如果你不想手动操作以上步骤，有一些社区工具可以帮忙：

| 工具 | 说明 | 链接 |
|------|------|------|
| bootstrap-love2d-project | 项目模板，内置 GitHub Actions 自动编译 Android APK、iOS IPA、Windows exe 等 | [GitHub](https://github.com/Oval-Tutu/bootstrap-love2d-project) |
| love-android Wiki | 官方打包文档 | [Wiki](https://github.com/love2d/love-android/wiki/Game-Packaging) |
| LÖVE2D Game Distribution | 官方发布文档（含多个平台的说明） | [Wiki](https://love2d.org/wiki/Game_Distribution) |

### 移动端发布检查清单

- [ ] 游戏已适配触摸输入（使用 `love.touch` 代替键盘/鼠标）
- [ ] 屏幕布局在小屏幕上也能正常显示
- [ ] 横竖屏方向已正确设置
- [ ] 在真机上测试过（模拟器不能代替真机测试）
- [ ] APK 已签名（Release 版本）
- [ ] 图标已替换为你自己的游戏图标
- [ ] 应用名称和版本号已正确设置

---

## 第五步：上传到平台

### itch.io（最推荐，桌面端）

itch.io 是独立游戏开发者最常用的发布平台：

1. 注册 [itch.io](https://itch.io) 账号
2. 点击"Create new project"
3. 填写游戏信息：标题、描述、标签、截图
4. 上传你的打包文件（.zip 内含可执行文件）
5. 设置价格（可以设为 $0 免费，或"pay what you want"）
6. 发布

> **Pro Tip**：itch.io 有一个 Butler 命令行工具，可以自动上传和更新游戏。

### GitHub Releases

适合开源项目或技术向游戏。如果你用了 bootstrap-love2d-project 模板，GitHub Actions 会自动编译各平台版本，直接在 Releases 页面下载：

1. 创建 GitHub 仓库
2. 在 Releases 页面创建新发布
3. 上传各平台的打包文件
4. 附上更新说明

### Steam

如果你想上 Steam（最专业的平台）：

1. 注册 Steam 开发者账号（费用 $100）
2. 通过 Steam Direct 提交游戏
3. 设置商店页面
4. 上传构建文件

> **建议**：先在 itch.io 发布，收集反馈。等游戏足够成熟后再考虑上 Steam。

---

## 社区传播——让你的游戏被看见

### 一、为什么"做完了"不等于"有人玩"

社区经验：一个没有传播策略的游戏就像一间没有招牌的店。Reddit /r/aigamedev 上大量帖子证明，分享本身也是开发的一部分。

### 二、5步传播法

1. **录15秒GIF**：社区最有效的传播形式。展示最有趣的玩法片段，不需要精美，要动起来
   - 工具推荐：ScreenToGif (Windows)、GIPHY Capture (Mac)、LICEcap (跨平台)

2. **写Build Story**：一段话讲清楚"你是谁、做了什么、怎么做的"
   - 模板："我是[背景]，用了[工具]，花了[时间]，做了[游戏]。这是我学到的3件事：..."
   - 社区最爱看这种故事（r/aigamedev 高赞帖模式）

3. **选择发布渠道**：

   | 渠道 | 适合什么 | 注意事项 |
   |------|---------|----------|
   | r/aigamedev | AI辅助开发的游戏 | 一定要强调"AI做的"和你的学习过程 |
   | r/vibecoding | Vibe coding作品 | 分享你的流程和工具链 |
   | r/indiegaming | 独立游戏 | 不强调AI，强调创意 |
   | itch.io | 可玩的游戏 | 免费托管，内置社区 |
   | Discord社区 | 即时反馈 | 找同期开发者互相测试 |
   | X/Twitter | 展示GIF | 加 #gamedev #indiedev 标签 |

4. **开源你的代码**：
   - 在GitHub上开源，README写清楚怎么运行
   - 开源=免费流量+信誉+帮助下一个新手

5. **持续开发日志(Devlog)**：
   - 每周记录一次进展
   - itch.io 内置devlog功能
   - 记录"做了什么+踩了什么坑"，后来者会感谢你

### 三、发布检查清单

- [ ] 游戏有标题和封面图？
- [ ] 游戏说明里写了操作方法？
- [ ] 录了GIF或短视频？
- [ ] 写了Build Story？
- [ ] 至少在3个渠道分享？
- [ ] 代码开源了？
- [ ] 开了Devlog？

---

## 第六步：写一个好商店页面

商店页面就是你游戏的"门面"。好的商店页面和好的游戏一样重要。

### 必要元素

| 元素 | 说明 | 好的做法 |
|------|------|---------|
| 标题 | 游戏名字 | 短小好记，不要太通用 |
| 封面图 | 第一印象 | 鲜明的视觉风格 |
| 截图 | 展示游戏玩法 | 至少3张，展示不同场景 |
| 描述 | 告诉玩家这是什么游戏 | 说清楚玩法，别说"很好玩" |
| 标签 | 帮玩家找到你的游戏 | 选最准确的3~5个 |
| 系统配置 | 最低硬件要求 | LÖVE 游戏一般要求很低 |

### 让AI帮你写商店描述

> 请帮我为我的 LÖVE2D 贪吃蛇游戏写一个 itch.io 商店描述。游戏特色：经典玩法、8-bit风格视觉、3条生命、速度随分数递增。风格轻松有趣，200字以内。

---

## 发布检查清单

在点击"发布"之前，确认以下事项：

- [ ] 游戏能从开始玩到结束，没有死循环或崩溃
- [ ] `conf.lua` 填写了正确的标题和版本
- [ ] 移除了所有调试代码和开发者快捷键
- [ ] 打包后测试过 `.love` 文件能正常运行
- [ ] 打包成可执行文件后测试过
- [ ] 有至少1张游戏截图
- [ ] 商店描述写清楚了游戏玩法
- [ ] 标注了游戏的操作方式（键盘/鼠标/手柄）
- [ ] 如果用了外部素材，确认了许可证允许商用

---

## 发布顺序建议

如果你是一个刚完成第一个游戏的新手，推荐按以下顺序逐步推进：

```
1. 先在 Windows/Mac 上完成所有测试
        │
2. 打包成桌面端可执行文件，发布到 itch.io
        │
3. （可选）如果你想支持 Android，学习 love-android 打包
        │
4. （可选）如果你想上 Steam，等游戏成熟后再考虑
        │
5. （谨慎考虑）iOS 发布，除非你有明确的 App Store 需求
```

> 不要急着让游戏出现在所有平台上。一个平台上完美运行，比五个平台上都有 bug 好得多。

---

## 下一步

发布后你可能遇到各种问题。别怕，下一章我们来总结常见的坑和解决方案。

[第10章：避坑指南 →](10-pitfalls.md)
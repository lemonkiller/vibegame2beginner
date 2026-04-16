# 第1章 选你的武器

> 工欲善其事，必先利其器。但在2026年，"利其器"这件事本身也可以让AI帮你做。

## 你需要安装什么？

整个开发环境只需要三样东西：

| # | 工具 | 干什么用 | 费用 |
|---|------|---------|------|
| 1 | LÖVE2D | 运行你做的游戏 | 免费 |
| 2 | AI编程助手 | 帮你写代码 | 有免费选项 |
| 3 | 终端/命令行 | 运行游戏（可选，但推荐） | 免费，系统自带 |

就这么三样。没有"配置开发环境"的噩梦，没有十几步的安装教程。下面一步步教你装好。

---

## 第一步：安装 LÖVE2D

LÖVE2D 是我们用来做2D游戏的游戏框架。你可以把它理解为一个"游戏播放器"——它能把你写的游戏代码变成一个真正可以玩的游戏。

### Windows

1. 打开浏览器，访问 [https://love2d.org](https://love2d.org)
2. 点击下载页面，找到最新版本的 Windows 安装包（`.exe`文件）
3. 双击安装，一路"下一步"就行
4. 安装完成后，打开命令提示符（按 `Win+R`，输入 `cmd`，回车），输入：
   ```
   love --version
   ```
   如果显示版本号（比如 `LOVE 11.5`），说明安装成功

> **如果命令行找不到love**：你可能需要把 LÖVE 的安装目录加到系统的 PATH 环境变量里。或者，更简单的办法——直接把 `.love` 文件拖到 love.exe 上运行。

### macOS

1. 打开终端（按 `Cmd+空格`，输入"终端"）
2. 如果你装了 Homebrew（Mac的软件管家），直接运行：
   ```
   brew install --cask love
   ```
   如果没装 Homebrew，先去 [https://brew.sh](https://brew.sh) 按提示安装
3. 验证安装：在终端输入 `love --version`

### Linux

大多数发行版可以直接从包管理器安装：

```
# Ubuntu/Debian
sudo apt install love

# Arch
sudo pacman -S love

# Fedora
sudo dnf install love
```

### 另一种方式：免安装运行

如果你不想装软件，也可以下载"便携版"（zipped version），解压到哪里都能用。游戏做好后，把 `.love` 文件拖到 `love.exe`（Windows）或 `love`（Mac/Linux）上就能运行。

---

## 第二步：选择 AI 编程助手

这是最重要的选择。AI编程助手就是你的"编程搭档"——你告诉它你想要什么，它帮你写代码。

2026年的AI编程工具生态已经非常丰富，主要有三大类：终端AI助手、AI代码编辑器、网页版AI。下面逐一介绍。

### 方案A：终端AI编程助手（本手册新增推荐）

终端AI助手在命令行中运行，你打字描述需求，它直接帮你写代码、修改文件、运行命令。这类工具的最大优势是**零成本起步**——你可以用免费模型开始，不需要任何付费订阅。

#### Pi Coding Agent

**Pi** 是目前最活跃的开源终端AI编程工具，GitHub 35000+ 星，npm 周下载 200 万次。

| 特点 | 说明 |
|------|------|
| 费用 | 免费开源（MIT协议） |
| 安装 | `npm install -g @mariozechner/pi-coding-agent` |
| 模型支持 | Claude、GPT、Gemini、GLM、DeepSeek、Qwen、Ollama本地模型等几乎所有主流模型 |
| 核心理念 | 极简设计，只有4个内置工具（read/write/edit/bash），通过"技能"和"扩展"按需增强 |
| 独特功能 | 子智能体（多个AI协作）、LSP代码智能、MCP协议、技能市场 |
| 官网 | [pi.dev](https://pi.dev) |
| GitHub | [github.com/badlogic/pi-mono](https://github.com/badlogic/pi-mono) |

**为什么推荐Pi？**

1. **免费起步**：配合 Gemini 的免费 API 额度或 Ollama 本地模型，完全零成本
2. **灵活强大**：你可以用自然语言指挥它读文件、写代码、运行命令，像一个全功能的编程助手
3. **可扩展**：社区有大量共享的技能（skills），也可以自己写
4. **多模型切换**：根据任务需要随时切换模型，比如编码用Claude，中文用GLM

**安装Pi（5分钟）：**

```bash
# 1. 确保你安装了 Node.js（18以上版本）
node --version

# 2. 全局安装Pi
npm install -g @mariozechner/pi-coding-agent

# 3. 启动Pi
pi
```

首次启动会引导你配置AI模型。推荐新手先用 Gemini（有免费额度）或 Ollama（完全本地、无需联网）。

#### Crush（原 OpenCode）

**Crush** 由 Charm 团队开发，GitHub 22000+ 星。它的前身是 OpenCode，项目已正式更名为 Crush。

| 特点 | 说明 |
|------|------|
| 费用 | 免费开源 |
| 安装 | `curl -fsSL https://opencode.ai/install \| bash`（Mac/Linux）或从GitHub下载（Windows） |
| 模型支持 | 多模型支持（Claude、GPT、Gemini等） |
| 核心特点 | 终端原生界面（Charm风格TUI）、LSP集成、MCP服务器 |
| GitHub | [github.com/charmbracelet/crush](https://github.com/charmbracelet/crush) |

> **注意**：你可能会在网上看到 "OpenCode" 这个名字，但该GitHub仓库已于2025年9月归档，项目已改名为 Crush，由原作者和 Charm 团队继续开发。

### 方案B：AI代码编辑器

如果你更喜欢在图形界面的编辑器中工作，这类工具把AI对话集成到了代码编辑器里。

| 工具 | 适合谁 | 费用 | 说明 |
|------|--------|------|------|
| **Cursor** | 想要认真做游戏的人 | 免费/Pro $20/月 | 最强的AI代码编辑器，VS Code内核 |
| **Windsurf** | 想免费体验的人 | 免费/Pro $15/月 | Codeium出品，AI能力不错 |
| **VS Code + Copilot** | 已有VS Code的人 | 免费/Pro $10/月 | 传统方案，Copilot提供AI辅助 |

### 方案C：网页版AI

最简单的方案：打开浏览器就能用。缺点是你需要手动复制代码到文件里。

| 工具 | 链接 | 说明 |
|------|------|------|
| **Claude** | [claude.ai](https://claude.ai) | 对Lua/LOVE支持最好，有免费额度 |
| **ChatGPT** | [chat.openai.com](https://chat.openai.com) | GPT系列，有免费额度 |
| **Gemini** | [gemini.google.com](https://gemini.google.com) | 上下文最长（1M），免费额度大 |

### 本手册推荐路线

根据你的情况选择：

**路线1：零成本起步（推荐新手先试这个）**

1. 安装 LÖVE2D
2. 安装 Pi Coding Agent：`npm install -g @mariozechner/pi-coding-agent`
3. 配置 Gemini 免费 API 或安装 Ollama 本地模型
4. 开始做游戏，全程零花费

**路线2：最强组合（适合决定长期做的）**

1. 安装 LÖVE2D
2. 安装 Cursor Pro（$20/月）或 Pi + Claude订阅
3. 享受最好的AI编程体验

**路线3：纯网页版（最简单但有局限）**

1. 安装 LÖVE2D
2. 用记事本写代码
3. 在 claude.ai 或 gemini.google.com 问AI要代码，手动复制过去

> 无论选择哪条路线，都能完成本手册的所有项目。区别在于效率：路线1最高效，路线3最慢但最简单。

### 安装 Pi Coding Agent（路线1详细步骤）

**前置条件**：安装 [Node.js](https://nodejs.org)（18以上版本），下载后双击安装即可。

```bash
# 安装Pi
npm install -g @mariozechner/pi-coding-agent

# 进入你的游戏项目目录
cd my_game

# 启动Pi
pi
```

首次启动会引导你选择AI模型。推荐配置：

- **免费方案**：选 Gemini，用 Gmail 账号即可获取免费 API Key
- **本地方案**：安装 [Ollama](https://ollama.ai)，下载 qwen2.5-coder 模型，完全离线运行
- **付费最强**：选 Claude，需要 Anthropic API Key

在Pi中，你可以直接用自然语言让它帮你写游戏代码：

```
你> 帮我创建一个贪吃蛇游戏，用LÖVE2D框架，用方向键控制

Pi会自动：
1. 创建 main.lua 和 conf.lua
2. 写入完整的游戏代码
3. 告诉你如何运行
```

### 安装 Cursor（路线2详细步骤）

1. 访问 [https://cursor.com](https://cursor.com)
2. 下载对应系统的安装包
3. 安装后打开，它会问你要不要从 VS Code 导入设置——如果你之前用过 VS Code 就导入，没有就跳过
4. 登录你的账号（可以用 Google 账号）
5. 安装完成后，打开 Cursor，按 `Ctrl+Shift+X`（Mac 是 `Cmd+Shift+X`）打开扩展面板
6. 搜索并安装 **Lua**（by sumneko）和 **Love2D Dev Tools**

### 安装 VS Code 替代方案

如果你不想用 Cursor，也可以用普通的 VS Code：

1. 下载 [VS Code](https://code.visualstudio.com)
2. 安装以下扩展：
   - **Lua**（by sumneko）：提供代码补全和错误提示
   - **Love2D Dev Tools**：专门为 LÖVE2D 开发设计，提供一键运行和调试

---

## 第三步：安装 Lua 语言支持（推荐但非必须）

这一步是为了让编辑器能"看懂"你的代码，给你更好的提示。

### 在 Cursor / VS Code 中

1. 按 `Ctrl+Shift+X`（Mac 是 `Cmd+Shift+X`）打开扩展面板
2. 搜索 `Lua`，安装由 `sumneko` 开发的那个（应该排第一个）
3. 搜索 `Love`，安装 `Love2D Dev Tools`

装完之后，编辑器就能自动补全 LÖVE 的函数名，帮你检查代码错误了。

> **如果提示不工作**：别慌。这些提示只是辅助，没有它们也能写代码。AI会帮你补全一切。

---

## 验证你的环境

创建一个测试文件夹，看看一切是否就绪：

### 手动创建项目

1. 在随便什么地方创建一个文件夹，比如 `my_test_game`
2. 在里面创建一个文件，名叫 `main.lua`
3. 写入以下内容（直接复制）：

```lua
-- 我的第一个LÖVE程序
function love.draw()
    love.graphics.print("Hello, 游戏世界!", 300, 300)
end
```

4. 在命令行中进入这个文件夹，运行：
   ```
   love .
   ```
5. 如果弹出一个窗口，上面写着"Hello, 游戏世界!"——恭喜你，环境配好了！

### 用AI创建项目

**用 Pi Coding Agent：**

1. 在终端中进入你的项目文件夹：`cd my_test_game`
2. 启动 Pi：`pi`
3. 输入：
   > 帮我创建一个最简单的 LÖVE2D 项目，在屏幕中央显示"Hello, 游戏世界！"
4. Pi 会自动创建 `main.lua` 文件和代码
5. 在终端中运行 `love .` 看效果

**用 Cursor：**

1. 按 `Ctrl+I`（Mac 是 `Cmd+I`）打开 AI 对话
2. 输入：
   > 帮我创建一个最简单的 LÖVE2D 项目，在屏幕中央显示"Hello, 游戏世界！"
3. AI 会帮你创建 `main.lua` 文件和代码
4. 在终端中运行 `love .` 看效果

---

## 常见问题

### Q: 我运行 `love .` 提示"command not found"

**Windows**：LÖVE 没加到 PATH。两种解决方式：
1. 找到你的 LÖVE 安装目录（通常是 `C:\Program Files\LOVE\`），把这个路径加到系统 PATH 中
2. 或者直接把你的游戏文件夹拖到 `love.exe` 上运行

**Mac**：如果你是手动下载的 `.app`，终端可能找不到。用 Homebrew 安装的没有这个问题。

**Linux**：确认你已经用包管理器安装了，或者 `love` 可执行文件在 PATH 中。

### Q: Pi 或 Cursor 的 AI 不回答我关于 LÖVE 的问题

**Pi**：确保你在项目文件夹中启动了 Pi（`cd my_game` 然后 `pi`），这样 Pi 才能看到你的项目结构。

**Cursor**：确保你在项目文件夹中打开了 Cursor（用 `File > Open Folder`），而不是单独打开一个文件。AI 需要知道你的项目结构才能给出好的回答。

### Q: 我只想试试，不想装这么多东西

最轻量方案有两种：

**纯网页方案（最简单）：**
1. 安装 LÖVE（必装）
2. 用电脑自带的文本编辑器（记事本也行）写 `main.lua`
3. 用命令行运行 `love .`
4. 在 [claude.ai](https://claude.ai) 或 [gemini.google.com](https://gemini.google.com) 问AI要代码，手动复制

**终端AI方案（推荐，也很简单）：**
1. 安装 LÖVE（必装）
2. 安装 Node.js（双击安装包就行）
3. 安装 Pi Coding Agent：`npm install -g @mariozechner/pi-coding-agent`
4. 启动Pi，选免费模型（Gemini 或 Ollama），开始做游戏

这两种方案都能完成本手册所有项目，区别是终端AI方案效率高很多。

### Q: 我该不该付费买AI助手？

先别急着花钱。2026年的免费方案已经非常强大：

1. **Pi + Gemini免费API**：Gemini 每天有免费额度，足够完成本手册所有项目
2. **Pi + Ollama**：完全免费，完全离线，模型质量也够用
3. **Claude/ChatGPT网页版免费额度**：每天可以问几十个问题

建议你：
1. 先用免费方案把前3章走完（贪吃蛇做完）
2. 确认自己真的想继续做游戏
3. 再考虑是否升级到付费方案（Cursor Pro 或 Claude Pro）

付费方案的额外价值主要是：更快的响应速度、更长的上下文、更强的模型。对于做小游戏来说，免费方案完全够用。

---

## 大模型怎么选？（2026年4月）

AI编程工具只是一个"壳"，真正写代码的是里面的大模型。选对模型，代码质量天差地别。以下是截止2026年4月的主要编程大模型排行：

| 模型 | 编程能力 | 特点 | 免费可用 |
|------|---------|------|----------|
| Claude Mythos Preview | 当前最强 | SWE-bench Pro 得分最高 | 否 |
| Claude Opus 4.5 | 极强 | SWE-bench Verified 首个破80% | 否 |
| GPT-5.4 | 极强 | BenchLM 编码综合88.3 | 否 |
| Gemini 3.1 Pro | 很强 | 1M上下文，性价比极高 | 是（免费API额度大） |
| GPT-5.3 Codex | 很强 | 开源编程之星 | 是（开源） |
| GLM-5.1 | 开源最强之一 | MoE 754B参数，编程+中文均优 | 是（开源） |
| DeepSeek V3.2 | 开源很强 | MoE架构，性价比之王 | 是（开源） |
| Qwen 3.5 Max | 开源很强 | 阿里出品，中文+代码兼优 | 是（开源） |

> 数据来源：BenchLM.ai 2026年4月快照。模型能力更新很快，实际体验以官方最新数据为准。

**新手推荐**：Gemini 3.1 Pro（免费额度大，上下文超长）或 GLM-5.1（中文理解最好，免费）。

**进阶推荐**：Claude（Lua/LOVE代码质量最高）。

**零成本方案**：Ollama + DeepSeek-Coder 或 Qwen2.5-Coder（完全本地运行，无需联网）。

---

## 文件夹结构约定

从现在起，你的每个游戏项目都应该有一个清晰的文件夹结构：

```
my_game/           <- 游戏根目录
|-- main.lua        <- 游戏入口（必须有）
|-- conf.lua        <- 游戏配置（可选，但推荐）
|-- assets/         <- 放图片、音频等素材
|   |-- images/
|   |-- sounds/
|   `-- fonts/
`-- src/            <- 游戏代码（项目大了才需要）
    |-- player.lua
    |-- enemy.lua
    `-- ...
```

对于小游戏（前三章的例子），你只需要 `main.lua` 就够了。别过度设计目录结构。

---

## 下一步

环境准备好了，但我们还需要学会和AI"说话"的技巧。

[第2章：学会和AI说话 ->](02-prompt-engineering.md)
# 附录A 术语对照表

> 遇到不懂的词，来这里查。

## 基础概念

| 中文 | 英文 | 简单解释 |
|------|------|---------|
| 游戏循环 | Game Loop | 游戏每帧重复执行"输入→更新→绘制"的过程 |
| 帧 | Frame | 游戏画面更新一次，通常60帧/秒 |
| 帧率 | FPS (Frames Per Second) | 每秒绘制多少帧画面，60FPS表示流畅 |
| Delta Time | dt | 上一帧到这一帧的时间间隔，用于保证不同帧率下游戏速度一致 |
| 渲染 | Render | 把游戏数据画到屏幕上的过程 |
| 碰撞检测 | Collision Detection | 判断两个物体是否接触/重叠 |
| 精灵 | Sprite | 2D游戏中可移动的图片对象 |
| 纹理 | Texture | 贴在3D模型或2D精灵上的图片 |
| 坐标系 | Coordinate System | 描述位置的数学系统，LÖVE中(0,0)在左上角 |
| 像素 | Pixel | 屏幕上最小的显示单位 |

## LÖVE2D 专有术语

| 中文 | 英文 | 简单解释 |
|------|------|---------|
| 回调函数 | Callback | LÖVE会在特定时刻自动调用的函数，如 `love.update`、`love.draw` |
| love.load | - | 游戏启动时调用一次，用于初始化 |
| love.update | - | 每帧调用，用于更新游戏逻辑 |
| love.draw | - | 每帧调用，用于绘制画面 |
| love.keypressed | - | 按键按下时调用 |
| Source | Sound Source | LÖVE中的音频对象 |
| SoundData | - | LÖVE中的原始音频数据 |
| .love文件 | Love File | LÖVE的游戏打包格式，本质是ZIP |
| conf.lua | Configuration File | LÖVE的游戏配置文件 |

## Lua 语言术语

| 中文 | 英文 | 简单解释 |
|------|------|---------|
| 表 | Table | Lua中唯一的数据结构，可以是数组、字典、对象，几乎一切数据都用表表示 |
| 元表 | Metatable | Lua的特殊表，可以改变另一个表的行为（比如让两个表相加时执行自定义操作），类似其他语言的运算符重载 |
| 协程 | Coroutine | Lua的轻量级线程，可以暂停和恢复执行，适合做动画序列、对话系统等需要"等一等再继续"的场景 |
| 闭包 | Closure | 一个函数加上它引用的外部变量，在LÖVE2D中常用于回调函数和状态保持 |
| local | - | Lua中声明局部变量的关键字，用local声明的变量作用域有限，比全局变量更快更安全 |
| require | - | Lua的模块加载函数，用来引入其他文件中的代码 |

## 编程通用术语

| 中文 | 英文 | 简单解释 |
|------|------|---------|
| 变量 | Variable | 存储数据的"容器"，有名字和值 |
| 函数 | Function | 一段可以重复使用的代码，有名字和参数 |
| 参数 | Parameter / Argument | 传给函数的输入值 |
| 返回值 | Return Value | 函数执行后给出的结果 |
| 条件判断 | If/Else | "如果...就...否则..."的逻辑分支 |
| 循环 | Loop | 重复执行一段代码，如 for/while |
| 数组/表 | Array / Table | Lua中存储多个值的容器，用 `{}` 定义 |
| 索引 | Index | 数组中元素的位置编号（Lua从1开始） |
| 全局变量 | Global Variable | 任何地方都能访问的变量 |
| 局部变量 | Local Variable | 只在当前作用域（函数/文件）内有效的变量 |
| 字符串 | String | 文本数据，用引号包围，如 `"hello"` |
| 布尔值 | Boolean | 只有 `true`（真）和 `false`（假）两个值 |
| Nil | Nil | Lua中表示"什么都没有"的特殊值 |
| 作用域 | Scope | 变量可以被访问的范围 |
| 模块 | Module | 一个独立的Lua文件，提供特定功能 |

## AI编程术语

| 中文 | 英文 | 简单解释 |
|------|------|---------|
| 提示词 | Prompt | 你给AI的指令/问题 |
| 上下文 | Context | AI能看到的背景信息（代码、对话历史等） |
| 上下文窗口 | Context Window | AI一次能处理的最大文本长度 |
| 幻觉 | Hallucination | AI编造不存在的函数、API或代码 |
| Token | Token | AI处理文本的最小单位（约0.75个英文单词） |
| Agent模式 | Agent Mode | AI自主执行多步操作的工作模式 |
| 补全 | Autocomplete | 编辑器中AI自动补全你正在写的代码 |
| 代码审查 | Code Review | AI帮你检查代码质量和潜在问题 |

## 游戏设计术语

| 中文 | 英文 | 简单解释 |
|------|------|---------|
| 游戏机制 | Game Mechanic | 游戏的核心规则和交互方式 |
| 核心循环 | Core Loop | 玩家在游戏中反复进行的核心行为 |
| MVP | Minimum Viable Product | 最小可行产品，只包含核心功能的最简版本 |
| 原型 | Prototype | 用来验证游戏想法的早期可玩版本 |
| 迭代 | Iteration | 反复改进的过程 |
| 平衡性 | Balance | 游戏各种数值之间的关系是否合理 |
| 难度曲线 | Difficulty Curve | 游戏难度随时间/关卡的变化趋势 |
| 反馈 | Feedback | 玩家操作后游戏给出的回应（视觉/听觉/触觉） |
| 状态机 | State Machine | 用"状态"和"转换"描述游戏的逻辑流程 |
| 对话树 | Dialogue Tree | 分支式的NPC对话结构 |

## 文件格式

| 扩展名 | 读法 | 用途 |
|--------|------|------|
| .lua | Lua脚本文件 | LÖVE游戏代码 |
| .love | Love文件 | LÖVE游戏打包格式 |
| .png | PNG图片 | 支持透明的图片格式 |
| .ogg | OGG音频 | 开源音频格式，适合背景音乐 |
| .wav | WAV音频 | 无损音频格式，适合音效 |
| .ttf | TrueType字体 | 可缩放字体文件 |

---

[返回目录](../README.md) | [推荐资源 →](appendix-b-resources.md)
# 第10章 让游戏变好听

> 一个游戏没有声音，就像电影没有配乐——能看，但总觉得少了什么。

## 声音在游戏中的三种角色

| 角色 | 例子 | 效果 |
|------|------|------|
| **反馈** | 点击按钮的"咔嗒"、攻击的"嘭" | 告诉玩家"你做了事" |
| **氛围** | 森林的鸟叫、洞穴的水滴 | 让玩家"身临其境" |
| **情绪** | Boss战的紧张音乐、胜利的凯旋曲 | 操控玩家的感情 |

---

## 第一种方式：用代码生成音效

LÖVE2D 可以不依赖外部音频文件，直接用代码生成音效。适合做简单的8-bit风格声音。

### 生成一个简单的"嘟"声

```lua
-- 生成一个440Hz的简单方块波音效，持续0.1秒
local sample_rate = 44100
local duration = 0.1
local samples = math.floor(sample_rate * duration)
local sound_data = love.sound.newSoundData(samples, sample_rate, 16, 1)

for i = 0, samples - 1 do
    local t = i / sample_rate
    -- 方波：频率440Hz
    local wave = math.sin(2 * math.pi * 440 * t) > 0 and 1 or -1
    -- 淡入淡出，避免"咔嗒"杂音
    local envelope = math.min(1, i / (sample_rate * 0.01)) *
                     math.min(1, (samples - i) / (sample_rate * 0.02))
    sound_data:setSample(i, wave * envelope * 0.3)
end

local beep = love.audio.newSource(sound_data)
beep:play()
```

这不完全是最简单的写法，但你可以把这个函数给AI，让它帮你实现各种音效。

### 常用音效模式

让AI帮你生成各种游戏音效：

> 请用 LÖVE2D 的 SoundData API 生成以下8-bit风格音效：
> 1. 吃食物：短促的上升音
> 2. 跳跃：弹性的"嘣"声
> 3. 受伤：低沉的"嗡"声
> 4. 游戏结束：下降的悲伤音
> 5. 按钮点击：轻巧的"咔"声

### 音效管理器

当你的游戏有多个音效时，建议用一个管理器统一管理：

```lua
-- 音效管理器
local sfx = {}

function sfx.init()
    -- 在游戏加载时生成所有音效
    sfx.eat = generate_sound("eat")
    sfx.hurt = generate_sound("hurt")
    sfx.jump = generate_sound("jump")
    sfx.click = generate_sound("click")
end

function sfx.play(name)
    if sfx[name] then
        -- 每次播放新建一个Source对象，因为同一个Source不能重叠播放
        local source = sfx[name]:clone()
        source:play()
    end
end
```

---

## 第二种方式：使用外部音频文件

当你的音效需求超过代码生成的范围时，就该用外部音频文件了。

### 支持的格式

| 格式 | 适合 | 说明 |
|------|------|------|
| WAV | 音效 | 无损、文件小（短音效） |
| OGG | 背景音乐 | 有损压缩、体积小 |
| MP3 | 背景音乐 | 兼容性好但有解码延迟 |

> **建议**：音效用 WAV，背景音乐用 OGG。

### 在 LÖVE2D 中播放音频

```lua
-- 加载
local bgm = love.audio.newSource("assets/sounds/bgm.ogg", "stream")  -- 背景音乐用stream
local sfx_jump = love.audio.newSource("assets/sounds/jump.wav", "static")  -- 音效用static

-- 播放音效（可以多个同时播放）
love.audio.play(sfx_jump)

-- 播放背景音乐（循环播放）
bgm:setLooping(true)
bgm:setVolume(0.5)  -- 0~1
bgm:play()
```

> **"stream" vs "static"**：音效短小，一次性加载到内存用"static"；背景音乐很长，边播边加载用"stream"。

---

## 第三种方式：用AI生成音频

### 音乐生成工具

| 工具 | 类型 | 费用 | 说明 |
|------|------|------|------|
| Suno | AI音乐生成 | 免费/订阅 | 输入文字描述就出歌 |
| Udio | AI音乐生成 | 免费/订阅 | 同上，质量接近 |
| AIVA | AI作曲 | 免费/订阅 | 更偏古典、影视配乐 |
| sfxr | 音效生成器 | 免费 | 经典的8-bit音效生成器 |
| jsfxr | 音效生成器（网页版） | 免费 | sfxr的网页版 |

### 生成背景音乐的提示词

> 生成一段30秒的循环背景音乐，风格是轻松的8-bit像素游戏风，节奏中等，旋律简单欢快，适合2D冒险游戏。

### 生成音效的提示词

> 生成以下游戏音效：
> 1. 金币拾取：清脆的两声"叮叮"
> 2. 跳跃：弹性的上升音
> 3. 爆炸：低频的"轰"声加高频碎片声

---

## 实战：给贪吃蛇加声音

让我们给第5章的贪吃蛇加上音效：

1. 吃食物 → 短促上升音
2. 转向 → 轻微的"嗒"声
3. 游戏结束 → 下降音

在 Cursor 中输入：

> 请为我的 LÖVE2D 贪吃蛇游戏添加音效，要求用代码生成（不使用外部文件）：
> 1. 蛇吃到食物时播放一个短促的上升音
> 2. 游戏结束时播放一个下降的"嘟"声
> 3. 开始游戏时播放一个轻快的"嘀嘟"声
> 4. 确保音效不会重叠导致爆音

---

## 音频常见问题

### Q: 音效播放有延迟

短音效用 `"static"` 模式加载，不要用 `"stream"`。`static` 是一次性加载到内存的，播放没有延迟。

### Q: 同一个音效不能重叠播放

一个 `Source` 对象同一时刻只能播放一次。要重叠播放，需要 `clone()`：

```lua
local clone = sound:clone()
clone:play()
```

### Q: 背景音乐和音效音量不平衡

分别设置音量：

```lua
bgm:setVolume(0.3)   -- 背景音乐小声点
sfx:setVolume(0.7)   -- 音效大声点
```

### Q: 想做音量设置选项

```lua
-- 全局音量
love.audio.setVolume(0.8)  -- 0~1

-- 分类音量：用全局变量控制
local MASTER_VOL = 1.0
local BGM_VOL = 0.5
local SFX_VOL = 0.8

bgm:setVolume(BGM_VOL * MASTER_VOL)
sfx_jump:setVolume(SFX_VOL * MASTER_VOL)
```

---

## 下一步

游戏能看、能听了。接下来最重要的一步：让别人也能玩到你的游戏。

[第11章：从原型到发布 →](11-publishing.md)
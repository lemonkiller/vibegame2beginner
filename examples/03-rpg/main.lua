-- RPG对话冒险 - LÖVE2D
-- 文字冒险RPG，包含房间探索、对话选择、回合制战斗

-- ========== 游戏配置 ==========
local WINDOW_W = 800
local WINDOW_H = 600
local SCENE_H = 420            -- 场景区域高度
local DIALOG_H = 180           -- 对话区域高度
local TYPE_SPEED = 40          -- 打字机效果：每秒显示字符数

-- UTF-8 支持
local utf8 = require("utf8")

-- 字体缓存（避免重复创建）
local fonts = {}
function load_fonts()
    fonts.large = love.graphics.newFont("font/zpix.ttf", 52)
    fonts.title = love.graphics.newFont("font/zpix.ttf", 32)
    fonts.dialogue = love.graphics.newFont("font/zpix.ttf", 17)
    fonts.choice = love.graphics.newFont("font/zpix.ttf", 16)
    fonts.medium = love.graphics.newFont("font/zpix.ttf", 20)
    fonts.small = love.graphics.newFont("font/zpix.ttf", 18)
    fonts.tiny = love.graphics.newFont("font/zpix.ttf", 14)
    fonts.stats = love.graphics.newFont("font/zpix.ttf", 15)
    fonts.combat = love.graphics.newFont("font/zpix.ttf", 24)
end

-- ========== 游戏状态 ==========
local state = "start"          -- "start" / "explore" / "dialogue" / "combat" / "gameover" / "win"
local current_room = nil
local player = {}
local current_npc = nil
local current_dialogue = nil
local dialogue_shown = ""      -- 当前已显示的文字
local dialogue_timer = 0
local dialogue_complete = false -- 文字是否全部显示完
local combat_state = {}
local show_help = false          -- 帮助面板显示状态

-- ========== 房间数据 ==========
local rooms = {
    village = {
        name = "宁静村庄",
        description = "一个小村庄坐落在大山脚下。村民们看起来忧心忡忡。",
        color = {0.4, 0.6, 0.3},
        npcs = {"elder", "herbalist"},
        exits = {north = "forest", east = "tower"}
    },
    forest = {
        name = "黑暗森林",
        description = "树木遮天蔽日，偶尔能听到远处的嚎叫。",
        color = {0.15, 0.3, 0.15},
        npcs = {"hunter"},
        exits = {south = "village", north = "cave"},
        enemy = "goblin"
    },
    cave = {
        name = "龙息洞穴",
        description = "洞穴入口冒着热气，能闻到硫磺味。深处传来沉重的呼吸声。",
        color = {0.25, 0.2, 0.2},
        exits = {south = "forest", north = "throne"},
        enemy = "skeleton"
    },
    tower = {
        name = "巫师之塔",
        description = "一座高耸的石塔，塔顶闪着奇异的光芒。",
        color = {0.2, 0.2, 0.4},
        npcs = {"wizard"},
        exits = {west = "village"}
    },
    throne = {
        name = "龙之王座",
        description = "巨龙的巢穴。金币堆成了山，但危险也潜伏其中。",
        color = {0.35, 0.15, 0.1},
        exits = {},  -- 没有出口，打败Boss才能胜利
        enemy = "dragon",
        boss = true
    },
}

-- ========== NPC数据 ==========
local npcs = {
    elder = {
        name = "村长",
        greeting = "年轻人，你终于来了。我等你好久了。",
        dialogues = {
            [1] = {
                text = "北方的巨龙苏醒了，我们的村庄随时可能被摧毁。你能帮助我们吗？",
                choices = {
                    {text = "我来帮忙！告诉我该怎么打倒它。", next = 2, flag = "quest_accept"},
                    {text = "我为什么要帮你？", next = 3},
                }
            },
            [2] = {
                text = "好！先去森林里找到猎人，他知道巨龙的弱点。然后去巫师之塔，巫师也许能给你魔法武器。",
                choices = {
                    {text = "我这就出发。", next = -1},  -- -1 表示对话结束
                }
            },
            [3] = {
                text = "......如果你改变主意，我随时在这里。但时间不多了。",
                choices = {
                    {text = "好吧，我答应你。", next = 2, flag = "quest_accept"},
                    {text = "告辞。", next = -1},
                }
            },
        }
    },
    herbalist = {
        name = "草药师",
        greeting = "哦，又来一个冒险者。让我看看你的伤......",
        dialogues = {
            [1] = {
                text = "带上这些草药吧，关键时刻能救命。给你3瓶回复药水。",
                choices = {
                    {text = "谢谢！多谢你的好意。", next = -1, action = "give_potions"},
                    {text = "不必了，我不需要。", next = 2},
                }
            },
            [2] = {
                text = "随你吧。不过我要提醒你，巨龙的火焰可不是闹着玩的。",
                choices = {
                    {text = "好吧，我收下。", next = -1, action = "give_potions"},
                    {text = "我会小心的。", next = -1},
                }
            },
        }
    },
    hunter = {
        name = "猎人",
        greeting = "嘘！小声点。这片林子里到处都是哥布林。",
        dialogues = {
            [1] = {
                text = "你是来找巨龙的？我知道它的弱点——胸口的鳞片有一道裂缝，那是它的命门。但你要先通过这条洞穴才能到它那边。",
                choices = {
                    {text = "裂缝？有多大？", next = 2, flag = "know_weakness"},
                    {text = "多谢，我记住了。", next = -1, flag = "know_weakness"},
                }
            },
            [2] = {
                text = "大概一个拳头那么宽。你击中那里，它就完了。问题是，怎么接近它......",
                choices = {
                    {text = "这就是我该操心的事了。", next = -1},
                }
            },
        }
    },
    wizard = {
        name = "巫师",
        greeting = "嚯嚯嚯！一个勇敢的冒险者！我已经很久没见过活人了。",
        dialogues = {
            [1] = {
                text = "我知道你为何而来。这把附魔匕首能帮助你刺穿巨龙的鳞甲。",
                choices = {
                    {text = "太好了！我正需要它。", next = 2, action = "give_dagger"},
                    {text = "有什么代价？", next = 3},
                }
            },
            [2] = {
                text = "拿去吧。记住，只有击中弱点才有用。祝你好运，冒险者。",
                choices = {
                    {text = "我不会让你失望的。", next = -1},
                }
            },
            [3] = {
                text = "代价？嚯嚯......你帮我做一件事：击败巨龙就够了。它太吵了，害我睡不好觉。",
                choices = {
                    {text = "成交！", next = 2, action = "give_dagger"},
                }
            },
        }
    },
}

-- ========== 敌人数据 ==========
local enemies = {
    goblin = {
        name = "哥布林",
        hp = 30, max_hp = 30,
        attack = 8,
        description = "一个矮小但凶狠的绿皮怪物",
        color = {0.4, 0.7, 0.3},
        reward_text = "你打败了哥布林，继续前进吧。"
    },
    skeleton = {
        name = "骷髅战士",
        hp = 50, max_hp = 50,
        attack = 12,
        description = "一具骷髅持着生锈的剑挡住了去路",
        color = {0.8, 0.8, 0.7},
        reward_text = "骷髅化为碎片散落在地。前方的洞穴深处就是巨龙的巢穴。"
    },
    dragon = {
        name = "远古巨龙",
        hp = 100, max_hp = 100,
        attack = 20,
        description = "巨龙张开翅膀，烈焰从它口中喷出！",
        color = {0.8, 0.2, 0.1},
        reward_text = "",
        boss = true
    },
}

-- ========== 初始化 ==========
function love.load()
    love.window.setTitle("RPG对话冒险")
    load_fonts()
    init_game()
end

function init_game()
    player = {
        hp = 80,
        max_hp = 80,
        attack = 15,
        potions = 0,
        has_dagger = false,
        know_weakness = false,
        quest_accept = false,
        defending = false,
    }
    current_room = "village"
    state = "start"
    current_npc = nil
    current_dialogue = nil
    combat_state = {}
end

-- ========== 输入处理 ==========
function love.keypressed(key)
    -- H键切换帮助面板（所有状态下都可切换）
    if key == "h" then show_help = not show_help end

    if state == "start" then
        if key == "space" then
            state = "explore"
        end
    elseif state == "explore" then
        handle_explore_input(key)
    elseif state == "dialogue" then
        handle_dialogue_input(key)
    elseif state == "combat" then
        handle_combat_input(key)
    elseif state == "gameover" or state == "win" then
        if key == "r" then
            init_game()
            state = "explore"
        end
    end
end

-- ========== 探索输入 ==========
function handle_explore_input(key)
    local room = rooms[current_room]

    if key == "e" and room.npcs then
        -- 和NPC对话（选择第一个NPC）
        start_dialogue(room.npcs[1])
    elseif key == "n" and room.exits.north then
        move_to_room(room.exits.north)
    elseif key == "s" and room.exits.south then
        move_to_room(room.exits.south)
    elseif key == "d" and room.exits.east then
        move_to_room(room.exits.east)
    elseif key == "w" and room.exits.west then
        move_to_room(room.exits.west)
    elseif key == "f" and room.enemy then
        -- 进入战斗（或者进入boss房间）
        if room.boss and not player.quest_accept then
            return  -- 还没接任务不能打Boss
        end
        start_combat(room.enemy)
    elseif key == "p" and player.potions > 0 then
        -- 使用药水
        player.hp = math.min(player.max_hp, player.hp + 30)
        player.potions = player.potions - 1
    end
end

function move_to_room(room_id)
    current_room = room_id
    -- 进入有敌人的房间时自动遇敌（森林和洞穴）
    local room = rooms[current_room]
    if room.enemy and not room.boss and love.math.random() < 0.5 then
        start_combat(room.enemy)
    end
end

-- ========== 对话系统 ==========
function start_dialogue(npc_id)
    local npc = npcs[npc_id]
    if not npc then return end

    current_npc = npc_id
    -- 找到起始对话（第一个选项）
    current_dialogue = npc.dialogues[1]
    dialogue_shown = ""
    dialogue_timer = 0
    dialogue_complete = false
    state = "dialogue"
end

function handle_dialogue_input(key)
    if not dialogue_complete then
        -- 跳过打字机效果，直接显示全部文字
        if key == "space" then
            dialogue_shown = current_dialogue.text
            dialogue_complete = true
        end
        return
    end

    -- 选择选项
    local choice_num = tonumber(key)
    if choice_num and current_dialogue.choices and choice_num <= #current_dialogue.choices then
        local choice = current_dialogue.choices[choice_num]

        -- 执行flag
        if choice.flag then
            if choice.flag == "quest_accept" then player.quest_accept = true end
            if choice.flag == "know_weakness" then player.know_weakness = true end
        end

        -- 执行action
        if choice.action == "give_potions" then
            player.potions = player.potions + 3
        elseif choice.action == "give_dagger" then
            player.has_dagger = true
            player.attack = player.attack + 10
        end

        -- 对话结束
        if choice.next == -1 then
            state = "explore"
            current_dialogue = nil
        else
            -- 跳到下一轮对话
            current_dialogue = npcs[current_npc].dialogues[choice.next]
            dialogue_shown = ""
            dialogue_timer = 0
            dialogue_complete = false
        end
    end
end

-- ========== 战斗系统 ==========
function start_combat(enemy_id)
    local template = enemies[enemy_id]
    combat_state = {
        enemy = {
            id = enemy_id,
            name = template.name,
            hp = template.hp,
            max_hp = template.max_hp,
            attack = template.attack,
            description = template.description,
            color = template.color,
            reward_text = template.reward_text,
            boss = template.boss,
        },
        message = template.description,
        player_turn = true,
        anim_timer = 0,
        reward_shown = false,
    }
    player.defending = false
    state = "combat"
end

function handle_combat_input(key)
    if not combat_state.player_turn then return end
    if combat_state.reward_shown then
        -- 战斗结束，按任意键继续
        if key then
            local room = rooms[current_room]
            if combat_state.enemy.boss then
                state = "win"
            else
                state = "explore"
            end
        end
        return
    end

    if key == "1" then
        -- 攻击
        player.defending = false
        local dmg = player.attack
        -- 弱点加成
        if combat_state.enemy.boss and player.know_weakness and player.has_dagger then
            dmg = dmg * 3  -- 知道弱点+有匕首 = 暴击
            combat_state.message = "你瞄准了巨龙胸口的裂缝，给了致命一击！造成 " .. dmg .. " 点伤害！"
        else
            combat_state.message = "你发起攻击，造成 " .. dmg .. " 点伤害。"
        end
        combat_state.enemy.hp = math.max(0, combat_state.enemy.hp - dmg)
        end_player_turn()
    elseif key == "2" then
        -- 防御
        player.defending = true
        combat_state.message = "你举起防御姿态，下次受到的伤害将减半。"
        end_player_turn()
    elseif key == "3" and player.potions > 0 then
        -- 使用药水
        player.defending = false
        local heal = 30
        player.hp = math.min(player.max_hp, player.hp + heal)
        player.potions = player.potions - 1
        combat_state.message = "你喝下药水，恢复了 " .. heal .. " 点生命值。"
        end_player_turn()
    end
end

function end_player_turn()
    combat_state.player_turn = false
    combat_state.anim_timer = 0.5  -- 0.5秒后敌人行动
end

function enemy_turn()
    if combat_state.enemy.hp <= 0 then
        -- 敌人已死
        combat_state.reward_shown = true
        if combat_state.enemy.reward_text ~= "" then
            combat_state.message = combat_state.enemy.reward_text
        else
            combat_state.message = "你赢了！"
        end
        return
    end

    local dmg = combat_state.enemy.attack
    if player.defending then
        dmg = math.floor(dmg / 2)
        combat_state.message = combat_state.enemy.name .. "发起了攻击！你防御了部分伤害，受到 " .. dmg .. " 点伤害。"
    else
        combat_state.message = combat_state.enemy.name .. "发起了攻击！你受到 " .. dmg .. " 点伤害！"
    end
    player.hp = math.max(0, player.hp - dmg)

    if player.hp <= 0 then
        state = "gameover"
        return
    end

    player.defending = false
    combat_state.player_turn = true
end

-- ========== 游戏更新 ==========
function love.update(dt)
    if state == "dialogue" and not dialogue_complete then
        dialogue_timer = dialogue_timer + dt * TYPE_SPEED
        local chars = math.floor(dialogue_timer)
        local text_len = utf8.len(current_dialogue.text)
        if chars >= text_len then
            dialogue_shown = current_dialogue.text
            dialogue_complete = true
        else
            -- 安全截断 UTF-8 字符串
            local byte_pos = utf8.offset(current_dialogue.text, chars + 1) - 1
            dialogue_shown = current_dialogue.text:sub(1, byte_pos)
        end
    end

    if state == "combat" and not combat_state.player_turn and not combat_state.reward_shown then
        combat_state.anim_timer = combat_state.anim_timer - dt
        if combat_state.anim_timer <= 0 then
            enemy_turn()
        end
    end
end

-- ========== 绘制画面 ==========
function love.draw()
    if state == "start" then
        draw_start_screen()
    elseif state == "explore" then
        draw_explore()
    elseif state == "dialogue" then
        draw_explore()
        draw_dialogue()
    elseif state == "combat" then
        draw_combat()
    elseif state == "gameover" then
        draw_end_screen("游戏结束", {1, 0.3, 0.3}, "你的冒险在此画上了句号......")
    elseif state == "win" then
        draw_end_screen("胜利！", {1, 0.84, 0}, "你击败了巨龙，拯救了世界！你成为了传说中的英雄！")
    end

    draw_help_overlay()
end

-- 开始界面
function draw_start_screen()
    love.graphics.setColor(0.08, 0.06, 0.12)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    love.graphics.setColor(0.9, 0.7, 0.3)
    love.graphics.setFont(fonts.large)
    local title = "RPG对话冒险"
    local tw = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (WINDOW_W - tw) / 2, 120)

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.setFont(fonts.small)
    local story = "巨龙苏醒，村庄危在旦夕。"
    local story2 = "你是唯一的希望。"
    love.graphics.print(story, (WINDOW_W - love.graphics.getFont():getWidth(story)) / 2, 220)
    love.graphics.print(story2, (WINDOW_W - love.graphics.getFont():getWidth(story2)) / 2, 248)

    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.setFont(fonts.medium)
        local hint = "按 空格键 开始冒险"
        love.graphics.print(hint, (WINDOW_W - love.graphics.getFont():getWidth(hint)) / 2, 350)
    end

    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.setFont(fonts.tiny)
    local ctrl = "数字键选择选项 | E 交谈 | N/S/D/W 移动 | F 战斗 | P 使用药水"
    love.graphics.print(ctrl, (WINDOW_W - love.graphics.getFont():getWidth(ctrl)) / 2, 450)

    -- 帮助提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(fonts.tiny)
    local help_hint = "按 H 查看帮助"
    love.graphics.print(help_hint, (WINDOW_W - love.graphics.getFont():getWidth(help_hint)) / 2, 480)
end

-- 探索画面
function draw_explore()
    local room = rooms[current_room]

    -- 场景区域背景色
    local c = room.color
    love.graphics.setColor(c[1] * 0.3, c[2] * 0.3, c[3] * 0.3)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, SCENE_H)

    -- 场景装饰：简单的几何图形
    draw_room_visual(current_room)

    -- 房间名称
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    love.graphics.print(room.name, 30, 20)

    -- 房间描述
    love.graphics.setColor(0.85, 0.85, 0.85)
    love.graphics.setFont(fonts.small)
    love.graphics.printf(room.description, 30, 65, WINDOW_W - 60)

    -- 玩家状态
    draw_player_status()

    -- 可用操作提示
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.setFont(fonts.stats)
    local y = SCENE_H - 80

    -- NPC提示
    if room.npcs and #room.npcs > 0 then
        local npc_names = {}
        for _, nid in ipairs(room.npcs) do
            table.insert(npc_names, npcs[nid].name)
        end
        love.graphics.setColor(0.5, 0.8, 1)
        love.graphics.print("[E] 交谈: " .. table.concat(npc_names, ", "), 30, y)
        y = y + 22
    end

    -- 出口提示
    love.graphics.setColor(0.5, 1, 0.5)
    local exit_dirs = {}
    for dir, room_id in pairs(room.exits) do
        local dir_name = {north="北[N]", south="南[S]", east="东[D]", west="西[W]"}
        table.insert(exit_dirs, dir_name[dir] .. "→" .. rooms[room_id].name)
    end
    if #exit_dirs > 0 then
        love.graphics.print("出口: " .. table.concat(exit_dirs, "  "), 30, y)
        y = y + 22
    end

    -- 敌人提示
    if room.enemy then
        love.graphics.setColor(1, 0.5, 0.3)
        if room.boss then
            love.graphics.print("[F] 挑战: " .. enemies[room.enemy].name .. " (Boss!)", 30, y)
        else
            love.graphics.print("[F] 前进 (可能遇到敌人)", 30, y)
        end
    end

    -- 药水提示
    if player.potions > 0 then
        love.graphics.setColor(0.3, 1, 0.5)
        love.graphics.print("[P] 使用药水 (" .. player.potions .. "瓶)", 30, y)
    end

    -- 对话区域底板
    love.graphics.setColor(0.1, 0.1, 0.14)
    love.graphics.rectangle("fill", 0, SCENE_H, WINDOW_W, DIALOG_H)
    love.graphics.setColor(0.3, 0.3, 0.4)
    love.graphics.line(0, SCENE_H, WINDOW_W, SCENE_H)
end

-- 房间视觉装饰
function draw_room_visual(room_id)
    local t = love.timer.getTime()
    if room_id == "village" then
        -- 小房子
        for i = 0, 3 do
            local hx = 100 + i * 160
            love.graphics.setColor(0.5, 0.35, 0.25)
            love.graphics.rectangle("fill", hx, 220, 80, 60)
            love.graphics.setColor(0.7, 0.3, 0.2)
            love.graphics.polygon("fill", hx - 10, 220, hx + 40, 180, hx + 90, 220)
        end
    elseif room_id == "forest" then
        -- 树
        for i = 0, 6 do
            local tx = 50 + i * 110
            love.graphics.setColor(0.3, 0.2, 0.15)
            love.graphics.rectangle("fill", tx + 15, 240, 20, 60)
            love.graphics.setColor(0.15, 0.35 + math.sin(t + i) * 0.05, 0.15)
            love.graphics.circle("fill", tx + 25, 220, 40)
        end
    elseif room_id == "cave" then
        -- 石笋
        for i = 0, 5 do
            love.graphics.setColor(0.4, 0.35, 0.3)
            local sx = 80 + i * 130
            love.graphics.polygon("fill", sx, 300, sx + 20, 300, sx + 10, 200 + love.math.random(30))
        end
        -- 火光
        love.graphics.setColor(0.8, 0.4, 0.1, 0.2 + math.sin(t * 3) * 0.1)
        love.graphics.circle("fill", 400, 300, 30)
    elseif room_id == "tower" then
        -- 塔
        love.graphics.setColor(0.35, 0.35, 0.4)
        love.graphics.rectangle("fill", 350, 130, 100, 200)
        love.graphics.setColor(0.4, 0.4, 0.45)
        love.graphics.polygon("fill", 340, 130, 400, 80, 460, 130)
        -- 发光
        love.graphics.setColor(0.5, 0.3, 1, 0.3 + math.sin(t * 2) * 0.15)
        love.graphics.circle("fill", 400, 110, 15)
    elseif room_id == "throne" then
        -- 金币堆
        love.graphics.setColor(0.8, 0.65, 0.2)
        for i = 1, 20 do
            -- 用确定性哈希替代 setSeed，避免破坏全局随机状态
            local gx = 50 + ((i * 259) % 700)    -- 与700不互质但前20个值分布良好
            local gy = 250 + ((i * 137) % 100)   -- 与100互质，全周期均匀分布
            local gr = 5 + ((i * 187) % 10)     -- 与10互质，全周期
            love.graphics.circle("fill", gx, gy, gr)
        end
    end
end

-- 玩家状态栏
function draw_player_status()
    local sx = WINDOW_W - 220
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", sx - 5, 15, 215, 80, 5)

    love.graphics.setFont(fonts.stats)
    -- HP
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.print("HP: " .. player.hp .. "/" .. player.max_hp, sx, 20)
    -- HP条
    local hp_ratio = player.hp / player.max_hp
    love.graphics.setColor(0.3, 0.1, 0.1)
    love.graphics.rectangle("fill", sx, 40, 200, 10, 3)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill", sx, 40, 200 * hp_ratio, 10, 3)

    -- 攻击力
    love.graphics.setColor(0.9, 0.8, 0.3)
    love.graphics.print("攻击: " .. player.attack, sx, 55)

    -- 药水
    love.graphics.setColor(0.3, 1, 0.5)
    love.graphics.print("药水: " .. player.potions, sx + 100, 55)

    -- 特殊物品
    love.graphics.setColor(0.7, 0.5, 1)
    local items = {}
    if player.has_dagger then table.insert(items, "附魔匕首") end
    if player.know_weakness then table.insert(items, "龙之弱点") end
    if #items > 0 then
        love.graphics.print("装备: " .. table.concat(items, ", "), sx, 75)
    end
end

-- 对话界面
function draw_dialogue()
    -- 对话区域
    love.graphics.setColor(0.1, 0.1, 0.14)
    love.graphics.rectangle("fill", 0, SCENE_H, WINDOW_W, DIALOG_H)

    -- NPC名称
    local npc = npcs[current_npc]
    love.graphics.setColor(0.9, 0.8, 0.4)
    love.graphics.setFont(fonts.medium)
    love.graphics.print(npc.name, 30, SCENE_H + 10)

    -- 对话内容（打字机效果）
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(fonts.dialogue)
    love.graphics.printf(dialogue_shown, 30, SCENE_H + 40, WINDOW_W - 60)

    -- 选项
    if dialogue_complete and current_dialogue.choices then
        for i, choice in ipairs(current_dialogue.choices) do
            love.graphics.setColor(0.6, 0.8, 1)
            love.graphics.setFont(fonts.choice)
            love.graphics.print(i .. ". " .. choice.text, 30, SCENE_H + 90 + (i - 1) * 25)
        end
    end

    -- 未完成时的提示
    if not dialogue_complete then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.setFont(fonts.tiny)
        love.graphics.print("按 空格键 跳过", WINDOW_W - 150, SCENE_H + DIALOG_H - 25)
    end
end

-- 战斗界面
function draw_combat()
    local enemy = combat_state.enemy
    local c = enemy.color

    -- 背景
    love.graphics.setColor(0.1, 0.05, 0.08)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    -- 敌人
    love.graphics.setColor(c[1], c[2], c[3])
    -- 简单的敌人图形
    if enemy.boss then
        -- 龙形
        love.graphics.polygon("fill", 350, 100, 300, 200, 350, 180, 400, 200, 450, 180, 500, 200)
        love.graphics.circle("fill", 400, 80, 40)
        -- 翅膀
        love.graphics.polygon("fill", 300, 150, 200, 100, 250, 180)
        love.graphics.polygon("fill", 500, 150, 600, 100, 550, 180)
        -- 眼睛
        love.graphics.setColor(1, 0.8, 0)
        love.graphics.circle("fill", 388, 70, 6)
        love.graphics.circle("fill", 412, 70, 6)
    else
        -- 普通敌人：一个大方块
        love.graphics.rectangle("fill", 340, 120, 120, 120, 10)
        love.graphics.setColor(1, 0.3, 0.3)
        -- 眼睛
        love.graphics.circle("fill", 370, 165, 8)
        love.graphics.circle("fill", 430, 165, 8)
    end

    -- 敌人信息
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.combat)
    love.graphics.print(enemy.name, 300, 240)

    -- 敌人HP条
    local ehp_ratio = enemy.hp / enemy.max_hp
    love.graphics.setColor(0.3, 0.1, 0.1)
    love.graphics.rectangle("fill", 250, 275, 300, 15, 3)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.rectangle("fill", 250, 275, 300 * ehp_ratio, 15, 3)
    love.graphics.setFont(fonts.tiny)
    love.graphics.print(enemy.hp .. "/" .. enemy.max_hp, 570, 275)

    -- 玩家HP条
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setFont(fonts.small)
    love.graphics.print("冒险者", 50, 400)
    local php_ratio = player.hp / player.max_hp
    love.graphics.setColor(0.1, 0.1, 0.3)
    love.graphics.rectangle("fill", 50, 430, 200, 12, 3)
    love.graphics.setColor(0.3, 0.7, 1)
    love.graphics.rectangle("fill", 50, 430, 200 * php_ratio, 12, 3)
    love.graphics.setFont(fonts.tiny)
    love.graphics.print(player.hp .. "/" .. player.max_hp, 260, 428)

    -- 战斗信息
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.setFont(fonts.small)
    love.graphics.printf(combat_state.message, 50, 460, WINDOW_W - 100, "center")

    -- 操作选项
    if combat_state.player_turn and not combat_state.reward_shown then
        love.graphics.setColor(0.6, 0.8, 1)
        love.graphics.setFont(fonts.dialogue)
        love.graphics.print("[1] 攻击", 50, 510)
        love.graphics.print("[2] 防御", 200, 510)
        love.graphics.print("[3] 药水(" .. player.potions .. ")", 350, 510)
    elseif combat_state.reward_shown then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.setFont(fonts.choice)
        love.graphics.print("按任意键继续", 340, 510)
    else
        love.graphics.setColor(1, 0.5, 0.3)
        love.graphics.setFont(fonts.dialogue)
        love.graphics.print(enemy.name .. " 正在行动...", 50, 510)
    end

    -- 弱点提示
    if enemy.boss and player.know_weakness and player.has_dagger then
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.setFont(fonts.stats)
        love.graphics.print("你感知到了巨龙的弱点！攻击将造成暴击伤害！", 180, 550)
    end
end

-- 帮助面板叠加层
function draw_help_overlay()
    if not show_help then return end

    -- 半透明黑色遮罩
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    -- 帮助面板边框和背景
    local panel_w = 400
    local panel_h = 400
    local panel_x = (WINDOW_W - panel_w) / 2
    local panel_y = (WINDOW_H - panel_h) / 2
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8)
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 8)

    -- 标题
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.setFont(fonts.title)
    local title = "操作帮助"
    local title_w = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (WINDOW_W - title_w) / 2, panel_y + 15)

    -- 分割线
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.line(panel_x + 20, panel_y + 55, panel_x + panel_w - 20, panel_y + 55)

    -- 操作按键列表
    local items = {
        {"空格键", "开始冒险/跳过打字机效果"},
        {"N/S/D/W", "向北/南/东/西移动"},
        {"E", "与NPC交谈"},
        {"F", "战斗/前进"},
        {"P", "使用药水"},
        {"1/2/3", "选择对话选项或战斗行动"},
        {"R", "重新开始"},
    }
    local y = panel_y + 68
    for _, item in ipairs(items) do
        love.graphics.setColor(0.6, 0.8, 1)
        love.graphics.setFont(fonts.small)
        love.graphics.print(item[1], panel_x + 30, y)
        love.graphics.setColor(0.85, 0.85, 0.85)
        love.graphics.setFont(fonts.small)
        love.graphics.print(item[2], panel_x + 140, y)
        y = y + 35
    end

    -- 底部关闭提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(fonts.tiny)
    local close_hint = "按 H 关闭帮助"
    local ch_w = love.graphics.getFont():getWidth(close_hint)
    love.graphics.print(close_hint, (WINDOW_W - ch_w) / 2, panel_y + panel_h - 28)
end

-- 结束画面
function draw_end_screen(title, color, desc)
    love.graphics.setColor(0.05, 0.05, 0.08)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.setFont(fonts.large)
    local tw = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (WINDOW_W - tw) / 2, 150)

    love.graphics.setColor(0.85, 0.85, 0.85)
    love.graphics.setFont(fonts.medium)
    local dw = love.graphics.getFont():getWidth(desc)
    love.graphics.printf(desc, 50, 240, WINDOW_W - 100, "center")

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.setFont(fonts.small)
    local hint = "按 R 重新开始"
    love.graphics.print(hint, (WINDOW_W - love.graphics.getFont():getWidth(hint)) / 2, 350)
end
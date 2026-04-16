-- 贪吃蛇游戏 - LÖVE2D
-- 用方向键控制蛇的移动，吃食物变长，撞墙或自己则游戏结束

-- ========== 游戏配置 ==========
local GRID_SIZE = 20          -- 每个格子的像素大小
local GRID_W = 40             -- 水平格子数（800/20）
local GRID_H = 30             -- 垂直格子数（600/20）
local INITIAL_SPEED = 8       -- 初始速度（每秒移动几格）
local SPEED_INCREMENT = 0.5   -- 每吃一个食物加速多少

-- ========== 游戏状态 ==========
local state = "start"         -- "start" / "playing" / "gameover"
local snake = {}              -- 蛇的身体坐标列表
local direction = {}          -- 当前移动方向
local next_direction = {}     -- 下一帧的移动方向（防止180度转弯）
local food = {}               -- 食物位置
local score = 0               -- 当前分数
local high_score = 0          -- 最高分
local move_timer = 0          -- 移动计时器
local current_speed = INITIAL_SPEED
local show_help = false          -- 帮助面板显示状态

-- 字体缓存（避免每帧重复创建）
local fonts = {}

-- ========== 初始化 ==========
function love.load()
    -- 设置窗口
    love.window.setTitle("贪吃蛇")

    -- 预创建所有字体对象
    fonts.title = love.graphics.newFont("font/zpix.ttf", 48)
    fonts.score_big = love.graphics.newFont("font/zpix.ttf", 28)
    fonts.help_title = love.graphics.newFont("font/zpix.ttf", 24)
    fonts.record = love.graphics.newFont("font/zpix.ttf", 22)
    fonts.medium = love.graphics.newFont("font/zpix.ttf", 20)
    fonts.normal = love.graphics.newFont("font/zpix.ttf", 18)
    fonts.small = love.graphics.newFont("font/zpix.ttf", 16)
    fonts.tiny = love.graphics.newFont("font/zpix.ttf", 14)

    reset_game()
end

-- 重置游戏状态
function reset_game()
    -- 蛇初始位置在屏幕中央，长度3格
    local start_x = math.floor(GRID_W / 2)
    local start_y = math.floor(GRID_H / 2)
    snake = {
        {x = start_x, y = start_y},
        {x = start_x - 1, y = start_y},
        {x = start_x - 2, y = start_y},
    }
    direction = {x = 1, y = 0}       -- 初始向右
    next_direction = {x = 1, y = 0}
    score = 0
    current_speed = INITIAL_SPEED
    move_timer = 0
    spawn_food()
end

-- 在随机位置生成食物（不能和蛇重叠）
function spawn_food()
    local valid = false
    while not valid do
        food = {
            x = love.math.random(1, GRID_W),
            y = love.math.random(1, GRID_H),
        }
        valid = true
        -- 检查食物是否在蛇身上
        for _, segment in ipairs(snake) do
            if segment.x == food.x and segment.y == food.y then
                valid = false
                break
            end
        end
    end
end

-- ========== 输入处理 ==========
function love.keypressed(key)
    -- H键切换帮助面板（所有状态下都可切换）
    if key == "h" then show_help = not show_help end

    if state == "start" then
        if key == "space" then
            state = "playing"
        end
    elseif state == "playing" then
        -- 方向键控制，不能180度转弯
        if key == "up" and direction.y ~= 1 then
            next_direction = {x = 0, y = -1}
        elseif key == "down" and direction.y ~= -1 then
            next_direction = {x = 0, y = 1}
        elseif key == "left" and direction.x ~= 1 then
            next_direction = {x = -1, y = 0}
        elseif key == "right" and direction.x ~= -1 then
            next_direction = {x = 1, y = 0}
        end
    elseif state == "gameover" then
        if key == "r" then
            reset_game()
            state = "playing"
        elseif key == "space" then
            reset_game()
            state = "start"
        end
    end
end

-- ========== 游戏更新 ==========
function love.update(dt)
    if state ~= "playing" then return end

    -- 按速度计时，到了就移动一格
    move_timer = move_timer + dt
    local move_interval = 1 / current_speed

    if move_timer >= move_interval then
        move_timer = move_timer - move_interval
        direction = next_direction
        move_snake()
    end
end

-- 移动蛇
function move_snake()
    -- 计算蛇头新位置
    local head = snake[1]
    local new_head = {
        x = head.x + direction.x,
        y = head.y + direction.y,
    }

    -- 碰撞检测：撞墙
    if new_head.x < 1 or new_head.x > GRID_W or
       new_head.y < 1 or new_head.y > GRID_H then
        game_over()
        return
    end

    -- 碰撞检测：撞自己（从2开始，避免检测到自己）
    for i = 2, #snake do
        if snake[i].x == new_head.x and snake[i].y == new_head.y then
            game_over()
            return
        end
    end

    -- 在蛇头前面插入新位置
    table.insert(snake, 1, new_head)

    -- 检查是否吃到食物
    if new_head.x == food.x and new_head.y == food.y then
        score = score + 1
        current_speed = INITIAL_SPEED + score * SPEED_INCREMENT
        spawn_food()
        -- 吃到食物，尾巴不去掉，蛇就变长了
    else
        -- 没吃到食物，去掉尾巴
        table.remove(snake)
    end
end

-- 游戏结束
function game_over()
    state = "gameover"
    if score > high_score then
        high_score = score
    end
end

-- ========== 绘制画面 ==========
function love.draw()
    if state == "start" then
        draw_start_screen()
    elseif state == "playing" then
        draw_game()
    elseif state == "gameover" then
        draw_game()
        draw_gameover_overlay()
    end

    draw_help_overlay()
end

-- 开始界面
function draw_start_screen()
    -- 背景渐变效果
    for i = 0, GRID_H do
        local t = i / GRID_H
        local r = math.floor(20 + t * 10)
        local g = math.floor(60 + t * 30)
        local b = math.floor(30 + t * 10)
        love.graphics.setColor(r/255, g/255, b/255)
        love.graphics.rectangle("fill", 0, i * GRID_SIZE, 800, GRID_SIZE)
    end

    -- 标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    local title = "贪吃蛇"
    local title_w = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (800 - title_w) / 2, 180)

    -- 提示文字
    love.graphics.setFont(fonts.medium)
    local hint = "按 空格键 开始游戏"
    local hint_w = love.graphics.getFont():getWidth(hint)
    -- 闪烁效果
    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        love.graphics.print(hint, (800 - hint_w) / 2, 280)
    end

    -- 操作说明
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(fonts.small)
    local controls = "方向键控制移动 | 吃食物变长 | 撞墙或自己则结束"
    local controls_w = love.graphics.getFont():getWidth(controls)
    love.graphics.print(controls, (800 - controls_w) / 2, 380)

    -- 最高分
    if high_score > 0 then
        love.graphics.setColor(1, 0.84, 0)
        local hs_text = "最高分: " .. high_score
        local hs_w = love.graphics.getFont():getWidth(hs_text)
        love.graphics.print(hs_text, (800 - hs_w) / 2, 420)
    end

    -- 帮助提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(fonts.tiny)
    local help_hint = "按 H 查看帮助"
    local hh_w = love.graphics.getFont():getWidth(help_hint)
    love.graphics.print(help_hint, (800 - hh_w) / 2, 460)
end

-- 游戏画面
function draw_game()
    -- 清空背景
    love.graphics.setColor(0.1, 0.1, 0.12)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- 画网格线（淡灰色）
    love.graphics.setColor(0.15, 0.15, 0.17)
    for x = 0, GRID_W do
        love.graphics.line(x * GRID_SIZE, 0, x * GRID_SIZE, 600)
    end
    for y = 0, GRID_H do
        love.graphics.line(0, y * GRID_SIZE, 800, y * GRID_SIZE)
    end

    -- 画食物（红色圆形）
    love.graphics.setColor(1, 0.3, 0.3)
    local food_cx = (food.x - 0.5) * GRID_SIZE
    local food_cy = (food.y - 0.5) * GRID_SIZE
    love.graphics.circle("fill", food_cx, food_cy, GRID_SIZE * 0.4)

    -- 画蛇（渐变绿色）
    for i, segment in ipairs(snake) do
        local t = 1 - (i - 1) / #snake  -- 从头到尾渐变
        local green = 0.4 + 0.6 * t
        love.graphics.setColor(0.1, green, 0.2)

        local sx = (segment.x - 1) * GRID_SIZE
        local sy = (segment.y - 1) * GRID_SIZE
        -- 方块比格子稍小，留一点间距
        local pad = 1
        love.graphics.rectangle("fill",
            sx + pad, sy + pad,
            GRID_SIZE - pad * 2, GRID_SIZE - pad * 2,
            3  -- 圆角
        )
    end

    -- 蛇头画眼睛
    if #snake > 0 then
        local head = snake[1]
        local hx = (head.x - 1) * GRID_SIZE
        local hy = (head.y - 1) * GRID_SIZE
        love.graphics.setColor(1, 1, 1)
        -- 根据方向画眼睛
        local eye_offset = GRID_SIZE * 0.25
        if direction.x == 1 then      -- 向右
            love.graphics.circle("fill", hx + GRID_SIZE * 0.65, hy + eye_offset, 2)
            love.graphics.circle("fill", hx + GRID_SIZE * 0.65, hy + GRID_SIZE - eye_offset, 2)
        elseif direction.x == -1 then  -- 向左
            love.graphics.circle("fill", hx + GRID_SIZE * 0.35, hy + eye_offset, 2)
            love.graphics.circle("fill", hx + GRID_SIZE * 0.35, hy + GRID_SIZE - eye_offset, 2)
        elseif direction.y == -1 then  -- 向上
            love.graphics.circle("fill", hx + eye_offset, hy + GRID_SIZE * 0.35, 2)
            love.graphics.circle("fill", hx + GRID_SIZE - eye_offset, hy + GRID_SIZE * 0.35, 2)
        else                           -- 向下
            love.graphics.circle("fill", hx + eye_offset, hy + GRID_SIZE * 0.65, 2)
            love.graphics.circle("fill", hx + GRID_SIZE - eye_offset, hy + GRID_SIZE * 0.65, 2)
        end
    end

    -- 画分数
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.medium)
    love.graphics.print("分数: " .. score, 10, 10)
end

-- 帮助面板叠加层
function draw_help_overlay()
    if not show_help then return end

    -- 半透明黑色遮罩
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- 帮助面板边框和背景
    local panel_w = 360
    local panel_h = 300
    local panel_x = (800 - panel_w) / 2
    local panel_y = (600 - panel_h) / 2
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.rectangle("fill", panel_x, panel_y, panel_w, panel_h, 8)
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panel_x, panel_y, panel_w, panel_h, 8)

    -- 标题
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.setFont(fonts.help_title)
    local title = "操作帮助"
    local title_w = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (800 - title_w) / 2, panel_y + 20)

    -- 分割线
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.line(panel_x + 20, panel_y + 55, panel_x + panel_w - 20, panel_y + 55)

    -- 操作按键列表
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(fonts.normal)
    local items = {
        {"空格键", "开始游戏"},
        {"方向键", "控制蛇的移动方向"},
        {"R键", "重新开始"},
        {"空格键", "游戏结束后回到标题"},
    }
    local y = panel_y + 70
    for _, item in ipairs(items) do
        love.graphics.setColor(0.6, 0.8, 1)
        love.graphics.print(item[1], panel_x + 30, y)
        love.graphics.setColor(0.85, 0.85, 0.85)
        love.graphics.print(item[2], panel_x + 130, y)
        y = y + 35
    end

    -- 底部关闭提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(fonts.tiny)
    local close_hint = "按 H 关闭帮助"
    local ch_w = love.graphics.getFont():getWidth(close_hint)
    love.graphics.print(close_hint, (800 - ch_w) / 2, panel_y + panel_h - 30)
end

-- 游戏结束叠加层
function draw_gameover_overlay()
    -- 半透明遮罩
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- 游戏结束文字
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.setFont(fonts.title)
    local go_text = "游戏结束"
    local go_w = love.graphics.getFont():getWidth(go_text)
    love.graphics.print(go_text, (800 - go_w) / 2, 200)

    -- 最终分数
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.score_big)
    local score_text = "最终分数: " .. score
    local score_w = love.graphics.getFont():getWidth(score_text)
    love.graphics.print(score_text, (800 - score_w) / 2, 270)

    -- 最高分
    if score >= high_score and score > 0 then
        love.graphics.setColor(1, 0.84, 0)
        love.graphics.setFont(fonts.record)
        local new_record = "新纪录！"
        local nr_w = love.graphics.getFont():getWidth(new_record)
        love.graphics.print(new_record, (800 - nr_w) / 2, 310)
    end

    -- 重新开始提示
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(fonts.normal)
    local restart_hint = "按 R 重新开始 | 按 空格键 回到标题"
    local rh_w = love.graphics.getFont():getWidth(restart_hint)
    love.graphics.print(restart_hint, (800 - rh_w) / 2, 370)
end
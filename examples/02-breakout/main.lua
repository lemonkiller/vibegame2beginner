-- 打砖块游戏 - LÖVE2D
-- 用方向键或鼠标控制挡板，弹球消除砖块

-- ========== 游戏配置 ==========
local WINDOW_W = 800
local WINDOW_H = 600
local PADDLE_W = 100
local PADDLE_H = 15
local PADDLE_SPEED = 500        -- 键盘控制时挡板每秒移动的像素
local PADDLE_Y = WINDOW_H - 40  -- 挡板的Y位置
local BALL_RADIUS = 8
local BALL_SPEED = 350          -- 球的初始速度（像素/秒）
local BRICK_ROWS = 5
local BRICK_COLS = 8
local BRICK_W = 80              -- (800 - 间距) / 8
local BRICK_H = 25
local BRICK_PAD = 5             -- 砖块间距
local BRICK_OFFSET_X = 35       -- 砖块区域左边距
local BRICK_OFFSET_Y = 60       -- 砖块区域上边距
local MAX_LIVES = 3
local BRICK_SCORE = 10

-- ========== 游戏状态 ==========
local state = "start"           -- "start" / "playing" / "gameover" / "win"
local paddle = {}
local ball = {}
local bricks = {}
local score = 0
local lives = MAX_LIVES
local particles = {}            -- 粒子效果（砖块碎裂）
local show_help = false          -- 帮助面板显示状态

-- 字体缓存（避免每帧重复创建）
local fonts = {}

-- 砖块每行的颜色（RGB 0~1）
local ROW_COLORS = {
    {0.9, 0.3, 0.3},  -- 红
    {0.9, 0.6, 0.2},  -- 橙
    {0.9, 0.9, 0.3},  -- 黄
    {0.3, 0.85, 0.4},  -- 绿
    {0.3, 0.5, 0.9},  -- 蓝
}

-- ========== 初始化 ==========
function love.load()
    love.window.setTitle("打砖块")

    -- 预创建所有字体对象
    fonts.title = love.graphics.newFont("font/zpix.ttf", 48)
    fonts.score_big = love.graphics.newFont("font/zpix.ttf", 28)
    fonts.help_title = love.graphics.newFont("font/zpix.ttf", 24)
    fonts.medium = love.graphics.newFont("font/zpix.ttf", 20)
    fonts.normal = love.graphics.newFont("font/zpix.ttf", 18)
    fonts.small = love.graphics.newFont("font/zpix.ttf", 16)
    fonts.tiny = love.graphics.newFont("font/zpix.ttf", 14)

    init_game()
end

function init_game()
    -- 挡板初始化
    paddle = {
        x = WINDOW_W / 2 - PADDLE_W / 2,
        y = PADDLE_Y,
        w = PADDLE_W,
        h = PADDLE_H,
    }

    -- 球初始化（附着在挡板上）
    ball = {
        x = paddle.x + paddle.w / 2,
        y = paddle.y - BALL_RADIUS,
        vx = 0,
        vy = 0,
        radius = BALL_RADIUS,
        attached = true,  -- 球附着在挡板上，按空格发射
    }

    -- 砖块初始化
    bricks = {}
    for row = 1, BRICK_ROWS do
        for col = 1, BRICK_COLS do
            local bx = BRICK_OFFSET_X + (col - 1) * (BRICK_W + BRICK_PAD)
            local by = BRICK_OFFSET_Y + (row - 1) * (BRICK_H + BRICK_PAD)
            table.insert(bricks, {
                x = bx,
                y = by,
                w = BRICK_W,
                h = BRICK_H,
                alive = true,
                color = ROW_COLORS[row],
            })
        end
    end

    score = 0
    lives = MAX_LIVES
    particles = {}
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
        if key == "space" and ball.attached then
            -- 发射球
            ball.attached = false
            local angle = -math.pi / 2 + (love.math.random() - 0.5) * 0.5  -- 略微随机
            ball.vx = math.cos(angle) * BALL_SPEED
            ball.vy = math.sin(angle) * BALL_SPEED
        end
    elseif state == "gameover" or state == "win" then
        if key == "r" then
            init_game()
            state = "playing"
        elseif key == "space" then
            init_game()
            state = "start"
        end
    end
end

-- ========== 游戏更新 ==========
function love.update(dt)
    if state ~= "playing" then return end

    -- 挡板控制：键盘
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        paddle.x = paddle.x - PADDLE_SPEED * dt
    end
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        paddle.x = paddle.x + PADDLE_SPEED * dt
    end

    -- 挡板控制：鼠标总是跟随位置（平滑移动）
    local mx = love.mouse.getX()
    local target = mx - paddle.w / 2
    paddle.x = paddle.x + (target - paddle.x) * 0.3

    -- 限制挡板在屏幕内
    paddle.x = math.max(0, math.min(WINDOW_W - paddle.w, paddle.x))

    -- 如果球附着在挡板上，跟着挡板走
    if ball.attached then
        ball.x = paddle.x + paddle.w / 2
        ball.y = paddle.y - ball.radius
        return
    end

    -- 移动球
    ball.x = ball.x + ball.vx * dt
    ball.y = ball.y + ball.vy * dt

    -- 墙壁碰撞
    -- 左墙
    if ball.x - ball.radius < 0 then
        ball.x = ball.radius
        ball.vx = math.abs(ball.vx)
    end
    -- 右墙
    if ball.x + ball.radius > WINDOW_W then
        ball.x = WINDOW_W - ball.radius
        ball.vx = -math.abs(ball.vx)
    end
    -- 上墙
    if ball.y - ball.radius < 0 then
        ball.y = ball.radius
        ball.vy = math.abs(ball.vy)
    end

    -- 球掉到底部
    if ball.y + ball.radius > WINDOW_H then
        lives = lives - 1
        if lives <= 0 then
            state = "gameover"
        else
            -- 重置球到挡板上
            ball.attached = true
            ball.vx = 0
            ball.vy = 0
            ball.x = paddle.x + paddle.w / 2
            ball.y = paddle.y - ball.radius
        end
        return
    end

    -- 挡板碰撞
    if ball.vy > 0 and check_ball_rect_collision(ball, paddle) then
        ball.y = paddle.y - ball.radius
        -- 根据球碰到挡板的位置计算反弹角度
        local hit_pos = (ball.x - paddle.x) / paddle.w  -- 0~1，左边到右边
        local angle = (hit_pos - 0.5) * math.pi * 0.7  -- -63度 ~ +63度
        local speed = math.sqrt(ball.vx^2 + ball.vy^2)
        ball.vx = math.sin(angle) * speed
        ball.vy = -math.cos(angle) * speed
    end

    -- 砖块碰撞
    for _, brick in ipairs(bricks) do
        if brick.alive and check_ball_rect_collision(ball, brick) then
            brick.alive = false
            score = score + BRICK_SCORE

            -- 判断球从哪个方向碰到砖块，决定反弹方向
            local ball_cx = ball.x
            local ball_cy = ball.y
            local brick_cx = brick.x + brick.w / 2
            local brick_cy = brick.y + brick.h / 2

            local dx = ball_cx - brick_cx
            local dy = ball_cy - brick_cy

            -- 比较横向和纵向的重叠量
            local overlap_x = (brick.w / 2 + ball.radius) - math.abs(dx)
            local overlap_y = (brick.h / 2 + ball.radius) - math.abs(dy)

            if overlap_x < overlap_y then
                ball.vx = -ball.vx
            else
                ball.vy = -ball.vy
            end

            -- 生成碎裂粒子
            spawn_particles(brick.x + brick.w/2, brick.y + brick.h/2, brick.color)

            -- 只碰一块砖
            break
        end
    end

    -- 检查是否全部消除
    local all_dead = true
    for _, brick in ipairs(bricks) do
        if brick.alive then
            all_dead = false
            break
        end
    end
    if all_dead then
        state = "win"
    end

    -- 更新粒子
    update_particles(dt)
end

-- ========== 碰撞检测 ==========
-- 球（圆形）和矩形碰撞
function check_ball_rect_collision(b, r)
    -- 找到矩形上离球心最近的点
    local closest_x = math.max(r.x, math.min(b.x, r.x + r.w))
    local closest_y = math.max(r.y, math.min(b.y, r.y + r.h))

    local dist_x = b.x - closest_x
    local dist_y = b.y - closest_y

    return (dist_x * dist_x + dist_y * dist_y) < (b.radius * b.radius)
end

-- ========== 粒子系统 ==========
function spawn_particles(x, y, color)
    for i = 1, 12 do
        local angle = love.math.random() * math.pi * 2
        local speed = love.math.random(80, 250)
        table.insert(particles, {
            x = x,
            y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = 1.0,           -- 1.0 ~ 0.0
            decay = love.math.random(1.5, 3.0),
            color = {color[1], color[2], color[3]},
            size = love.math.random(2, 5),
        })
    end
end

function update_particles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.vy = p.vy + 200 * dt  -- 重力
        p.life = p.life - p.decay * dt
        if p.life <= 0 then
            table.remove(particles, i)
        end
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
        draw_overlay("游戏结束", {1, 0.3, 0.3})
    elseif state == "win" then
        draw_game()
        draw_overlay("恭喜通关!", {1, 0.84, 0})
    end

    draw_help_overlay()
end

-- 开始界面
function draw_start_screen()
    -- 深色背景
    love.graphics.setColor(0.08, 0.08, 0.12)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    -- 装饰：随机画些彩色方块
    math.randomseed(42)
    for i = 1, 40 do
        local row = love.math.random(1, 5)
        local col = love.math.random(1, 8)
        local bx = BRICK_OFFSET_X + (col - 1) * (BRICK_W + BRICK_PAD)
        local by = BRICK_OFFSET_Y + (row - 1) * (BRICK_H + BRICK_PAD)
        local c = ROW_COLORS[row]
        love.graphics.setColor(c[1] * 0.3, c[2] * 0.3, c[3] * 0.3)
        love.graphics.rectangle("fill", bx, by, BRICK_W, BRICK_H, 3)
    end

    -- 标题
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.title)
    local title = "打砖块"
    local tw = love.graphics.getFont():getWidth(title)
    love.graphics.print(title, (WINDOW_W - tw) / 2, 250)

    -- 提示
    love.graphics.setFont(fonts.medium)
    love.graphics.setColor(0.7, 0.7, 0.7)
    if math.floor(love.timer.getTime() * 2) % 2 == 0 then
        local hint = "按 空格键 开始游戏"
        local hw = love.graphics.getFont():getWidth(hint)
        love.graphics.print(hint, (WINDOW_W - hw) / 2, 340)
    end

    -- 操作说明
    love.graphics.setFont(fonts.small)
    local ctrl = "方向键/鼠标 控制挡板 | 空格键 发射球"
    local cw = love.graphics.getFont():getWidth(ctrl)
    love.graphics.print(ctrl, (WINDOW_W - cw) / 2, 390)

    -- 帮助提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(fonts.tiny)
    local help_hint = "按 H 查看帮助"
    local hh_w = love.graphics.getFont():getWidth(help_hint)
    love.graphics.print(help_hint, (WINDOW_W - hh_w) / 2, 430)
end

-- 游戏画面
function draw_game()
    -- 背景
    love.graphics.setColor(0.08, 0.08, 0.12)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    -- 砖块
    for _, brick in ipairs(bricks) do
        if brick.alive then
            local c = brick.color
            -- 砖块主体
            love.graphics.setColor(c[1], c[2], c[3])
            love.graphics.rectangle("fill", brick.x, brick.y, brick.w, brick.h, 3)
            -- 高光
            love.graphics.setColor(c[1] * 1.3, c[2] * 1.3, c[3] * 1.3, 0.4)
            love.graphics.rectangle("fill", brick.x + 2, brick.y + 2, brick.w - 4, brick.h / 3, 2)
        end
    end

    -- 粒子
    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
        love.graphics.rectangle("fill", p.x - p.size/2, p.y - p.size/2, p.size, p.size)
    end

    -- 挡板
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.rectangle("fill", paddle.x, paddle.y, paddle.w, paddle.h, 4)
    -- 挡板高光
    love.graphics.setColor(1, 1, 1, 0.3)
    love.graphics.rectangle("fill", paddle.x + 3, paddle.y + 2, paddle.w - 6, paddle.h / 3, 2)

    -- 球
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    -- 球的光晕
    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius * 2.5)

    -- HUD：分数和生命
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.normal)
    love.graphics.print("分数: " .. score, 15, 15)

    -- 用爱心表示生命
    for i = 1, MAX_LIVES do
        if i <= lives then
            love.graphics.setColor(1, 0.3, 0.4)
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end
        local hx = WINDOW_W - 30 - (i - 1) * 25
        love.graphics.print("♥", hx, 12)
    end

    -- 附着提示
    if ball.attached then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.setFont(fonts.small)
        local a_hint = "按 空格键 发射球"
        local ahw = love.graphics.getFont():getWidth(a_hint)
        love.graphics.print(a_hint, (WINDOW_W - ahw) / 2, WINDOW_H / 2)
    end
end

-- 帮助面板叠加层
function draw_help_overlay()
    if not show_help then return end

    -- 半透明黑色遮罩
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    -- 帮助面板边框和背景
    local panel_w = 380
    local panel_h = 340
    local panel_x = (WINDOW_W - panel_w) / 2
    local panel_y = (WINDOW_H - panel_h) / 2
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
    love.graphics.print(title, (WINDOW_W - title_w) / 2, panel_y + 20)

    -- 分割线
    love.graphics.setColor(0.4, 0.5, 0.7)
    love.graphics.line(panel_x + 20, panel_y + 55, panel_x + panel_w - 20, panel_y + 55)

    -- 操作按键列表
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(fonts.normal)
    local items = {
        {"空格键", "开始游戏"},
        {"方向键/A/D", "控制挡板移动"},
        {"鼠标", "控制挡板位置"},
        {"空格键", "发射球"},
        {"R键", "重新开始"},
    }
    local y = panel_y + 70
    for _, item in ipairs(items) do
        love.graphics.setColor(0.6, 0.8, 1)
        love.graphics.print(item[1], panel_x + 30, y)
        love.graphics.setColor(0.85, 0.85, 0.85)
        love.graphics.print(item[2], panel_x + 160, y)
        y = y + 35
    end

    -- 底部关闭提示
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(fonts.tiny)
    local close_hint = "按 H 关闭帮助"
    local ch_w = love.graphics.getFont():getWidth(close_hint)
    love.graphics.print(close_hint, (WINDOW_W - ch_w) / 2, panel_y + panel_h - 30)
end

-- 结束/通关叠加层
function draw_overlay(title_text, title_color)
    -- 遮罩
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, WINDOW_W, WINDOW_H)

    -- 标题
    love.graphics.setColor(title_color[1], title_color[2], title_color[3])
    love.graphics.setFont(fonts.title)
    local tw = love.graphics.getFont():getWidth(title_text)
    love.graphics.print(title_text, (WINDOW_W - tw) / 2, 200)

    -- 分数
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.score_big)
    local score_text = "最终分数: " .. score
    local sw = love.graphics.getFont():getWidth(score_text)
    love.graphics.print(score_text, (WINDOW_W - sw) / 2, 270)

    -- 提示
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(fonts.normal)
    local hint = "按 R 重新开始 | 按 空格键 回到标题"
    local hw = love.graphics.getFont():getWidth(hint)
    love.graphics.print(hint, (WINDOW_W - hw) / 2, 340)
end
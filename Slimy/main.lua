function love.load()
    math.randomseed(os.time())
    
    gameState = "playing"
    game = {0,0,0,0,0,0,0,0,0}
    
    love.graphics.setBackgroundColor(60/255, 139/255, 70/255)
    
    x = 400
    y = 400
    speed = 220         

    bx = -100 
    by = -100
    bdx, bdy = 0, 0
    bulletSpeed = 550   

    ex = 100 
    ey = 100
    enemySpeed = 130    
    difficultyScale = 15 

    ebx = -100
    eby = -100
    ebdx, ebdy = 0, 0
    enemyBulletSpeed = 400
    shootTimer = 0
    shootCooldown = 1.5
    
    player = love.graphics.newImage("player.png")
    bullet = love.graphics.newImage("bullet.png")
    enemy  = love.graphics.newImage("enemy.png")
    x_img  = love.graphics.newImage("x.png")
end

function checkCollision(x1, y1, img1, x2, y2, img2)
    local w1, h1 = img1:getDimensions()
    local w2, h2 = img2:getDimensions()
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
end

function checkWin()
    local winLines = {
        {1, 2, 3}, {4, 5, 6}, {7, 8, 9}, 
        {1, 4, 7}, {2, 5, 8}, {3, 6, 9}, 
        {1, 5, 9}, {3, 5, 7}             
    }
    for _, line in ipairs(winLines) do
        if game[line[1]] == "X" and game[line[2]] == "X" and game[line[3]] == "X" then
            return true
        end
    end
    return false
end

function love.update(dt)
    if gameState ~= "playing" then return end

    if love.keyboard.isDown("right") then x = x + speed * dt end
    if love.keyboard.isDown("left") then x = x - speed * dt end
    if love.keyboard.isDown("up") then y = y - speed * dt end
    if love.keyboard.isDown("down") then y = y + speed * dt end

    bx = bx + bdx * bulletSpeed * dt
    by = by + bdy * bulletSpeed * dt

    local edx = x - ex
    local edy = y - ey
    local distance = math.sqrt(edx * edx + edy * edy)

    if distance > 0 then
        ex = ex + (edx / distance) * enemySpeed * dt
        ey = ey + (edy / distance) * enemySpeed * dt
    end

    shootTimer = shootTimer + dt
    if shootTimer >= shootCooldown then
        shootTimer = 0
        ebx = ex
        eby = ey
        
        local tdx = x - ex
        local tdy = y - ey
        local tDist = math.sqrt(tdx * tdx + tdy * tdy)
        
        if tDist > 0 then
            ebdx = tdx / tDist
            ebdy = tdy / tDist
        end
    end

    ebx = ebx + ebdx * enemyBulletSpeed * dt
    eby = eby + ebdy * enemyBulletSpeed * dt

    if checkCollision(bx, by, bullet, ex, ey, enemy) then
        enemykilled()
    end

    if checkCollision(x, y, player, ex, ey, enemy) then
        gameState = "lost"
    end

    if checkCollision(ebx, eby, bullet, x, y, player) then
        gameState = "lost"
    end
end

function drawgame()
    local startX = love.graphics.getWidth() / 2 - 60
    local startY = 20
    local cellSize = 40

    for i = 1, 9 do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local posx = startX + (col * cellSize)
        local posy = startY + (row * cellSize)

        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.rectangle("line", posx, posy, 35, 35)
        love.graphics.setColor(1, 1, 1, 1)

        if game[i] == "X" then
            love.graphics.draw(x_img, posx, posy)
        end
    end
end

function enemykilled()
    local emptyCells = {}
    for i = 1, #game do
        if game[i] == 0 then
            table.insert(emptyCells, i)
        end
    end

    if #emptyCells > 0 then
        local randomIndex = emptyCells[math.random(1, #emptyCells)]
        game[randomIndex] = "X"
    end

    if checkWin() then
        gameState = "won"
        return
    end

    enemySpeed = enemySpeed + difficultyScale
    speed = math.max(140, speed - 8) 
    
    shootCooldown = math.max(0.6, shootCooldown - 0.1)

    repeat
        ex = math.random(0, love.graphics.getWidth() - enemy:getWidth())
        ey = math.random(0, love.graphics.getHeight() - enemy:getHeight())
        local distance = math.sqrt((x - ex)^2 + (y - ey)^2)
    until distance > 250 

    bx, by = -100, -100
    bdx, bdy = 0, 0
    ebx, eby = -100, -100
    ebdx, ebdy = 0, 0
end

function love.draw()
    drawgame()

    love.graphics.draw(player, x, y)
    love.graphics.draw(bullet, bx, by)
    love.graphics.draw(enemy, ex, ey)
    
    love.graphics.draw(bullet, ebx, eby)

    if gameState == "won" then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("You Won!", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    elseif gameState == "lost" then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.print("Game Over! :(", love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
end

function love.mousepressed(mx, my, button)
    if gameState ~= "playing" then return end

    if button == 1 then
        bx = x
        by = y
        local dx = mx - x
        local dy = my - y
        local distance = math.sqrt(dx * dx + dy * dy)
        if distance > 0 then
            bdx = dx / distance
            bdy = dy / distance
        end
    end
end

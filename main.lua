-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(1280, 720, {})
    -- x, y, w, h = 20, 20, 60, 20  -- Note that these are global

    -- local z = 69 -- This is local

    -- gameState = { -- This is a table
    --     dog = "cat"
    -- }

    -- print(gameState.dog) -- Prints "cat"
    -- print(gameState["dog"]) -- Also prints "cat"

    -- -- For loop
    -- team = {"Stuart", "Grace", "Andy"}
    -- for i = 1, 3 do
    --     print(team[i])
    -- end
    
    -- -- Remember that hashmaps are the only data structure,
    -- -- so these two are identical
    -- team = {"Stuart", "Grace", "Andy"}
    -- teamExplicit = {[1]="Stuart", [2]="Grace", [3]="Andy"}

    -- print(teamExplicit[2]) -- Prints Grace
    speedCount, scoreCount, carCount, giraffeCount, jeepCount, maxSpeedCount, maxScoreCount, maxCarCount, maxGiraffeCount, maxJeepCount =
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    xSpeed = 0
    buttonFont = love.graphics.newFont(48)
    scoreFont = love.graphics.newFont(18)
    print("hello world")

    showMenuScreen()

end
 
-- Increase the size of the rectangle every frame.
function love.update(dt)
    if isMenuScene then
    else
        -- Counter increments
        speedCount = speedCount + 5
        scoreCount = scoreCount + 4
        carCount = carCount + 3
        giraffeCount = giraffeCount + 2
        jeepCount = jeepCount + 1

        if speedCount > maxSpeedCount then
            maxSpeedCount = speedCount
        end
        if scoreCount > maxScoreCount then
            maxScoreCount = scoreCount
        end
        if carCount > maxCarCount then
            maxCarCount = carCount
        end
        if giraffeCount > maxGiraffeCount then
            maxGiraffeCount = giraffeCount
        end
        if jeepCount > maxJeepCount then
            maxJeepCount = jeepCount
        end

        -- Movement
        buttonX = buttonX + xSpeed
        if xSpeed > 0 then
            xSpeed = xSpeed - 1
        elseif xSpeed < 0 then
            xSpeed = xSpeed + 1
        end
    end
end
 
-- Draw a coloured rectangle.
function love.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    if isMenuScene then
        -- bg
        love.graphics.setBackgroundColor(.3,.7,.1)

        -- play button
        love.graphics.setColor(0, 0.4, 0.4)
        love.graphics.rectangle("fill", buttonX, buttonY, buttonWidth, buttonHeight)

        -- play button text
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(buttonFont)
        -- love.graphics.setFont()
        love.graphics.print("Play", buttonX + 20, buttonY + 20)
    else
        love.graphics.setColor(0, 0.4, 0.4)
        love.graphics.rectangle("fill", buttonX + 20, buttonY, buttonHeight, buttonWidth + 40)
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(buttonFont)
        love.graphics.print("Train", buttonX + 20, buttonY + 20)

        -- Speed / top; Score / top; cars / top; giraffes / total; jeeps / total

        displayXval = 1000
        topDisplayXval = 1180
        
        displayYVals = {
            [30] = {"Speed", speedCount, maxSpeedCount},
            [70] = {"Score", scoreCount, maxScoreCount},
            [110] = {"Cars", carCount, maxCarCount},
            [150] = {"Giraffes", giraffeCount, maxGiraffeCount},
            [190] = {"Jeeps", jeepCount, maxJeepCount},
        }
        
        for k,v in pairs(displayYVals) do
            love.graphics.setColor(0, 0.4, 0.4)

            love.graphics.circle("fill", displayXval, k, 15)
            love.graphics.rectangle("fill", displayXval, k - 15, 280, 30)

            love.graphics.setColor(1,1,1)
            love.graphics.setFont(scoreFont)
            love.graphics.print(v[1] .. ": " .. v[2], displayXval, k - 12)
            love.graphics.print("Top: " .. v[3], topDisplayXval, k - 12)
        end

    end

    -- love.graphics.setColor(0, 0.4, 0.4)
    -- love.graphics.rectangle("fill", x, y, w, h)
end

function showMenuScreen()
    -- todo: add options, for now, create a 'play' button
    isMenuScene = true
    buttonX, buttonY, buttonWidth, buttonHeight = 420, 260, 300, 100
end

function showGameScreen()
    isMenuScene = false
end

function moveLeft()
    xSpeed = - 5
end

function moveRight()
    xSpeed = 5
end

function love.keypressed(key)
    print("key was "..key)
    if isMenuScene then
        if key == "space" or key == "return" then
            showGameScreen()
        end
    else
        if key == "a" then
            moveLeft()
        elseif key == "d" then
            moveRight()
        end
    end
end

function love.mousepressed(x,y)
    if (isMenuScene and (x > buttonX and x < buttonX + buttonWidth) and (y > buttonY and y < buttonY + buttonHeight)) then
        showGameScreen()
    else
        -- todo
    end
end
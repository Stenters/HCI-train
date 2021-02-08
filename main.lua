PI = 3.1415926535


Train = {
    image = love.graphics.newImage("train.png"),
    x = 0,
    y = 0,
    accel = 0.8,
    vel = 0,
    angle = 0
}

function Train:update(dt)
    -- Update velocity and position
    self.vel = self.vel + self.accel * dt
    self.x = self.x + math.cos(self.angle) * self.vel * dt;
    self.y = self.y + math.sin(self.angle) * self.vel * dt;

    -- Update train angle based off of user input
    if love.keyboard.isDown("d") then
        self.angle = self.angle + (PI / 8) * dt
    end
    if love.keyboard.isDown("a") then
        self.angle = self.angle - (PI / 8) * dt
    end
end

function Train:draw()
    love.graphics.draw(self.image,
        self.x, self.y,
        self.angle,
        1, 1, -- Scaling factor
        0, 24
    )
end


-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(1280, 720, {})

    -- Menu screen vars
    buttonX, buttonY, buttonWidth, buttonHeight = 420, 260, 300, 100

    -- Global count vars
    speedCount, speedMaxCount = 0,0
    scoreCount, scoreMaxCount = 0,0
    carCount, carMaxCount = 3,0
    jeepCount, jeepMaxCount = 0,0
    giraffeCount, giraffeMaxCount = 0,0
    buttonFont = love.graphics.newFont(48)
    scoreFont = love.graphics.newFont(18)

    windowy = love.graphics.getHeight()
	
	bg1 = {}
	bg1.img = love.graphics.newImage("img/grass1.jpg")
	bg1.y = 0
	bg1.height = bg1.img:getHeight()

	bg2 = {}
	bg2.img = love.graphics.newImage("img/grass2.jpg")
	bg2.y = -windowy
	bg2.height = bg2.img:getHeight()

    speed = 250
    num_giraffes = 10
    giraffes = {}
    math.randomseed(os.time())
    for i = 1,num_giraffes do
        giraffes[i] = {
                image = love.graphics.newImage("img/giraffe-bright.png"),
                x = math.random() * 1200,
                y = math.random() * 720,
                onTrain = false
                }
    end

    trees = {{image = love.graphics.newImage("img/tree.png"), x = 100, y = 100}, {image = love.graphics.newImage("img/tree.png"), x = 300, y = 300}}
    jeeps = {}
    sanctuaries = {}

    showMenuScreen()
end

function updateTrain(dt)
    -- Update velocity and position
    Train.vel = Train.vel + Train.accel * dt
    Train.x = Train.x + math.cos(Train.angle) * Train.vel * dt;
    Train.y = Train.y + math.sin(Train.angle) * Train.vel * dt;

    -- Update train angle based off of user input
    if love.keyboard.isDown("d") then
        Train.angle = Train.angle + (PI / 8) * dt
    end
    if love.keyboard.isDown("a") then
        Train.angle = Train.angle - (PI / 8) * dt
    end
    
end

function updateGiraffes(dt)
    
    for i = 1,num_giraffes do
        if not giraffes[i].onTrain then
            giraffes[i].y = giraffes[i].y + speed * dt

            if giraffes[i].y > windowy then
                giraffes[i].y = 0
                giraffes[i].x = math.random() * 1200
            end
        end
    end

end

function updateBackground(dt)
    bg1.y = bg1.y + speed * dt
	bg2.y = bg2.y + speed * dt

	if bg1.y > windowy then
		bg1.y = bg2.y - bg1.height
	end
	if bg2.y > windowy then
		bg2.y = bg1.y - bg2.height
	end
	
end

function checkTreeCollisions(dt)
    for _, tree in pairs(trees) do 
        if checkCollisionWithTrain(tree) then
            tree.image = love.graphics.newImage("img/tree_collapsed.png")
            -- Slow the train down since it hit a tree
            Train.vel = Train.vel - Train.accel * dt
            -- TODO: Have the train lose a box car
        end
    end
end

function checkJeepCollisions(dt)
    for _, jeep in pairs(jeeps) do 
        if checkCollisionWithTrain(jeep) then 
            jeep.image = love.graphics.newImage('TODO') -- TODO: Replace this once Jeep graphics are done
            -- Slow the train down since it hit a jeep
            Train.vel = Train.vel - Train.accel * dt
            jeepCount = jeepCount + 1
            scoreCount = scoreCount + 10
        end
    end
end

function checkGiraffeCollisions()
    for _, giraffe in pairs(giraffes) do 
        if checkCollisionWithTrain(giraffe) then 
            -- TODO: Remove giraffe from being displayed
            -- TODO: Add the giraffe to the train
            giraffeCount = giraffeCount + 1
            giraffe.onTrain = true
        end
    end
end

function checkSanctuaryCollisions()
    for _, sanctuary in pairs(sanctuaries) do 
        if checkCollisionWithTrain(sanctuary) then 
            if giraffeCount > 1 then
                giraffeCount = giraffeCount - 1
                scoreCount = scoreCount + 50
                -- TODO: actually remove giraffe from train
            end
        end
    end
end

function checkCountMaxes()
    if speedCount > speedMaxCount then
        speedMaxCount = speedCount
    end
    if scoreCount > scoreMaxCount then
        scoreMaxCount = scoreCount
    end
    if carCount > carMaxCount then
        carMaxCount = carCount
    end
    if giraffeCount > giraffeMaxCount then
        giraffeMaxCount = giraffeCount
    end
    if jeepCount > jeepMaxCount then
        jeepMaxCount = jeepCount
    end
end    

function love.update(dt)
    if isMenuScene then
    else
        speedCount = Train.vel
        updateBackground(dt)
        updateGiraffes(dt)
        updateTrain(dt)
        checkTreeCollisions(dt)
        checkJeepCollisions(dt)
        checkGiraffeCollisions()
        checkSanctuaryCollisions()
        checkCountMaxes()
    end
end

function drawTrain()
    love.graphics.draw(Train.image, Train.x, Train.y, Train.angle)
end

function drawGiraffes()
    for i = 1,num_giraffes do
        love.graphics.draw(
            giraffes[i].image, 
            giraffes[i].x,
            giraffes[i].y, 0,
            0.15, 0.15)
    end
end

function drawBackground()
    love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg1.img, 0, bg1.y)
	love.graphics.draw(bg2.img, 0, bg2.y)
end

function drawTrees()
    for _, value in pairs(trees) do 
        love.graphics.draw(value.image, value.x, value.y)
    end
end

function drawGUI()
    -- Speed / top; Score / top; cars / top; giraffes / total; jeeps / total

    displayXval = 1000
    topDisplayXval = 1180
    
    displayYVals = {
        [30] = {"Speed", speedCount, speedMaxCount},
        [70] = {"Score", scoreCount, scoreMaxCount},
        [110] = {"Cars", carCount, carMaxCount},
        [150] = {"Giraffes", giraffeCount, giraffeMaxCount},
        [190] = {"Jeeps", jeepCount, jeepMaxCount},
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

function showMenuScreen()
    -- todo: add options, for now, create a 'play' button
    isMenuScene = true
end

function showGameScreen()
    isMenuScene = false
end
 
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
        drawTrain()
        drawGiraffes()
        drawBackground()
        drawTrees()
        drawGUI()
    end
end

function checkCollisionWithTrain(gameObjectTable)
    return Train.x < gameObjectTable.x + gameObjectTable.image:getWidth() and
        gameObjectTable.x < Train.x + Train.image:getWidth() and
        Train.y < gameObjectTable.y + gameObjectTable.image:getHeight() and
        gameObjectTable.y < Train.y + Train.image:getHeight()
end

function love.keypressed(key)
    if isMenuScene then
        if key == "space" or key == "return" then
            showGameScreen()
        end
    end
end

function love.mousepressed(x,y)
    if (isMenuScene and (x > buttonX and x < buttonX + buttonWidth) and (y > buttonY and y < buttonY + buttonHeight)) then
        showGameScreen()
    end
end

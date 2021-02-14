PI = 3.1415926535

SCREEN_W = 1280
SCREEN_H = 720

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

function lerp(a, b, amount)
    return (1 - amount) * a + amount * b
end

world = love.physics.newWorld(0, 0, true)

Train = {
    CART_CHAIN_LENGTH = 5,

    -- The ratio torque, thrust, and max speed is multiplied
    -- by each time a cart is added
    RATIO_TORQUE_PER_CART = 0.95,  -- I.e. it gets 5% more difficult to steer per cart
    RATIO_THRUST_PER_CART = 0.98,  -- I.e. thrust is reduced by 2% per cart
    RATIO_MAX_SPEED_PER_CART = 1.02,  -- I.e. max speed is increased by 2% per cart

    image = love.graphics.newImage("train.png"),
    body = love.physics.newBody(world, 100, 100, "dynamic"),

    w = 128,
    h = 48,
    thrust = 400,
    torque = 1,
    maxSpeed = 1000,
    
    carts = {}
}

Train.body:setInertia(10)
Train.body:setAngle(PI * 3 / 2)

function Train:update(dt)
    -- Update train angle based off of user input
    local angularVel = 0
    if love.keyboard.isDown("d") then
        angularVel = (4 * PI ) * dt
    end
    if love.keyboard.isDown("a") then
        angularVel = -(4 * PI) * dt
    end
    self.body:setAngularVelocity(angularVel)
    if love.keyboard.isDown("space") then
        self:addCart()
    end
    if love.keyboard.isDown("backspace") then
        self:removeCart()
    end

    -- Apply a force to the back of the train in the direction
    local fx, fy = math.cos(self.body:getAngle()), math.sin(self.body:getAngle())
    local cx, cy = self.body:getWorldCenter()
    self.body:applyForce(fx * self.thrust, fy * self.thrust, cx, cy)

    -- Apply max speed
    local vx, vy = self.body:getLinearVelocity()
    local speed = math.sqrt(vx^2 + vy^2)
    if (speed > self.maxSpeed) then
        -- Find the unit vector and multiply by max speed
        local ux, uy = vx / speed, vy / speed
        self.body:setLinearVelocity(ux * self.maxSpeed, uy * self.maxSpeed)
    end

    -- Update the position and angle of all the carts
    local lastTailX, lastTailY = self.body:getWorldPoint(-self.CART_CHAIN_LENGTH, 0)
    local lastAngle = self.body:getAngle()

    for i, cart in ipairs(self.carts) do
        local currentAngle = cart.body:getAngle()
        cart.body:setPosition(lastTailX, lastTailY)
        cart.body:setAngle(lerp(currentAngle, lastAngle, 0.05 * dt))

        lastTailX, lastTailY = cart.body:getWorldPoint(-cart.w - self.CART_CHAIN_LENGTH, 0)
        lastAngle = cart.body:getAngle()
    end

    local x = self.body:getX()
    if x > self.w + SCREEN_W then
        self.body:setX(x - SCREEN_W - self.w)
    end
    if x < -self.w then
        self.body:setX(x + SCREEN_W + self.w)
    end
end

function Train:draw()
    -- Draw carts
    local wx, wy = self.body:getPosition()
    local centerY = SCREEN_H / 2
    love.graphics.draw(self.image,
        wx, centerY,
        self.body:getAngle(),
        1, 1, -- Scaling factor
        0, self.h / 2 -- Rotate around the center back of the train
    )

    -- Draw carts
    for _, cart in ipairs(self.carts) do
        love.graphics.draw(self.image,
            cart.body:getX(), centerY + cart.body:getY() - wy,
            cart.body:getAngle(),
            1, 1, -- Scaling factor
            cart.w, cart.h / 2
        )
    end
end

function Train:addCart()
    -- Create new cart and add it to the list
    local newCart = {
        w = 128,
        h = 48,
        body = nil
    }
    newCart.body = love.physics.newBody(world, self.w, self.h, "dynamic")
    newCart.body:setAngle(PI * 3 / 2)
    self.carts[#self.carts + 1] = newCart

    -- Adjust train max speed, turn radius, and thrust
    self.maxSpeed = self.maxSpeed * self.RATIO_MAX_SPEED_PER_CART
    self.torque = self.torque * self.RATIO_TORQUE_PER_CART
    self.thrust = self.thrust * self.RATIO_THRUST_PER_CART
end

function Train:removeCart()
    if #self.carts > 0 then
        self.carts[#self.carts] = nil

        -- Adjust train max speed, turn radius, and thrust
        self.maxSpeed = self.maxSpeed / self.RATIO_MAX_SPEED_PER_CART
        self.torque = self.torque / self.RATIO_TORQUE_PER_CART
        self.thrust = self.thrust / self.RATIO_THRUST_PER_CART
    end
end

function Train:getSpeed()
    local vx, vy = self.body:getLinearVelocity()
    local speed = math.sqrt(vx^2 + vy^2)
    return speed
end


-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(SCREEN_W, SCREEN_H, {})
    windowx = love.graphics.getWidth()
	
	bg1 = {}
	bg1.img = love.graphics.newImage("img/grass1.jpg")
	bg1.x = 0
	bg1.width = bg1.img:getWidth()

	bg2 = {}
	bg2.img = love.graphics.newImage("img/grass2.jpg")
	bg2.x = -windowx
	bg2.width = bg2.img:getWidth()

    speed = 250
    num_giraffes = 10
    num_trees = 5
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

    trees = {}
    for i = 1, num_trees do 
        trees[i] = {
            image = love.graphics.newImage("img/tree.png"),
            x = math.random() * 1200,
            y = math.random() * 720,
            collapsed = false
        }
    end

    jeeps = {}
    sanctuaries = {}

    showMenuScreen()
end

function updateGiraffes(dt)
    for i = 1,num_giraffes do
        if not giraffes[i].onTrain then
            giraffes[i].x = giraffes[i].x - speed * dt

            if giraffes[i].x < 0 then
                giraffes[i].x = windowx
                giraffes[i].y = math.random() * 1200
            end
        end
    end

end

function updateTrees(dt)
    for i = 1, num_trees do 
        trees[i].y = trees[i].y + speed * dt

        if trees[i].y > windowy then
            trees[i].image = love.graphics.newImage("img/tree.png")
            trees[i].collapsed = false
            trees[i].y = 0
            trees[i].x = math.random() * 1200
        end
    end
end

function updateBackground(dt)
    local velocityX, velocityY = Train.body:getLinearVelocity()
    velocityY = velocityY * -1
    bg1.x = bg1.x - velocityX * dt
	bg2.x = bg2.x - velocityX * dt

	if bg1.x + bg1.width <= 0 then
		bg1.x = bg2.x + bg2.width
	end
	if bg2.x + bg2.width <= 0  then
		bg2.x = bg1.x + bg1.width
	end

    if bg1.x > bg1.width then
		bg1.x = bg2.x - bg1.width
	end
	if bg2.x > bg2.width  then
		bg2.x = bg1.x - bg2.width
	end
	
end

function checkTreeCollisions(dt)
    for _, tree in pairs(trees) do 
        if not tree.collapsed and checkCollisionWithTrain(tree) then
            tree.image = love.graphics.newImage("img/tree_collapsed.png")
            tree.collapsed = true
            -- Slow the train down since it hit a tree
            velX, velY = Train.body:getLinearVelocity()
            Train.body:setLinearVelocity(velX - velX * dt, velY - velY * dt)
            Train:removeCart()
            carCount = carCount - 1
        end
    end
end

function checkJeepCollisions(dt)
    for _, jeep in pairs(jeeps) do 
        if checkCollisionWithTrain(jeep) then 
            jeep.image = love.graphics.newImage('TODO') -- TODO: Replace this once Jeep graphics are done
            -- Slow the train down since it hit a tree
            velX, velY = Train.body:getLinearVelocity()
            Train.body:setLinearVelocity(velX - velX * dt, velY - velY * dt)
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
            scoreCount = scoreCount + 50
        end
    end
end

function checkSanctuaryCollisions()
    for _, sanctuary in pairs(sanctuaries) do 
        if checkCollisionWithTrain(sanctuary) then 
            if giraffeCount > 1 then
                giraffeCount = giraffeCount - 1
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
        speedCount = Train:getSpeed()
        Train:update(dt)
        world:update(dt)
        updateBackground(dt)
        updateGiraffes(dt)
        updateTrees(dt)
        checkTreeCollisions(dt)
        checkJeepCollisions(dt)
        checkGiraffeCollisions()
        checkSanctuaryCollisions()
        checkCountMaxes()
    end
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
	love.graphics.draw(bg1.img, bg1.x, 0)
	love.graphics.draw(bg2.img, bg2.x, 0)
end

function drawTrees()
    for _, value in pairs(trees) do 
        love.graphics.draw(value.image, value.x, value.y)
    end
end

function drawGUI()
    -- Speed / top; Score / top; cars / top; giraffes / total; jeeps / total
    -- Todo: numbers not updating correctly

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
        love.graphics.print(v[1] .. ": " .. math.floor(v[2]), displayXval, k - 12)
        love.graphics.print("Top: " .. math.floor(v[3]), topDisplayXval, k - 12)
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
        drawBackground()
        drawGiraffes()
        drawTrees()
        drawGUI()
        Train:draw()
    end
end

function checkCollisionWithTrain(gameObjectTable)
    -- First check to see if the object collided with the engine
    trainX, trainY = Train.body:getPosition()
    trainW, trainH = Train.w, Train.h
    objectCollidedWithEngine = trainX < gameObjectTable.x + gameObjectTable.image:getWidth() and
        gameObjectTable.x < trainX + trainW and
        trainY < gameObjectTable.y + gameObjectTable.image:getHeight() and
        gameObjectTable.y < trainY + trainH
    
    if objectCollidedWithEngine then 
        return true
    end

    for _, cart in pairs(Train.carts) do 
        cartX, cartY = cart.body:getPosition()
        cartW, cartH = cart.w, cart.h
        objectCollidedWithCart = cartX < gameObjectTable.x + gameObjectTable.image:getWidth() and
            gameObjectTable.x < cartX + cartW and
            cartY < gameObjectTable.y + gameObjectTable.image:getHeight() and
            gameObjectTable.y < cartY + cartH
        if objectCollidedWithCart then 
            return true
        end
    end
    return false
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

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

    distanceTraveled = 0,
    y = 0,
    vx = 0,
    vy = 0,
    speed = 100,
    
    shape = love.physics.newRectangleShape(100, 100),
    
    carts = {}
}

Train.body:setInertia(10)
Train.body:setAngle(0)
Train.fixture = love.physics.newFixture(Train.body, Train.shape)
Train.fixture:setUserData({name="train"})

function Train:update(dt)
    -- Update train angle based off of user input
    local angularVel = 0
    if love.keyboard.isDown("w") then
        angularVel = (4 * PI ) * dt
    end
    if love.keyboard.isDown("s") then
        angularVel = -(4 * PI) * dt
    end
    self.body:setAngularVelocity(angularVel)
    if love.keyboard.isDown("space") then
        self:addCart()
    end
    if love.keyboard.isDown("backspace") then
        self:removeCart()
    end

    -- Update position
    local angle = self.body:getAngle()
    self.vx = self.speed * math.cos(angle)
    self.vy = self.speed * math.sin(angle)

    self.distanceTraveled = self.distanceTraveled + self.vx * dt
    self.y = self.y + self.vy * dt

    -- Wrap train when driven off screen
    if self.y < -self.h then
        self.y = self.y + SCREEN_H + 2 * self.h
    elseif self.y > SCREEN_H + self.h then
        self.y = self.y - SCREEN_H - 2 * self.h
    end

    -- Set the position of the physics body
    self.body:setPosition(0, self.y)
end

function Train:draw()
    -- Draw carts
    local wx, wy = self.body:getPosition()
    local centerY = SCREEN_H / 2
    love.graphics.draw(self.image,
        self.body:getX(), self.body:getY(),
        self.body:getAngle(),
        1, 1, -- Scaling factor
        0, self.h / 2 -- Rotate around the center back of the train
    )

    -- Draw carts
    for _, cart in ipairs(self.carts) do
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
	
	bg1 = {}
	bg1.img = love.graphics.newImage("img/grass1.jpg")
	bg1.x = 0
	bg1.width = bg1.img:getWidth()

	bg2 = {}
	bg2.img = love.graphics.newImage("img/grass2.jpg")
	bg2.x = -SCREEN_W
	bg2.width = bg2.img:getWidth()

    sanctuary = {
        image = love.graphics.newImage("img/fence-zone.png"),
            body = love.physics.newBody(
                world, 
                0,
                0,
                "dynamic"
            )
    }
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    num_giraffes = 5
    num_trees = 5
    giraffes = {}
    math.randomseed(os.time())
    for i = 1,num_giraffes do
        giraffes[i] = {
                image = love.graphics.newImage("img/giraffe-bright.png"),
                body = love.physics.newBody(
                    world, 
                    math.random() * SCREEN_W,
                    math.random() * SCREEN_H,
                    "dynamic"
                ),
                shape = love.physics.newRectangleShape(65, 85)
            }
        giraffes[i].body:setMass(10)
        giraffes[i].fixture = love.physics.newFixture(giraffes[i].body, giraffes[i].shape)
        giraffes[i].fixture:setUserData({id=i, name="giraffe", onTrain=false})
    end

    trees = {}
    for i = 1, num_trees do 
        trees[i] = {
            image = love.graphics.newImage("img/tree.png"),
            body = love.physics.newBody(
                world, 
                math.random() * SCREEN_W,
                math.random() * SCREEN_H,
                "dynamic"
            ),
            collapsed = false
        }
    end

    jeeps = {}

    showMenuScreen()
end
function updateSanctuary(dt)
    velocityX = Train.vx
    sanctuary.body:setX(sanctuary.body:getX() - velocityX * dt)
    if (sanctuary.body:getX() < 0 - sanctuary.image:getWidth()) then
        random = math.random() * 5
        sanctuary.body:setX(SCREEN_W * random) -- place an arbitrary number of units in future
    end
end

function updateGiraffes(dt)
    local velocityX, _ = Train.vx
    for i = 1,num_giraffes do

        if (giraffes[i].fixture:getUserData().onTrain == false) then
            giraffes[i].body:setLinearVelocity(velocityX * -1, 0)

            if giraffes[i].body:getX() < -65 then
                giraffes[i].body:setX(SCREEN_W)
                giraffes[i].body:setY(math.random() * 1200)
            end

            if giraffes[i].body:getX() > SCREEN_W then
                giraffes[i].body:setX(0)
                giraffes[i].body:setY(math.random() * 1200)
            end
        else
            giraffes[i].body:setLinearVelocity(0, 0)
            giraffes[i].body:setX(Train.body:getX())
            giraffes[i].body:setY(Train.body:getY())         
        end
    
    end

end

function updateTrees(dt)
    for i = 1, num_trees do 
        velocityX = Train.vx
        trees[i].body:setX(trees[i].body:getX() - velocityX * dt)
        
        if trees[i].body:getX() < -65 then
            trees[i].image = love.graphics.newImage("img/tree.png")
            trees[i].collapsed = false
            trees[i].body:setX(SCREEN_W)
            trees[i].body:setY(math.random() * 1200)
        end

        if trees[i].body:getX() > SCREEN_W then
            trees[i].image = love.graphics.newImage("img/tree.png")
            trees[i].collapsed = false
            trees[i].body:setX(0)
            trees[i].body:setY(math.random() * 1200)
        end
    end
end

function updateBackground(dt)
    local velocityX  = Train.vx
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


function checkSanctuaryCollisions()
    if checkCollisionWithTrain(sanctuary) then 
        if giraffeCount > 1 then
            giraffeCount = giraffeCount - 1
            -- TODO: actually remove giraffe from train
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
        world:update(dt)
        speedCount = Train:getSpeed()
        Train:update(dt)
        updateBackground(dt)
        updateSanctuary(dt)
        updateGiraffes(dt)
        updateTrees(dt)
        checkTreeCollisions(dt)
        checkJeepCollisions(dt)
        checkSanctuaryCollisions()
        checkCountMaxes()
    end
end

function drawGiraffes()
    for i = 1,num_giraffes do
        love.graphics.draw(
            giraffes[i].image, 
            giraffes[i].body:getX(),
            giraffes[i].body:getY(), 0,
            0.15, 0.15)
    end
end

function drawBackground()
    love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg1.img, bg1.x, 0)
	love.graphics.draw(bg2.img, bg2.x, 0)
    love.graphics.draw(sanctuary.image, sanctuary.body:getX(), sanctuary.body:getY())
end

function drawTrees()
    for _, value in pairs(trees) do 
        love.graphics.draw(value.image, value.body:getX(), value.body:getY())
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
    trainX = Train.body:getX()
    trainY = SCREEN_H / 2
    trainW, trainH = Train.w, Train.h
    objectCollidedWithEngine = trainX < gameObjectTable.body:getX() + gameObjectTable.image:getWidth() and
        gameObjectTable.body:getX() < trainX + trainW and
        trainY < gameObjectTable.body:getY() + gameObjectTable.image:getHeight() and
        gameObjectTable.body:getY() < trainY + trainH
    
    if objectCollidedWithEngine then 
        return true
    end

    for _, cart in pairs(Train.carts) do 
        cartX, cartY = cart.body:getPosition()
        cartX = cart.body:getX()
        cartY = trainY + cart.body:getY() - Train.body:getY()
        cartW, cartH = cart.w, cart.h
        objectCollidedWithCart = cartX < gameObjectTable.body:getX() + gameObjectTable.image:getWidth() and
            gameObjectTable.body:getX() < cartX + cartW and
            cartY < gameObjectTable.body:getY() + gameObjectTable.image:getHeight() and
            gameObjectTable.body:getY() < cartY + cartH
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

-- collision code
function beginContact(a, b, coll)


end

function endContact(a, b, coll)
    if (a == nil or b == nil) then return end
    if (a:getUserData().name == 'train' and b:getUserData().name == 'giraffe') then

        print("Running collision handler :D")
        b:getUserData().onTrain = true

    end
    if (a:getUserData().name == 'giraffe' and b:getUserData().name == 'train')
    then
        print("Running collision handler :D")
        b:getUserData().onTrain = true
    end
end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end
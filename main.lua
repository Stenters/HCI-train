PI = 3.1415926535

SCREEN_W = 1280
SCREEN_H = 720

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
    num_giraffees = 10
    giraffees = {}
    math.randomseed(os.time())
    for i = 1,num_giraffees do
        giraffees[i] = {
                image = love.graphics.newImage("img/giraffee-bright.png"),
                x = math.random() * 1200,
                y = math.random() * 720,
                onTrain = false
                }
    end

    trees = {{image = love.graphics.newImage("img/tree.png"), x = 100, y = 100}, {image = love.graphics.newImage("img/tree.png"), x = 300, y = 300}}
    jeeps = {}
    sanctuaries = {}
end

function updateGiraffees(dt)
    
    for i = 1,num_giraffees do
        if not giraffees[i].onTrain then
            giraffees[i].y = giraffees[i].y + speed * dt

            if giraffees[i].y > windowy then
                giraffees[i].y = 0
                giraffees[i].x = math.random() * 1200
            end
        end
    end

end

function updateBackground(dt)
    local _, velocityY = Train.body:getLinearVelocity()
    bg1.y = bg1.y - velocityY * dt
	bg2.y = bg2.y - velocityY * dt

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
            -- TODO: Increment points
        end
    end
end

function checkGiraffeCollisions()
    for _, giraffe in pairs(giraffees) do 
        if checkCollisionWithTrain(giraffe) then 
            -- TODO: Remove giraffe from being displayed
            -- TODO: Add the giraffe to the train
        end
    end
end

function checkSanctuaryCollisions()
    for _, sanctuary in pairs(sanctuaries) do 
        if checkCollisionWithTrain(sanctuary) then 
            -- TODO: If there's a giraffe in the train decrement the number of giraffees in the train and increment points
        end
    end
end

function love.update(dt)
    Train:update(dt)
    world:update(dt)
    updateBackground(dt)
    updateGiraffees(dt)
    checkTreeCollisions(dt)
    checkJeepCollisions(dt)
    checkGiraffeCollisions()
    checkSanctuaryCollisions()
end

function drawTrain()
    love.graphics.draw(Train.image, Train.x, Train.y, Train.angle)
end

function drawGiraffees()
    for i = 1,num_giraffees do
        love.graphics.draw(
            giraffees[i].image, 
            giraffees[i].x,
            giraffees[i].y, 0,
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
 
function love.draw()
    drawBackground()
    drawTrees()
    drawGiraffees()
    Train:draw()
end

function checkCollisionWithTrain(gameObjectTable)
    trainX, trainY = Train.body:getPosition()
    trainW, trainH = Train.w, Train.h
    return trainX < gameObjectTable.x + gameObjectTable.image:getWidth() and
        gameObjectTable.x < trainX + trainW and
        trainY < gameObjectTable.y + gameObjectTable.image:getHeight() and
        gameObjectTable.y < trainY + trainH
end

PI = 3.1415926535

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
    thrust = 40,
    torque = 1,
    maxSpeed = 10,
    
    carts = {}
}

Train.body:setInertia(10)

function Train:update(dt)
    -- Update train angle based off of user input
    if love.keyboard.isDown("d") then
        self.body:applyTorque(1)
    end
    if love.keyboard.isDown("a") then
        self.body:applyTorque(-1)
    end
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
end

function Train:draw()
    -- Draw carts
    love.graphics.draw(self.image,
        self.body:getX(), self.body:getY(),
        self.body:getAngle(),
        1, 1, -- Scaling factor
        0, self.h / 2 -- Rotate around the center back of the train
    )

    -- Draw carts
    for _, cart in ipairs(self.carts) do
        love.graphics.draw(self.image,
            cart.body:getX(), cart.body:getY(),
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

function Train:currentSpeed()
    local vx, vy = self.body:getLinearVelocity()
    local speed = math.sqrt(vx^2 + vy^2)
    return speed
end

-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(1280, 720, {})


    x, y, w, h = 20, 20, 60, 20  -- Note that these are global

    local z = 69 -- This is local

    gameState = { -- This is a table
        dog = "cat"
    }

    print(gameState.dog) -- Prints "cat"
    print(gameState["dog"]) -- Also prints "cat". Arrays are zero indexed

    -- For loop
    team = {"Stuart", "Grace", "Andy"}
    for i = 1, 3 do
        print(team[i])
    end
    
    -- Remember that hashmaps are the only data structure,
    -- so these two are identical
    team = {"Stuart", "Grace", "Andy"}
    teamExplicit = {[1]="Stuart", [2]="Grace", [3]="Andy"}

    print(teamExplicit[2]) -- Prints Grace
    



end
 
function love.update(dt)
    Train:update(dt)
    world:update(dt)
end
 
function love.draw()
    Train:draw()
end
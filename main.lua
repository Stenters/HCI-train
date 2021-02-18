PI = 3.1415926535

SCREEN_W = 1280
SCREEN_H = 720

-- Menu screen vars
buttonX, buttonY, buttonWidth, buttonHeight = 420, 260, 300, 100

-- Global count vars
speedCount, speedMaxCount = 0,0
scoreCount, scoreMaxCount = 0,0
carCount, carMaxCount = 0,0
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
    COLLISION_PENALTY = 0.75, -- Speed lost per collision

    -- The ratio torque, thrust, and max speed is multiplied
    -- by each time a cart is added
    RATIO_TORQUE_PER_CART = 0.95,  -- I.e. it gets 5% more difficult to steer per cart
    RATIO_THRUST_PER_CART = 0.98,  -- I.e. thrust is reduced by 2% per cart
    RATIO_MAX_SPEED_PER_CART = 1.02,  -- I.e. max speed is increased by 2% per cart

    image = love.graphics.newImage("train.png"),
    body = love.physics.newBody(world, 100, 100, "dynamic"),

    rect = {
         x = 0,
         y = 0,
         w = 128,
         h = 48,
    },
    thrust = 400,
    torque = 1,
    maxSpeed = 1000,

    vx = 0,
    vy = 0,
    speed = 100,
    
    shape = love.physics.newRectangleShape(100, 100),
    
    carts = {},
    giraffeCount = 0
}

-- Create the physics body
Train.fixture = love.physics.newFixture(Train.body, Train.shape)
Train.fixture:setUserData({name="train"})
Train.body:setInertia(0)
Train.body:setAngle(0)

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

    -- Accelerate
    self.speed = lerp(self.speed, self.maxSpeed, (1 / 3) * dt)

    -- Update position
    local angle = self.body:getAngle()
    self.vx = self.speed * math.cos(angle)
    self.vy = self.speed * math.sin(angle)

    self.rect.y = self.rect.y + self.vy * dt

    -- Wrap train when driven off screen
    if self.rect.y < -self.rect.h then
        self.rect.y = self.rect.y + SCREEN_H + 2 * self.rect.h
    elseif self.rect.y > SCREEN_H + self.rect.h then
        self.rect.y = self.rect.y - SCREEN_H - 2 * self.rect.h
    end

    self.body:setPosition(self.rect.x, self.rect.y)
end

function Train:draw()
    -- Draw carts
    local wx, wy = self.body:getPosition()
    local centerY = SCREEN_H / 2
    love.graphics.draw(self.image,
        self.rect.x, self.rect.y + self.rect.h / 2,
        self.body:getAngle(),
        1, 1, -- Scaling factor
        0, self.rect.h / 2 -- Rotate around the center back of the train
    )

    local cx, cy = self.body:getWorldCenter()

    local w = giraffeImage:getWidth() * 0.075
    local h = giraffeImage:getHeight() * 0.075
    for i=1, self.giraffeCount do
        x = (self.rect.x + i * w * 0.2) * math.cos(self.body:getAngle())
        y = self.rect.y + i * h * 0.2 * math.sin(self.body:getAngle())
        love.graphics.draw(giraffeImage,
            x + w, y, self.body:getAngle(),
            -0.075, 0.075,
            0, 0)
    end
end

function Train:getSpeed()
    return self.speed
end

function Train:collideTree()
    self.speed = self.speed * (1 - self.COLLISION_PENALTY)
end

function Train:collideSanctuary()
    self.giraffeCount = 0
end

function Train:collideGiraffe()
    self.giraffeCount = self.giraffeCount + 1
end

function love.load()
    love.window.setMode(SCREEN_W, SCREEN_H, {})
    math.randomseed(os.time())
	
    -- Initialize parallaxing background
	bg1 = {}
	bg1.img = love.graphics.newImage("img/grass1.jpg")
	bg1.x = 0
	bg1.width = bg1.img:getWidth()

	bg2 = {}
	bg2.img = love.graphics.newImage("img/grass2.jpg")
	bg2.x = -SCREEN_W
	bg2.width = bg2.img:getWidth()

    -- Initialize the sanctuary
    sanctuaryImage = love.graphics.newImage("img/fence-zone.png")
    sanctuary = {
        rect = {
            x = 500,
            y = SCREEN_H * 0.25,
            w = 640 * 0.25,
            h = 960 * 0.25
        },
        hit = false
    }

    -- Initialize the giraffes
    numGiraffes = 2
    giraffes = {}
    giraffeImage = love.graphics.newImage("img/giraffe-bright.png")
    giraffeIconImage = love.graphics.newImage("img/giraffe-bright.png")
    for i = 1, numGiraffes do
        giraffes[i] = {
            rect = {
                x = math.random() * SCREEN_W,
                y = math.random() * SCREEN_H,
                w = giraffeImage:getWidth() * 0.17,
                h = giraffeImage:getHeight() * 0.17
            },
            hit = false
        }
    end

    -- Initialize the trees
    numTrees = 1
    trees = {}
    treeImage = love.graphics.newImage("img/tree.png")
    treeHitImage = love.graphics.newImage("img/tree_collapsed.png")
    for i = 1, numTrees do 
        trees[i] = {
            rect = {
                x = math.random() * SCREEN_W,
                y = math.random() * (SCREEN_H - treeImage:getHeight()),
                w = treeImage:getWidth() / 4,
                h = treeImage:getHeight() * 2 / 3
            },
            hit = false
        }
    end

    jeeps = {}
end

function updateSanctuary(dt)
    local dx = -Train.vx * dt

    if not sanctuary.hit and rectCollision(sanctuary.rect, Train.rect) then
        sanctuary.hit = true
        Train:collideSanctuary()
    end

    if sanctuary.rect.x + dt < -sanctuary.rect.w then
        -- Reset sanctuary
        sanctuary.hit = false
        sanctuary.rect.x = SCREEN_W * 4
        sanctuary.rect.y = math.random() * (SCREEN_H - sanctuaryImage:getHeight() * 0.1)
    else
        -- Move the sanctuary normally
        sanctuary.rect.x = sanctuary.rect.x + dx
    end
end

function updateGiraffes(dt)
    local dx = -Train.vx * dt

    for _, giraffe in pairs(giraffes) do 
        if not giraffe.hit and rectCollision(giraffe.rect, Train.rect) then
            -- Giraffe collided with a train
            giraffe.hit = true
            Train:collideGiraffe()
        end

        if giraffe.rect.x + dt < -giraffe.rect.w then
            -- Reset giraffe
            giraffe.hit = false
            giraffe.rect.x = SCREEN_W
            giraffe.rect.y = math.random() * (SCREEN_H - giraffeImage:getHeight() * 0.17)
        else
            -- Move the giraffe normally
            giraffe.rect.x = giraffe.rect.x + dx
        end
    end
end

function updateTrees(dt)
    local dx = -Train.vx * dt

    for i = 1, numTrees do 
        local tree = trees[i]

        if not tree.hit and rectCollision(tree.rect, Train.rect) then
            -- Tree collided with a train
            tree.hit = true
            Train:collideTree()
        end

        if tree.rect.x + dt < -tree.rect.w then
            -- Reset tree
            tree.hit = false
            tree.rect.x = SCREEN_W
            tree.rect.y = math.random() * (SCREEN_H - treeImage:getHeight())
        else
            -- Move the tree normally
            tree.rect.x = tree.rect.x + dx
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
        checkJeepCollisions(dt)
        checkCountMaxes()
    end
end

function drawGiraffes()
    for _, giraffe in pairs(giraffes) do
        if not giraffe.hit then
            love.graphics.draw(
                giraffeImage, 
                giraffe.rect.x,
                giraffe.rect.y, 0,
                0.15, 0.15)
        end
    end
end

function drawBackground()
    love.graphics.setColor(255,255,255,255)
	love.graphics.draw(bg1.img, bg1.x, 0)
	love.graphics.draw(bg2.img, bg2.x, 0)
end

function drawTrees()
    for _, tree in pairs(trees) do
        if tree.hit then
            love.graphics.draw(treeHitImage, tree.rect.x, tree.rect.y + tree.rect.h / 2)
        else
            love.graphics.draw(treeImage, tree.rect.x - tree.rect.w, tree.rect.y - tree.rect.h / 3)
        end
    end
end

function drawSanctuary()
    love.graphics.draw(sanctuaryImage, sanctuary.rect.x, sanctuary.rect.y, 0, 0.25, 0.25)
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
        drawSanctuary()
        drawGiraffes()
        drawTrees()
        drawGUI()
        Train:draw()
    end
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

end
 
function preSolve(a, b, coll)
 
end
 
function postSolve(a, b, coll, normalimpulse, tangentimpulse)
 
end

function rectCollision(rect1, rect2)
    return rect1.x < rect2.x + rect2.w and
        rect1.x + rect1.w > rect2.x and
        rect1.y < rect2.y + rect2.h and
        rect1.y + rect1.h > rect2.y
end
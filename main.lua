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

    trees = {{image = love.graphics.newImage("img/tree.png"), x = 100, y = 100}, {image = love.graphics.newImage("img/tree.png"), x = 300, y = 300}}
    jeeps = {}
    giraffes = {}
    sanctuaries = {}
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
            -- TODO: Increment points
        end
    end
end

function checkGiraffeCollisions()
    for _, giraffe in pairs(giraffes) do 
        if checkCollisionWithTrain(giraffe) then 
            -- TODO: Remove giraffe from being displayed
            -- TODO: Add the giraffe to the train
        end
    end
end

function checkSanctuaryCollisions()
    for _, sanctuary in pairs(sanctuaries) do 
        if checkCollisionWithTrain(sanctuary) then 
            -- TODO: If there's a giraffe in the train decrement the number of giraffes in the train and increment points
        end
    end
end

function love.update(dt)
    updateBackground(dt)
    updateTrain(dt)
    checkTreeCollisions(dt)
    checkJeepCollisions(dt)
    checkGiraffeCollisions()
    checkSanctuaryCollisions()
end

function drawTrain()
    love.graphics.draw(Train.image, Train.x, Train.y, Train.angle)
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
    drawTrain()
end

function checkCollisionWithTrain(gameObjectTable)
    return Train.x < gameObjectTable.x + gameObjectTable.image:getWidth() and
        gameObjectTable.x < Train.x + Train.image:getWidth() and
        Train.y < gameObjectTable.y + gameObjectTable.image:getHeight() and
        gameObjectTable.y < Train.y + Train.image:getHeight()
end

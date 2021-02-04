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
end
 
function love.draw()
    Train:draw()
end
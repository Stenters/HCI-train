PI = 3.1415926535


-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(1280, 720, {})

    train = {
        image = love.graphics.newImage("train.png"),
        x = 0,
        y = 0,
        accel = 0.8,
        vel = 0,
        angle = 0
    }

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

function updateTrain(dt)
    -- Update velocity and position
    train.vel = train.vel + train.accel * dt
    train.x = train.x + math.cos(train.angle) * train.vel * dt;
    train.y = train.y + math.sin(train.angle) * train.vel * dt;

    -- Update train angle based off of user input
    if love.keyboard.isDown("d") then
        train.angle = train.angle + (PI / 8) * dt
    end
    if love.keyboard.isDown("a") then
        train.angle = train.angle - (PI / 8) * dt
    end
end
 
function love.update(dt)
    updateTrain(dt)
end

function drawTrain()
    love.graphics.draw(train.image, train.x, train.y, train.angle)
end
 
function love.draw()
    drawTrain()
end
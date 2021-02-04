-- Load some default values for our rectangle.
function love.load()
    love.window.setMode(1280, 720, {})
    x, y, w, h = 20, 20, 60, 20  -- Note that these are global

    local z = 69 -- This is local

    gameState = { -- This is a table
        dog = "cat"
    }

    print(gameState.dog) -- Prints "cat"
    print(gameState["dog"]) -- Also prints "cat"

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
 
-- Increase the size of the rectangle every frame.
function love.update(dt)
    if w < 1240 then
	w = w + 10
    end
    if h < 680 then
        h = h + 10
    end
end
 
-- Draw a coloured rectangle.
function love.draw()
    -- In versions prior to 11.0, color component values are (0, 102, 102)
    love.graphics.setColor(0, 0.4, 0.4)
    love.graphics.rectangle("fill", x, y, w, h)
end

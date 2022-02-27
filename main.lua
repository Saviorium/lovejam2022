local noise, shader, image

function love.load()
    -- b2Vec2 gravity(0.0f, -10.0f);
    love.physics.setMeter(64)
    world = love.physics.newWorld(0, 9.81*64, true)

    objects = {} -- table to hold all our physical objects
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    --let's create the ground
    objects.ground = {}
    --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
    objects.ground.body = love.physics.newBody(world, width/2, height - 50/2)
    --make a rectangle with a width of 650 and a height of 50 
    objects.ground.shape = love.physics.newRectangleShape(width, 50) 
    objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body

    --let's create a ball
    objects.ball = {}
    objects.ball.body = love.physics.newBody(world, width/2, height/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
    objects.ball.shape = love.physics.newCircleShape( 20) --the ball's shape has a radius of 20
    objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape, 3) -- Attach fixture to body and give it a density of 1.
    objects.ball.fixture:setRestitution(0.9) --let the ball bounce

    --let's create a couple blocks to play around with
    objects.block1 = {}
    objects.block1.body = love.physics.newBody(world, width - 450, height - 200, "dynamic")

    objects.block1.shape = love.physics.newPolygonShape( 0, 0, 50, -25, 25, -50, 75, -25, 100, 0 )
    objects.block1.fixture = love.physics.newFixture(objects.block1.body, objects.block1.shape, 5) -- A higher density gives it more mass.

    objects.block2 = {}
    objects.block2.body = love.physics.newBody(world, width - 450, height - 250, "dynamic")
    objects.block2.shape = love.physics.newRectangleShape(0, 0, 100, 50)
    objects.block2.fixture = love.physics.newFixture(objects.block2.body, objects.block2.shape, 2)

    joint = love.physics.newFrictionJoint( objects.block1.body, objects.block2.body, width - 450, height - 100, true)

    love.graphics.setBackgroundColor(0.41, 0.53, 0.97) --set the background color to a nice blue
    love.window.setMode(650, 650) --set the window dimensions to 650 by 650 with no fullscreen, vsync on, and no antialiasing
end

function love.update(dt)
    world:update(dt) --this puts the world into motion

    --here we are going to create some keyboard events
    if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
        objects.ball.body:applyForce(400, 0)
    elseif love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
        objects.ball.body:applyForce(-400, 0)
    elseif love.keyboard.isDown("up") then --press the up arrow key to set the ball in the air
        objects.ball.body:applyForce(0, -100)
    elseif love.keyboard.isDown("down") then --press the up arrow key to set the ball in the air
        objects.ball.body:setPosition(650/2, 650/2)
        objects.ball.body:setLinearVelocity(0, 0) --we must set the velocity to zero to prevent a potentially large velocity generated by the change in position
    end
end

function love.draw()
    love.graphics.setColor(0.28, 0.63, 0.05) -- set the drawing color to green for the ground
    love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates
    love.graphics.setColor(0.76, 0.18, 0.05) --set the drawing color to red for the ball
    love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())

    love.graphics.setColor(0.20, 0.20, 0.20) -- set the drawing color to grey for the blocks
    love.graphics.polygon("fill", objects.block1.body:getWorldPoints(objects.block1.shape:getPoints()))
    love.graphics.polygon("fill", objects.block2.body:getWorldPoints(objects.block2.shape:getPoints()))
end
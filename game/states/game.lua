local Circle = require"game.circle_shape"
local Polygon = require"game.polygon_shape"
local Chelovechek = require"game.chelovechek"

local state = {}
local destroyQueue = {}


function state:enter(prev_state, args)
    -- b2Vec2 gravity(0.0f, -10.0f);
    love.physics.setMeter(64)
    local world = love.physics.newWorld(0, 9.81*64, true)
    self.world = world
    --These callback function names can be almost any you want:
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    text       = ""   -- we'll use this to put info text on the screen later
    persisting = 0    -- we'll use this to store the state of repeated callback calls

    local objects = {}
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    objects.ground = {}
    objects.ground.body = love.physics.newBody(world, 0, height + 50)
    self:createNewGroundpolygon(objects.ground.body, 100.)
    -- objects.ground.shape = love.physics.newPolygonShape(self:createNewGroundpolygon(4))
    -- objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
    -- objects.ground.fixture:setUserData({
    --     name = "Ground",
    -- })

    -- love.physics.newFixture(love.physics.newBody(world, 0, height - 50/2), love.physics.newRectangleShape(50, height) ):setUserData({
    --     name = "Ground",
    -- })
    -- love.physics.newFixture(love.physics.newBody(world, width - 50, height - 50/2), love.physics.newRectangleShape(50, height) ):setUserData({
    --     name = "Ground",
    -- })


    --let's create a ball
    objects.ball = Circle({world = world, position = {x = width/2, y = height/2}, range = 20})

    --let's create a couple blocks to play around with
    objects.block1 = Polygon({world = world, 
        position = {x = width - 450, y = height - 200}, 
        polygonVertexes = {0, 0, 50, -25, 25, -50, 75, -25, 100, 0}})

    objects.block2 = Polygon({world = world, 
        position = {x = width - 450, y = height - 250}, 
        polygonVertexes = {0, 0, 100, 0, 100, 50, 0, 50}})

    self.objects = objects

    love.graphics.setBackgroundColor(0.41, 0.53, 0.97) --set the background color to a nice blue

    self.rayCastPoints = {}
    self.touchPoints = {}
    self.brokenObjects = {}

    self.pointForBuild = 1000
    self.ui = require "game.ui"(self)
end

function state:createNewGroundpolygon(body, numberOfVertexes)

    local vertexes = {Vector(0,0)}
    local x, y = -50, 200
    local iterX = (love.graphics.getWidth()-x)/numberOfVertexes
    local heighMaxDifference = 10
    for i = 1, numberOfVertexes do
        local randomSeed = love.math.random(20) - 10
        local lhmd = -(math.sin(math.deg(x + randomSeed)) + math.cos(math.deg(x - randomSeed))) * heighMaxDifference
        local x2, y2 = x + iterX, (y + lhmd) > 150 and -(y + lhmd) or (y + lhmd)
        local shape = love.physics.newPolygonShape(x, y, x2, y2, x2, 150, x, 150 )
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData({
            name = "Ground",
        })
        fixture:setMask( 3 )
        fixture:setCategory( 1 )
        x, y = x2, y2
    end
end

function state:mousepressed(x, y)
    self.startMousePos = Vector(x, y)
    self.endMousePos = nil
    self.rayCastPoints = {}
    self.ui:mousepressed(x, y)
    if self.creatingBody then
        self.creatingBody.body:setFixedRotation( false )
        for _, fix in pairs(self.creatingBody.body:getFixtures()) do
            fix:setCategory(2)  
            fix:setMask(3) 
        end   
        self.joint:destroy()
        self.joint = nil
        self.creatingBody = nil
    end
end

function state:mousereleased(x, y)
    self.endMousePos = Vector(x, y)

    if self.startMousePos and self.endMousePos then
        for _, body in pairs(self.world:getBodies()) do 
            Polygon.splitObject(self, body, self.startMousePos, self.endMousePos)
        end
    end
    self.ui:mousereleased(x, y)
end

function state:createPolygonShapeFromAnotherObject(body, shape, vertexes)
    local result = Polygon({ world = self.world, polygonVertexes = vertexes, parentObject = {body = body, shape = shape}})
    return result
end

function state:keypressed(key)
    self.ui:keypressed(key)
     if self.creatingBody then
        self.creatingBody:keypressed(key)
    end
end

function state:update(dt)
    if not self.chelovechekDestroyed then
        self.world:update(dt) --this puts the world into motion
        self.ui:update(dt)

        for ind, object in pairs(destroyQueue) do
            if not object:isDestroyed() then
                if object:getUserData().name == 'Ball' then
                    Circle.dublicateCircle(object)
                else
                    object:destroy()
                end
            end
            destroyQueue[ind] = nil
        end

        if self.joint then
            local cx, cy = self.creatingBody.body:getLocalCenter()
            local x, y = love.mouse.getPosition()
            self.joint:setTarget(x + cx, y + cy)
        end

        for _, object in pairs(self.brokenObjects) do
            if not object.object:isDestroyed() then
                local x1, y1, f1 = nil, nil, nil
                local power = 1
                local startVector = nil
                repeat
                    power = power * 10
                    startVector = object.position - object.normal * power
                    x1, y1, f1 = object.object:rayCast(startVector.x, startVector.y, object.position.x, object.position.y, 1)
                until f1

                local r1HitX1 = startVector.x + (object.position.x - startVector.x) * f1
                local r1HitY1 = startVector.y + (object.position.y - startVector.y) * f1

                Polygon.splitObject(self, object.object:getBody(), object.position, Vector(r1HitX1, r1HitY1))
            end
        end
    end
end

function state:draw()
    local objects = self.objects
    love.graphics.setColor(0.28, 0.63, 0.05) -- set the drawing color to green for the ground
    -- love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints())) -- draw a "filled in" polygon using the ground's coordinates

    for ind, obj in pairs(self.world:getBodies()) do
        for _, fixture in pairs(obj:getFixtures()) do
            local userData = fixture:getUserData()
            local shapeName = userData and userData.name or nil
            if shapeName == 'Ball' then
                love.graphics.setColor(0.76, 0.18, 0.05) --set the drawing color to red for the ball
                love.graphics.circle("fill", obj:getX(), obj:getY(), fixture:getShape():getRadius())
            elseif fixture:getShape():getPoints() then
                love.graphics.setColor(0.20, 0.20, 0.20) -- set the drawing color to grey for the blocks
                love.graphics.polygon("fill", obj:getWorldPoints(fixture:getShape():getPoints()))
            end

            local texture = userData and userData.texture or nil
            if texture then
                love.graphics.push()
                love.graphics.setColor(1,1,1,1)
                love.graphics.translate(obj:getX(), obj:getY())
                love.graphics.rotate(obj:getAngle())
                love.graphics.draw(texture)
                love.graphics.pop()
            end
        end
    end
            love.graphics.setColor(0.76, 0.18, 0.05) --set the drawing color to red for the ball
    if self.startMousePos and self.endMousePos then
        love.graphics.line(self.startMousePos.x, self.startMousePos.y, self.endMousePos.x, self.endMousePos.y)
    end
    for _, point in pairs(self.rayCastPoints) do
        love.graphics.circle( 'fill', point.x, point.y, 4 )
    end
    for _, point in pairs(self.touchPoints) do
        love.graphics.circle( 'fill', point.x, point.y, 4 )
    end
    self.ui:draw()
end

function beginContact(a, b, coll)
end

function endContact(a, b, coll)
    persisting = 0    -- reset since they're no longer touching
end

function preSolve(a, b, coll)
    persisting = persisting + 1    -- keep track of how many updates they've been touching for
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
    -- local velocity = coll:getVelocity()
    local aName = a:getUserData().name
    local bName = b:getUserData().name
    if normalimpulse > 2000 then
        if aName == 'Ball' and bName ~= 'Ball' then
            table.insert(destroyQueue, a)
        elseif bName == 'Ball'  and aName ~= 'Ball' then
            table.insert(destroyQueue, b)
        end
    end

    if normalimpulse > 500 and not(aName == 'Ball' or bName == 'Ball') then
        if string.sub(aName,1, -5) == 'Chelovechek' or string.sub(bName,1, -5) == 'Chelovechek' then
            Chelovechek.destroyPart(string.sub(aName,1, -5) == 'Chelovechek' and a or b, state)
        else
            local x1, y1,x2, y2 = coll:getPositions()
            local nx, ny = coll:getNormal( )
            table.insert(state.touchPoints, Vector(x1, y1)) 
            table.insert(state.touchPoints, Vector(x2, y2))
            if a:getUserData() ~= 'Ground' then
                table.insert(state.brokenObjects, {object = a, position = Vector(x1, y1), normal = Vector( nx, ny )}) 
            end
            if b:getUserData() ~= 'Ground' then
                table.insert(state.brokenObjects, {object = b, position = Vector(x2, y2), normal = Vector( nx, ny )}) 
            end
        end
    end
end

return state
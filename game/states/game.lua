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
    -- objects.ground.body = love.physics.newBody(world, 0, height + 50, 'dynamic')
    -- objects.ground.body:setFixedRotation( true )
    self:createNewGroundpolygon(world, 75)
    -- love.physics.newMouseJoint( objects.ground.body, width/2, height - 100 )

    self.objects = objects

    love.graphics.setBackgroundColor(config.colors.blue) --set the background color to a nice blue

    self.rayCastPoints = {}
    self.touchPoints = {}
    self.brokenObjects = {}
    self.pillarsToChange = {}

    self.pointForBuild = config.money
    self.ui = require "game.ui"(self)
    self.timer = 0

    MusicPlayer:play("greece")
    self.shakeRoundDuration = 10
    self.shakeRound = 1
    self.shaking = false
end

function state:createNewGroundpolygon(world, numberOfVertexes)

    local vertexes = {Vector(0,0)}
    local x, y = -50, 200

    local iterX = (love.graphics.getWidth()-x)/numberOfVertexes

    for i = 1, numberOfVertexes do
        local body = love.physics.newBody(world, 0, love.graphics.getHeight() - 50, 'dynamic')
        body:setFixedRotation( true )

        -- local iterY = self:coutIterWithTrigonometry(x, y)
        local iterY = self:coutIterWithTrigonometry(x, y)
        local x2, y2 = x + iterX, (y + iterY) > 150 and -(y + iterY) or (y + iterY)

        local shape = love.physics.newPolygonShape(x - 1, y, x2 + 1, y2, x2 + 1, 150, x - 1, 150 )
        local fixture = love.physics.newFixture(body, shape, 100)

        fixture:setUserData({
            name = "Ground",
        })
        fixture:setMask( 1, 3, 4 )
        fixture:setCategory( 1 )
        love.physics.newMouseJoint( body, x, love.graphics.getHeight() - 100 )
        x, y = x2, y2
    end
end

function state:coutIterWithTrigonometry(x, y)
    local heighMaxDifference = 10
    local rand = love.math.random(20) - 10
    return -(math.sin(math.deg(x + rand)/100) + math.cos(math.deg(x - rand))/100) * heighMaxDifference
end

function state:coutIterWithNoise(x, y)
    local heighMaxDifference = 25
    local rand = love.math.random(20) - 10
    local value = love.math.noise( x + rand, y + rand  ) - 0.5
    return - value * heighMaxDifference
end

function state:coutIterWithFunctions(x, y)
    local heighMaxDifference = 25
    local rand = love.math.random(20) - 10
    local value = love.math.noise( x + rand, y + rand  ) - 0.5
    return - value * heighMaxDifference
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
        if not self.shaking then
            self.ui:update(dt)
        end

        self:destroyObjects()

        if self.shaking then

            local rand = love.math.random(4)
            self.timer = self.timer + dt

            self:shakeGround( 1100000, 4 * math.sin(self.timer) * self.timer, self.shakeRound )

            if self.timer > self.shakeRoundDuration then
                self.timer = 0
                self.shakeRound = self.shakeRound + 1
                self.shaking = false
            end
        end

        self:brakeAllThings()

        if self.joint then
            local cx, cy = self.creatingBody.body:getLocalCenter()
            local x, y = love.mouse.getPosition()
            self.joint:setTarget(x + cx, y + cy)
        end

        for ind, obj in pairs(self.world:getBodies()) do
            for _, fixture in pairs(obj:getFixtures()) do
                local group = fixture:getCategory( )
                if fixture:getUserData().name == 'Pillar' and group ~= 4 and fixture:getUserData().ready  then
                    local data = fixture:getUserData()
                    data.name = 'BlockShape'
                    fixture:setUserData(data)
                elseif fixture:getUserData().name == 'Pillar' and group ~= 3 and not fixture:getUserData().ready then
                    local data = fixture:getUserData()
                    data.ready = true
                    fixture:setUserData(data)
                end
            end
        end

        for _, obj in pairs(self.pillarsToChange) do
            for _, fixture in pairs(obj.pillar:getFixtures()) do
                fixture:setCategory(4)  
                fixture:setMask(1, 3)
            end
            love.physics.newWeldJoint( obj.pillar, obj.ground, obj.pos.x, obj.pos.y )
        end
        -- print(self:getFinalScore())
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

            local texture = userData and userData.texture or nil
            if texture then
                love.graphics.push()
                love.graphics.setColor(1,1,1,1)
                love.graphics.translate(obj:getX(), obj:getY())
                love.graphics.rotate(obj:getAngle())
                love.graphics.draw(texture)
                love.graphics.pop()
            elseif shapeName == 'Ball' then
                love.graphics.setColor(0.76, 0.18, 0.05) --set the drawing color to red for the ball
                love.graphics.circle("fill", obj:getX(), obj:getY(), fixture:getShape():getRadius())
            elseif shapeName == 'Ground' then
                love.graphics.setColor(config.colors.green)
                love.graphics.polygon("fill", obj:getWorldPoints(fixture:getShape():getPoints()))
            end
        end
    end

    -- for _, point in pairs(self.touchPoints) do
    --     love.graphics.circle('fill', point.x, point.y, 4)
    -- end
    if not self.shaking then
        self.ui:draw()
    end
    -- love.graphics.setColor(0.76, 0.18, 0.05)
end

function beginContact(a, b, coll)
    local aName = a:getUserData().name
    local bName = b:getUserData().name
    if (aName == 'Pillar' or bName == 'Pillar') and (aName == 'Ground' or bName == 'Ground') then
        local pillar, ground = aName == 'Pillar' and a or b, aName == 'Ground' and a or b
        table.insert(state.pillarsToChange, {pillar = pillar:getBody(), ground = ground:getBody(), pos = Vector(coll:getPositions())}) 
    end
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

    if normalimpulse > 750 and not(aName == 'Ball' or bName == 'Ball') then
        local x1, y1,x2, y2 = coll:getPositions()
        local nx, ny = coll:getNormal( )
        -- table.insert(state.touchPoints, Vector(x1, y1)) 
        -- table.insert(state.touchPoints, Vector(x2, y2))

        if aName ~= 'Ground' and not  (aName == 'Pillar' and a:getCategory( ) ~= 4 ) then
            table.insert(state.brokenObjects, {object = a, position = Vector(x1, y1), normal = Vector( nx, ny )}) 
        end
        if bName ~= 'Ground' and not (bName == 'Pillar' and b:getCategory( ) ~= 4 ) then
            table.insert(state.brokenObjects, {object = b, position = Vector(x2, y2), normal = Vector( nx, ny )}) 
        end
    end

    if normalimpulse > 500 and (string.sub(aName,1, -5) == 'Chelovechek' or string.sub(bName,1, -5) == 'Chelovechek') then
        Chelovechek.destroyPart(string.sub(aName,1, -5) == 'Chelovechek' and a or b, state)
    end
end

function state:brakeAllThings()
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

function state:destroyObjects()
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
end

function state:shakeGround( shakeForce, shakeSeed, shakeRound )
    
    for ind, obj in pairs(self.world:getBodies()) do
        for _, fixture in pairs(obj:getFixtures()) do
            if fixture:getUserData().name == 'Ground' then
                local x, y, mass, inertia = fixture:getMassData( )
                obj:applyForce( 0, -(shakeForce * (shakeRound > 2 and 1.5 or 1) ) * math.sin(  shakeSeed * (shakeRound > 1 and x or 1) ))
            end
        end
    end
end

function state:getFinalScore()
    local cx, cy = nil, nil
    for ind, obj in pairs(self.world:getBodies()) do
        for _, fixture in pairs(obj:getFixtures()) do
            if string.sub(fixture:getUserData().name, 1, -5) == 'Chelovechek' then
                cx, cy = obj:getWorldCenter( )
            end
        end
    end
    if cx and cy then
        for ind, obj in pairs(self.world:getBodies()) do
            for _, fixture in pairs(obj:getFixtures()) do
                if fixture:getUserData().name == 'Ground' then
                    local x1, y1, f1 = fixture:rayCast(cx, cy, cx, cy + 1000, 1)
                    if f1 then
                        local r1HitX1 = cx + (cx - cx) * f1
                        local r1HitY1 = cy + ((cy + 1000) - cy) * f1 
                        return Vector(cx - r1HitX1, cy - r1HitY1):len()
                    end
                end
            end
        end
    end
    return 0
end

return state
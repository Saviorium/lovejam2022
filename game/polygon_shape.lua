
local Polygon = Class{
    init = function(self, params)
        local world, position, polygonVertexes, parentObject, image, name = params.world, params.position, params.polygonVertexes, params.parentObject, params.image, params.name
        self.world = world
        if not parentObject then
            self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
            self.shape = love.physics.newPolygonShape(polygonVertexes)
            local texture = self.getTexture(image, {self.shape:getPoints()})
            self.fixture = love.physics.newFixture(self.body, self.shape, 4)
            self.fixture:setMask( 3 )
            self.fixture:setCategory( 2 )
            self.fixture:setUserData({
                name = name or "BlockShape",
                image = image,
                texture = texture,
            })
        else
            local velocity = {}
            velocity.x, velocity.y = parentObject.body:getLinearVelocity()

            self.body = love.physics.newBody(world, parentObject.body:getX(), parentObject.body:getY(), "dynamic")
            self.body:setAngle(parentObject.body:getAngle())
            self.body:setAngularVelocity(parentObject.body:getAngularVelocity())
            self.body:setLinearVelocity(velocity.x, velocity.y)
            self.shape = love.physics.newPolygonShape(polygonVertexes)
            local texture = self.getTexture(image, {self.shape:getPoints()})
            self.fixture = love.physics.newFixture(self.body, self.shape, 4)
            self.fixture:setUserData({
                name = name or "BlockShape",
                image = image,
                texture = texture,
            })
            self.fixture:setMask( 3 )
            self.fixture:setCategory( 2 )
        end
    end,
}

function Polygon.divideOnePolygon(objectShape, rx1, ry1, rx2, ry2)
    local poly1, poly2 = {Vector(rx1, ry1), Vector(rx2, ry2)}, {Vector(rx1, ry1), Vector(rx2, ry2)}

    for _, point in pairs(Utils.verticiesToVectors({objectShape:getPoints()})) do

        local diff1, diff2 = Vector(point.x, point.y) - Vector(rx1, ry1), Vector(point.x, point.y) - Vector(rx2, ry2)
        if not (diff1:len() == 0 and diff2:len() == 0) then

            local test = (rx2-rx1) * (rx2 - point.x) + (ry2-ry1) * (ry2 - point.y)
            local test2 = ((ry2-ry1)/(rx2-rx1)) * (point.x - rx1) - (point.y - ry1)

            if test2 >= 0 then
                table.insert(poly1,Vector(point.x, point.y))
            else
                table.insert(poly2,Vector(point.x, point.y))
            end
        end
    end
    return Utils.vectorsToVerticies(poly1), Utils.vectorsToVerticies(poly2)
end

function Polygon.getTexture(image, polygon)
    if not image then
        return
    end
    local texture = love.graphics.newCanvas(image:getWidth(), image:getHeight())
    texture:renderTo( function()
        local mode, alphamode = love.graphics.getBlendMode( )
        love.graphics.setColor(1,1,1,1)
        love.graphics.polygon("fill", polygon)
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(image)
        love.graphics.setBlendMode(mode, alphamode)
    end)
    return texture
end

function Polygon.splitObject(state, body, startPos, endPos)
    for _, fixture in pairs(body:getFixtures()) do
        local x1, y1, f1 = fixture:rayCast(startPos.x, startPos.y, endPos.x, endPos.y, 1)
        local x2, y2, f2 = fixture:rayCast(endPos.x, endPos.y, startPos.x, startPos.y, 1)
        if f1 and f2 then
            local r1HitX1 = startPos.x + (endPos.x - startPos.x) * f1
            local r1HitY1 = startPos.y + (endPos.y - startPos.y) * f1
            local r1HitX2 = endPos.x + (startPos.x - endPos.x) * f2
            local r1HitY2 = endPos.y + (startPos.y - endPos.y) * f2
            local lrx1, lry1 = body:getLocalPoint( r1HitX1, r1HitY1 )
            local lrx2, lry2 = body:getLocalPoint( r1HitX2, r1HitY2 )
            local vertex1, vertex2 = Polygon.divideOnePolygon(fixture:getShape(), math.floor(lrx1), math.floor(lry1), math.floor(lrx2), math.floor(lry2))

            vardump(Polygon.checkVertexesAndCreatePolygon(state, vertex1, body, fixture))
            vardump(Polygon.checkVertexesAndCreatePolygon(state, vertex2, body, fixture))

            fixture:destroy()
        end
    end
end

function Polygon:draw()
    love.graphics.draw(self.image)
end

function Polygon.checkVertexesAndCreatePolygon(state, vertex, body, fixture)
    local equalVertexes = false
    local onOneLineX, onOneLineY = true, true
    local vectors = Utils.verticiesToVectors(vertex)
    local resultVectors = {}
    for ind1, vec1 in pairs(vectors) do
        equalVertexes = false
        for ind2, vec2 in pairs(vectors) do
            if vec1 == vec2 and ind1 ~= ind2 then
                equalVertexes = true
            end
        end
        if not equalVertexes then
            table.insert(resultVectors, vec1)
        end
    end
    -- local sum = 0
    -- for ind1, vec1 in pairs(resultVectors) do
    --     sum = sum + vec1.x * resultVectors[(ind1+1) < table.getn(resultVectors) and (ind1+1) or 1].y
    --     sum = sum - resultVectors[(ind1+1) < table.getn(resultVectors) and (ind1+1) or 1].x * vec1.y
    --     for ind2, vec2 in pairs(resultVectors) do
    --         if vec1.x ~= vec2.x then
    --             onOneLineX = false
    --         end
    --         if vec1.y ~= vec2.y then
    --             onOneLineY = false
    --         end
    --     end
    -- end

    resultVectors = Utils.vectorsToVerticies(resultVectors)
    if table.getn(resultVectors) > 4 and table.getn(resultVectors) <= 14 then -- and (math.abs(sum/2) > 1) and not (onOneLineX or onOneLineY) then
        local userData = fixture:getUserData()
        return pcall(Polygon, { world = state.world, polygonVertexes = resultVectors, parentObject = {body = body, shape = fixture:getShape()}, image = userData.image, name = fixture:getUserData().name })
    end
    return false
end

return Polygon
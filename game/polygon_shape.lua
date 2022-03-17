local Polygon = Class{
    init = function(self, params)
        local world, position, polygons, parentObject, image, name, mask =
        params.world, params.position, params.polygons, params.parentObject, params.image, params.name, params.mask
        if type(polygons[1]) == "number" then
            polygons = {polygons} -- assume only one polygon passed
        end
        self.world = world
        if not parentObject then
            self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
            self.body:setUserData({
                image = image
            })
            self.parts = self.createParts(self.body, polygons, params)

            self.addTexture(self.body)
        else
            local velocity = {}
            velocity.x, velocity.y = parentObject.body:getLinearVelocity()

            self.body = love.physics.newBody(world, parentObject.body:getX(), parentObject.body:getY(), "dynamic")
            self.body:setAngle(parentObject.body:getAngle())
            self.body:setAngularVelocity(parentObject.body:getAngularVelocity())
            self.body:setLinearVelocity(velocity.x, velocity.y)
            self.body:setUserData({
                image = image
            })
            self.parts = self.createParts(self.body, polygons, params)

            self.addTexture(self.body)
        end
    end,
}

function Polygon.createParts(body, polygons, params)
    local mask = params.mask or {3}
    local name = params.name or "BlockShape"
    local image = params.image

    local parts = {}
    for i, polygonVertices in ipairs(polygons) do
        local part = {}
        part.shape = love.physics.newPolygonShape(polygonVertices)
        part.fixture = love.physics.newFixture(body, part.shape, 4)
        part.fixture:setMask(mask)
        part.fixture:setCategory(2)
        part.fixture:setFriction(0.6)
        part.fixture:setUserData({
            name = name or "BlockShape",
            image = image,
        })
        parts[i] = part
    end
    return parts
end

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

function Polygon.addTexture(body)
    local userData = body:getUserData() or {}
    vardump(userData)
    local texture = Polygon.getTexture(userData.image, body)
    userData.texture = texture
    body:setUserData(userData)
end

function Polygon.getTexture(image, body)
    if not image then
        print("no image!")
        return
    end
    local texture = love.graphics.newCanvas(image:getWidth(), image:getHeight())
    local polygons = {}
    if body then
        for _, fixture in ipairs(body:getFixtures()) do
            table.insert(polygons, { fixture:getShape():getPoints() })
        end
    end
    texture:renderTo( function()
        local mode, alphamode = love.graphics.getBlendMode( )
        love.graphics.setColor(1,1,1,1)
        if #polygons < 1 then
            love.graphics.rectangle("fill", 0, 0, image:getWidth(), image:getHeight())
        else
            for _, polygon in ipairs(polygons) do
                love.graphics.polygon("fill", polygon)
            end
        end
        love.graphics.setBlendMode("multiply", "premultiplied")
        love.graphics.draw(image)
        love.graphics.setBlendMode(mode, alphamode)
    end)
    return texture
end

function Polygon.splitObject(state, body, startPos, endPos)
    local bodyChanged = false
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

            Polygon.checkVertexesAndCreatePolygon(state, vertex1, body, fixture)
            Polygon.checkVertexesAndCreatePolygon(state, vertex2, body, fixture)

            fixture:destroy()
            bodyChanged = true
        end
    end
    if bodyChanged then
        if #body:getFixtures() < 1 then
            body:destroy()
            return
        end
        Polygon.addTexture(body)
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
        return pcall(Polygon, { world = state.world, polygons = resultVectors, parentObject = {body = body, shape = fixture:getShape()}, image = userData.image, name = fixture:getUserData().name })
    end
    return false
end

return Polygon
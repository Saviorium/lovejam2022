
local Polygon = Class{
    init = function(self, params)
    	local world, position, polygonVertexes, parentObject = params.world, params.position, params.polygonVertexes, params.parentObject
        self.world = world
        if not parentObject then
            self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
            self.shape = love.physics.newPolygonShape(polygonVertexes)
            self.fixture = love.physics.newFixture(self.body, self.shape, 2)
            self.fixture:setMask( 3 )
            self.fixture:setCategory( 2 )
            self.fixture:setUserData("Block")
        else
            local velocity = {} 
            velocity.x, velocity.y = parentObject.body:getLinearVelocity()

            self.body = love.physics.newBody(world, parentObject.body:getX(), parentObject.body:getY(), "dynamic")
            self.body:setAngle(parentObject.body:getAngle())
            self.body:setAngularVelocity(parentObject.body:getAngularVelocity())
            self.body:setLinearVelocity(velocity.x, velocity.y)
            self.shape = love.physics.newPolygonShape(polygonVertexes)
            self.fixture = love.physics.newFixture(self.body, self.shape, 2)
            self.fixture:setUserData("BlockShape")
            self.fixture:setMask( 3 )
            self.fixture:setCategory( 2 )
        end
    end, 
}


function Polygon.divideOnePolygon(objectShape, rx1, ry1, rx2, ry2)
    local poly1, poly2 = {Vector(rx1, ry1), Vector(rx2, ry2)}, {Vector(rx1, ry1), Vector(rx2, ry2)}

    for _, point in pairs(verticiesToVectors({objectShape:getPoints()})) do

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
    return vectorsToVerticies(poly1), vectorsToVerticies(poly2)
end


function Polygon:splitObject(body, startPos, endPos)
    local x1, y1, f1 = body:getFixtures()[1]:rayCast(startPos.x, startPos.y, endPos.x, endPos.y, 1)
    local x2, y2, f2 = body:getFixtures()[1]:rayCast(endPos.x, endPos.y, startPos.x, startPos.y, 1)
    if f1 and f2 then
        local r1HitX1 = startPos.x + (endPos.x - startPos.x) * f1
        local r1HitY1 = startPos.y + (endPos.y - startPos.y) * f1
        local r1HitX2 = endPos.x + (startPos.x - endPos.x) * f2
        local r1HitY2 = endPos.y + (startPos.y - endPos.y) * f2
        local lrx1, lry1 = body:getLocalPoint( r1HitX1, r1HitY1 )
        local lrx2, lry2 = body:getLocalPoint( r1HitX2, r1HitY2 )
        local vertex1, vertex2 = Polygon.divideOnePolygon(body:getFixtures()[1]:getShape(), math.floor(lrx1), math.floor(lry1), math.floor(lrx2), math.floor(lry2))

        if table.getn(vertex1) > 4 and table.getn(vertex2) > 4 and table.getn(vertex1) < 14 and table.getn(vertex2) < 14 then
            Polygon({ world = self.world, polygonVertexes = vertex1, parentObject = {body = body, shape = body:getFixtures()[1]:getShape()}})
            Polygon({ world = self.world, polygonVertexes = vertex2, parentObject = {body = body, shape = body:getFixtures()[1]:getShape()}})
        end

        body:destroy()
    end
end

return Polygon
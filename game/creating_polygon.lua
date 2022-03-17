local PolygonShape = require "game.polygon_shape"

local Polygon = Class{
    init = function(self, params)
        local world, position, polygons, state, image, name = params.world, params.position, params.polygons, params.state, params.image, params.name

        if type(polygons[1]) == "number" then
            polygons = {polygons} -- assume only one polygon passed
        end

        self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
        self.body:setFixedRotation( true )

        local parts = {}
        for i, polygonVertices in ipairs(polygons) do
            local part = {}
            part.shape = love.physics.newPolygonShape(polygonVertices)
            part.fixture = love.physics.newFixture(self.body, part.shape, 5) -- A higher density gives it more mass.
            part.fixture:setCategory(3)
            part.fixture:setFriction(0.6)
            part.fixture:setUserData({
                name = name or "BlockShape",
                image = image,
            })
            parts[i] = part
        end
        self.parts = parts

        local texture = PolygonShape.getTexture(image, self.body)
        self.body:setUserData({
            texture = texture,
            image = image,
        })

        local cx, cy = self.body:getLocalCenter()
        state.joint = love.physics.newMouseJoint( self.body, position.x + cx, position.y + cy )
    end,
}

function Polygon:keypressed(key)
    if key == 'e' then
        self.body:setAngle(self.body:getAngle( ) + 15*math.pi/180)
    elseif key == 'q' then
        self.body:setAngle(self.body:getAngle( ) - 15*math.pi/180)
    end
end

return Polygon
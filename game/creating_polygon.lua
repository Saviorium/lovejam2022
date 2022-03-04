local PolygonShape = require "game.polygon_shape"

local Polygon = Class{
    init = function(self, params)
        local world, position, polygonVertexes, state, image = params.world, params.position, params.polygonVertexes, params.state, params.image

        self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
        self.body:setFixedRotation( true )
        -- body:setAngle(30*math.pi/180)
        self.shape = love.physics.newPolygonShape(polygonVertexes)
        local texture = PolygonShape.getTexture(image, {self.shape:getPoints()})
        self.fixture = love.physics.newFixture(self.body, self.shape, 5) -- A higher density gives it more mass.

        self.fixture:setCategory(3)
        self.fixture:setUserData({
            name = "BlockShape",
            image = image,
            texture = texture,
        })

        local cx, cy = self.body:getLocalCenter()
        state.joint = love.physics.newMouseJoint( self.body, position.x + cx, position.y + cy )
    end,
}

function Polygon:keypressed(key)
    if key == 'e' then
        self.body:setAngle(self.body:getAngle( ) + 1*math.pi/180)
    elseif key == 'q' then
        self.body:setAngle(self.body:getAngle( ) - 1*math.pi/180)
    end
end

return Polygon
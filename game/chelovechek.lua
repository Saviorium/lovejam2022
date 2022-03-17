local PolygonShape = require "game.polygon_shape"

local Chelovechek = Class{
    init = function(self, params)
        local world, position, state = params.world, params.position, params.state

        local image = AssetManager:getImage("player")
        self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
        self.body:setFixedRotation( true )
        self.shapeLeg1 = love.physics.newPolygonShape(0,    35, 39,   35, 39,    42 ,  0,   42)
        self.shapeBody = love.physics.newPolygonShape(12,    0, 26,   0, 32,    13,  34,   41, 4, 41, 5,13)
        local texture = PolygonShape.getTexture(image)
        self:fixPart(self.body, self.shapeLeg1, 5, 'Leg1')
        self:fixPart(self.body, self.shapeBody, 5, 'Body')

        self.body:setUserData({
            texture = texture,
        })

        local cx, cy = self.body:getLocalCenter()
        state.joint = love.physics.newMouseJoint( self.body, position.x + cx, position.y + cy )
    end,
}

function Chelovechek:fixPart(body, shape, dens, part)
    self['fixture'..part] = love.physics.newFixture(body, shape, dens) -- A higher density gives it more mass.
    self['fixture'..part]:setCategory(3)
    self['fixture'..part]:setUserData({
        name = "Chelovechek"..part,
    })
end

function Chelovechek.destroyPart(part, state)
	if part:getUserData().name ~= 'ChelovechekBody' then
		part:destroy()
	else
		state.chelovechekDestroyed = true
	end
end


return Chelovechek
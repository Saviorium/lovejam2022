
local Chelovechek = Class{
    init = function(self, params)
    	local world, position, state = params.world, params.position, params.state
        
        self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
        self.body:setFixedRotation( true )
        -- body:setAngle(30*math.pi/180)
        self.shapeLeg1 = love.physics.newPolygonShape(5,    0, 15,   0, 15,    15 ,  5,   15)
        self.shapeLeg2 = love.physics.newPolygonShape(25,   0, 35,   0, 35,    15 ,  25,  15)
        self.shapeBody = love.physics.newPolygonShape(0,    0, 40,   0, 40,    -40,  0,   -40)
        self.shapeHead = love.physics.newPolygonShape(17.5, 0, 22.5, 0, 22.5,  -45,  17.5,-45)
        self:fixPart(self.body, self.shapeHead, 5, 'Head')
        self:fixPart(self.body, self.shapeLeg1, 5, 'Leg1')
        self:fixPart(self.body, self.shapeLeg2, 5, 'Leg2')
        self:fixPart(self.body, self.shapeBody, 5, 'Body')

        local cx, cy = self.body:getLocalCenter()
        state.joint = love.physics.newMouseJoint( self.body, position.x + cx, position.y + cy )
    end, 
}

function Chelovechek:fixPart(body, shape, dens, part)
    self['fixture'..part] = love.physics.newFixture(body, shape, dens) -- A higher density gives it more mass.
    self['fixture'..part]:setCategory(3)
    self['fixture'..part]:setUserData({
                name = "Chelovechek"..part
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
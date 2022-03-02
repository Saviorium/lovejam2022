
local Circle = Class{
    init = function(self, params)
    	local world, position, range, velocity = params.world, params.position, params.range, params.velocity

    	self.body = love.physics.newBody(world, position.x, position.y, "dynamic")
	    self.shape = love.physics.newCircleShape(range)
	    self.fixture = love.physics.newFixture(self.body, self.shape, 6)
	    if velocity and velocity.x and velocity.y then
	        self.body:setLinearVelocity(velocity.x, velocity.y)
	    end
	    self.fixture:setRestitution(0.9) --let the ball bounce
	    self.fixture:setUserData("Ball")
	    self.fixture:setMask( 3 )
	    self.fixture:setCategory( 2 )
    end, 
}

function Circle.dublicateCircle(circle)
    local range = circle:getShape():getRadius()/1.2
    if range > 5 then
        local x, y = circle:getBody():getX(), circle:getBody():getY()
        local world = circle:getBody():getWorld()
        local velocity = {}
        velocity.x, velocity.y = circle:getBody():getLinearVelocity()
        circle:getBody():destroy()

        Circle({world = world, position = {x = x+10, y = y}, range = range, velocity = velocity})
        Circle({world = world, position = {x = x-10, y = y}, range = range, velocity = velocity})
    end
end

return Circle
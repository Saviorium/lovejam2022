local function random(n)
    if n <= 0 then return 0 end
    return love.math.random() * 2 * n - n
end

local Particle = Class {
    init = function(self, type)
        self.type = type
        self.color = {0, 0, 0, 0}
        self.size = 0
        self.position = Vector(0, 0)
        self.prevPosition = Vector(0, 0)
        self.velocity = Vector(0, 0)
        self.alive = false
        self.dieAt = 0
    end
}

function Particle:spawn(position, angleGlobal) -- angle in deg, from up, clockwise
    local time = love.timer.getTime()
    self.dieAt = time + self.type.timeToLive + random(self.type.random.timeToLive)
    self.color[1] = self.type.color[1] + random(self.type.random.color) -- optimisations, reusing...
    self.color[2] = self.type.color[2] + random(self.type.random.color)
    self.color[3] = self.type.color[3] + random(self.type.random.color)
    self.color[4] = self.type.color[4]
    self.size = self.type.size + random(self.type.random.size)
    self.position.x = position.x + random(self.type.random.translate)
    self.position.y = position.y + random(self.type.random.translate)
    self.prevPosition.x = self.position.x
    self.prevPosition.y = self.position.y
    local angleInRad = math.rad(angleGlobal + random(self.type.random.angle))
    self.velocity.x = 1
    self.velocity.y = 0
    self.velocity = self.velocity:rotateInplace(angleInRad) * (self.type.speed + random(self.type.random.speed))
    self.alive = true
end

function Particle:update(dt)
    if not self.alive then
        return
    end
    self.prevPosition.x = self.position.x
    self.prevPosition.y = self.position.y
    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y
    self.velocity.y = self.velocity.y + self.type.gravity
    self.velocity.x = self.velocity.x * self.type.friction
    self.velocity.y = self.velocity.y * self.type.friction
    self.color[1] = self.color[1] + self.type.colorStep[1]
    self.color[2] = self.color[2] + self.type.colorStep[2]
    self.color[3] = self.color[3] + self.type.colorStep[3]
    self.color[4] = self.color[4] + self.type.colorStep[4]
end

function Particle:draw()
    love.graphics.setColor(self.color)
    if self.type.drawType == "rectangle" then
        love.graphics.rectangle(
        'fill',
        self.position.x,
        self.position.y,
        self.size,
        self.size
        )
    elseif self.type.drawType == "line" then
        love.graphics.setLineWidth(self.size)
        love.graphics.line(
        self.position.x,
        self.position.y,
        self.prevPosition.x,
        self.prevPosition.y
        )
    elseif self.type.drawType == "circle" then
        love.graphics.circle(
        'fill',
        self.position.x,
        self.position.y,
        self.size
        )
    end
end

return Particle

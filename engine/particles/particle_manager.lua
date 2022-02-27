local Particle = require "engine.particles.particle"
local function random(n)
    if n <= 0 then return 0 end
    return love.math.random() * 2 * n - n
end

local ParticleManager = Class {
    init = function(self, particleTypes)
        self.particles = {}
        self.drawCache = {}
        for type, particleParams in pairs(particleTypes) do
            self.particles[type] = {
                type = particleParams,
                particles = {},
                emitters = {}, -- { [emitterId][particleName] = {getPositionFunc, getAngleFunc, intensity = number, spawn = number}, }
            }
            if not self.drawCache[particleParams.spawnType] then
                self.drawCache[particleParams.spawnType] = {}
            end
            self.drawCache[particleParams.spawnType][type] = self.particles[type].particles

            if particleParams.targetColor then
                particleParams.colorStep = {
                    (particleParams.targetColor[1] - particleParams.color[1]) / (particleParams.timeToLive * 60),
                    (particleParams.targetColor[2] - particleParams.color[2]) / (particleParams.timeToLive * 60),
                    (particleParams.targetColor[3] - particleParams.color[3]) / (particleParams.timeToLive * 60),
                    (particleParams.targetColor[4] - particleParams.color[4]) / (particleParams.timeToLive * 60)
                }
            else
                particleParams.colorStep = {0,0,0,0}
            end
        end
    end
}

function ParticleManager:addEmitter(emitterId, particleName, getPositionFunc, getAngleFunc)
    self.particles[particleName].emitters[emitterId] = {
        getPositionFunc = getPositionFunc,
        getAngleFunc = getAngleFunc,
        intensity = 0,
        spawn = love.math.random(),
    }
end

function ParticleManager:removeEmitter(emitterId)
    for particleName, particle in pairs(self.particles) do
        if particle.emitters[emitterId] then
            particle.emitters[emitterId] = nil
        end
    end
end

function ParticleManager:setIntensity(emitterId, particleName, value)
    local particlePool = self.particles[particleName].emitters[emitterId]
    if particlePool then
        local maxIntensity = self.particles[particleName].type.maxIntensity
        particlePool.intensity = math.clamp(0, value, maxIntensity)
    end
end

function ParticleManager:spawn(emitterId, particleName, value)
    local particlePool = self.particles[particleName].emitters[emitterId]
    if particlePool then
        local maxIntensity = self.particles[particleName].type.maxIntensity
        particlePool.spawn = particlePool.spawn + math.clamp(0, value, maxIntensity)
    end
end

function ParticleManager:update(dt)
    local time = love.timer.getTime()
    for type, particlesOfType in pairs(self.particles) do
        local particleId = 1
        for _, emitter in pairs(particlesOfType.emitters) do
            local position = emitter:getPositionFunc() -- translate for that emitter
            local angle = emitter:getAngleFunc()
            position = particlesOfType.type.translate:rotated(math.rad(angle)) + position
            angle = angle + particlesOfType.type.angle

            if emitter.intensity > 0 then
                -- converting intensity to number of new particles to spawn
                local intensityRandomness = random(particlesOfType.type.random.intensity)
                local spawnChance = math.max(0, (emitter.intensity + intensityRandomness)/60)
                emitter.spawn = emitter.spawn + spawnChance
            end

            while emitter.spawn > 1 do
                -- spawn new, reuse and update particles in one pass over the particles table
                local particle = particlesOfType.particles[particleId]
                if particleId > particlesOfType.type.maxTotalNum then
                    emitter.spawn = 0
                elseif not particle then
                    local newParticle = Particle(particlesOfType.type)
                    newParticle:spawn(position, angle)
                    newParticle:update(dt)
                    emitter.spawn = emitter.spawn - 1
                    particlesOfType.particles[particleId] = newParticle
                    particleId = particleId + 1
                elseif particle.alive == false then
                    particle:spawn(position, angle)
                    particle:update(dt)
                    emitter.spawn = emitter.spawn - 1
                    particleId = particleId + 1
                else
                    particle:update(dt)
                    if time > particle.dieAt then
                        particle.alive = false
                    end
                    particleId = particleId + 1
                end
            end
        end
        while particleId <= #particlesOfType.particles do -- if there are still particles to update
            local particle = particlesOfType.particles[particleId]
            particle:update(dt)
            if time > particle.dieAt then
                particle.alive = false
            end
            particleId = particleId + 1
        end
    end
end

function ParticleManager:draw(spawnType)
    if not spawnType or not self.drawCache[spawnType] then
        return
    end
    for type, particlesOfType in pairs(self.drawCache[spawnType]) do
        for i, particle in pairs(particlesOfType) do
            if particle.alive then
                particle:draw()
            end
        end
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.setLineWidth(1)
end

return ParticleManager

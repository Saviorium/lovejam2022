local Class = require "lib.hump.class"

local AnimationState = Class {
    init = function(self, name, animator, updateFn, onEnter, onExit)
        self.name = name
        self.animator = animator
        self.update = updateFn
        self.onEnter = onEnter
        self.onExit = onExit
    end
}

local Animator = Class {
    init = function(self)
        self.states = {}
        self.transitions = {} -- self.transitions[from][to] = condition
    end
}

local AnimatorInstance

function Animator.newSimpleVarToTagStateAnimatorInstance(animation)
    local animator = Animator()
        :addSimpleVarToTagState("tagState", "tag")
        :addInstantTransition("_start", "tagState")
    return animator:newInstance(animation)
end

function Animator:newInstance(animation)
    return AnimatorInstance(self, animation)
end

function Animator:addState(state)
    self.states[state.name] = state
    return self
end

function Animator:createSimpleTagState(stateName, tagName)
    if not tagName then
        tagName = stateName
    end
    return AnimationState(
        stateName,
        self,
        nil,
        function(state) state:play(tagName) end,
        nil
    )
end

function Animator:addSimpleTagState(stateName, tagName)
    local state = self:createSimpleTagState(stateName, tagName)
    self:addState(state)
    return self
end

function Animator:createSimpleVarToState(stateName, varName)
    if not varName then
        varName = stateName
    end
    return AnimationState(
        stateName,
        self,
        function (animatorInstance)
            local prevValName = "prev-" .. varName
            local lastVal = animatorInstance:getVariable(prevValName)
            local newVal = animatorInstance:getVariable(varName)
            if newVal ~= lastVal then
                animatorInstance:play(newVal)
                animatorInstance:setVariable(prevValName, newVal)
            end
        end,
        nil,
        nil
    )
end

function Animator:addSimpleVarToTagState(stateName, varName)
    local state = self:createSimpleVarToState(stateName, varName)
    self:addState(state)
    return self
end

function Animator:addInstantTransition(from, to)
    self:addTransition(from, to, function() return true end)
    return self
end

function Animator:addTransitionOnAnimationEnd(from, to, condition)
    if not condition then
        self:addTransition(from, to, function(animator) return animator:isLooped() end)
    else
        self:addTransition(from, to, function(animator) return condition and animator:isLooped() end)
    end
    return self
end

-- from - string or { string, string, ... }
-- special states:
-- *      - any state
-- _start - first transition on init
-- to - string
-- condition - function, returns bool
function Animator:addTransition(from, to, condition)
    if type(from) == "string" or type(from) == "number" then
        from = {from}
    end
    for _, fromState in ipairs(from) do
        if not self.transitions[fromState] then
            self.transitions[fromState] = {}
        end
        self.transitions[fromState][to] = condition
    end
    return self
end

AnimatorInstance = Class {
    init = function(self, animator, animation)
        self.animation = animation
        self.animator = animator
        self.state = nil
        self.variables = {
            flipH = false,
            flipV = false
        }
        self.animationSpeed = 1
        self._isLooped = false
        self.animation:onLoop(function() self._isLooped = true end)
    end
}

function AnimatorInstance:play(tag)
    self.animation:setTag(tag)
    self.animation:play()
end

function AnimatorInstance:setSpeed(speed)
    self.animationSpeed = speed
end

function AnimatorInstance:isLooped()
    return self._isLooped
end

function AnimatorInstance:getWidth()
    return self.animation:getWidth()
end

function AnimatorInstance:getHeight()
    return self.animation:getHeight()
end

function AnimatorInstance:setVariable(key, value)
    self.variables[key] = value
end

function AnimatorInstance:getVariable(key)
    return self.variables[key]
end


function AnimatorInstance:draw(x, y, rot, sx, sy, ox, oy)
    sx = sx or 1
    sy = sy or 1
    ox = ox or 0
    oy = oy or 0
    if self:getVariable("flipH") then
        sx = -sx
        ox = ox + self.animation:getWidth()
    end
    if self:getVariable("flipV") then
        sy = -sy
        oy = oy + self.animation:getHeight()
    end
    self.animation:draw(x, y, rot, sx, sy, ox, oy)
end

function AnimatorInstance:update(dt)
    local currentState = self.state

    local transitionTo
    if currentState then
        transitionTo = self:_checkTransitions(self.animator.transitions["*"])
        if currentState == transitionTo then
            transitionTo = nil
        end
        if not transitionTo then
            transitionTo = self:_checkTransitions(self.animator.transitions[currentState])
        end
    else
        transitionTo = self:_checkTransitions(self.animator.transitions["_start"])
    end
    if transitionTo then
        self:switchToState(transitionTo)
    end

    currentState = self.state
    if currentState and self.animator.states[currentState] and self.animator.states[currentState].update then
        self.animator.states[currentState].update(self, dt)
    end
    self.animation:update(dt*self.animationSpeed)
end

function AnimatorInstance:_checkTransitions(from)
    if not from then
        return nil
    end

    for toState, condition in pairs(from) do
        if condition and condition(self) then
            return toState
        end
    end
    return nil
end

function AnimatorInstance:switchToState(state)
    if self.animator.states[self.state] and self.animator.states[self.state].onExit then
        self.animator.states[self.state].onExit(self)
    end
    self.state = state
    self._isLooped = false
    if Debug and Debug.PrintAnimationEvents then
        print("Switched to animation state: " .. state)
    end
    if self.animator.states[self.state] and self.animator.states[self.state].onEnter then
        self.animator.states[self.state].onEnter(self)
    end
end

return Animator

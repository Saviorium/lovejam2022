local NineSliceSprite = require "engine.ui.nine_slice.nine_slice_sprite"

local NineSliceMultiStatedSprite = Class {
    init = function(self, imageNamePrefix, border, states)
        self.border = border
        self.imageNamePrefix = imageNamePrefix

        states = states or { "up", "hovered", "pushed" }

        self.size = Vector()
        self.sprites = {}
        for _, state in pairs(states) do
            self:addState(state)
        end

        self.currentState = "up"
    end
}

function NineSliceMultiStatedSprite:addState(name)
    local image = AssetManager:getImage(self.imageNamePrefix .. "-" .. name)
    self.sprites[name] = {}
    self.sprites[name].sprite = NineSliceSprite(image, self.border):setSize(self.size.x, self.size.y)
    return self
end

function NineSliceMultiStatedSprite:setSize(width, height)
    self.size.x = width
    self.size.y = height
    for k, v in pairs(self.sprites) do
        v.sprite:setSize(width, height)
    end
    return self
end

function NineSliceMultiStatedSprite:setState(stateName)
    self.currentState = stateName
end

function NineSliceMultiStatedSprite:draw(x, y)
    local sprite = self.sprites[self.currentState]
    sprite.sprite:draw(x, y)
end

return NineSliceMultiStatedSprite

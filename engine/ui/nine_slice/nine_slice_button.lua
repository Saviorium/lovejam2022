local Button = require "engine.ui.button"
local NineSliceButtonBg = require "engine.ui.nine_slice.nine_slice_multi_stated_sprite"

local NineSliceButton = Class {
    __includes = Button,
    init = function(self, parent, parameters)
        Button.init(self, parent, parameters)
        local imagePrefix = parameters.nineSliceImagePrefix
        local border = parameters.nineSliceBorder
        local sprite = NineSliceButtonBg(imagePrefix, border)
            :setSize(self.width, self.height)
        self.nineSliceBg = sprite
        self.isHovered = false
        self.isPushed = false
    end,
}

function NineSliceButton:update(dt)
    if self.isPushed and self.isHovered then
        self.nineSliceBg:setState("pushed")
    elseif self.isHovered then
        self.nineSliceBg:setState("hovered")
    else
        self.nineSliceBg:setState("up")
    end

    Button.update(self, dt)
end

function NineSliceButton:render()
    self.nineSliceBg:draw()
end

return NineSliceButton
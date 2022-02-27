local UIobject = require "engine.ui.uiparents.uiobject"

local NineSliceUiImage = Class {
    __includes = UIobject,
    init = function(self, parent, parameters)
        UIobject.init(self, parent, parameters)
        self.sprite = parameters.nineSliceSprite
        self.sprite:setSize(self.width, self.height)
    end
}

function NineSliceUiImage:render()
	if self.sprite then
        self.sprite:draw()
	end
end

return NineSliceUiImage
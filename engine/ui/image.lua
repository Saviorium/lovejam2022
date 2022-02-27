local UIobject = require "engine.ui.uiparents.uiobject"

local Image = Class {
    __includes = UIobject,
    init = function(self, parent, parameters)
        UIobject.init(self, parent, parameters)
        self.image = parameters.image
        if parameters.animation then
            self.animation = parameters.animation
            self.animation:setTag(parameters.startTag or "Loop")
            self.animation:play()
            -- print(self.tag)
        end

        self.color = parameters.color or {1,1,1,1}
    end
}

function Image:render()
	if self.image then 

		love.graphics.setColor(self.color)

        local width, height = self.image:getDimensions()
        love.graphics.draw(self.image, 0, 0, 0, self.width/width, self.height/height )

		love.graphics.setColor(1,1,1,1)
	elseif self.animation then

        love.graphics.setColor(self.color)

        local width, height = self.animation:getWidth() or self.width, self.animation:getHeight() or self.height
        self.animation:draw(0, 0, 0, self.width/width, self.height/height )

        love.graphics.setColor(1,1,1,1)

    end
end

return Image
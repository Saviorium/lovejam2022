local UIobject = require "engine.ui.uiparents.uiobject"

-- Просто лейбл, для удобства выписывания всякого и для единообразности объектов в UI
local Label = Class {
    __includes = UIobject,
    init = function(self, parent, parameters)
        UIobject.init(self, parent, parameters)
        self.getText = parameters.getText
        self.font = parameters.font
        self.align = parameters.align or 'center'
        self.verticalAlign = parameters.verticalAlign
        self.textColor = parameters.textColor or {1, 1, 1}
        self.outline = parameters.outline or 1
        self.limit = self.width
        self.backGroundOffset = parameters.backGroundOffset or Vector(0,0)
        self:setText(parameters.text or "")
    end
}

function Label:drawBackground()
    if self.background and self.backGroundOffset then
        local width, height = self.background:getDimensions()
        love.graphics.draw(self.background, self.backGroundOffset.x, self.backGroundOffset.y, 0, self.width/width, self.height/height )
    end
end

function Label:update(dt)
    if self.getText then
        self.text = self.getText()
    end
    UIobject.update(self, dt)
end

function Label:render()
    love.graphics.push()
    local locFont
    if self.font then
        locFont = love.graphics.getFont( )
        love.graphics.setFont(self.font)
    end
    if self.scale then
        love.graphics.scale(self.scale, self.scale)
    end
    if self.outline and self.outline > 0 then
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.text, self.outline, 0, self.limit, self.align)
        love.graphics.printf(self.text, 0, self.outline, self.limit, self.align)
        love.graphics.printf(self.text, -self.outline, 0, self.limit, self.align)
        love.graphics.printf(self.text, 0, -self.outline, self.limit, self.align)
    end
    love.graphics.setColor(self.textColor)
    love.graphics.printf(self.text, 0, 0, self.limit, self.align)
    if self.font then
        love.graphics.setFont(locFont)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

function Label:setText(text)
    self.text = text
    if not self.verticalAlign then
        return
    end
    local parentHeight = self.parent.height
    local width = self.font:getWidth(text)
    local lines = math.ceil(width / self.parent.width)
    if width > self.parent.width then
        width = self.parent.width
    end
    local height = self.font:getHeight() * lines
    self.height = height
    local verticalPos = 0
    if self.verticalAlign == "center" then
        verticalPos = parentHeight/2 - height/2
    elseif self.verticalAlign == "down" then
        verticalPos = parentHeight - height
    end
    local x, y = self:getPosition()
    self:moveTo(x, verticalPos)
end

return Label
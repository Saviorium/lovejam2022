
local UIobject = require "engine.ui.uiparents.uiobject"

local ResourceBar =
Class {
    __includes = UIobject,
    init = function(self, parent, parameters)
        UIobject.init(self, parent, parameters)
        self.color = parameters.color
        self.bgColor = parameters.bgColor
        self.getMax = parameters.getMax
        self.max = self.getMax()
        self.getValue = parameters.getValue
        self.borders = parameters.borders or 3
        self.textColor = parameters.textColor or {1, 1, 1}
        self.direction = parameters.direction
    end
}

function ResourceBar:render()

    local leftSpaceInPercents = math.clamp(0, (1 - (self.getValue() / self.max)), 1)

    -- Отрисовка максимального количества ресурса цветом ресурса
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", 0, 0, self.width , self.height)

    -- Отрисовка недостающего кол-ва ресурса цветом бэкграунда полосы
    love.graphics.setColor(self.bgColor)
    local leftWidth = self.width * leftSpaceInPercents
    love.graphics.rectangle("fill",
        self.direction == 'RightToLeft' and self.width - leftWidth or self.borders ,
        self.borders,
        leftWidth > self.borders*2 and (leftWidth - self.borders*2) or 0 ,
        self.height - self.borders*2)

    --- Отрисовка текста поверх ресурса
    -- love.graphics.setColor(self.textColor)
    -- love.graphics.printf(self.tag, self.x + 3, self.y-5, self.height, 'center')
    -- love.graphics.setColor(1, 1, 1)

    self.max = self.getMax()

end

return ResourceBar

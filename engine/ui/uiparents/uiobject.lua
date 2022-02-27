Class = require "lib.hump.class"
-- Абстрактный класс любого атомарного объекта для UI, сожержит зародыши умений объектов, такие как DragAndDrop и Кликабельность, также позиционирование

local UIobject = Class {
    init = function(self, parent, parameters)
        self.parent = parent
        self.tag = parameters.tag

        self.interactions = parameters.interactions or {
            hover   = {},
            click   = {},
            release = {},
            wheel   = {},
            key     = {},
        }

        self.isHovered = false

        self.width = parameters.width or (self.parent and self.parent.width or love.graphics.getWidth())
        self.height = parameters.height or (self.parent and self.parent.height or love.graphics.getHeight())

        self.hidden = parameters.hidden or false
        self.color = parameters.color or {1, 1, 1, 1}
        self.colorBg = parameters.colorBg or parameters.color or self.color

        self.transform = love.math.newTransform()
        self.scale = parameters.scale

        self.objects = parameters.objects or {}
        self.background = parameters.background
        self.cellBackground = parameters.cellBackground
        self.backgroundSize = parameters.backgroundSize
        self.cellBackgroundSize = parameters.cellBackgroundSize

        self.columns = parameters.columns or 1
        self.rows = parameters.rows or 1
        self.margin = parameters.margin or {x = 10, y = 10}
        self.calculatePositionMethods = {
                                            self.calculatePositionWithAlign,
                                            self.calculateRelationalPosition,
                                            self.calculateFixedPosition,
                                        }


        if self.columns > 1 or self.rows > 1 then
            self.cell_width = (self.width - self.margin.x*(self.columns-1))/self.columns
            self.cell_height = (self.height - self.margin.y*(self.rows-1))/self.rows
            for ind = 0, self.columns * self.rows - 1 do
                self:addNewCell(ind)
            end
        end
    end
}

function UIobject:addNewCell(ind)
    local x = (self.cell_width + self.margin.x) * (ind % self.columns)
    local y = (self.cell_height + self.margin.y) * (ind/self.columns - (ind / self.columns)%1)
    self:registerNewObject(ind, {fixedX = x, fixedY = y}, {tag = tostring(ind), width = self.cell_width, height = self.cell_height, background = self.cellBackground, backgroundSize = self.cellBackgroundSize})
end

-- Регистрация объекта в окошке, для его отображения и считывания действий
function UIobject:registerNewObject(index, position, parameters, PresettedUiObject)
    local object
    if (self.rows == 1 and self.columns == 1) or not(position.row and position.column) then
        object = PresettedUiObject and PresettedUiObject(self, parameters) or UIobject(self, parameters)
        self:calculateCoordinatesAndWriteToObject(position, object)
        object.x, object.y = position.x, position.y
        self.objects[index] = {
                                position = position,
                                parameters = parameters,
                                entity = object,
                              }
       
    else
        local row, column = position.row, position.column
        position.row, position.column = nil, nil
        local parentCell = self.objects[ (row - 1) * self.columns + (column - 1) ].entity
        object = PresettedUiObject and PresettedUiObject(parentCell or self, parameters) or UIobject(parentCell or self, parameters)
        self.objects[ (row - 1) * self.columns + (column - 1) ].entity:registerObject(index, position, object)
    end
    return object
end

function UIobject:registerObject(index, position, object)
    if (self.rows == 1 and self.columns == 1) or not(position.row and position.column) then
        self:calculateCoordinatesAndWriteToObject(position, object)
        self.objects[index] = {
                                position = position,
                                parameters = nil,
                                entity = object,
                              }

    else
        local row, column = position.row, position.column
        position.row, position.column = nil, nil
        local ind = (row - 1) * self.columns + (column - 1)
        if self.objects[ind] then
            self.objects[ind].entity:registerObject(index, position, object)
        else
            self:addNewCell(ind)
            self.objects[ind].entity:registerObject(index, position, object)
        end
    end
    return object
end

-- Всем объектам надо уметь понимать случилась ли коллизия, причем не важно с мышкой или чем-то ещё
function UIobject:getCollision(x, y)
    return 	0 < x and
            self.width > x and
            0 < y and
            self.height > y
end

function UIobject:getObjectByIndex(index)
    local result
    for ind, obj in pairs(self.objects) do
        if ind == index then
            result = obj
        else
            if obj.entity.getObjectByIndex and obj.entity:getObjectByIndex(index) then
                result = obj.entity:getObjectByIndex(index) or result
            end
        end
    end
    return result
end

function UIobject:getObjectGlobalPos(index, pos)
    local lPos = pos or Vector(0,0)
    local result
    for ind, obj in pairs(self.objects) do
        if ind == index then
            result = lPos + Vector(obj.position.x, obj.position.y)
            -- print('1',self.tag, obj.entity.tag, lPos)
        else
            local Pos = lPos + Vector(obj.position.x - ( obj.position.align and obj.entity.width/2 or 0),
            obj.position.y - ( obj.position.align and obj.entity.height/2 or 0))

            -- print('2',self.tag, obj.entity.tag, Pos)
            if obj.entity.getObjectGlobalPos then
                result = obj.entity:getObjectGlobalPos(index, Pos) or result
            end
        end
    end
    return result
end

-- Указан отдельный объект чтобы логика указанная в Draw была сквозной, а опциональная была в render
function UIobject:move(dx, dy)
    for ind, obj in pairs(self.parent.objects) do
        if obj.entity.tag == self.tag then
            obj.position.x = obj.position.x + dx
            obj.position.y = obj.position.y + dy
        end
    end
end

function UIobject:moveTo(x, y)
    for ind, obj in pairs(self.parent.objects) do
        if obj.entity.tag == self.tag then
            obj.position.x = x
            obj.position.y = y
        end
    end
end

function UIobject:getPosition()
    for ind, obj in pairs(self.parent.objects) do
        if obj.entity.tag == self.tag then
            return obj.position.x, obj.position.y
        end
    end
end

function UIobject:moveChildTo(tag, toX, toY)
    for ind, obj in pairs(self.objects) do
        if obj.entity.tag == tag then
            obj.position.x = toX
            obj.position.y = toY
        end
    end
end

function UIobject:calculateFixedPosition(position, x, y, object)
    x = position.fixedX or x
    y = position.fixedY or y
    return x, y
end

function UIobject:calculateRelationalPosition(position, x, y, object)
    if position.left or position.right or position.up or position.down then
        x = x + (position.left or 0) + (self.width - (position.right or self.width))
        y = y + (position.up or 0) + (self.height - (position.down or self.height))
    end
    return x, y
end

function UIobject:calculatePositionWithAlign(position, x, y, object)

    if position.align == 'center' then
        x = self.width/2 - object.width/2
        y = self.height/2 - object.height/2
    elseif  position.align == 'right' then
        x = self.width - object.width
        y = self.height/2 - object.height/2
    elseif  position.align == 'left' then
        x = x
        y = self.height/2 - object.height/2
    elseif  position.align == 'up' then
        x = self.width/2 - object.width/2
        y = y
    elseif  position.align == 'down' then
        x = self.width/2 - object.width/2
        y = self.height - object.height
    end
    return x, y
end

function UIobject:calculateCoordinatesAndWriteToObject(position, object)
    position.x, position.y = 0, 0
    for ind, func in pairs(self.calculatePositionMethods) do
        position.x, position.y = func(self, position, position.x, position.y, object)
    end
end

function UIobject:draw()
    if not self.hidden then
        love.graphics.setColor( self.colorBg )
        self:drawBackground()
        love.graphics.setColor( self.color )
        self:render()
        
        for _, object in pairs(self.objects) do
            local transform = self.transform:reset()
            transform = transform:translate(object.position.x,
                                            object.position.y)
            love.graphics.applyTransform( transform )
            object.entity:draw()
            local inverse = transform:inverse()
            love.graphics.applyTransform( inverse )
        end
    end
    if Debug.drawUiDebug then
        self:debugDraw()
    end
end

-- Указан отдельный объект чтобы логика указанная в Draw была сквозной, а опциональная была в render
function UIobject:render()
end

function UIobject:drawBackground()
    if self.background then
        local width, height = self.background:getDimensions()
        local bgWidth, bgHeight = self.backgroundSize and self.backgroundSize.x or self.width, self.backgroundSize and self.backgroundSize.y or self.height
        love.graphics.draw(self.background, 0, 0, 0, bgWidth/width, bgHeight/height )
    end
end

-- Указан отдельный объект чтобы логика указанная в Draw была сквозной, а опциональная была в render
function UIobject:drawCells(color, lineWidth)
    if self.columns <= 1 or self.rows <= 1 then
        return
    end
    love.graphics.setLineWidth( lineWidth )
    love.graphics.setColor( color.r, color.g, color.b, 1 )
    for ind = 0, self.columns * self.rows - 1, 1 do
        local x = (self.cell_width + self.margin.x) * (ind % self.columns)
        local y = (self.cell_height + self.margin.y) * (ind/self.columns - (ind / self.columns)%1)
        love.graphics.rectangle( 'line', x, y, self.cell_width, self.cell_height )
    end
    love.graphics.setLineWidth( 1 )
    love.graphics.setColor( 1, 1, 1, 1 )
end

function UIobject:drawBoxAroundObject(color, lineWidth, x, y)
    local x, y = x and x or 0, y and y or 0
    love.graphics.setColor( color.r, color.g, color.b, 1 )
    love.graphics.setLineWidth( lineWidth )
    love.graphics.rectangle( 'line', x, y, self.width, self.height )
    love.graphics.setLineWidth( 1 )
    love.graphics.setColor( 1, 1, 1, 1 )
end

function UIobject:showOriginalPoint(color)
    love.graphics.setColor( color.r, color.g, color.b, 1 )
    love.graphics.circle( 'fill', 0, 0, 4, 4 )
    love.graphics.setColor( 1, 1, 1, 1 )
end

function UIobject:drawInfoText(color)
    love.graphics.setColor( color.r, color.g, color.b, 1 )
    love.graphics.print( self.tag or "", 4, 4 )
    love.graphics.print( string.format("%dx%d", self.width, self.height), 4, 11  )
    love.graphics.setColor( 1, 1, 1, 1 )
end

function UIobject:debugDraw()
    self:showOriginalPoint({r = 1, g = 0, b = 0 })
    self:drawBoxAroundObject({r = 0, g = 1, b = 0 }, 2)
    self:drawCells({r = 0, g = 0, b = 1 }, 4)
    self:drawInfoText({r = 0, g = 1, b = 0 })
end


function UIobject:getObject(id)
    return self.objects[id].entity
end

function UIobject:update(dt)
    if not self.parent then
        self:handleHoverInteraction()
        self:updateHoverState()
    end
    for _, object in pairs(self.objects) do
        object.entity:update(dt)
    end
end

function UIobject:addInteraction(type, func, isGlobal)
    if isGlobal == nil then
        isGlobal = true
    end
    table.insert(self.interactions[type], { func = func, isGlobal = isGlobal })
    return self
end

-- Interaction called once on change: unhovered -> hovered
-- or on hovered -> unhovered
function UIobject:addHoverInteraction(hoverType, func)
    if hoverType == "hover" then
        self:addInteraction("hover", func, false)
    else
        self:addInteraction("hover", func, true)
    end
    return self
end

-- params = {
--     x, y, key, -- special fields
--     some, value -- custom fields
-- }
function UIobject:handleInteraction(type, params)
    local x = params.x
    local y = params.y
    if not x or not y then
        x, y = love.mouse.getPosition()
    end

    local mouseCollision = self:getCollision(x, y)
    for id, interaction in pairs(self.interactions[type]) do
        if type == "hover" then
            if mouseCollision and not interaction.isGlobal and not self.isHovered then
                -- unhovered -> hovered
                interaction.func(self, params)
            end
            if not mouseCollision and interaction.isGlobal and self.isHovered then
                -- hovered -> unhovered
                interaction.func(self, params)
            end
        else
            if interaction.isGlobal or mouseCollision then
                interaction.func(self, params)
            end
        end
    end

    for ind, object in pairs(self.objects) do
        params.x = x - object.position.x -- mutation, careful
        params.y = y - object.position.y
        local targetObject = object.entity
        targetObject:handleInteraction(type, params)
    end
end

function UIobject:handleHoverInteraction()
    self:handleInteraction("hover", {})
end

function UIobject:updateHoverState(x, y)
    if not x or not y then
        x, y = love.mouse.getPosition()
    end
    local mouseCollision = self:getCollision(x, y)
    self.isHovered = mouseCollision
    for ind, object in pairs(self.objects) do
        local localx = x - object.position.x
        local localy = y - object.position.y
        local targetObject = object.entity
        targetObject:updateHoverState(localx, localy)
    end
end

function UIobject:mousepressed(x, y)
    self:handleInteraction("click", { x = x, y = y })
end

function UIobject:mousereleased(x, y)
    self:handleInteraction("release", { x = x, y = y })
end

function UIobject:wheelmoved(x, y)
    self:handleInteraction("wheel", { wheelX = x, wheelY = y })
end

function UIobject:keypressed(key)
    self:handleInteraction("key", { key = key })
end

return UIobject
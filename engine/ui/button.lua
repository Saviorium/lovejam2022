local UIobject = require "engine.ui.uiparents.uiobject"
local Label = require "engine.ui.label"

local Button = Class {
    __includes = UIobject,
    init = function(self, parent, parameters)
        UIobject.init(self, parent, parameters)
        self.clickCallback = parameters.callback
        self:addInteraction( "release",
            function(btn, params)
                if self.isPushed and self.isHovered then
                    self.clickCallback(btn, params)
                end
            end, false)
        self:addInteraction( "click",
            function()
                self.isPushed = true
                if self.animation then
                    self.animation:setTag('pressed')
                end
            end,
            false)
        self:addInteraction( "release",
            function()
                self.isPushed = false
                if self.animation then
                    self.animation:setTag('unpressed')
                end
            end
        )
        if parameters.hoveredAction then
            self:addHoverInteraction( "hover", parameters.hoveredAction )
        end
        self.isActiveFunction = parameters.isActiveFunction
        self.isActive = true
        self.colors = Utils.mergeAndClone( parameters.colors, self.defaultColors )
        self.currentColor = self.colors.up

        self.animation = parameters.animation
        if self.animation then
            self.animation:setTag('unpressed')
            self.animation:play()
        end

        if parameters.labelText then
            self:registerObject(
                'Label',
                {right = self.width*0.5, up = -self.height*0.25},
                Label(self, {
                    align = parameters.align,
                    font = parameters.font,
                    tag = self.tag..' Label',
                    text = parameters.labelText,
                    width = self.width*0.8,
                    height = self.height*0.8
                })
            )
        end
    end,
    defaultColors = {
        up = {1, 1, 1, 1},
        heldDown = {1, 0, 0, 1},
        hovered = {1, 1, 1, 1},
        disabled = { 0.1, 0.1, 0.1, 1},
    },
}
function Button:update(dt)
    -- if not self.isActive then
    --     self.currentColor = self.colors.disabled
    -- else
    --     if self.holded then
    --         self.currentColor = self.colors.heldDown
    --         self.clickCallback(self)
    --     else
    --         self.currentColor = self.colors.up
    --     end
    -- end

    if self.animation then
        self.animation:update(dt)
    end
    -- if self.Hovered then
    --     if self.animation then
    --         self.animation:setTag('selected')
    --     end
    --     -- self.currentColor = self.colors.hovered
    -- end
    -- if self.isActiveFunction then
    --     self.isActive = self.isActiveFunction(self)
    -- end
    UIobject.update(self, dt)
end

function Button:render()
    if self.animation then
        love.graphics.setColor(self.currentColor)
        local width, height = self.width, self.height
        local lwidth, lheight = self.animation:getWidth(), self.animation:getHeight()
        self.animation:draw(0, 0, 0, width/lwidth, height/lheight)

        love.graphics.setColor(self.defaultColors.up)
    end
end

return Button
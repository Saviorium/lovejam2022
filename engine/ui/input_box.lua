local UIobject = require "engine.ui.uiparents.uiobject"
local utf8 = require "utf8"
local Label = require "engine.ui.label"

local InputBox = Class {
    __includes = UIobject,
    init = function(self, parent, parameters)
        UIobject.init(self, parent, parameters)

        self:addInteraction("click",
        function (obj, params)
            obj.focused = true
        end,
        false)

        self:addInteraction("release",
        function (obj, params)
            if not obj:getCollision(params.x, params.y) then
                obj.focused = false
            end
        end)

        self:registerObject('Field_Name',
                               { left = -self.width*0.55, up = self.height*0.1},
                               Label(self, {tag = 'test_label1', text = self.tag, width = self.width*0.5, height = self.height*0.8 }))
        self:registerObject('Entered_text',
                               { align = 'center' },
                               Label(self, {tag = 'test_label2', text = nvl(parameters.defaultText, ''), width = self.width*0.8, height = self.height*0.8 }))

        self:addInteraction("key",
        function(obj, params)
            if not obj.focused then
                return
            end
            local key = params.key
            local text = obj:getText()
            if obj.serviceButtonPressed and
               (obj.serviceButton == 'lctrl' or obj.serviceButton == 'rctrl') and
               key == 'backspace'
            then
                obj:setText('')
            elseif key == "backspace" then
                local byteoffset = utf8.offset(text, -1)
                if byteoffset then
                    obj:setText(string.sub(text, 1, byteoffset - 1))
                end
            elseif obj.serviceButtonPressed and
                  (obj.serviceButton == 'lctrl' or obj.serviceButton == 'rctrl') and
                   key == 'v'
            then
                obj:setText(love.system.getClipboardText())
            elseif obj.serviceButtonPressed and
                  (obj.serviceButton == 'lctrl' or obj.serviceButton == 'rctrl') and
                   key == 'c'
            then
                love.system.setClipboardText(text)
            elseif string.len(key) == 1 then
                if obj.serviceButtonPressed then
                    obj.serviceButtonPressed = false
                    obj.serviceButton = ''
                else
                    obj:setText(text .. key)
                end
            else
                obj.serviceButtonPressed = true
                obj.serviceButton = key
            end
        end)
    end
}

function InputBox:render()
end

function InputBox:getText()
    return self.objects['Entered_text'].entity.text
end

function InputBox:setText(text)
    self.objects['Entered_text'].entity.text = text
end

return InputBox
local UiObject = require "engine.ui.uiparents.uiobject"
local Button = require "engine.ui.button"
local Label = require "engine.ui.label"
local NineSliceButton = require "engine.ui.nine_slice.nine_slice_button"

local fontsCache = {
    bigFont = function() return fonts.getFont("rusPixelatedMono", 2) end,
    resultWindowText = function() return fonts.getFont("rusPixelatedMono",2) end,
    buttonTexts = function() return fonts.getFont("rusPixelatedMono",1) end,
}

local UI =
    Class {
    __includes = UiObject,
    init = function(self, params)

        UiObject.init(self, nil, {tag = "UI"})

        self.params = params

        self.mainWindow = self:registerNewObject(
            "main_window",
            {	align = 'up'},
            {
                tag = "main_window",
                width = self.width,
            },
            UiObject
        )

        self.mainWindow.drawBackground =
        function(self)
            love.graphics.setColor(0, 0, 0, 0.85)
            love.graphics.rectangle('fill', 0, 0, self.width , self.height)
            love.graphics.setColor(1,1,1)
        end

        local buttonsWidth = self.mainWindow.width * 0.175
        local buttonsHeight = self.mainWindow.height * 0.09
        local sideStep = self.mainWindow.width * 0.4
        self.upStep = self.mainWindow.height * 0.75

        local returnButton = self.mainWindow:registerNewObject(
            'button_to_return_in_game',
            {left = sideStep, up = self.upStep},
            {
                tag = 'button_to_return_in_game',
                callback = function(btn, params)
                    StateManager.switch(states.game)
                end,
                width = buttonsWidth,
                height = buttonsHeight,
                nineSliceImagePrefix = "box-button-dithered",
                nineSliceBorder = Vector(10, 36),
            },
            NineSliceButton
        )
        local resetLabel = returnButton:registerNewObject(
            'button_to_return_in_game_label',
            {
                align = "center", up = returnButton.height * 0.075
            },
            {
                tag = 'button_to_return_in_game_label',
            text = 'Restart',
                font = fontsCache.buttonTexts(),
                height = returnButton.height * 0.5,
                outline = 1,
            },
            Label
        )

        local textHeight = self.height * 0.05
        local marginBetweenStrings = self.height * 0.01
        local textPosFunc = nil


        self.strCount = 0
        for ind, _ in pairs(self.params.text) do
            if ind ~= 'textAlign' then
                self.strCount = self.strCount + 1
            end
        end
        textPosFunc = self.textDrawFromCenter

        for ind, str in pairs(self.params.text) do
            if ind ~= 'textAlign' then
                if type(str) == 'table' then
                    local label = self.mainWindow:registerObject(
                        "end_window_"..ind,
                        {up = textPosFunc(self, textHeight, marginBetweenStrings, ind), left = self.width*0.05},
                        Label(self.mainWindow, {
                            tag = "end_window_"..ind,
                            text = str.str,
                            align = str.align or 'center',
                            height = textHeight,
                            width = self.width*0.9,
                            font = str.font or fontsCache.resultWindowText()
                        })
                    )
                else
                    local label = self.mainWindow:registerObject(
                        "end_window_"..ind,
                        {up = textPosFunc(self, textHeight, marginBetweenStrings, ind), left = self.width*0.05},
                        Label(self.mainWindow, {
                            tag = "end_window_"..ind,
                            text = str,
                            align = 'center',
                            height = textHeight,
                            width = self.width*0.9,
                            font = fontsCache.resultWindowText()
                        })
                    )
                end
            end
        end
    end
}

function UI:textDrawFromUpToDown(textHeight, marginBetweenStrings, ind)
    return textHeight * (ind) + marginBetweenStrings * (ind)
end

function UI:textDrawFromCenter(textHeight, marginBetweenStrings, ind)
    return self.upStep/2 - textHeight * ((self.strCount/2 - (self.strCount/2%1)) - (ind - 1)) + marginBetweenStrings * (ind)
end

return UI

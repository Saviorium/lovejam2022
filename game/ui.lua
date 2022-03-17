local UiObject = require "engine.ui.uiparents.uiobject"
local NewShapeButton = require "game.new_shape_button"
local NineSliceUiImage = require "engine.ui.nine_slice.nine_slice_ui_image"
local NineSliceButton = require "engine.ui.nine_slice.nine_slice_button"
local Label = require "engine.ui.label"
local Chelovechek = require"game.chelovechek"

local images = {
    bgUi = AssetManager:getImage("bg-ui"),
}

local fontsCache = {
    thin = function() return fonts.getFont("rusPixelatedMono") end,
}

return function(state)

    local Ui = UiObject(nil, {
        tag = "main-ui"
     })

    NewShapeButton({Ui = Ui, name = 'Block',
        LabelText = 'Block',
        position = {up = love.graphics.getHeight()*0.1, left = 0},
        state = state,
        polygonVertexes = {0, 0, 68, 0, 68, 36, 0, 36},
        cost = 100, size = {width = love.graphics.getWidth()*0.2, heigth = love.graphics.getHeight()*0.1},
        image = "block-block",
        polygonName = 'Pillar'
    })

    NewShapeButton({Ui = Ui, name = 'Triangle',
        LabelText = 'Triangle',
        position = {up = love.graphics.getHeight()*0.1, left = love.graphics.getWidth()*0.2},
        state = state,
        polygonVertexes = {101, 0, 202, 54, 0, 54},
        cost = 100, size = {width = love.graphics.getWidth()*0.2, heigth = love.graphics.getHeight()*0.1},
        image = "triangle-block",
    })

    NewShapeButton({Ui = Ui, name = 'Column',
        LabelText = 'Pillar',
        position = {up = love.graphics.getHeight()*0.1, left = love.graphics.getWidth()*0.6},
        state = state,
        polygonVertexes = {8, 0, 40, 0, 40, 146, 8, 146},
        cost = 100, size = {width = love.graphics.getWidth()*0.2, heigth = love.graphics.getHeight()*0.1},
        image = "column-block",
        polygonName = 'Pillar'
    })

    local labelError = Ui:registerNewObject(
        "Start-button-label-error",
        {
            align = "up",
            up = love.graphics.getHeight()*0.30,
        },
        {
            align = "center",
            verticalAlign = "center",
            tag =  "Start-button-label-error",
            text = 'First add a character',
            font = fontsCache.thin(),
            width = Ui.width * 0.8,
            outline = 1,
            hidden = true
        },
        Label
    )

    local NewShapeButton = Ui:registerNewObject(
        'Chelovechek-button',
        {up = love.graphics.getHeight()*0.1, left = love.graphics.getWidth()*0.8},
        {
            tag = 'Chelovechek-button',
            callback = function(btn, params)
                if state.chelovechekCreated then
                    state.chelovechekCreated = false
                    state:destroyChelovechek()
                end

                state.joint = nil
                local x, y = love.mouse.getPosition()
                state.creatingBody = Chelovechek({world = state.world,
                    position = {x = x, y = y},
                    state = state})
                state.chelovechekCreated = true     
                labelError.hidden = true           
            end,
            width = love.graphics.getWidth()*0.2,
            height = love.graphics.getHeight()*0.1,
            nineSliceImagePrefix = "box-button-undithered",
            nineSliceBorder = Vector(7, 7),
        },
        NineSliceButton
        )

    local label = NewShapeButton:registerNewObject(
        "Chelovechek-button-label",
        {
            align = "center",
            left = NewShapeButton.width * 0.1,
        },
        {
            align = "left",
            verticalAlign = "center",
            tag =  "Chelovechek-button-label",
            text = 'Player',
            font = fontsCache.thin(),
            width = NewShapeButton.width * 0.8,
            outline = 1
        },
        Label
    )


    local NewShapeButton = Ui:registerNewObject(
        'Start-button',
        {up = love.graphics.getHeight()*0.15, left = love.graphics.getWidth()*0.45},
        {
            tag = 'Start-button',
            callback = function(btn, params)
                if state.chelovechekCreated then
                    state.shaking = true
                    SoundManager:play("earthquake")
                    labelError.hidden = true
                else
                    labelError.hidden = false
                end
            end,
            width = love.graphics.getWidth()*0.1,
            height = love.graphics.getHeight()*0.1,
            nineSliceImagePrefix = "box-button-undithered",
            nineSliceBorder = Vector(7, 7),
        },
        NineSliceButton
        )


    local Startlabel = NewShapeButton:registerNewObject(
        "Start-button-label",
        {
            align = "center",
            left = NewShapeButton.width * 0.1,
        },
        {
            align = "left",
            verticalAlign = "center",
            tag =  "Start-button-label",
            text = 'Start',
            font = fontsCache.thin(),
            width = NewShapeButton.width * 0.8,
            outline = 1,
        },
        Label
    )


    local Scorelabel = Ui:registerNewObject(
            "Score-image",
            {
                align = "up",
            },
            {
                align = "center",
                verticalAlign = "center",
                tag =  "Score-image",
                text = state.pointForBuild,
                getText = function() return state.pointForBuild end,
                font = fontsCache.thin(),
                width = love.graphics.getWidth()*0.25,
                height = love.graphics.getHeight()*0.1,
                outline = 1,
                background = images.bgUi
            },
            Label
        )

    return Ui
end
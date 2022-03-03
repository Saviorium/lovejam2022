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
		LabelText = 'Блок', 
		position = {up = love.graphics.getHeight()*0.1, left = 0}, 
		state = state, 
		polygonVertexes = {0, 0, 100, 0, 100, 50, 0, 50},
		cost = 100, size = {width = love.graphics.getWidth()*0.2, heigth = love.graphics.getHeight()*0.1} })

	NewShapeButton({Ui = Ui, name = 'Triangle',
		LabelText = 'Треугольник', 
		position = {up = love.graphics.getHeight()*0.1, left = love.graphics.getWidth()*0.2}, 
		state = state, 
		polygonVertexes = {0, 0, 50, -50, 100, 0},
		cost = 100, size = {width = love.graphics.getWidth()*0.2, heigth = love.graphics.getHeight()*0.1} })

	NewShapeButton({Ui = Ui, name = 'Column',
		LabelText = 'Колонна', 
		position = {up = love.graphics.getHeight()*0.1, left = love.graphics.getWidth()*0.6}, 
		state = state, 
		polygonVertexes = {0, 0, 20, 0, 20, 100, 0, 100},
		cost = 100, size = {width = love.graphics.getWidth()*0.2, heigth = love.graphics.getHeight()*0.1} })

   
	local NewShapeButton = Ui:registerNewObject(
	    'Chelovechek-button',
	    {up = love.graphics.getHeight()*0.1, left = love.graphics.getWidth()*0.8},
	    {
	        tag = 'Chelovechek-button',
	        callback = function(btn, params)
	        	if not state.chelovechekCreated then
		            state.joint = nil
		            local x, y = love.mouse.getPosition()
		            state.creatingBody = Chelovechek({world = state.world, 
		            	position = {x = x, y = y}, 
		            	state = state})
		            state.chelovechekCreated = true
		        end
	        end,
	        width = love.graphics.getWidth()*0.2,
	        height = love.graphics.getHeight()*0.1,
	        nineSliceImagePrefix = "box-button-dithered",
	        nineSliceBorder = Vector(10, 38),
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
            text = 'Человечек',
            font = fontsCache.thin(),
            width = NewShapeButton.width * 0.8,
            outline = 1,
        },
        Label
    )
    -- local boxImage = Ui:registerNewObject(
    --     "Score-image",
    --     {
    --         align = "up",
    --     },
    --     {
    --         align = "center",
    --         tag = "Score-image",
    --         width = love.graphics.getWidth()*0.25,
    --         height = love.graphics.getHeight()*0.1,
    --         nineSliceSprite = NineSliceSprite(images.box, 18),
    --         nineSliceSprite = NineSliceSprite(images.buttonFrameConfirm, 21),
    --         color = colors.consoleFrame,
    --         background = images.bgUi
    --     },
    --     NineSliceUiImage
    -- )
	local label = Ui:registerNewObject(
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
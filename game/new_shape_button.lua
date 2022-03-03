local UiObject = require "engine.ui.uiparents.uiobject"
local NineSliceButton = require "engine.ui.nine_slice.nine_slice_button"
local Label = require "engine.ui.label"
local CreatingPolygon = require"game.creating_polygon"

local fontsCache = {
    thin = function() return fonts.getFont("rusPixelatedMono") end,
}

return function( params )
	local Ui, 		 LabelText, 	   position, 		state, 		  polygonVertexes, 		  name, 	   size, 		cost  		= 
   		  params.Ui, params.LabelText, params.position, params.state, params.polygonVertexes, params.name, params.size, params.cost  

	local NewShapeButton = Ui:registerNewObject(
    name,
    position, --{down = love.graphics.getHeight()*0.2, left = 0},
    {
        tag = name,
        callback = function(btn, params)
        	if cost and state.pointForBuild > cost then
        		state.pointForBuild = state.pointForBuild - cost
	            state.joint = nil
	            local x, y = love.mouse.getPosition()
	            state.creatingBody = CreatingPolygon({world = state.world, 
	            	position = {x = x, y = y}, 
	            	polygonVertexes = polygonVertexes, 
	            	state = state})
	        end
        end,
        width = size.width or love.graphics.getHeight()*0.1,
        height = size.height or love.graphics.getHeight()*0.1,
        nineSliceImagePrefix = "box-button-dithered",
        nineSliceBorder = Vector(10, 38),
    },
    NineSliceButton
    )

	local label = NewShapeButton:registerNewObject(
	        "Button-label",
	        {
	            align = "center",
	            left = NewShapeButton.width * 0.1,
	        },
	        {
	            align = "left",
	            verticalAlign = "center",
	            tag =  "Button-label",
	            text = LabelText,
	            font = fontsCache.thin(),
	            width = NewShapeButton.width * 0.8,
	            outline = 1,
	        },
	        Label
	    )
	return NewShapeButton
end
local UiObject = require "engine.ui.uiparents.uiobject"
local NewShapeButton = require "game.new_shape_button"

return function(state)

	local Ui = UiObject(nil, {
	    tag = "main-ui"
	 })

	NewShapeButton({Ui = Ui, name = 'Block',
		LabelText = 'Блок', 
		position = {down = love.graphics.getHeight()*0.2, left = 0}, 
		state = state, 
		polygonVertexes = {0, 0, 100, 0, 100, 50, 0, 50} })

	NewShapeButton({Ui = Ui, name = 'Triangle',
		LabelText = 'Треугольник', 
		position = {down = love.graphics.getHeight()*0.2, left = love.graphics.getHeight()*0.2}, 
		state = state, 
		polygonVertexes = {0, 0, 50, -50, 100, 0} })

	NewShapeButton({Ui = Ui, name = 'Column',
		LabelText = 'Колонна', 
		position = {down = love.graphics.getHeight()*0.2, left = love.graphics.getHeight()*0.4}, 
		state = state, 
		polygonVertexes = {0, 0, 20, 0, 20, 100, 0, 100} })
	return Ui
end
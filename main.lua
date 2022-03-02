Vector = require "lib.hump.vector"
Class = require "lib.hump.class"
Utils = require "engine.utils.utils"

require "settings"

prof  = require "lib.jprof.jprof"

StateManager = require "lib.hump.gamestate"

AssetManager = require "engine.utils.asset_manager"
AssetManager:load("data")

-- local SoundData = require "data.sound.sound_data"
-- SoundManager = require "engine.sound.sound_manager" (SoundData)

-- local MusicData = require "data.music.music_data"
-- MusicPlayer = require "engine.sound.music_player" (MusicData)

fonts = require "data.fonts.fonts"

states = {
    game = require "game.states.game",
}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    StateManager.switch(states.game)
    love.keyboard.setKeyRepeat( true )
end

function love.draw()
    love.graphics.setFont(fonts.thin.font)
    StateManager.draw()
    if Debug and Debug.showFps == 1 then
        love.graphics.print(""..tostring(love.timer.getFPS( )), 2, 2)
    end
    if Debug and Debug.mousePos == 1 then
        local x, y = love.mouse.getPosition()
        love.graphics.print(""..tostring(x)..","..tostring(y), 2, 16)
    end
    prof.pop("frame")
end

function love.fixedUpdate(dt)
    prof.push("frame")
    StateManager.update(dt)
end

function love.mousepressed(x, y)
    if StateManager.current().mousepressed then
        StateManager.current():mousepressed(x, y)
    end
end

function love.mousereleased(x, y)
    if StateManager.current().mousereleased then
        StateManager.current():mousereleased(x, y)
    end
end

function love.keypressed(key)
    if StateManager.current().keypressed then
        StateManager.current():keypressed(key)
    end
end

function love.quit()
    prof.write("prof.mpack")
end

function love.resize( w, h )
    if StateManager.current().resize then
        StateManager.current():resize(w, h)
    end
end

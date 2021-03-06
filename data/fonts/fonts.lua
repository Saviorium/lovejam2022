local fonts = {
    thin = {
        -- self-made font drawn by Savioirum, inspired by m3x6, CC BY-SA 4.0
        font = love.graphics.newImageFont(
            "data/fonts/lowres_font.png",
            " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=_+[]{};':»,./<>?\\|*@#$%^&()!АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
        ),
        height = 7,
        width = 4,
        size = 8
    },
    rusPixelatedMono = { file = "data/fonts/vcr_osd_mono_rus.ttf", size = 24, pixelated = true},
    getFont = function(name, scale)
        scale = scale or 1
        local font = love.graphics.newFont(
            fonts[name].file,
            math.clamp(0, math.floor(love.graphics.getWidth()/config.graphics.originalScreenSize.x * fonts[name].size * scale), fonts[name].size * scale)
        )
        if fonts[name].pixelated then
            font:setFilter("nearest", "nearest")
        end
        return font
    end
}

fonts.thin.font:setFilter("nearest", "nearest")

if not config.graphics.originalScreenSize or not(config.graphics.originalScreenSize.x and config.graphics.originalScreenSize.y) then
    config.graphics.originalScreenSize = {}
    config.graphics.originalScreenSize.x = love.graphics.getWidth()
    config.graphics.originalScreenSize.y = love.graphics.getHeight()
end

return fonts

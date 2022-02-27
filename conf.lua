function love.conf(t)
    t.window.width = 1600
    t.window.height = 900
    t.window.title = "lovejam2022"
    t.window.vsync = 1
    t.window.resizable = true
    -- t.window.fullscreen = true
    PROF_CAPTURE = false
end

function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local dt = 0

    local fixedFps = 60
    local minFps = 30
    local framesCount = 0
    local timer = 0
    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Update dt, as we'll be passing it to update
        if love.timer then dt = dt + love.timer.step() end

        timer = timer + love.timer.getDelta()

        -- Call update and draw
        if love.update then love.update(love.timer.getDelta()) end -- will pass 0 if love.timer is disabled

        if dt >= 1/fixedFps then
            if dt > 1/minFps then
                dt = 1/minFps
            end

            framesCount = framesCount + 1
            if timer >= 1 then
                framesCount = 0
                timer = 0
            end

            -- Call update and draw
            if love.fixedUpdate then love.fixedUpdate(dt) end -- will pass 0 if love.timer is disabled

            if love.graphics and love.graphics.isActive() then
                love.graphics.origin()
                love.graphics.clear(love.graphics.getBackgroundColor())

                if love.draw then love.draw() end

                love.graphics.present()
            end

            dt = 0
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

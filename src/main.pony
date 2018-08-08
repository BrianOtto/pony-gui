use "debug"

use sdl = "sdl"
use gfx = "sdl-gfx"

actor Main
    new create(env: Env) =>
        let init = sdl.Init(sdl.INITVIDEO())
        Debug.out("init = ".add(init.string()))
        
        if init != 0 then
            Debug.out("init error")
        end
        
        let window = sdl.CreateWindow("Hello World!", 100, 100, 800, 600, sdl.WINDOWSHOWN())
        Debug.out("window = ".add(window.usize().string()))
        
        if window.is_null() then
        	Debug.out("window error")
        	
        	sdl.Quit()
        end

        let rFlags = sdl.RENDERERACCELERATED() or sdl.RENDERERPRESENTVSYNC()
        let renderer = sdl.CreateRenderer(window, -1, rFlags)
        Debug.out("renderer = ".add(renderer.usize().string()))
        
        if renderer.is_null() then
        	Debug.out("renderer error")
        	
        	sdl.DestroyWindow(window)
        	sdl.Quit()
        end
        
        var event: sdl.Event ref = sdl.Event
        
        while true do
            if sdl.PollEvent(MaybePointer[sdl.Event](event)) > 0 then
                match event.eventType
                | sdl.EVENTQUIT() => break
                end
            end
            
            sdl.SetRenderDrawColor(renderer, 0x00, 0x00, 0xFF, 0xFF)
            sdl.RenderClear(renderer)
            
            let circle = gfx.CircleColor(renderer, 400, 300, 200, 0xFF0000FF)
            // Debug.out("circle = ".add(circle.string()))
            
            sdl.RenderPresent(renderer)
            sdl.Delay(10)
        end
        
        sdl.DestroyRenderer(renderer)
        sdl.DestroyWindow(window)
        
        sdl.Quit()
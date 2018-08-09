use "debug"

use sdl = "sdl"
use gfx = "sdl-gfx"
use ttf = "sdl-ttf"

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
        
        let initTTF = ttf.Init()
        Debug.out("initTTF = ".add(initTTF.string()))
        
        if initTTF == -1 then
            Debug.out("init ttf error = ".add(String.from_cstring(ttf.GetError())))
        	
        	sdl.DestroyWindow(window)
        	sdl.Quit()
        end
        
        let font = ttf.OpenFont("res/fonts/OpenSans/OpenSans-Regular.ttf", 24)
        Debug.out("font = ".add(font.usize().string()))
        
        if font.is_null() then
            Debug.out("font error = ".add(String.from_cstring(ttf.GetError())))
        	
        	ttf.Quit()
        	
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
            
            var color = sdl.Color
            color.r = 0x00
            color.g = 0xFF
            color.b = 0x00
            color.a = 0xFF
            
            // TODO: Why is the color changing!!
            
            let surface = ttf.RenderTextSolid(font, "Hello TTF!", color)
            
            if surface.is_null() then
                Debug.out("ttf surface error = ".add(String.from_cstring(ttf.GetError())))
        	    
            	ttf.Quit()
            	
            	sdl.DestroyWindow(window)
            	sdl.Quit()
            end
            
            let texture = sdl.CreateTextureFromSurface(renderer, surface)
            sdl.FreeSurface(surface)
            
            var rectangle = sdl.Rect
            rectangle.x = 10
            rectangle.y = 10
            
            @SDL_QueryTexture[U32](texture, Pointer[U32], Pointer[I32], addressof rectangle.w, addressof rectangle.h)
            // Debug.out("rect w = ".add(rectangle.w.string()))
            // Debug.out("rect h = ".add(rectangle.h.string()))
            
            sdl.RenderCopy(renderer, texture, Pointer[sdl.Rect], MaybePointer[sdl.Rect](rectangle))
            sdl.RenderPresent(renderer)
            
            sdl.Delay(1000)
        end
        
        ttf.CloseFont(font)
        ttf.Quit()
        
        sdl.DestroyRenderer(renderer)
        sdl.DestroyWindow(window)
        
        sdl.Quit()
use "debug"

use sdl = "sdl"
use gfx = "sdl-gfx"
use img = "sdl-image"
use ttf = "sdl-ttf"

class App
    var out: Env
    
    var gui: Array[GuiRow] = Array[GuiRow]
    
    var initSDL: U32 = 0
    var initIMG: I32 = 0
    var initTTF: U32 = 0
    
    var window: Pointer[sdl.Window] = Pointer[sdl.Window]
    var renderer: Pointer[sdl.Renderer] = Pointer[sdl.Renderer]
    
    new create(env: Env) =>
        out = env
    
    fun ref init()? =>
        // load our GUI
        
        Gui(this).load()?
        
        // initialize SDL
        
        initSDL = sdl.Init(sdl.INITVIDEO())
        Debug.out("initSDL = " + initSDL.string())
        
        if initSDL != 0 then
            logAndExit("init sdl error")?
        end
        
        // create our window
        
        let windowW: I32 = 800
        let windowH: I32 = 600
        
        let wFlags = sdl.WINDOWSHOWN() // or sdl.WINDOWRESIZABLE()
        window = sdl.CreateWindow("Pony GUI", 100, 100, windowW, windowH, wFlags)
        Debug.out("window = " + window.usize().string())
        
        if window.is_null() then
        	logAndExit("create window error")?
        end
        
        // create our renderer
        
        let rFlags = sdl.RENDERERACCELERATED() or sdl.RENDERERPRESENTVSYNC()
        renderer = sdl.CreateRenderer(window, -1, rFlags)
        Debug.out("renderer = " + renderer.usize().string())
        
        if renderer.is_null() then
        	logAndExit("create renderer error")?
        end
        
        // initialize SDL Image
        
        let iFlags = img.INITJPG() or img.INITPNG()
        initIMG = img.Init(iFlags)
        Debug.out("initIMG = " + initIMG.string())
        
        if initIMG == 0 then
            logAndExit("init img error")?
        end
        
        if ((initIMG and iFlags) != iFlags) then
            logAndExit("init img flags error")?
        end
        
        // load our image
        
        let image = img.Load("sample.png")
        
        if image.is_null() then
            logAndExit("load image error")?
        end
        
        let textIMG = sdl.CreateTextureFromSurface(renderer, image)
        sdl.FreeSurface(image)
        
        var rectIMG = sdl.Rect
        
        sdl.QueryTexture(textIMG, Pointer[U32], Pointer[I32], rectIMG)
        
        rectIMG.x = (windowW - rectIMG.w) / 2
        rectIMG.y = (windowH - rectIMG.h) / 2
        
        // initialize SDL TTF
        
        initTTF = ttf.Init()
        Debug.out("initTTF = " + initTTF.string())
        
        if initTTF != 0 then
            logAndExit("init ttf error")?
        end
        
        // load our font
        
        let font = ttf.OpenFont("OpenSans-Regular.ttf", 32)
        Debug.out("font = " + font.usize().string())
        
        if font.is_null() then
            logAndExit("load font error")?
        end
        
        let surfaceTTF = ttf.RenderTextBlended(font, "Pony GUI", 0x030307)
        
        if surfaceTTF.is_null() then
            logAndExit("font surface error")?
    	end
        
        let textTTF = sdl.CreateTextureFromSurface(renderer, surfaceTTF)
        sdl.FreeSurface(surfaceTTF)
        
        var rectTTF = sdl.Rect
        
        sdl.QueryTexture(textTTF, Pointer[U32], Pointer[I32], rectTTF)
        
        rectTTF.x = (windowW - rectTTF.w) / 2
        rectTTF.y = (300 - 200 - rectTTF.h) / 2
        
        // event polling
        
        var event: sdl.Event ref = sdl.Event
        
        while true do
            if sdl.PollEvent(MaybePointer[sdl.Event](event)) > 0 then
                match event.eventType
                | sdl.EVENTQUIT() => break
                end
            end
            
            // set our background color
            sdl.SetRenderDrawColor(renderer, 0x31, 0x3D, 0x78, 0xFF)
            
            // remove all drawn items
            sdl.RenderClear(renderer)
            
            // draw our circle (with an anti-aliased edge)
            gfx.FilledCircleRGBA(renderer, 400, 300, 200, 0x47, 0x58, 0xAE, 0xFF)
            gfx.AACircleRGBA(renderer, 400, 300, 200, 0x47, 0x58, 0xAE, 0xFF)
            
            // draw our image
            sdl.RenderCopy(renderer, textIMG, Pointer[sdl.Rect], MaybePointer[sdl.Rect](rectIMG))
            
            // draw our text
            sdl.RenderCopy(renderer, textTTF, Pointer[sdl.Rect], MaybePointer[sdl.Rect](rectTTF))
            
            // display everything
            sdl.RenderPresent(renderer)
        end
        
        ttf.CloseFont(font)
        
        logAndExit()?
    
    fun ref logAndExit(msg: String = "", isSDL: Bool = true)? =>
        if initTTF == 0 then
            ttf.Quit()
        end
        
        if initIMG > 0 then
            img.Quit()
        end
        
        if not renderer.is_null() then
            sdl.DestroyRenderer(renderer)
        end
        
        if not window.is_null() then
            sdl.DestroyWindow(window)
        end
        
        if initSDL == 0 then
            sdl.Quit()
        end
        
        if msg != "" then
            if isSDL then
                msg.add(" = " + String.from_cstring(sdl.GetError()))
            end
            
            out.out.print(msg)
        end
        
        out.exitcode(1)
        
        error
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
    
    var elements: Array[RenderElement] = Array[RenderElement]
    
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
        
        // initialize SDL TTF
        
        initTTF = ttf.Init()
        Debug.out("initTTF = " + initTTF.string())
        
        if initTTF != 0 then
            logAndExit("init ttf error")?
        end
        
        var hTotal: I32 = 0
        var wTotal: I32 = 0
        
        let guiRows = gui.values()
        
        while guiRows.has_next() do
            let guiRow = guiRows.next()?
            let guiCols = guiRow.cols.values()
            
            let h: I32 = (windowH.f32() * guiRow.height).i32()
            
            wTotal = 0
            
            while guiCols.has_next() do
                let guiCol = guiCols.next()?
                let guiElements = guiCol.elements.values()
                
                let w: I32 = (windowW.f32() * guiCol.width).i32()
                
                while guiElements.has_next() do
                    let guiElement = guiElements.next()?
                    var texture = Pointer[sdl.Texture]
                    
                    match guiElement.command
                    | "load" =>
                        let src = guiElement.properties("src")?
                        
                        match guiElement.properties("media")?
                        | "image" =>
                            // load our image
                            let image = img.Load(src)
                            
                            if image.is_null() then
                                logAndExit("load image error")?
                            end
                            
                            texture = sdl.CreateTextureFromSurface(renderer, image)
                            sdl.FreeSurface(image)
                        end
                    | "text" =>
                        let fontName = guiElement.properties("font")?
                        let fontSize = guiElement.properties("font-size")?.i32()?
                        
                        // convert to a hexadecimal string
                        var fontColorAsString = "0x" + guiElement.properties("font-color")?
                        
                        // default to 0 for any missing RGBA values
                        while fontColorAsString.size() < 10 do
                            fontColorAsString = fontColorAsString + "0"
                        end
                        
                        // convert to a unsigned integer
                        let fontColor = try fontColorAsString.u32()? else 0 end
                        
                        // load our font
                        
                        let font = ttf.OpenFont(fontName, fontSize)
                        Debug.out("font = " + font.usize().string())
                        
                        if font.is_null() then
                            logAndExit("load font error")?
                        end
                        
                        let fontSurface = ttf.RenderUTF8Blended(font, guiElement.properties("value")?, fontColor)
                        
                        if fontSurface.is_null() then
                            logAndExit("font surface error")?
                    	end
                        
                        texture = sdl.CreateTextureFromSurface(renderer, fontSurface)
                        sdl.FreeSurface(fontSurface)
                        
                        ttf.CloseFont(font)
                    end
                    
                    let rect = _getRect(texture, guiElement, w, h, wTotal, hTotal)?
                    elements.push(RenderElement(texture, rect))
                end
                
                wTotal = wTotal + w
            end
            
            hTotal = hTotal + h
        end
        
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
            
            let re = elements.values()
            
            while re.has_next() do
                let element = re.next()?
                sdl.RenderCopy(renderer, element.texture, Pointer[sdl.Rect], MaybePointer[sdl.Rect](element.rect))
            end
            
            // display everything
            sdl.RenderPresent(renderer)
        end
        
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
    
    fun ref _getRect(texture: Pointer[sdl.Texture], guiElement: GuiElement, 
                     w: I32, h: I32, wTotal: I32, hTotal: I32): sdl.Rect ? =>
        
        let rect = sdl.Rect
        
        sdl.QueryTexture(texture, Pointer[U32], Pointer[I32], rect)
        
        if guiElement.properties.contains("x") then
            let guiElementX = guiElement.properties("x")?
            
            if guiElementX == "center" then
                rect.w = if rect.w > w then w else rect.w end
                rect.x = wTotal + ((w - rect.w) / 2)
            else
                rect.x = wTotal + try guiElementX.i32()? else 0 end
            end
        end
        
        if guiElement.properties.contains("y") then
            let guiElementY = guiElement.properties("y")?
            
            if guiElementY == "center" then
                rect.h = if rect.h > h then h else rect.h end
                rect.y = hTotal + ((h - rect.h) / 2)
            else
                rect.y = hTotal + try guiElementY.i32()? else 0 end
            end
        end
        
        rect
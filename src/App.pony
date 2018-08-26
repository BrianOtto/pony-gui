use "debug"

use sdl = "sdl"
use gfx = "sdl-gfx"
use img = "sdl-image"
use ttf = "sdl-ttf"

class App
    var out: Env
    
    var initSDL: U32 = 0
    var initIMG: I32 = 0
    var initTTF: U32 = 0
    
    var window: Pointer[sdl.Window] = Pointer[sdl.Window]
    var windowTitle: String = ""
    var windowW: I32 = 1280
    var windowH: I32 = 720
    
    var renderer: Pointer[sdl.Renderer] = Pointer[sdl.Renderer]
    
    var gui: Array[GuiRow] = Array[GuiRow]
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
        
        let wFlags = sdl.WINDOWSHOWN() // or sdl.WINDOWRESIZABLE()
        window = sdl.CreateWindow(windowTitle, 100, 100, windowW, windowH, wFlags)
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
                    
                    var callbacks: Array[{ref (): Any val}] = []
                    var texture = Pointer[sdl.Texture]
                    
                    match guiElement.command
                    | "draw" =>
                        match guiElement.properties("shape")?
                        | "circle" =>
                            var x: I32 = 0
                            var y: I32 = 0
                            
                            // TODO: allow radius to be specified as a percentage of w / h (e.g "1/3")
                            var radius: I32 = try guiElement.properties("radius")?.i32()? else 0 end
                            radius = if radius > w then w else radius end
                            radius = if radius > h then h else radius end
                            
                            if guiElement.properties.contains("x") then
                                let guiElementX = guiElement.properties("x")?
                                
                                if guiElementX == "center" then
                                    x = wTotal + ((w - (radius * 2)) / 2) + radius
                                else
                                    x = wTotal + try guiElementX.i32()? else 0 end
                                end
                            end
                            
                            if guiElement.properties.contains("y") then
                                let guiElementY = guiElement.properties("y")?
                                
                                if guiElementY == "center" then
                                    y = hTotal + ((h - (radius * 2)) / 2) + radius
                                else
                                    y = hTotal + try guiElementY.i32()? else 0 end
                                end
                            end
                            
                            let antiAliased: Bool = try
                                if guiElement.properties("anti-aliased")? == "1" then true else false end
                            else
                                true // default to true
                            end
                            
                            let border: Bool = try
                                if guiElement.properties("border")? == "1" then true else false end
                            else
                                true // default to true
                            end
                            
                            var borderColor: U32 = 0
                            
                            if border and guiElement.properties.contains("border-color") then
                                // convert to a hexadecimal string
                                var borderColorAsString = "0x" + try guiElement.properties("border-color")? else "" end
                                
                                // default to 0 for any missing RGB values
                                while borderColorAsString.size() < 10 do
                                    borderColorAsString = borderColorAsString + 
                                        if borderColorAsString.size() < 8 then "0" else "F" end
                                end
                                
                                // convert to a unsigned integer
                                borderColor = try borderColorAsString.u32()? else 0 end
                            end
                            
                            if guiElement.properties.contains("fill") then
                                // convert to a hexadecimal string
                                var fillAsString = "0x" + try guiElement.properties("fill")? else "" end
                                
                                // default to 0 for any missing RGB values
                                while fillAsString.size() < 10 do
                                    fillAsString = fillAsString + 
                                        if fillAsString.size() < 8 then "0" else "F" end
                                end
                                
                                // convert to a unsigned integer
                                let fill = try fillAsString.u32()? else 0 end
                                
                                if antiAliased and not guiElement.properties.contains("border-color") then
                                    borderColor = fill
                                end
                                
                                callbacks.push(
                                    gfx.FilledCircleColor~apply(renderer, x.i16(), y.i16(), radius.i16(), fill)
                                )
                            end
                            
                            if antiAliased then
                                callbacks.push(
                                    gfx.AACircleColor~apply(renderer, x.i16(), y.i16(), radius.i16(), borderColor)
                                )
                            else
                                callbacks.push(
                                    gfx.CircleColor~apply(renderer, x.i16(), y.i16(), radius.i16(), borderColor)
                                )
                            end
                        end
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
                        var fontColorAsString = "0x" + try guiElement.properties("font-color")? else "" end
                        
                        // default to 0 for any missing RGB values
                        while fontColorAsString.size() < 10 do
                            fontColorAsString = fontColorAsString + 
                                if fontColorAsString.size() < 8 then "0" else "F" end
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
                    
                    let re = RenderElement
                    
                    if callbacks.size() > 0 then
                        re.callbacks = callbacks
                    end
                    
                    if not texture.is_null() then
                        re.texture = texture
                        re.rect = _getRect(texture, guiElement, w, h, wTotal, hTotal)?
                    end
                    
                    elements.push(re)
                end
                
                wTotal = wTotal + w
            end
            
            hTotal = hTotal + h
        end
        
        // event polling
        
        var poll = true
        while poll do
            var more: I32 = 1
            while more > 0 do
                sdl.PumpEvents()
                
                var peek: sdl.CommonEvent ref = sdl.CommonEvent
                sdl.PeekEvent(MaybePointer[sdl.CommonEvent](peek))
                
                match peek.eventType
                | sdl.EVENTMOUSEMOTION() =>
                    var event: sdl.MouseMotionEvent ref = sdl.MouseMotionEvent
                    more = sdl.PollMouseMotionEvent(MaybePointer[sdl.MouseMotionEvent](event))
                    
                    Debug.out("x = " + event.x.string())
                    Debug.out("y = " + event.y.string())
                | sdl.EVENTQUIT() =>
                    more = 0
                    poll = false
                else
                    var event: sdl.CommonEvent ref = sdl.CommonEvent
                    more = sdl.PollCommonEvent(MaybePointer[sdl.CommonEvent](event))
                end
            end
            
            // set our background color
            sdl.SetRenderDrawColor(renderer, 0x31, 0x3D, 0x78, 0xFF)
            
            // remove all drawn items
            sdl.RenderClear(renderer)
            
            let re = elements.values()
            
            while re.has_next() do
                let element = re.next()?
                
                if not element.texture.is_null() then
                    sdl.RenderCopy(renderer, element.texture, Pointer[sdl.Rect], MaybePointer[sdl.Rect](element.rect))
                end
                
                let cb = element.callbacks.values()
                
                while cb.has_next() do
                    cb.next()?()
                end
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
use "collections"
use "debug"

use sdl = "sdl"
use img = "sdl-image"
use ttf = "sdl-ttf"

class App
    var out: Env
    
    var gui: Array[GuiRow] = Array[GuiRow]
    var elements: Array[RenderElement] = Array[RenderElement]
    var events: Map[String, Array[GuiEvent]] = Map[String, Array[GuiEvent]]
    
    var initSDL: U32 = 0
    var initIMG: I32 = 0
    var initTTF: U32 = 0
    
    var window: Pointer[sdl.Window] = Pointer[sdl.Window]
    var windowTitle: String = ""
    var windowW: I32 = 1280
    var windowH: I32 = 720
    
    var renderer: Pointer[sdl.Renderer] = Pointer[sdl.Renderer]
    
    new create(env: Env) =>
        out = env
    
    fun ref init()? =>
        // load our gui and events
        Gui(this).load()?
        
        // initialize our libraries
        // and create our window and renderer
        _initLibraries()?
        
        // render our elements 
        // and their events
        Render(this).load()?
        
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
                    
                    if events.contains("over") then
                        let guiEvents = events("over")?.values()
                        let renderElements = elements.values()
                        
                        while guiEvents.has_next() do
                            var ge = guiEvents.next()?
                            
                            while renderElements.has_next() do
                                var re = renderElements.next()?
                                
                                if ge.id == re.id then
                                    if (event.x >= re.rect.x) and
                                       (event.x <= (re.rect.x + re.rect.w)) and
                                       (event.y >= re.rect.y) and
                                       (event.y <= (re.rect.y + re.rect.h)) then
                                        
                                        let commands = ge.commands.values()
                                        
                                        while commands.has_next() do
                                            var command = commands.next()?
                                            
                                            var reEvent = try re.events(command.eventId)? else continue end
                                            var when = false
                                            
                                            if not re.data.contains(command.whenVar) then
                                                re.data.insert(command.whenVar, "0")?
                                            end
                                            
                                            if re.data(command.whenVar)? == command.whenVal then
                                                when = true
                                            end
                                            Debug(command.whenVar+"="+re.data(command.whenVar)?)
                                            if when and (reEvent.texture != re.texture) then
                                                re.textureLast = re.texture
                                                re.rectLast = re.rect
                                                
                                                re.texture = reEvent.texture
                                                re.rect = reEvent.rect
                                            end
                                        end
                                    else
                                        // over is always a temporary change in style
                                        // TODO: add an out command instead and use it when it exists
                                        if not re.textureLast.is_null() then
                                            re.texture = re.textureLast
                                            re.rect = re.rectLast
                                        end
                                    end
                                end
                            end
                        end
                    end
                | sdl.EVENTMOUSEBUTTONUP() =>
                    var event: sdl.MouseButtonEvent ref = sdl.MouseButtonEvent
                    more = sdl.PollMouseButtonEvent(MaybePointer[sdl.MouseButtonEvent](event))
                    
                    Debug.out("clicks = " + event.clicks.string())
                    
                    if events.contains("click") then
                        let guiEvents = events("click")?.values()
                        let renderElements = elements.values()
                        
                        while guiEvents.has_next() do
                            var ge = guiEvents.next()?
                            
                            while renderElements.has_next() do
                                var re = renderElements.next()?
                                
                                if ge.id == re.id then
                                    if (event.x >= re.rect.x) and
                                       (event.x <= (re.rect.x + re.rect.w)) and
                                       (event.y >= re.rect.y) and
                                       (event.y <= (re.rect.y + re.rect.h)) then
                                       
                                        let commands = ge.commands.values()
                                        
                                        while commands.has_next() do
                                            var command = commands.next()?
                                            
                                            var when = false
                                            
                                            if not re.data.contains(command.whenVar) then
                                                re.data.insert(command.whenVar, "0")?
                                            end
                                            
                                            if re.data(command.whenVar)? == command.whenVal then
                                                when = true
                                            end
                                            
                                            if command.command == "set" then
                                                if when then
                                                    if re.data.contains(command.dataVar) then
                                                        re.data.update(command.dataVar, command.dataVal)
                                                    else
                                                        re.data.insert(command.dataVar, command.dataVal)?
                                                    end
                                                else
                                                    if re.data.contains(command.elseVar) then
                                                        re.data.update(command.elseVar, command.elseVal)
                                                    else
                                                        re.data.insert(command.elseVar, command.elseVal)?
                                                    end
                                                end
                                            end
                                            
                                            if command.command == "run" then
                                                var reEvent = RenderElement
                                                reEvent = try re.events(command.eventId)? else continue end
                                                
                                                // click is always a permanent change in style
                                                if when then
                                                    re.textureLast = re.texture
                                                    re.rectLast = re.rect
                                                    
                                                    re.texture = reEvent.texture
                                                    re.rect = reEvent.rect
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
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
    
    fun ref _initLibraries()? =>
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
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
    
    fun ref init() ? =>
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
                    
                    var elementsByEvent = _getElementsByEvent("over")?
                    var reEvents = elementsByEvent.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                           (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h)) then
                           
                           Debug.out("over")
                           
                           // TODO: add support for a "cursor" property
                           sdl.SetCursor(sdl.CreateSystemCursor(sdl.CURSORHAND()))
                           
                           _runEventCommands(ge, re)?
                        end
                    end
                    
                    elementsByEvent = _getElementsByEvent("out")?
                    reEvents = elementsByEvent.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x < re.rect.x) or (event.x > (re.rect.x + re.rect.w)) or
                           (event.y < re.rect.y) or (event.y > (re.rect.y + re.rect.h)) then
                           
                           Debug.out("out")
                           
                           // TODO: add support for a "cursor" property
                           sdl.SetCursor(sdl.CreateSystemCursor(sdl.CURSORARROW()))
                           
                           _runEventCommands(ge, re)?
                        end
                    end
                | sdl.EVENTMOUSEBUTTONUP() =>
                    var event: sdl.MouseButtonEvent ref = sdl.MouseButtonEvent
                    more = sdl.PollMouseButtonEvent(MaybePointer[sdl.MouseButtonEvent](event))
                    
                    Debug.out("x = " + event.x.string())
                    Debug.out("y = " + event.y.string())
                    
                    let elementsByEvent = _getElementsByEvent("click")?
                    let reEvents = elementsByEvent.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                           (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h)) then
                           
                           Debug.out("click")
                           
                           _runEventCommands(ge, re)?
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
    
    fun ref _initLibraries() ? =>
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
    
    fun ref _getElementsByEvent(eventType: String): Array[(GuiEvent, RenderElement)] ? =>
        var elementsByEvent: Array[(GuiEvent, RenderElement)] = []
        
        if events.contains(eventType) then
            let guiEvents = events(eventType)?.values()
            let renderElements = elements.values()
            
            while guiEvents.has_next() do
                let ge = guiEvents.next()?
                
                while renderElements.has_next() do
                    let re = renderElements.next()?
                    
                    if ge.id == re.id then
                        elementsByEvent.push((ge, re))
                    end
                end
            end
        end
        
        elementsByEvent
    
    fun ref _runEventCommands(ge: GuiEvent, re: RenderElement) ? =>
        let commands = ge.commands.values()
        
        while commands.has_next() do
            let command = commands.next()?
            var when = false
            
            if not re.data.contains(command.whenVar) then
                re.data.insert(command.whenVar, "0")?
            end
            
            if re.data(command.whenVar)? == command.whenVal then
                when = true
            end
            
            match command.command
            | "set" =>
                if when then
                    Debug.out("set " + command.dataVar + " = " + command.dataVal)
                    re.data.update(command.dataVar, command.dataVal)
                else
                    Debug.out("set " + command.elseVar + " = " + command.elseVal)
                    re.data.update(command.elseVar, command.elseVal)
                end
            | "run" =>
                var reEvent = RenderElement
                reEvent = try re.events(command.eventId)? else continue end
                
                if when then
                    re.texture = reEvent.texture
                    re.rect = reEvent.rect
                end
            end
        end
    
    fun ref logAndExit(msg: String = "", isSDL: Bool = true) ? =>
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
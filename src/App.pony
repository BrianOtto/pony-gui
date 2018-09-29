use "collections"
use "crypto"
use "debug"
use "time"

use sdl = "sdl"
use img = "sdl-image"
use ttf = "sdl-ttf"

class App
    var out: Env
    
    var gui: Array[GuiRow] = Array[GuiRow]
    var elements: Array[RenderElement] = Array[RenderElement]
    var events: Map[String, Array[GuiEvent]] = Map[String, Array[GuiEvent]]
    
    var cursors: Map[String, sdl.Cursor] = Map[String, sdl.Cursor]
    
    var initSDL: U32 = 0
    var initIMG: I32 = 0
    var initTTF: U32 = 0
    
    var window: Pointer[sdl.Window] = Pointer[sdl.Window]
    var windowFlags: Array[String] = Array[String]
    var windowTitle: String = ""
    var windowColor: sdl.Color = sdl.Color
    var windowW: I32 = 1280
    var windowH: I32 = 720
    
    var renderer: Pointer[sdl.Renderer] = Pointer[sdl.Renderer]
    
    var liveMode: Bool = false
    var liveTime: I64 = 0
    var liveFile: String = "layout.gui"
    var liveFileHashes: Map[String, String] = Map[String, String]
    
    var state: AppState = AppState
    
    new create(env: Env, settings: Map[String, String]) ? =>
        out = env
        
        if settings.contains("live") then
            liveMode = true
            
            if settings("live")? != "" then
                liveFile = settings("live")?
            end
        end
    
    fun ref init() ? =>
        // load our gui and events
        Gui(this).load(liveFile)?
        
        // initialize our libraries
        // and create our window and renderer
        _initLibraries()?
        
        // render our elements 
        // and their states
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
                    
                    var elementsByEvent = _getElementsByEvent("out")?
                    var reEvents = elementsByEvent.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x < re.rect.x) or (event.x > (re.rect.x + re.rect.w)) or
                           (event.y < re.rect.y) or (event.y > (re.rect.y + re.rect.h)) then

                            Debug.out("out = " + re.id)

                            _runEventCommands(ge, re)?
                        end
                    end
                    
                    let reCursors = elements.values()
            
                    while reCursors.has_next() do
                        let rc = reCursors.next()?
                        
                        if (event.x >= rc.rect.x) and (event.x <= (rc.rect.x + rc.rect.w)) and
                           (event.y >= rc.rect.y) and (event.y <= (rc.rect.y + rc.rect.h)) then
                            
                            Debug.out("over for cursor = " + rc.id)
                            
                            if cursors.contains(rc.cursor) then
                                sdl.SetCursor(cursors(rc.cursor)?)
                            end
                        end
                    end
                    
                    elementsByEvent = _getElementsByEvent("over")?
                    reEvents = elementsByEvent.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                           (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h)) then

                            Debug.out("over = " + re.id)

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

                            Debug.out("click = " + re.id)

                            _runEventCommands(ge, re)?
                        end
                    end
                | sdl.EVENTWINDOWEVENT() =>
                    var event: sdl.WindowEvent ref = sdl.WindowEvent
                    more = sdl.PollWindowEvent(MaybePointer[sdl.WindowEvent](event))
                    
                    if event.event == sdl.WINDOWEVENTRESIZED() then
                        windowW = event.data1
                        windowH = event.data2
                        
                        Debug.out("resized to " + windowW.string() + " x " + windowH.string())
                        
                        Render(this).recalc()?
                        
                        if events.contains("resize") then
                            let guiEvents = events("resize")?.values()
                            
                            while guiEvents.has_next() do
                                let ge = guiEvents.next()?
                                
                                _runEventCommands(ge, state)?
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
            sdl.SetRenderDrawColor(renderer, windowColor.r, windowColor.g, windowColor.b, windowColor.a)
            
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
            
            if liveMode and ((Time.seconds() - liveTime) > 1) then
                reload(liveFile)?
            end
        end
        
        logAndExit()?
    
    fun ref reload(fileName: String) ? =>
        Debug.out("Reloading GUI ...")
        
        let liveFileHashesClone = liveFileHashes.clone()
        let liveFileHashesOld = liveFileHashesClone.values()
        
        liveFileHashes.clear()
        
        Gui(this).load(fileName, true)?
        
        let liveFileHashesNew = liveFileHashes.values()
        var liveFileHashesDifferent = false
        
        while liveFileHashesNew.has_next() do
            let hashNew = liveFileHashesNew.next()?
            let hashOld = try liveFileHashesOld.next()? else
                liveFileHashesDifferent = true
                break
            end
            
            if hashNew != hashOld then
                liveFileHashesDifferent = true
                break
            end
        end
        
        if liveFileHashesDifferent then
            Debug.out("Reloading Render ...")
            
            Render(this).load()?
        end
        
        liveTime = Time.seconds()
    
    fun ref _initLibraries() ? =>
        // initialize SDL
        
        initSDL = sdl.Init(sdl.INITVIDEO())
        Debug.out("initSDL = " + initSDL.string())
        
        if initSDL != 0 then
            logAndExit("init sdl error")?
        end
        
        // create our window
        
        var wFlags = sdl.WINDOWSHOWN()
        
        for flag in windowFlags.values() do
            match flag
            | "allowhighdpi" =>
                wFlags = wFlags or sdl.WINDOWALLOWHIGHDPI()
            | "alwaysontop" =>
                wFlags = wFlags or sdl.WINDOWALWAYSONTOP()
            | "borderless" =>
                wFlags = wFlags or sdl.WINDOWBORDERLESS()
            | "foreign" =>
                wFlags = wFlags or sdl.WINDOWFOREIGN()
            | "fullscreen" =>
                wFlags = wFlags or sdl.WINDOWFULLSCREEN()
            | "fullscreendesktop" =>
                wFlags = wFlags or sdl.WINDOWFULLSCREENDESKTOP()
            | "hidden" =>
                wFlags = wFlags or sdl.WINDOWHIDDEN()
            | "inputfocus" =>
                wFlags = wFlags or sdl.WINDOWINPUTFOCUS()
            | "inputgrabbed" =>
                wFlags = wFlags or sdl.WINDOWINPUTGRABBED()
            | "maximized" =>
                wFlags = wFlags or sdl.WINDOWMAXIMIZED()
            | "minimized" =>
                wFlags = wFlags or sdl.WINDOWMINIMIZED()
            | "mousecapture" =>
                wFlags = wFlags or sdl.WINDOWMOUSECAPTURE()
            | "mousefocus" =>
                wFlags = wFlags or sdl.WINDOWMOUSEFOCUS()
            | "opengl" =>
                wFlags = wFlags or sdl.WINDOWOPENGL()
            | "popupmenu" =>
                wFlags = wFlags or sdl.WINDOWPOPUPMENU()
            | "resizeable" =>
                wFlags = wFlags or sdl.WINDOWRESIZABLE()
            | "skiptaskbar" =>
                wFlags = wFlags or sdl.WINDOWSKIPTASKBAR()
            | "tooltip" =>
                wFlags = wFlags or sdl.WINDOWTOOLTIP()
            | "utility" =>
                wFlags = wFlags or sdl.WINDOWUTILITY()
            | "vulkan" =>
                wFlags = wFlags or sdl.WINDOWVULKAN()
            end
        end
        
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
        
        // create our cursors
        
        cursors.update("arrow", sdl.CreateSystemCursor(sdl.CURSORARROW()))
        cursors.update("crosshair", sdl.CreateSystemCursor(sdl.CURSORCROSSHAIR()))
        cursors.update("hand", sdl.CreateSystemCursor(sdl.CURSORHAND()))
        cursors.update("ibeam", sdl.CreateSystemCursor(sdl.CURSORIBEAM()))
        cursors.update("no", sdl.CreateSystemCursor(sdl.CURSORNO()))
        cursors.update("sizeall", sdl.CreateSystemCursor(sdl.CURSORSIZEALL()))
        cursors.update("sizenesw", sdl.CreateSystemCursor(sdl.CURSORSIZENESW()))
        cursors.update("sizens", sdl.CreateSystemCursor(sdl.CURSORSIZENS()))
        cursors.update("sizenwse", sdl.CreateSystemCursor(sdl.CURSORSIZENWSE()))
        cursors.update("sizewe", sdl.CreateSystemCursor(sdl.CURSORSIZEWE()))
        cursors.update("wait", sdl.CreateSystemCursor(sdl.CURSORWAIT()))
        cursors.update("waitarrow", sdl.CreateSystemCursor(sdl.CURSORWAITARROW()))
        
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
            
            while guiEvents.has_next() do
                let ge = guiEvents.next()?
                
                let renderElements = elements.values()
                
                while renderElements.has_next() do
                    let re = renderElements.next()?
                    
                    if ge.id == re.id then
                        elementsByEvent.push((ge, re))
                    end
                end
            end
        end
        
        elementsByEvent
    
    fun ref _runEventCommands(ge: GuiEvent, re: CanRunCommands, setData: Bool = false) ? =>
        let commands = ge.commands.values()
        
        while commands.has_next() do
            let command = commands.next()?
            var when = false
            
            if command.whenVar == "" then
                when = true
            else
                // TODO: look into allowing the ability to specify variables in other elements
                //  e.g. when "app.gui.<id>.x" gt 10
                
                let whenVarParts: Array[String] = command.whenVar.split_by(".")
                var whenVarValue: String = ""
                
                try
                    if whenVarParts(0)? == "app" then
                        match whenVarParts(1)?
                        | "system" =>
                            match whenVarParts(2)?
                            | "window" =>
                                match whenVarParts(3)?
                                | "width" =>
                                    whenVarValue = windowW.string()
                                | "height" =>
                                    whenVarValue = windowH.string()
                                end
                            end
                        end
                    else
                        if not re.getData().contains(command.whenVar) then
                            // we are just initializing an empty var and
                            // so the data event doesn't need to be run
                            re.setDataValue(command.whenVar, "0")
                        end
                        
                        whenVarValue = re.getDataValue(command.whenVar)?
                    end
                    
                    match command.whenCon
                    | "eq" =>
                        if whenVarValue == command.whenVal then
                            when = true
                        end
                    | "ne" =>
                        if whenVarValue != command.whenVal then
                            when = true
                        end
                    | "ge" =>
                        if whenVarValue.u64()? >= command.whenVal.u64()? then
                            when = true
                        end
                    | "le" =>
                        if whenVarValue.u64()? <= command.whenVal.u64()? then
                            when = true
                        end
                    | "gt" =>
                        if whenVarValue.u64()? > command.whenVal.u64()? then
                            when = true
                        end
                    | "lt" =>
                        if whenVarValue.u64()? < command.whenVal.u64()? then
                            when = true
                        end
                    end
                else
                    continue
                end
            end
            
            match command.command
            | "set" =>
                if when then
                    re.setDataValue(command.dataVar, command.dataVal)
                elseif command.elseVar != "" then
                    re.setDataValue(command.elseVar, command.elseVal)
                end
                
                // make sure the data event has not already run
                // otherwise we can get into an endless loop
                if not setData then
                    var elementsByEvent = _getElementsByEvent("data")?
                    var reEvents = elementsByEvent.values()
                    
                    while reEvents.has_next() do
                        (let geSet, let reSet) = reEvents.next()?

                        if (re.getId() == reSet.getId()) then
                            Debug.out("data")

                            _runEventCommands(geSet, reSet, true)?
                        end
                    end
                end
            | "run" =>
                var runId = ""
                var runType = ""
                
                if when then
                    runId = command.stateId
                    runType = command.runType
                elseif command.elseVar != "" then
                    runId = command.elseVal
                    runType = command.elseVar
                end
                
                if runId != "" then
                    match runType
                    | "state" =>
                        try _runEventState(runId, re)? else continue end
                    | "api" =>
                        Api(runId, ge, re, this)
                    end
                end
            end
        end
    
    fun ref _runEventState(id: String, rc: CanRunCommands) ? =>
        // TODO: add the ability to hide / show rows and cols
        
        // check if the row / col states have changed, 
        // as this requires all element rects to be recalculated
        var recalc = false
        
        let rows = gui.values()
            
        while rows.has_next() do
            let row = rows.next()?
            
            if row.states.contains(id) then
                recalc = true
                break
            end
            
            let cols = row.cols.values()
            
            while cols.has_next() do
                let col = cols.next()?
                
                if col.states.contains(id) then
                    recalc = true
                    break
                end
            end
            
            if recalc == true then break end
        end
        
        if recalc then
            Render(this).recalc(id)?
        end
        
        _runEventStateForElements(id, rc)?
    
    fun ref _runEventStateForElements(id: String, rc: CanRunCommands) ? =>
        let renderElements = elements.values()
        
        while renderElements.has_next() do
            let re = renderElements.next()?
            
            let reState = try re.states(id)? else continue end
            
            // make sure the default state is only 
            // run on the element that called it
            if id == "default" then
                match rc
                | let rcType: RenderElement =>
                    let el = rc as RenderElement
                    if el.id != reState.id then continue end
                end
            end
            
            let persist = try reState.ge.properties("persist")? else "0" end
            
            if persist == "1" then
                Render(this).recalc(re.id, reState)?
            else
                re.cursor = reState.cursor
                re.texture = reState.texture
                re.rect = reState.rect
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
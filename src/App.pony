use "collections"
use "crypto"
use "debug"
use "time"
use "api"

use sdl = "sdl"
use img = "sdl-image"
use ttf = "sdl-ttf"

class App
    var out: Env
    
    var api: Api = Api
    
    var gui: Array[GuiRow] = Array[GuiRow]
    var elements: Array[RenderElement] = Array[RenderElement]
    var elementsByEvent: Map[String, Array[(GuiEvent, RenderElement)]] = Map[String, Array[(GuiEvent, RenderElement)]]
    var events: Map[String, Array[GuiEvent]] = Map[String, Array[GuiEvent]]
    
    var cursors: Map[String, sdl.Cursor] = Map[String, sdl.Cursor]
    var keys: Map[String, (I32, Array[U16])] = Map[String, (I32, Array[U16])]
    
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
        
        // initialize our list of valid cursors
        cursors.update("arrow", sdl.Cursor)
        cursors.update("crosshair", sdl.Cursor)
        cursors.update("hand", sdl.Cursor)
        cursors.update("ibeam", sdl.Cursor)
        cursors.update("no", sdl.Cursor)
        cursors.update("sizeall", sdl.Cursor)
        cursors.update("sizenesw", sdl.Cursor)
        cursors.update("sizens", sdl.Cursor)
        cursors.update("sizenwse", sdl.Cursor)
        cursors.update("sizewe", sdl.Cursor)
        cursors.update("wait", sdl.Cursor)
        cursors.update("waitarrow", sdl.Cursor)
        
        Keyboard(this).load()
    
    fun ref init() ? =>
        // load our gui and events
        Gui(this).load(liveFile)?
        
        // initialize our libraries
        // and create our window and renderer
        _initLibraries()?
        
        // render our elements 
        // and their states
        Render(this).load()?
        
        _getElementsByEvent("data")?
        _getElementsByEvent("keydown")?
        _getElementsByEvent("keyup")?
        _getElementsByEvent("mouseclick")?
        _getElementsByEvent("mousedown")?
        _getElementsByEvent("mouseout")?
        _getElementsByEvent("mouseover")?
        _getElementsByEvent("mouseup")?
        _getElementsByEvent("resize")?
        
        // event polling
        var poll = true
        var lastOver: U32 = -1
        var lastDown: U32 = -1
        
        while poll do
            var more: I32 = 1
            
            while more > 0 do
                sdl.PumpEvents()
                
                var peek: sdl.CommonEvent ref = sdl.CommonEvent
                sdl.PeekEvent(MaybePointer[sdl.CommonEvent](peek))
                
                match peek.eventType
                | sdl.EVENTKEYDOWN() =>
                    var event: sdl.KeyboardEvent ref = sdl.KeyboardEvent
                    more = sdl.PollKeyboardEvent(MaybePointer[sdl.KeyboardEvent](event))
                    
                    var reEvents = elementsByEvent("keydown")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        // TODO: get custom modifiers working
                        //       e.g. mod "ALT" key "F"
                        
                        (let reSym, let reMods) = keys.get_or_else(re.keyCode, (-1, [0x0000]))
                        (let eventSC, let eventSym, let eventMod, let eventNA) = event.keysym
                        
                        if ((reSym == eventSym) and (reMods.contains(eventMod))) then
                            _runEventCommands(ge, re)?
                        end
                    end
                | sdl.EVENTKEYUP() =>
                    var event: sdl.KeyboardEvent ref = sdl.KeyboardEvent
                    more = sdl.PollKeyboardEvent(MaybePointer[sdl.KeyboardEvent](event))
                    
                    var reEvents = elementsByEvent("keyup")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        // TODO: get custom modifiers working
                        //       e.g. mod "ALT" key "F"
                        
                        (let reSym, let reMods) = keys.get_or_else(re.keyCode, (-1, [0x0000]))
                        (let eventSC, let eventSym, let eventMod, let eventNA) = event.keysym
                        
                        if ((reSym == eventSym) and (reMods.contains(eventMod))) then
                            _runEventCommands(ge, re)?
                        end
                    end
                | sdl.EVENTMOUSEMOTION() =>
                    var event: sdl.MouseMotionEvent ref = sdl.MouseMotionEvent
                    more = sdl.PollMouseMotionEvent(MaybePointer[sdl.MouseMotionEvent](event))
                    
                    var reEvents = elementsByEvent("mouseout")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if re.guid != lastOver then continue end
                        
                        if (event.x < re.rect.x) or (event.x > (re.rect.x + re.rect.w)) or
                           (event.y < re.rect.y) or (event.y > (re.rect.y + re.rect.h)) then
                            sdl.SetCursor(cursors("arrow")?)
                            _runEventCommands(ge, re)?
                        end
                    end
                    
                    for rc in elements.values() do
                        if (event.x >= rc.rect.x) and (event.x <= (rc.rect.x + rc.rect.w)) and
                           (event.y >= rc.rect.y) and (event.y <= (rc.rect.y + rc.rect.h)) then
                            sdl.SetCursor(cursors(rc.cursor)?)
                        end
                    end
                    
                    reEvents = elementsByEvent("mouseover")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                           (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h)) then
                            _runEventCommands(ge, re)?
                            lastOver = re.guid
                        end
                    end
                | sdl.EVENTMOUSEBUTTONDOWN() =>
                    var event: sdl.MouseButtonEvent ref = sdl.MouseButtonEvent
                    more = sdl.PollMouseButtonEvent(MaybePointer[sdl.MouseButtonEvent](event))
                    
                    let reEvents = elementsByEvent("mousedown")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                           (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h)) then
                            _runEventCommands(ge, re)?
                            lastDown = re.guid
                        end
                    end
                | sdl.EVENTMOUSEBUTTONUP() =>
                    var event: sdl.MouseButtonEvent ref = sdl.MouseButtonEvent
                    more = sdl.PollMouseButtonEvent(MaybePointer[sdl.MouseButtonEvent](event))
                    
                    var reEvents = elementsByEvent("mouseup")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                           (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h)) then
                            _runEventCommands(ge, re)?
                        end
                    end
                    
                    reEvents = elementsByEvent("mouseclick")?.values()
                    
                    while reEvents.has_next() do
                        (let ge, let re) = reEvents.next()?
                        
                        if (re.guid == lastDown) or (
                               (lastDown == -1) and
                               (event.x >= re.rect.x) and (event.x <= (re.rect.x + re.rect.w)) and
                               (event.y >= re.rect.y) and (event.y <= (re.rect.y + re.rect.h))
                           ) then
                            _runEventCommands(ge, re)?
                        end
                    end
                    
                    lastDown = -1
                | sdl.EVENTWINDOWEVENT() =>
                    var event: sdl.WindowEvent ref = sdl.WindowEvent
                    more = sdl.PollWindowEvent(MaybePointer[sdl.WindowEvent](event))
                    
                    if event.event == sdl.WINDOWEVENTRESIZED() then
                        windowW = event.data1
                        windowH = event.data2
                        
                        Render(this).recalc()?
                        
                        if events.contains("resize") then
                            for ge in events("resize")?.values() do
                                _runEventCommands(ge, state)?
                            end
                        end
                    end
                | sdl.EVENTQUIT() =>
                    more = 0
                    poll = false
                    
                    logAndExit()?
                else
                    var event: sdl.CommonEvent ref = sdl.CommonEvent
                    more = sdl.PollCommonEvent(MaybePointer[sdl.CommonEvent](event))
                end
            end
            
            // set our background color
            sdl.SetRenderDrawColor(renderer, windowColor.r, windowColor.g, windowColor.b, windowColor.a)
            
            // remove all drawn items
            sdl.RenderClear(renderer)
            
            for element in elements.values() do
                if not element.texture.is_null() then
                    sdl.RenderCopy(renderer, element.texture, Pointer[sdl.Rect], MaybePointer[sdl.Rect](element.rect))
                end
                
                for callback in element.callbacks.values() do
                    callback()
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
        let liveFileHashesClone = liveFileHashes.clone()
        let liveFileHashesOld = liveFileHashesClone.values()
        
        liveFileHashes.clear()
        
        Gui(this).load(fileName, true)?
        
        var liveFileHashesDifferent = false
        
        for hashNew in liveFileHashes.values() do
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
            Render(this).load()?
        end
        
        liveTime = Time.seconds()
    
    fun ref _initLibraries() ? =>
        // initialize SDL
        
        initSDL = sdl.Init(sdl.INITVIDEO())
        
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
        
        if window.is_null() then
        	logAndExit("create window error")?
        end
        
        // create our renderer
        
        let rFlags = sdl.RENDERERACCELERATED() or sdl.RENDERERPRESENTVSYNC()
        renderer = sdl.CreateRenderer(window, -1, rFlags)
        
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
        
        if initIMG == 0 then
            logAndExit("init img error")?
        end
        
        if ((initIMG and iFlags) != iFlags) then
            logAndExit("init img flags error")?
        end
        
        // initialize SDL TTF
        
        initTTF = ttf.Init()
        
        if initTTF != 0 then
            logAndExit("init ttf error")?
        end
    
    fun ref _getElementsByEvent(eventType: String) ? =>
        elementsByEvent.update(eventType, Array[(GuiEvent, RenderElement)])
        
        if events.contains(eventType) then
            for ge in events(eventType)?.values() do
                for re in elements.values() do
                    if ((ge.id != "") and (ge.id == re.id)) or
                       ((ge.group != "") and (ge.group == re.group)) then
                        elementsByEvent(eventType)?.push((ge, re))
                    end
                end
            end
        end
    
    fun ref _runEventCommands(ge: GuiEvent, re: CanRunCommands, setData: Bool = false) ? =>
        for command in ge.commands.values() do
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
                        
                        whenVarValue = re.getDataValue(command.whenVar)
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
                    var reEvents = elementsByEvent("data")?.values()
                    
                    while reEvents.has_next() do
                        (let geSet, let reSet) = reEvents.next()?

                        if (re.getId() == reSet.getId()) then
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
                        api(runId, ge, re, this)
                    end
                end
            end
        end
    
    fun ref _runEventState(id: String, rc: CanRunCommands) ? =>
        // TODO: add the ability to hide / show rows and cols
        
        // check if the row / col states have changed, 
        // as this requires all element rects to be recalculated
        var recalc = false
        
        for row in gui.values() do
            if row.states.contains(id) then
                recalc = true
                break
            end
            
            for col in row.cols.values() do
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
        for re in elements.values() do
            let reState = re.states.get_or_else(id, re)
            
            // make sure the default or group state is only 
            // run on the element that called it
            if (id == "default") or (reState.group != "") then
                match rc
                | let rcType: RenderElement =>
                    let el = rc as RenderElement
                    if el.guid != reState.guid then continue end
                end
            end
            
            let persist = reState.ge.properties.get_or_else("persist", "0")
            
            if persist == "1" then
                Render(this).recalc(re.id, reState)?
            else
                re.callbacks = reState.callbacks
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
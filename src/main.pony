use "debug"
use "files"
use "regex"

use sdl = "sdl"
use gfx = "sdl-gfx"
use img = "sdl-image"
use ttf = "sdl-ttf"

actor Main
    new create(env: Env) =>
        try App(env).init()? end

class App
    var out: Env
    
    var initSDL: U32 = 0
    var initIMG: I32 = 0
    var initTTF: U32 = 0
    
    var window: Pointer[sdl.Window] = Pointer[sdl.Window]
    var renderer: Pointer[sdl.Renderer] = Pointer[sdl.Renderer]
    
    new create(env: Env) =>
        out = env
    
    fun ref init()? =>
        GUI(this).layout()?
        
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
            
            // draw our background
            sdl.SetRenderDrawColor(renderer, 0x31, 0x3D, 0x78, 0xFF)
            
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

// TODO: Move these classes into separate files

class GUI
    var app: App
    
    new create(myApp: App) =>
        app = myApp
    
    fun ref layout()? =>
        let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end
        let fileName = "layout.gui"
        
        let filePath = try FilePath(app.out.root as AmbientAuth, fileName, caps)? else 
            app.logAndExit("The \"" + fileName + "\" file is missing or has incorrect permissions.", false)?
            return // this is only here so that the compiler doesn't complain about filePath being None
        end
        
        let file = OpenFile(filePath) as File
        
        var lineCount: I32 = 0
        var lineRows = Array[Row]
        
        // TODO: Look into changing the comment syntax to -- or similar
        let lineRegex = Regex("(^\\s*((row \\d\\/\\d.*)|(col \\d\\/\\d.*)|(draw .*)|(text .*)|(load .*)|(\\/\\/.*)|($)))")?
        
        var rowCounter: I32 = 0
        var colCounter: I32 = 0
        
        for line in file.lines() do
            lineCount = lineCount + 1
            
            try
                if line.size() == 0 then
                    continue
                end
                
                let lineMatch = lineRegex(line)?
                
                let guiCommand: String = try lineMatch(2)?.substring(0, 4).>rstrip() else
                    continue
                end
                
                let guiProperties: Array[String] = lineMatch(2)?.split_by(" ")
                
                match guiCommand
                | "row" =>
                    let height = guiProperties(1)?.split_by("/")
                    
                    var guiRow = Row
                    guiRow.height = height(0)?.f32() / height(1)?.f32()
                    
                    let gp = guiProperties.values()
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        match key
                        | "id" =>
                            if gp.has_next() then
                                guiRow.id = gp.next()?.clone().>strip("\"")
                            end
                        end
                    end
                    
                    lineRows.push(guiRow)
                    
                    rowCounter = rowCounter + 1
                // TODO: Add col, text, draw, load and
                // create entries for missing rows and cols
                end
            else
                app.logAndExit("The \"" + fileName + "\" file has invalid syntax on line " + 
                                lineCount.string() + ".", false)?
            end
        end
        
        Debug.out("Rows")
        
        let lr = lineRows.values()
                    
        while lr.has_next() do
            let myRow = lr.next()?
            
            Debug.out("-----------------")
            Debug.out("id = " + myRow.id)
            Debug.out("height = " + myRow.height.string())
        end
        
        Debug.out("-----------------\n")

class Row
    var id: String = ""
    var height: F32 = 0
    var cols: Array[Col] = Array[Col]

    new create() => None

class Col
    var id: String = ""
    var width: F32 = 0
    var commands: Array[String] = Array[String]
    
    new create() => None
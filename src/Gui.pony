use "collections"
use "crypto"
use "debug"
use "files"
use "regex"

class Gui
    var app: App
    
    // Group Separator (ASCII 29)
    let placeholder: String = "\u001D"
    
    new create(myApp: App) =>
        app = myApp
    
    fun ref load(fileName: String = "layout.gui", reload: Bool = false) ? =>
        if reload then
            app.gui.clear()
            app.events.clear()
        end
        
        let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end
        let filePath = try FilePath(app.out.root as AmbientAuth, fileName, caps)? else 
            app.logAndExit("The \"" + fileName + "\" file is missing or has incorrect permissions.", false)?
            return // this is only here so that the compiler doesn't complain about filePath being None
        end
        
        var file = OpenFile(filePath) as File
        
        if reload then
            app.liveFileHashes.update(fileName, ToHexString(
                MD5(file.read_string(file.size()))
            ))
            
            file.dispose()
            
            file = OpenFile(filePath) as File
        end
        
        var lineCount: I32 = 0
        let lineRegex = Regex("^((app|row|col|draw|text|load|style|event) .*)|(--.*)|($)")?
        
        var rowCounter: USize = 0
        var colCounter: USize = 0
        
        let lines = file.lines()
        
        var line: String = ""
        var prev: String = ""
        
        let rMap = Map[String, Array[String]]
        
        rMap.insert("load", ["src"])?
        rMap.insert("text", ["font"; "font-size"; "font-color"])?
        
        let required = rMap.pairs()
        
        while lines.has_next() do
            if prev == "" then
                line = lines.next().clone().>strip()
                
                lineCount = lineCount + 1
            else
                line = prev
                prev = ""
            end
            
            if line.size() == 0 then
                continue
            end
            
            try
                // display a syntax error when the line doesn't match the expression
                // otherwise return the line as a string that can be iterated on
                let matchClean = _cleanLine(lineRegex(line)?(0)?)?
                
                let guiProperties: Array[String] = matchClean.split_by(" ")
                let gp = guiProperties.values()
                
                match guiProperties(0)?
                | "app" =>
                    if reload then continue end
                    
                    gp.next()?
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "title" =>
                                app.windowTitle = value
                            | "flags" =>
                                app.windowFlags = value.clone().>remove(" ").split_by(",")
                            | "width" =>
                                app.windowW = try value.i32()? else error end
                            | "height" =>
                                app.windowH = try value.i32()? else error end
                            end
                        end
                    end
                | "row" =>
                    gp.next()?
                    
                    let guiRow = GuiRow
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "id" =>
                                guiRow.id = value
                            | "height" =>
                                let height = value.split_by("/")
                                guiRow.height = height(0)?.f32() / height(1)?.f32()
                            end
                        end
                    end
                    
                    app.gui.push(guiRow)
                    
                    rowCounter = rowCounter + 1
                    colCounter = 0
                | "col" =>
                    if rowCounter == 0 then
                        let guiRow = GuiRow
                        guiRow.height = 1
                        
                        app.gui.push(guiRow)
                    
                        rowCounter = 1
                    end
                    
                    gp.next()?
                    
                    let guiCol = GuiCol
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "id" =>
                                guiCol.id = value
                            | "width" =>
                                let width = value.split_by("/")
                                guiCol.width = width(0)?.f32() / width(1)?.f32()
                            end
                        end
                    end
                    
                    try app.gui(rowCounter - 1)?.cols.push(guiCol) end
                    
                    colCounter = colCounter + 1
                | "text" | "draw" | "load" =>
                    if colCounter == 0 then
                        let guiCol = GuiCol
                        guiCol.width = 1
                        
                        try app.gui(rowCounter - 1)?.cols.push(guiCol) end
                    
                        colCounter = 1
                    end
                    
                    let guiElement = GuiElement
                    guiElement.command = gp.next()?
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            if key == "id" then
                                guiElement.id = value
                            else
                                guiElement.properties.insert(key, value)?
                            end
                        end
                    end
                    
                    try app.gui(rowCounter - 1)?.cols(colCounter - 1)?.elements.push(guiElement) end
                | "style" =>
                    gp.next()?
                    
                    var import = false
                    var guiElement = GuiElement
                    var styleEvent = GuiElement
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "import" =>
                                load(value)?
                                import = true
                                break
                            | "id" | "event" =>
                                if key == "event" then
                                    styleEvent.id = value
                                else
                                    for row in app.gui.values() do
                                        for col in row.cols.values() do
                                            for element in col.elements.values() do
                                                if element.id == value then
                                                    guiElement = element
                                                    break
                                                end
                                            end
                                            
                                            if guiElement.id != "" then
                                                break
                                            end
                                        end
                                        
                                        if guiElement.id != "" then
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    
                    if import then continue elseif guiElement.id == "" then
                        app.logAndExit("The style command has a missing or invalid \"id\" property.", false)?
                    end
                    
                    while lines.has_next() do
                        line = lines.next().clone().>strip()
                        
                        lineCount = lineCount + 1
                        
                        if line.size() == 0 then
                            continue
                        end
                        
                        let lineClean = _cleanLine(line)?
                        
                        let prop: Array[String] = lineClean.split_by(" ")
                        let propKey = prop(0)?
                        
                        if (propKey == "style") or (propKey == "event") then
                            prev = line
                            break
                        else
                            try
                                let propValue: String val = prop(1)?.clone().>strip("\"").>replace(placeholder, " ")
                                
                                if styleEvent.id != "" then
                                    styleEvent.properties.insert(propKey, propValue)?
                                else
                                    guiElement.properties.insert(propKey, propValue)?
                                end
                            end
                        end
                    end
                    
                    if styleEvent.id != "" then
                        guiElement.events.push(styleEvent)
                    else
                        while required.has_next() do
                            (var rCommand, var rProperties) = required.next()?
                            
                            if guiElement.command == rCommand then
                                let rp = rProperties.values()
                                
                                while rp.has_next() do
                                    let rProperty = rp.next()?
                                    
                                    if not guiElement.properties.contains(rProperty) then
                                        lineCount = lineCount - 1
                                        
                                        app.logAndExit("The \"" + rCommand + "\" command is missing a \"" + 
                                                        rProperty + "\" property.", false)?
                                    end
                                end
                            end
                        end
                    end
                | "event" =>
                    gp.next()?
                    
                    var import = false
                    var guiEvent = GuiEvent
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "import" =>
                                load(value)?
                                import = true
                                break
                            | "id" =>
                                for row in app.gui.values() do
                                    for col in row.cols.values() do
                                        for element in col.elements.values() do
                                            if element.id == value then
                                                guiEvent.id = element.id
                                                break
                                            end
                                        end
                                        
                                        if guiEvent.id != "" then
                                            break
                                        end
                                    end
                                    
                                    if guiEvent.id != "" then
                                        break
                                    end
                                end
                            | "type" =>
                                guiEvent.eventType = value
                            end
                        end
                    end
                    
                    if import then continue elseif guiEvent.id == "" then
                        app.logAndExit("The event command has a missing or invalid \"id\" property.", false)?
                    end
                    
                    if guiEvent.eventType == "" then
                        app.logAndExit("The event command has a missing \"type\" property.", false)?
                    end
                    
                    while lines.has_next() do
                        line = lines.next().clone().>strip()
                        
                        lineCount = lineCount + 1
                        
                        if line.size() == 0 then
                            continue
                        end
                        
                        let lineClean = _cleanLine(line)?
                        
                        let eventCommand: Array[String] = lineClean.split_by(" ")
                        let command = eventCommand(0)?
                        
                        if (command == "style") or (command == "event") then
                            prev = line
                            break
                        else
                            var runType: String val = ""
                            var eventId: String val = ""
                            var dataVar: String val = ""
                            var dataVal: String val = ""
                            var whenVar: String val = ""
                            var whenVal: String val = ""
                            var elseVar: String val = ""
                            var elseVal: String val = ""
                            
                            match command
                            | "run" =>
                                runType = eventCommand(1)?
                                eventId = eventCommand(2)?
                            | "set" =>
                                dataVar = eventCommand(1)?
                                dataVal = eventCommand(2)?
                            end
                            
                            whenVar = try eventCommand(4)? else "" end
                            whenVal = try eventCommand(5)? else
                                if whenVar == "" then "" else error end
                            end
                            
                            elseVar = try eventCommand(7)? else "" end
                            elseVal = try eventCommand(8)? else
                                if elseVar == "" then "" else error end
                            end
                            
                            let gec: GuiEventCommand ref = GuiEventCommand
                            gec.command = command
                            gec.runType = runType.clone().>strip("\"").>replace(placeholder, " ")
                            gec.eventId = eventId.clone().>strip("\"").>replace(placeholder, " ")
                            gec.dataVar = dataVar.clone().>strip("\"").>replace(placeholder, " ")
                            gec.dataVal = dataVal.clone().>strip("\"").>replace(placeholder, " ")
                            gec.whenVar = whenVar.clone().>strip("\"").>replace(placeholder, " ")
                            gec.whenVal = whenVal.clone().>strip("\"").>replace(placeholder, " ")
                            gec.elseVar = elseVar.clone().>strip("\"").>replace(placeholder, " ")
                            gec.elseVal = elseVal.clone().>strip("\"").>replace(placeholder, " ")
                            
                            guiEvent.commands.push(gec)
                        end
                    end
                    
                    if app.events.contains(guiEvent.eventType) then
                        app.events(guiEvent.eventType)?.push(guiEvent)
                    else
                        app.events.insert(guiEvent.eventType, [guiEvent])?
                    end
                end
            else
                app.logAndExit("The \"" + fileName + "\" file has invalid syntax on line " + 
                                lineCount.string() + ".", false)?
            end
        end
        
        // some debugging to verify we are parsing things properly
        
        if (fileName != "layout.gui") or (app.liveMode and (fileName != app.liveFile)) then
            return
        end
        
        file.dispose()
        
        let lr = app.gui.values()
                    
        while lr.has_next() do
            let myRow = lr.next()?
            
            Debug.out("\nRow")
            Debug.out("-----------------\n")
            Debug.out("id = " + myRow.id)
            Debug.out("height = " + myRow.height.string())
            
            let lc = myRow.cols.values()
            
            if lc.has_next() then
                Debug.out("\nCol")
                
                while lc.has_next() do
                    let myCol = lc.next()?
                    
                    Debug.out("-----------------\n")
                    Debug.out("id = " + myCol.id)
                    Debug.out("width = " + myCol.width.string())
                    
                    let lelements = myCol.elements.values()
            
                    if lelements.has_next() then
                        Debug.out("\nElements")
                        
                        while lelements.has_next() do
                            let myElement = lelements.next()?
                            
                            Debug.out("------------------\n")
                            Debug.out("id = " + myElement.id)
                            Debug.out("command = " + myElement.command)
                            
                            let lprops = myElement.properties.pairs()
                            
                            while lprops.has_next() do
                                let myProp = lprops.next()?
                                
                                Debug.out(myProp._1 + " = " + myProp._2)
                            end
                            
                            let lge = myElement.events.values()
                            
                            while lge.has_next() do
                                let myGuiEvent = lge.next()?
                                
                                Debug.out("\nevent id = " + myGuiEvent.id)
                                
                                let geprops = myGuiEvent.properties.pairs()
                    
                                while geprops.has_next() do
                                    let myGuiEventProp = geprops.next()?
                                    
                                    Debug.out(myGuiEventProp._1 + " = " + myGuiEventProp._2)
                                end
                            end
                            
                            if lelements.has_next() then
                                Debug.out("")
                            end
                        end
                    end
                end
            end
        end
        
        let lae = app.events.pairs()
            
        if lae.has_next() then
            Debug.out("")
            
            while lae.has_next() do
                let myEventType = lae.next()?
                
                Debug.out("Events - " + myEventType._1)
                
                let myEvents = myEventType._2.values()
                
                while myEvents.has_next() do
                    let myEvent = myEvents.next()?
                    
                    Debug.out("-----------------\n")
                    Debug.out("id = " + myEvent.id)
                    
                    Debug.out("")
                    
                    let lcommands = myEvent.commands.values()
                    
                    while lcommands.has_next() do
                        let myCommand = lcommands.next()?
                        
                        let myCommandId = if myCommand.eventId == "" then
                            myCommand.dataVar
                        else
                            myCommand.eventId
                        end
                        
                        Debug.out(myCommand.command + " " + myCommandId)
                    end
                    
                    Debug.out("")
                end
            end
        end
        
    fun ref _cleanLine(line: String): String ref ? =>
        let lineClean: String ref = line.clone()
        
        // get all property values (e.g. value "Pony GUI")
        let lm = MatchIterator(Regex("\"[^\"]+\"")?, line, 0)
        
        while lm.has_next() do
            var lmValue = try lm.next()? else break end
            
            var lmStart = lmValue.start_pos().isize()
            var lmEnd = lmValue.end_pos().isize() + 1
            
            var lmString: String = lineClean.substring(lmStart, lmEnd)
            
            // replace all spaces with a placeholder
            // it needs to be any character that will never be used in a value
            // so we can split on spaces when we get an element's properties
            lineClean.replace(lmString, lmString.clone().>replace(" ", placeholder))
        end
        
        lineClean
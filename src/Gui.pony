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
            return
        end
        
        var file = try OpenFile(filePath) as File else 
            app.logAndExit("The \"" + fileName + "\" file is missing or has incorrect permissions.", false)?
            return
        end
        
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
                    
                    // default to a white background
                    app.windowColor.r = 255
                    app.windowColor.g = 255
                    app.windowColor.b = 255
                    app.windowColor.a = 255
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "title" =>
                                app.windowTitle = value
                            | "color" =>
                                app.windowColor.r = try ("0x" + value.substring(0, 2)).u8()? else 0 end
                                app.windowColor.g = try ("0x" + value.substring(2, 4)).u8()? else 0 end
                                app.windowColor.b = try ("0x" + value.substring(4, 6)).u8()? else 0 end
                                app.windowColor.a = try ("0x" + value.substring(6, 8)).u8()? else 0 end
                            | "flags" =>
                                app.windowFlags = value.clone().>remove(" ").split_by(",")
                            | "width" =>
                                app.windowW = try value.i32()? else error end
                            | "height" =>
                                app.windowH = try value.i32()? else error end
                            else
                                error
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
                                if value.contains("/") then
                                    let height = value.split_by("/")
                                    guiRow.height = height(0)?.f32() / height(1)?.f32()
                                else
                                    guiRow.height = value.f32()
                                end
                            else
                                error
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
                                if value.contains("/") then
                                    let width = value.split_by("/")
                                    guiCol.width = width(0)?.f32() / width(1)?.f32()
                                else
                                    guiCol.width = value.f32()
                                end
                            else
                                error
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
                    
                    if guiProperties(0)? == "text" then
                        guiElement.properties.insert("font", "OpenSans-Regular.ttf")?
                        guiElement.properties.insert("font-size", "16")?
                        guiElement.properties.insert("font-color", "000000")?
                    end
                    
                    guiElement.command = gp.next()?
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "id" =>
                                guiElement.id = value
                            | "group" =>
                                guiElement.group = value
                            else
                                guiElement.properties.update(key, value)
                            end
                        end
                    end
                    
                    try app.gui(rowCounter - 1)?.cols(colCounter - 1)?.elements.push(guiElement) end
                | "style" =>
                    gp.next()?
                    
                    var import = false
                    var persist = "0"
                    
                    var guiRow = GuiRow
                    var guiCol = GuiCol
                    var guiElement = GuiElement
                    
                    var guiRowState = GuiRow
                    var guiColState = GuiCol
                    var guiElementState = GuiElement
                    
                    var guiElementsByGroup = Array[GuiElement]
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "import" =>
                                load(value)?
                                import = true
                                break
                            | "persist" =>
                                persist = "1"
                            | "id" | "state" | "group" =>
                                if key == "state" then
                                    guiRowState.id = value
                                    guiColState.id = value
                                    guiElementState.id = value
                                else
                                    for row in app.gui.values() do
                                        if row.id == value then
                                            guiRow = row
                                            break
                                        end
                                        
                                        for col in row.cols.values() do
                                            if col.id == value then
                                                guiCol = col
                                                break
                                            end
                                            
                                            for element in col.elements.values() do
                                                if key == "group" then
                                                    if element.group == value then
                                                        guiElementsByGroup.push(element)
                                                    end
                                                else
                                                    if element.id == value then
                                                        guiElement = element
                                                        break
                                                    end
                                                end
                                            end
                                            
                                            if (guiCol.id != "") or (guiElement.id != "") then
                                                break
                                            end
                                        end
                                        
                                        if (guiElement.id != "") then
                                            break
                                        end
                                    end
                                end
                            else
                                error
                            end
                        end
                    end
                    
                    if import then
                        continue
                    elseif (guiRow.id == "") and (guiCol.id == "") and (guiElement.id == "") and
                           (guiElementsByGroup.size() == 0) then
                        app.logAndExit("The style command has a missing or invalid \"id\" property.", false)?
                    end
                    
                    guiElementState.properties.insert("persist", persist)?
                    
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
                                
                                if propKey == "cursor" then
                                    if not app.cursors.contains(propValue) then
                                        app.logAndExit("The style command has an invalid \"cursor\" property.", false)?
                                    end
                                end
                                
                                if guiRow.id != "" then
                                    if propKey == "height" then
                                        if propValue.contains("/") then
                                            let pvHeight = propValue.split_by("/")
                                            guiRowState.height = pvHeight(0)?.f32() / pvHeight(1)?.f32()
                                        else
                                            guiRowState.height = propValue.f32()
                                        end
                                    end
                                elseif guiCol.id != "" then
                                    if propKey == "width" then
                                        if propValue.contains("/") then
                                            let pvWidth = propValue.split_by("/")
                                            guiColState.width = pvWidth(0)?.f32() / pvWidth(1)?.f32()
                                        else
                                            guiColState.width = propValue.f32()
                                        end 
                                    end
                                elseif guiElementState.id != "" then
                                    guiElementState.properties.update(propKey, propValue)
                                elseif guiElementsByGroup.size() > 0 then
                                    for geByGroup in guiElementsByGroup.values() do
                                        geByGroup.properties.update(propKey, propValue)
                                    end
                                else
                                    guiElement.properties.update(propKey, propValue)
                                end
                            end
                        end
                    end
                    
                    if guiRow.id != "" then
                        guiRow.states.insert(guiRowState.id, guiRowState)?
                    elseif guiCol.id != "" then
                        guiCol.states.insert(guiColState.id, guiColState)?
                    elseif guiElementState.id != "" then
                        if guiElementsByGroup.size() > 0 then
                            for geByGroup in guiElementsByGroup.values() do
                                geByGroup.states.insert(guiElementState.id, guiElementState)?
                            end
                        else
                            guiElement.states.insert(guiElementState.id, guiElementState)?
                        end
                    end
                | "event" =>
                    gp.next()?
                    
                    var import = false
                    var guiEvent = GuiEvent
                    
                    var guiEventsByGroup = Array[GuiEvent]
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value: String val = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            
                            match key
                            | "import" =>
                                load(value)?
                                import = true
                                break
                            | "id" | "group" =>
                                for row in app.gui.values() do
                                    if row.id == value then
                                        guiEvent.id = row.id
                                        break
                                    end
                                    
                                    for col in row.cols.values() do
                                        if col.id == value then
                                            guiEvent.id = col.id
                                            break
                                        end
                                        
                                        for element in col.elements.values() do
                                            if key == "group" then
                                                if element.group == value then
                                                    guiEvent.group = element.group
                                                    guiEventsByGroup.push(guiEvent)
                                                end
                                            else
                                                if element.id == value then
                                                    guiEvent.id = element.id
                                                    break
                                                end
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
                                if (key == "group") and (guiEventsByGroup.size() > 0) then
                                    for geByGroup in guiEventsByGroup.values() do
                                        geByGroup.eventType = value
                                    end
                                else
                                    guiEvent.eventType = value
                                end
                            else
                                error
                            end
                        end
                    end
                    
                    if import then
                        continue
                    elseif (guiEvent.id == "") and (guiEvent.eventType != "resize") and
                           (guiEventsByGroup.size() == 0) then
                        app.logAndExit("The event command has a missing or invalid \"id\" property.", false)?
                    end
                    
                    if guiEvent.eventType == "" then
                        app.logAndExit("The event command has a missing \"type\" property.", false)?
                    end
                    
                    if guiEventsByGroup.size() == 0 then
                        guiEventsByGroup.push(guiEvent)
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
                            var stateId: String val = ""
                            var dataVar: String val = ""
                            var dataVal: String val = ""
                            var whenVar: String val = ""
                            var whenCon: String val = ""
                            var whenVal: String val = ""
                            var elseVar: String val = ""
                            var elseVal: String val = ""
                            
                            match command
                            | "run" =>
                                runType = eventCommand(1)?
                                stateId = eventCommand(2)?
                            | "set" =>
                                dataVar = eventCommand(1)?
                                dataVal = eventCommand(2)?
                            else
                                error
                            end
                            
                            if (runType != "") and (runType != "state") and (runType != "api") then
                                error
                            end
                            
                            whenVar = try eventCommand(4)? else "" end
                            whenCon = try eventCommand(5)? else
                                if whenVar == "" then "" else error end
                            end
                            whenVal = try eventCommand(6)? else
                                if whenVar == "" then "" else error end
                            end
                            
                            elseVar = try eventCommand(8)? else "" end
                            elseVal = try eventCommand(9)? else
                                if elseVar == "" then "" else error end
                            end
                            
                            let gec: GuiEventCommand ref = GuiEventCommand
                            gec.command = command
                            gec.runType = runType.clone().>strip("\"").>replace(placeholder, " ")
                            gec.stateId = stateId.clone().>strip("\"").>replace(placeholder, " ")
                            gec.dataVar = dataVar.clone().>strip("\"").>replace(placeholder, " ")
                            gec.dataVal = dataVal.clone().>strip("\"").>replace(placeholder, " ")
                            gec.whenVar = whenVar.clone().>strip("\"").>replace(placeholder, " ")
                            gec.whenCon = whenCon.clone().>strip("\"").>replace(placeholder, " ")
                            gec.whenVal = whenVal.clone().>strip("\"").>replace(placeholder, " ")
                            gec.elseVar = elseVar.clone().>strip("\"").>replace(placeholder, " ")
                            gec.elseVal = elseVal.clone().>strip("\"").>replace(placeholder, " ")
                            
                            for geByGroup in guiEventsByGroup.values() do
                                geByGroup.commands.push(gec)
                            end
                        end
                    end
                    
                    for geByGroup in guiEventsByGroup.values() do
                        if app.events.contains(geByGroup.eventType) then
                            app.events(geByGroup.eventType)?.push(geByGroup)
                        else
                            app.events.insert(geByGroup.eventType, [geByGroup])?
                        end
                    end
                else
                    error
                end
            else
                app.logAndExit("The \"" + fileName + "\" file has invalid syntax on line " + 
                                lineCount.string() + ".", false)?
            end
        end
        
        if (fileName != "layout.gui") or (app.liveMode and (fileName != app.liveFile)) then
            return
        end
        
        file.dispose()
        
        /* some debugging to verify we are parsing things properly
        
        for myRow in app.gui.values() do
            Debug.out("\nRow")
            Debug.out("-----------------\n")
            Debug.out("id = " + myRow.id)
            Debug.out("height = " + myRow.height.string())
            
            if myRow.cols.values().has_next() then
                Debug.out("\nCol")
                
                for myCol in myRow.cols.values() do
                    Debug.out("-----------------\n")
                    Debug.out("id = " + myCol.id)
                    Debug.out("width = " + myCol.width.string())
                    
                    if myCol.elements.values().has_next() then
                        Debug.out("\nElements")
                        
                        for myElement in myCol.elements.values() do
                            Debug.out("------------------\n")
                            Debug.out("id = " + myElement.id)
                            Debug.out("command = " + myElement.command)
                            
                            for myProp in myElement.properties.pairs() do
                                Debug.out(myProp._1 + " = " + myProp._2)
                            end
                            
                            for myGuiState in myElement.states.values() do
                                Debug.out("\nstate id = " + myGuiState.id)
                                
                                for myGuiStateProp in myGuiState.properties.pairs() do
                                    Debug.out(myGuiStateProp._1 + " = " + myGuiStateProp._2)
                                end
                            end
                            
                            if myCol.elements.values().has_next() then
                                Debug.out("")
                            end
                        end
                    end
                end
            end
        end
        
        if app.events.pairs().has_next() then
            Debug.out("")
            
            for myEventType in app.events.pairs() do
                Debug.out("Events - " + myEventType._1)
                
                for myEvent in myEventType._2.values() do
                    Debug.out("-----------------\n")
                    Debug.out("id = " + myEvent.id)
                    
                    Debug.out("")
                    
                    for myCommand in myEvent.commands.values() do
                        let myCommandId = if myCommand.stateId == "" then
                            myCommand.dataVar
                        else
                            myCommand.stateId
                        end
                        
                        Debug.out(myCommand.command + " " + myCommandId)
                    end
                    
                    Debug.out("")
                end
            end
        end
        */
        
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
use "collections"
use "debug"
use "files"
use "regex"

class Gui
    var app: App
    
    new create(myApp: App) =>
        app = myApp
    
    fun ref load(fileName: String = "layout.gui")? =>
        let caps = recover val FileCaps.>set(FileRead).>set(FileStat) end
        let filePath = try FilePath(app.out.root as AmbientAuth, fileName, caps)? else 
            app.logAndExit("The \"" + fileName + "\" file is missing or has incorrect permissions.", false)?
            return // this is only here so that the compiler doesn't complain about filePath being None
        end
        
        let file = OpenFile(filePath) as File
        
        var lineCount: I32 = 0
        let lineRegex = Regex("^(row \\d\\/\\d.*)|(col \\d\\/\\d.*)|" + 
            "(draw .*)|(text .*)|(load .*)|(style .*)|(event .*)|(--.*)|($)")?
        
        var rowCounter: USize = 0
        var colCounter: USize = 0
        
        // Group Separator (ASCII 29)
        var placeholder = "\u001D"
        
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
                let lineMatch: String val = lineRegex(line)?(0)?
                let lineMatchClean: String ref = lineMatch.clone()
                
                // get all property values (e.g. value "Pony GUI")
                let lm = MatchIterator(Regex("\"[^\"]+\"")?, lineMatch, 0)
                
                while lm.has_next() do
                    var lmValue = try lm.next()? else break end
                    
                    var lmStart = lmValue.start_pos().isize()
                    var lmEnd = lmValue.end_pos().isize() + 1
                    
                    var lmString: String = lineMatchClean.substring(lmStart, lmEnd)
                    
                    // replace all spaces with a placeholder
                    // it needs to be any character that will never be used in a value
                    // so we can split on spaces when we get an element's properties
                    lineMatchClean.replace(lmString, lmString.clone().>replace(" ", placeholder))
                end
                
                let guiProperties: Array[String] = lineMatchClean.split_by(" ")
                let gp = guiProperties.values()
                
                match guiProperties(0)?
                | "row" =>
                    let height = guiProperties(1)?.split_by("/")
                    
                    var guiRow = GuiRow
                    guiRow.height = height(0)?.f32() / height(1)?.f32()
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        match key
                        | "id" =>
                            if gp.has_next() then
                                guiRow.id = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            end
                        end
                    end
                    
                    app.gui.push(guiRow)
                    
                    rowCounter = rowCounter + 1
                    colCounter = 0
                | "col" =>
                    if rowCounter == 0 then
                        var guiRow = GuiRow
                        guiRow.height = 1
                        
                        app.gui.push(guiRow)
                    
                        rowCounter = 1
                    end
                    
                    let width = guiProperties(1)?.split_by("/")
                    
                    var guiCol = GuiCol
                    guiCol.width = width(0)?.f32() / width(1)?.f32()
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        match key
                        | "id" =>
                            if gp.has_next() then
                                guiCol.id = gp.next()?.clone().>strip("\"").>replace(placeholder, " ")
                            end
                        end
                    end
                    
                    try app.gui(rowCounter - 1)?.cols.push(guiCol) end
                    
                    colCounter = colCounter + 1
                | "text" | "draw" | "load" =>
                    if colCounter == 0 then
                        var guiCol = GuiCol
                        guiCol.width = 1
                        
                        try app.gui(rowCounter - 1)?.cols.push(guiCol) end
                    
                        colCounter = 1
                    end
                    
                    gp.next()?
                    
                    var guiElement = GuiElement
                    
                    while gp.has_next() do
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value = gp.next()?
                            
                            if key == "id" then
                                guiElement.id = value.clone().>replace(placeholder, " ")
                            else
                                guiElement.properties.insert(key, value.clone().>strip("\"").>replace(placeholder, " "))?
                            end
                        end
                    end
                    
                    try app.gui(rowCounter - 1)?.cols(colCounter - 1)?.elements.push(guiElement) end
                | "style" | "event" =>
                    gp.next()?
                    
                    var guiElement = GuiElement
                    
                    if gp.has_next() then
                        let key = gp.next()?
                        
                        if gp.has_next() then
                            let value = gp.next()?
                            
                            match key
                            | "import" =>
                                load(value.clone().>strip("\""))?
                            | "id" =>
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
                    
                    if guiElement.id == "" then
                        continue
                    end
                    
                    while lines.has_next() do
                        line = lines.next().clone().>strip()
                        
                        lineCount = lineCount + 1
                        
                        if line.size() == 0 then
                            continue
                        end
                        
                        let prop: Array[String] = line.split_by(" ")
                        let propKey = prop(0)?
                        
                        if (propKey == "style") or (propKey == "event") then
                            prev = line
                            break
                        else
                            try
                                guiElement.properties.insert(
                                    propKey, prop(1)?.clone().>strip("\"").>replace(placeholder, " ")
                                )?
                            end
                        end
                    end
                    
                    try app.gui(rowCounter - 1)?.cols(colCounter - 1)?.elements.push(guiElement) end
                end
            else
                app.logAndExit("The \"" + fileName + "\" file has invalid syntax on line " + 
                                lineCount.string() + ".", false)?
            end
        end
        
        // some debugging to verify we are parsing things properly
        
        if fileName != "layout.gui" then
            return
        end
        
        let lr = app.gui.values()
                    
        while lr.has_next() do
            let myRow = lr.next()?
            
            Debug.out("\nRow")
            Debug.out("-----------------")
            Debug.out("id = " + myRow.id)
            Debug.out("height = " + myRow.height.string())
            
            let lc = myRow.cols.values()
            
            if lc.has_next() then
                Debug.out("\nCol")
                
                while lc.has_next() do
                    let myCol = lc.next()?
                    
                    Debug.out("-----------------")
                    Debug.out("id = " + myCol.id)
                    Debug.out("width = " + myCol.width.string())
                    
                    let lelements = myCol.elements.values()
            
                    if lelements.has_next() then
                        Debug.out("\nElements")
                        
                        while lelements.has_next() do
                            let myElement = lelements.next()?
                            
                            Debug.out("-----------------")
                            Debug.out("id = " + myElement.id)
                            
                            let lprops = myElement.properties.pairs()
                            
                            if lprops.has_next() then
                                while lprops.has_next() do
                                    let myProp = lprops.next()?
                                    
                                    Debug.out(myProp._1 + " = " + myProp._2)
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
        
        Debug.out("")
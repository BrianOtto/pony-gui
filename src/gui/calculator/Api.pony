use "debug"

class Api
    var screen: RenderElement = RenderElement
    var rTotal: Array[String] = Array[String]
    
    new create() => None
    
    fun ref apply(run: String, ge: GuiEvent, re: CanRunCommands, app: App) =>
        if screen.id == "" then
            for element in app.elements.values() do
                if element.id == "screen" then
                    screen = element
                end
            end
        end
        
        try
            match run
            | "displayNumber" =>
                match re
                | let reType: RenderElement =>
                    let el = re as RenderElement
                    
                    match el.keyCode
                    | "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" | "." =>
                        var number = screen.geState.properties.get_or_else("value", "0")
                        number = if number == "0" then el.keyCode else number + el.keyCode end
                        
                        screen.geState.properties.update("value", number)
                        Render(app).recalc(screen.id, screen)?
                    | "BACKSPACE" =>
                        var number = screen.geState.properties.get_or_else("value", "0")
                        
                        if number != "0" then
                            number = number.substring(0, number.size().isize() - 1)
                            if (number == "") or (number == "-") then number = "0" end
                            
                            screen.geState.properties.update("value", number)
                            Render(app).recalc(screen.id, screen)?
                        end
                    | "DELETE" =>
                        var number = screen.geState.properties.get_or_else("value", "0")
                        
                        screen.geState.properties.update("value", "0")
                        Render(app).recalc(screen.id, screen)?
                    | "ESCAPE" =>
                        rTotal.clear()
                        
                        screen.geState.properties.update("value", "0")
                        Render(app).recalc(screen.id, screen)?
                    | "F9" =>
                        var number = screen.geState.properties.get_or_else("value", "0")
                        
                        if number != "0" then
                            let sign = number.substring(0, 1)
                            
                            if sign == "-" then
                                number = number.substring(1, number.size().isize())
                            else
                                number = "-" + number
                            end
                            
                            screen.geState.properties.update("value", number)
                            Render(app).recalc(screen.id, screen)?
                        end
                    | "/" | "*" | "-" | "+" =>
                        var number = screen.geState.properties.get_or_else("value", "0")
                        
                        rTotal.push(number)
                        rTotal.push(el.keyCode)
                        
                        _total(app)?
                        
                        screen.geState.properties.update("value", "0")
                    | "=" =>
                        var number = screen.geState.properties.get_or_else("value", "0")
                        
                        rTotal.push(number)
                        rTotal.push("=")
                        
                        _total(app)?
                    end
                end
            end
        end
    
    fun ref _total(app: App) ? =>
        let rTotalValues = rTotal.values()
        
        var result:F64 = 0
        var number:F64 = 0
        var operation = ""
        
        while rTotalValues.has_next() do
            number = try rTotalValues.next()?.f64() else 0.0 end
            
            match operation
            | "/" =>
                result = result / number
            | "*" =>
                result = result * number
            | "-" =>
                result = result - number
            | "+" =>
                result = result + number
            else
                result = number
            end
            
            operation = try rTotalValues.next()? else break end
        end
        
        screen.geState.properties.update("value", result.string())
        Render(app).recalc(screen.id, screen)?
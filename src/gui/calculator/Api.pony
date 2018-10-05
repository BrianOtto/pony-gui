use "debug"

class Api
    var app: App
    var screen: RenderElement = RenderElement
    
    new create(myApp: App) =>
        app = myApp
        
        for re in app.elements.values() do
            if re.id == "screen" then
                screen = re
            end
        end
    
    fun ref apply(run: String, ge: GuiEvent, re: CanRunCommands) =>
        try
            match run
            | "displayNumber" =>
                match re
                | let reType: RenderElement =>
                    let el = re as RenderElement
                    
                    screen.geState.properties.update("value", el.keyCode)
                    Render(app).recalc(screen.id, screen)?
                end
            end
        end
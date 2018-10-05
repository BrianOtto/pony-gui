use "debug"

class Api
    var app: App
    
    new create(myApp: App) =>
        app = myApp
    
    fun ref apply(run: String, ge: GuiEvent, re: CanRunCommands) =>
        Debug.out("api call = " + run + " / " + ge.eventType + " / " + re.getId())
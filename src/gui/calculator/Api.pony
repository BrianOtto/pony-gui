use "debug"

class Api
    fun apply(run: String, ge: GuiEvent, re: CanRunCommands, app: App) =>
        Debug.out("api call = " + run + " / " + ge.eventType + " / " + re.getId())
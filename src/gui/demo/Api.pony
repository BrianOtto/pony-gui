use "debug"

class Api
    fun apply(run: String, ge: GuiEvent, re: RenderElement, app: App) =>
        Debug.out("api call = " + run + " / " + ge.eventType + " / " + re.id)
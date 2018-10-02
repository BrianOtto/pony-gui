class GuiEvent
    var id: String = ""
    var group: String = ""
    var eventType: String = ""
    var commands: Array[GuiEventCommand] = Array[GuiEventCommand]

    new create() => None
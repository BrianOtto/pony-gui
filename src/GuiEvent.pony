use "collections"

class GuiEvent
    var id: String = ""
    var eventType: String = ""
    var commands: Array[GuiEventCommand] = Array[GuiEventCommand]

    new create() => None

class GuiEventCommand
    var command: String = ""
    var eventId: String = ""
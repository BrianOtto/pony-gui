use "collections"

class GuiElement
    var id: String = ""
    var command: String = ""
    var properties: Map[String, String] = Map[String, String]
    var events: Array[GuiElement] = Array[GuiElement]

    new create() => None
use "collections"

class GuiElement
    var id: String = ""
    var command: String = ""
    var properties: Map[String, String] = Map[String, String]
    var events: Map[String, Map[String, String]] = Map[String, Map[String, String]]

    new create() => None
use "collections"

class GuiElement
    var id: String = ""
    var command: String = ""
    var properties: Map[String, String] = Map[String, String]
    var states: Array[GuiElement] = Array[GuiElement]

    new create() => None
    
    fun ref clone(): GuiElement =>
        let ge = GuiElement
        
        ge.id = id
        ge.command = command
        ge.properties = properties
        ge.states = states
        
        ge
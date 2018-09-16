use "collections"

class GuiElement
    var id: String = ""
    var command: String = ""
    var properties: Map[String, String] = Map[String, String]
    var states: Map[String, GuiElement] = Map[String, GuiElement]

    new create() => None
    
    fun ref clone(): GuiElement =>
        let ge = GuiElement
        
        ge.id = id
        ge.command = command
        ge.properties = properties.clone()
        ge.states = states.clone()
        
        ge
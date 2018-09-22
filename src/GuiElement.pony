use "collections"

class GuiElement
    var id: String = ""
    var command: String = ""
    var properties: Map[String, String] = Map[String, String]
    var states: Map[String, GuiElement] = Map[String, GuiElement]

    new create() => None
    
    fun ref clone(ge: GuiElement = GuiElement, cloneStates: Bool = false): GuiElement =>
        ge.id = id
        ge.command = command
        ge.properties = properties.clone()
        
        if cloneStates then
            ge.states = states.clone()
        end
        
        ge
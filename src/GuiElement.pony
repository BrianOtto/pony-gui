use "collections"

class GuiElement
    var guid: U32 = -1
    var id: String = ""
    var group: String = ""
    var modCode: String = ""
    var keyCode: String = ""
    var command: String = ""
    var properties: Map[String, String] = Map[String, String]
    var states: Map[String, GuiElement] = Map[String, GuiElement]

    new create() => None
    
    fun ref clone(ge: GuiElement = GuiElement, cloneStates: Bool = false): GuiElement =>
        ge.guid = guid
        ge.id = id
        ge.group = group
        ge.modCode = modCode
        ge.keyCode = keyCode
        ge.command = command
        ge.properties = properties.clone()
        
        if cloneStates then
            ge.states = states.clone()
        end
        
        ge
use "collections"

class GuiCol
    var id: String = ""
    var width: F32 = 0
    var elements: Array[GuiElement] = Array[GuiElement]
    var states: Map[String, GuiCol] = Map[String, GuiCol]
    
    new create() => None
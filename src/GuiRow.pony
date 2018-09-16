use "collections"

class GuiRow
    var id: String = ""
    var height: F32 = 0
    var cols: Array[GuiCol] = Array[GuiCol]
    var states: Map[String, GuiRow] = Map[String, GuiRow]

    new create() => None
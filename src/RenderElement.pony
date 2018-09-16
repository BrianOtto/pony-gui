use "collections"
use "debug"

use sdl = "sdl"

class RenderElement is ICanRunCommands
    var id: String = ""
    var ge: GuiElement = GuiElement
    var cursor: String = "arrow"
    var callbacks: Array[{ref (): Any val}] = []
    var texture: Pointer[sdl.Texture] = Pointer[sdl.Texture]
    var rect: sdl.Rect = sdl.Rect
    var states: Map[String, RenderElement] = Map[String, RenderElement]
    var _data: Map[String, String] = Map[String, String]
    
    new create() => None
    
    fun ref clone(): RenderElement =>
        let re = RenderElement
        
        re.id = id
        re.ge = ge.clone()
        re.cursor = cursor
        re.callbacks = callbacks.clone()
        re.texture = texture
        re.rect = rect
        re.states = states.clone()
        re._data = _data.clone()
        
        re
    
    fun ref getId(): String =>
        id
    
    fun ref getData(): Map[String, String] =>
        _data
    
    fun ref setDataValue(key: String, value: String): None =>
        Debug.out("set " + key + " = " + value)
        
        _data.update(key, value)
    
    fun ref getDataValue(key: String): String ? =>
        _data(key)?
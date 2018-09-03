use "collections"
use "debug"

use sdl = "sdl"

class RenderElement
    var id: String = ""
    var cursor: String = "arrow"
    var callbacks: Array[{ref (): Any val}] = []
    var texture: Pointer[sdl.Texture] = Pointer[sdl.Texture]
    var rect: sdl.Rect = sdl.Rect
    var events: Map[String, RenderElement] = Map[String, RenderElement]
    var _data: Map[String, String] = Map[String, String]
    
    new create() => None
    
    fun ref clone(): RenderElement =>
        let re = RenderElement
        
        re.id = id
        re.cursor = cursor
        re.callbacks = callbacks
        re.texture = texture
        re.rect = rect
        re.events = events
        re._data = _data
        
        re
    
    fun ref getData(): Map[String, String] =>
        _data
    
    fun ref setDataValue(key: String, value: String): None =>
        Debug.out("set " + key + " = " + value)
        
        _data.update(key, value)
    
    fun ref getDataValue(key: String): String ? =>
        _data(key)?
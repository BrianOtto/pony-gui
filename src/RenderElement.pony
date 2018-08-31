use "collections"

use sdl = "sdl"

class RenderElement
    var id: String = ""
    var callbacks: Array[{ref (): Any val}] = []
    var texture: Pointer[sdl.Texture] = Pointer[sdl.Texture]
    var textureLast: Pointer[sdl.Texture] = Pointer[sdl.Texture]
    var rect: sdl.Rect = sdl.Rect
    var rectLast: sdl.Rect = sdl.Rect
    var events: Map[String, RenderElement] = Map[String, RenderElement]
    var data: Map[String, String] = Map[String, String]
    
    new create() => None
    
    fun ref clone(): RenderElement =>
        let re = RenderElement
        
        re.id = id
        re.callbacks = callbacks
        re.texture = texture
        re.textureLast = textureLast
        re.rect = rect
        re.rectLast = rectLast
        re.events = events
        re.data = data
        
        re
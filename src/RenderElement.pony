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
    
    new create(t: Pointer[sdl.Texture] = Pointer[sdl.Texture], r: sdl.Rect = sdl.Rect) =>
        texture = t
        rect = r
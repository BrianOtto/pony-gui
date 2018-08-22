use sdl = "sdl"

class RenderElement
    var texture: Pointer[sdl.Texture]
    var rect: sdl.Rect
    
    new create(t: Pointer[sdl.Texture], r: sdl.Rect) =>
        texture = t
        rect = r
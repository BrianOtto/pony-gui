use sdl = "sdl"

class RenderElement
    var callbacks: Array[{ref (): Any val}] = []
    var texture: Pointer[sdl.Texture] = Pointer[sdl.Texture]
    var rect: sdl.Rect = sdl.Rect
    
    new create(t: Pointer[sdl.Texture] = Pointer[sdl.Texture], r: sdl.Rect = sdl.Rect) =>
        texture = t
        rect = r
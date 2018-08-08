use "lib:sdl-gfx/SDL2_GFX" if windows

use sdl = "../sdl"

// Functions

primitive CircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @circleColor[I32](renderer, x, y, rad, color)

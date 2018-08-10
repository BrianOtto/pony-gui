use "lib:sdl-gfx/SDL2_GFX" if windows

use sdl = "../sdl"

// Functions

primitive AACircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @aacircleColor[I32](renderer, x, y, rad, color)

primitive CircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @circleColor[I32](renderer, x, y, rad, color)

primitive FilledCircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @filledCircleColor[I32](renderer, x, y, rad, color)
use "lib:sdl-gfx/SDL2_GFX" if windows

use sdl = "../sdl"

// Functions

primitive AACircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @aacircleColor[I32](renderer, x, y, rad, color)

primitive AACircleRGBA
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, r: U8, g: U8, b: U8, a: U8): I32 =>
        @aacircleRGBA[I32](renderer, x, y, rad, r, g, b, a)

primitive CircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @circleColor[I32](renderer, x, y, rad, color)

primitive CircleRGBA
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, r: U8, g: U8, b: U8, a: U8): I32 =>
        @circleRGBA[I32](renderer, x, y, rad, r, g, b, a)

primitive FilledCircleColor
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @filledCircleColor[I32](renderer, x, y, rad, color)

primitive FilledCircleRGBA
    fun @apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, r: U8, g: U8, b: U8, a: U8): I32 =>
        @filledCircleRGBA[I32](renderer, x, y, rad, r, g, b, a)
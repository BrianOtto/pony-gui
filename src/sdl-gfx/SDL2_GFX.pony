use "lib:sdl-gfx/SDL2_GFX" if windows

use sdl = "../sdl"

// Functions

primitive AACircleColor
    fun apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @aacircleColor[I32](renderer, x, y, rad, ConvertColor(color))

primitive AACircleRGBA
    fun apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, r: U8, g: U8, b: U8, a: U8): I32 =>
        @aacircleRGBA[I32](renderer, x, y, rad, r, g, b, a)

primitive CircleColor
    fun apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @circleColor[I32](renderer, x, y, rad, ConvertColor(color))

primitive CircleRGBA
    fun apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, r: U8, g: U8, b: U8, a: U8): I32 =>
        @circleRGBA[I32](renderer, x, y, rad, r, g, b, a)

primitive FilledCircleColor
    fun apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, color: U32): I32 =>
        @filledCircleColor[I32](renderer, x, y, rad, ConvertColor(color))

primitive FilledCircleRGBA
    fun apply(renderer: Pointer[sdl.Renderer], x: I16, y: I16, rad: I16, r: U8, g: U8, b: U8, a: U8): I32 =>
        @filledCircleRGBA[I32](renderer, x, y, rad, r, g, b, a)

// Custom (for Pony or platform specific issues)

primitive ConvertColor
    fun apply(color: U32): U32 =>
        var colorLE: U32 = color
        
        ifdef windows then
            // convert to little endian
            colorLE = (((color << 24) and 0xFF000000) or ((color << 8) and 0x00FF0000) or 
                       ((color >> 8) and 0x0000FF00) or ((color >> 24) and 0x000000FF))
        end
        
        colorLE
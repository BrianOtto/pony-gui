use "lib:sdl-ttf/SDL2_TTF" if windows

use sdl = "../sdl"

// Pointers

primitive Font

// Functions

primitive CloseFont
    fun @apply(font: Pointer[Font]): None =>
        @TTF_CloseFont[None](font)

primitive GetError
    fun @apply(): Pointer[U8] =>
        sdl.GetError()

primitive Init
    fun @apply(): U32 =>
        @TTF_Init[U32]()

primitive OpenFont
    fun @apply(file: String, ptsize: I32): Pointer[Font] =>
        @TTF_OpenFont[Pointer[Font]](file.cstring(), ptsize)

primitive RenderUTF8Blended
    fun @apply(font: Pointer[Font], text: String, fg: U32 /* fg: sdl.Color */): Pointer[sdl.Surface] =>
        @TTF_RenderUTF8_Blended[Pointer[sdl.Surface]](font, text.cstring(), ConvertColor(fg))

primitive RenderUTF8Shaded
    fun @apply(font: Pointer[Font], text: String, fg: U32 /* fg: sdl.Color */): Pointer[sdl.Surface] =>
        @TTF_RenderUTF8_Shaded[Pointer[sdl.Surface]](font, text.cstring(), ConvertColor(fg))

primitive RenderUTF8Solid
    fun @apply(font: Pointer[Font], text: String, fg: U32 /* fg: sdl.Color */): Pointer[sdl.Surface] =>
        @TTF_RenderUTF8_Solid[Pointer[sdl.Surface]](font, text.cstring(), ConvertColor(fg))

primitive Quit
    fun @apply(): None =>
        @TTF_Quit[None]()

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
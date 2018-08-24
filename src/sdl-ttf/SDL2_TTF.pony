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
        var fgLE: U32 = fg
        
        ifdef windows then
            // convert to little endian
            fgLE = (((fg << 24) and 0xFF000000) or ((fg << 8) and 0x00FF0000) or
                    ((fg >> 8) and 0x0000FF00) or ((fg >> 24) and 0x000000FF))
        end
        
        @TTF_RenderUTF8_Blended[Pointer[sdl.Surface]](font, text.cstring(), fgLE)

primitive RenderUTF8Shaded
    fun @apply(font: Pointer[Font], text: String, fg: U32 /* fg: sdl.Color */): Pointer[sdl.Surface] =>
        var fgLE: U32 = fg
        
        ifdef windows then
            // convert to little endian
            fgLE = (((fg << 24) and 0xFF000000) or ((fg << 8) and 0x00FF0000) or
                    ((fg >> 8) and 0x0000FF00) or ((fg >> 24) and 0x000000FF))
        end
        
        @TTF_RenderUTF8_Shaded[Pointer[sdl.Surface]](font, text.cstring(), fgLE)

primitive RenderUTF8Solid
    fun @apply(font: Pointer[Font], text: String, fg: U32 /* fg: sdl.Color */): Pointer[sdl.Surface] =>
        var fgLE: U32 = fg
        
        ifdef windows then
            // convert to little endian
            fgLE = (((fg << 24) and 0xFF000000) or ((fg << 8) and 0x00FF0000) or
                    ((fg >> 8) and 0x0000FF00) or ((fg >> 24) and 0x000000FF))
        end
        
        @TTF_RenderUTF8_Solid[Pointer[sdl.Surface]](font, text.cstring(), fgLE)

primitive Quit
    fun @apply(): None =>
        @TTF_Quit[None]()
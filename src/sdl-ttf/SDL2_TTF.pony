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

primitive RenderTextBlended
    fun @apply(font: Pointer[Font], text: String, color: sdl.Color): Pointer[sdl.Surface] =>
        @TTF_RenderText_Blended[Pointer[sdl.Surface]](font, text.cstring(), color)

primitive RenderTextShaded
    fun @apply(font: Pointer[Font], text: String, color: sdl.Color): Pointer[sdl.Surface] =>
        @TTF_RenderText_Shaded[Pointer[sdl.Surface]](font, text.cstring(), color)

primitive RenderTextSolid
    fun @apply(font: Pointer[Font], text: String, color: sdl.Color): Pointer[sdl.Surface] =>
        @TTF_RenderText_Solid[Pointer[sdl.Surface]](font, text.cstring(), color)

primitive Quit
    fun @apply(): None =>
        @TTF_Quit[None]()
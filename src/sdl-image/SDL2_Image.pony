use "lib:sdl-image/SDL2_Image" if windows

use sdl = "../sdl"

// Flags - Init

primitive INITJPG
    fun apply(): I32 => 0x00000001

primitive INITPNG
    fun apply(): I32 => 0x00000002

primitive INITTIF
    fun apply(): I32 => 0x00000004

primitive INITWEBP
    fun apply(): I32 => 0x00000008

// Functions

primitive GetError
    fun @apply(): Pointer[U8] =>
        sdl.GetError()

primitive Init
    fun @apply(flags: I32): I32 =>
        @IMG_Init[I32](flags)

primitive Load
    fun @apply(file: String): Pointer[sdl.Surface] =>
        @IMG_Load[Pointer[sdl.Surface]](file.cstring())

primitive Quit
    fun @apply(): None =>
        @IMG_Quit[None]()

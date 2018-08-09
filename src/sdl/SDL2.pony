use "lib:sdl/SDL2" if windows

use "debug"

// Flags - Event

primitive EVENTQUIT
    fun apply(): U32 => 0x100

// Flags - Init

primitive INITAUDIO
    fun apply(): U32 => 0x00000010

primitive INITEVENTS
    fun apply(): U32 => 0x00004000

primitive INITEVERYTHING
    fun apply(): U32 => INITAUDIO() or INITEVENTS() or INITGAMECONTROLLER() or 
                        INITHAPTIC() or INITJOYSTICK() or INITTIMER() or INITVIDEO()

primitive INITGAMECONTROLLER
    fun apply(): U32 => 0x00002000 // implies INIT_JOYSTICK

primitive INITHAPTIC
    fun apply(): U32 => 0x00001000

primitive INITJOYSTICK
    fun apply(): U32 => 0x00000200 // implies INIT_EVENTS

primitive INITNOPARACHUTE
    fun apply(): U32 => 0x00000001 // this is ignored

primitive INITTIMER
    fun apply(): U32 => 0x00000001

primitive INITVIDEO
    fun apply(): U32 => 0x00000020 // implies INIT_EVENTS

// Flags - Renderer

primitive RENDERERACCELERATED
    fun apply(): U32 => 0x00000002

primitive RENDERERPRESENTVSYNC
    fun apply(): U32 => 0x00000004

primitive RENDERERSOFTWARE
    fun apply(): U32 => 0x00000001

primitive RENDERERTARGETTEXTURE
    fun apply(): U32 => 0x00000008

// Flags - Window

primitive WINDOWSHOWN
    fun apply(): U32 => 0x00000004

// TODO: Add the remaining window flags

// Structs

struct Color
    var r: U8 = 0
    var g: U8 = 0
    var b: U8 = 0
    var a: U8 = 0
    
    new create() => None

struct Event
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var windowID: U32 = 0
    var event: U8 = 0
    var data1: I32 = 0
    var data2: I32 = 0
    
    new create() => None

struct Rect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0
    
    new create() => None

// Pointers

primitive Renderer
primitive Surface
primitive Texture
primitive Window

// Functions

primitive CreateRenderer
    fun @apply(window: Pointer[Window], index: I32, flags: U32): Pointer[Renderer] =>
        @SDL_CreateRenderer[Pointer[Renderer]](window, index, flags)

primitive CreateTextureFromSurface
    fun @apply(renderer: Pointer[Renderer], surface: Pointer[Surface]): Pointer[Texture] =>
        @SDL_CreateTextureFromSurface[Pointer[Texture]](renderer, surface)

primitive CreateWindow
    fun @apply(title: String, x: I32, y: I32, w: I32, h: I32, flags: U32): Pointer[Window] =>
        @SDL_CreateWindow[Pointer[Window]](title.cstring(), x, y, w, h, flags)

primitive Delay
    fun @apply(ms: U32): None =>
        @SDL_Delay[None](ms)

primitive DestroyRenderer
    fun @apply(renderer: Pointer[Renderer]): None =>
        @SDL_DestroyRenderer[None](renderer)

primitive DestroyWindow
    fun @apply(window: Pointer[Window]): None =>
        @SDL_DestroyWindow[None](window)

primitive FreeSurface
    fun @apply(surface: Pointer[Surface]): None =>
        @SDL_FreeSurface[None](surface)

primitive GetError
    fun @apply(): Pointer[U8] =>
        @SDL_GetError[Pointer[U8]]()

primitive Init
    fun @apply(flags: U32): U32 =>
        @SDL_Init[U32](flags)

primitive PollEvent
    fun @apply(event: MaybePointer[Event]): I32 =>
        @SDL_PollEvent[I32](event)

primitive QueryTexture
    fun @apply(texture: Pointer[Texture], format: Pointer[U32], access: Pointer[I32], 
               w: Pointer[I32], h: Pointer[I32]): U32 =>
        
        // Pony does not allow us to pass a pointer to a struct member
        // and so this function can not be wrapped and must be called directly
        // e.g. @SDL_QueryTexture[U32](texture, Pointer[U32], Pointer[I32], addressof rect.w, addressof rect.h)
        
        try error else Debug.out("Please see the note in SDL2.pony @ QueryTexture") end
        
        // @SDL_QueryTexture[U32](texture, format, access, w, h)
        
        -1

primitive RenderClear
    fun @apply(renderer: Pointer[Renderer]): U32 =>
        @SDL_RenderClear[U32](renderer)

primitive RenderCopy
    fun @apply(renderer: Pointer[Renderer], texture: Pointer[Texture], 
               srcrect: Pointer[Rect], dstrect: MaybePointer[Rect]): U32 =>
        @SDL_RenderCopy[U32](renderer, texture, srcrect, dstrect)

primitive RenderPresent
    fun @apply(renderer: Pointer[Renderer]): None =>
        @SDL_RenderPresent[None](renderer)

primitive SetRenderDrawColor
    fun @apply(renderer: Pointer[Renderer], r: U8, g: U8, b: U8, a: U8): U32 =>
        @SDL_SetRenderDrawColor[U32](renderer, r, g, b, a)

primitive Quit
    fun @apply(): None =>
        @SDL_Quit[None]()

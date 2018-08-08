use "lib:sdl/SDL2" if windows

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

struct Event
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var windowID: U32 = 0
    var event: U8 = 0
    var data1: I32 = 0
    var data2: I32 = 0
    
    new create() => None

// Pointers

primitive Renderer
primitive Window

// Functions

primitive CreateRenderer
    fun @apply(window: Pointer[Window], index: I32, flags: U32): Pointer[Renderer] =>
        @SDL_CreateRenderer[Pointer[Renderer]](window, index, flags)

primitive CreateWindow
    fun @apply(title: String, x: I32, y: I32, w: I32, h: I32, flags: U32): Pointer[Window] =>
        @SDL_CreateWindow[Pointer[Window]](title.cstring(), x, y, w, h, flags)

primitive Delay
    fun @apply(ms: U32): I32 =>
        @SDL_Delay[I32](ms)

primitive DestroyRenderer
    fun @apply(renderer: Pointer[Renderer]): None =>
        @SDL_DestroyRenderer[None](renderer)

primitive DestroyWindow
    fun @apply(window: Pointer[Window]): None =>
        @SDL_DestroyWindow[None](window)

primitive Init
    fun @apply(flags: U32): I32 =>
        @SDL_Init[I32](flags)

primitive PollEvent
    fun @apply(event: MaybePointer[Event]): I32 =>
        @SDL_PollEvent[I32](event)

primitive RenderClear
    fun @apply(renderer: Pointer[Renderer]): I32 =>
        @SDL_RenderClear[I32](renderer)

primitive RenderPresent
    fun @apply(renderer: Pointer[Renderer]): None =>
        @SDL_RenderPresent[None](renderer)

primitive SetRenderDrawColor
    fun @apply(renderer: Pointer[Renderer], r: U8, g: U8, b: U8, a: U8): I32 =>
        @SDL_SetRenderDrawColor[I32](renderer, r, g, b, a)

primitive Quit
    fun @apply(): None =>
        @SDL_Quit[None]()

use "lib:sdl/SDL2" if windows

// Flags - Button

primitive BUTTONLEFT
    fun apply(): U8 => 1

primitive BUTTONMIDDLE
    fun apply(): U8 => 2

primitive BUTTONRIGHT
    fun apply(): U8 => 3

primitive BUTTONX1
    fun apply(): U8 => 4

primitive BUTTONX2
    fun apply(): U8 => 5

// Flags - Cursor

primitive CURSORARROW
    fun apply(): U8 => 0

primitive CURSORCROSSHAIR
    fun apply(): U8 => 3

primitive CURSORHAND
    fun apply(): U8 => 11

primitive CURSORIBEAM
    fun apply(): U8 => 1

primitive CURSORNO
    fun apply(): U8 => 10

primitive CURSORSIZEALL
    fun apply(): U8 => 9

primitive CURSORSIZENESW
    fun apply(): U8 => 6

primitive CURSORSIZENS
    fun apply(): U8 => 8

primitive CURSORSIZENWSE
    fun apply(): U8 => 5

primitive CURSORSIZEWE
    fun apply(): U8 => 7

primitive CURSORWAIT
    fun apply(): U8 => 2

primitive CURSORWAITARROW
    fun apply(): U8 => 4

// Flags - Event

primitive EVENTFIRSTEVENT
    fun apply(): U32 => 0x000

primitive EVENTKEYDOWN
    fun apply(): U32 => 0x300

primitive EVENTKEYUP
    fun apply(): U32 => 0x301

primitive EVENTLASTEVENT
    fun apply(): U32 => 0xFFFF

primitive EVENTMOUSEBUTTONDOWN
    fun apply(): U32 => 0x401

primitive EVENTMOUSEBUTTONUP
    fun apply(): U32 => 0x402

primitive EVENTMOUSEMOTION
    fun apply(): U32 => 0x400

primitive EVENTMOUSEWHEEL
    fun apply(): U32 => 0x403

primitive EVENTQUIT
    fun apply(): U32 => 0x100

// Flags - Event Action

primitive EVENTACTIONADDEVENT
    fun apply(): I32 => 0

primitive EVENTACTIONGETEVENT
    fun apply(): I32 => 2

primitive EVENTACTIONPEEKEVENT
    fun apply(): I32 => 1

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

// Flags - State

primitive STATEPRESSED
    fun apply(): U8 => 1

primitive STATERELEASED
    fun apply(): U8 => 0

// Flags - Window

primitive WINDOWALWAYSONTOP
    fun apply(): U32 => 0x00008000

primitive WINDOWBORDERLESS
    fun apply(): U32 => 0x00000010

primitive WINDOWFULLSCREEN
    fun apply(): U32 => 0x00000001

primitive WINDOWFULLSCREENDESKTOP
    // uses the current desktop resolution
    fun apply(): U32 => WINDOWFULLSCREEN() or 0x00001000

primitive WINDOWHIDDEN
    fun apply(): U32 => 0x00000008

primitive WINDOWINPUTFOCUS
    fun apply(): U32 => 0x00000200

primitive WINDOWINPUTGRABBED
    fun apply(): U32 => 0x00000100

primitive WINDOWMAXIMIZED
    fun apply(): U32 => 0x00000080

primitive WINDOWMINIMIZED
    fun apply(): U32 => 0x00000040

primitive WINDOWMOUSEFOCUS
    fun apply(): U32 => 0x00000400

primitive WINDOWOPENGL
    fun apply(): U32 => 0x00000002

primitive WINDOWRESIZABLE
    fun apply(): U32 => 0x00000020

primitive WINDOWSHOWN
    fun apply(): U32 => 0x00000004

primitive WINDOWVULKAN
    fun apply(): U32 => 0x10000000

// TODO: Add the remaining window flags

// Structs

struct Color
    var r: U8 = 0
    var g: U8 = 0
    var b: U8 = 0
    var a: U8 = 0
    
    new create() => None

struct CommonEvent
    var eventType: U32 = 0
    var timestamp: U32 = 0
    
    new create() => None

struct KeyboardEvent
    // TODO
    
    new create() => None

struct MouseButtonEvent
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var windowID: U32 = 0
    var which: U32 = 0
    var button: U8 = 0
    var state: U8 = 0
    var clicks: U8 = 0
    var padding1: U8 = 0
    var x: I32 = 0
    var y: I32 = 0
    
    new create() => None

struct MouseMotionEvent
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var windowID: U32 = 0
    var which: U32 = 0
    var state: U32 = 0
    var x: I32 = 0
    var y: I32 = 0
    var xrel: I32 = 0
    var yrel: I32 = 0
    
    new create() => None

struct MouseWheelEvent
    // TODO
    
    new create() => None

struct Rect
    var x: I32 = 0
    var y: I32 = 0
    var w: I32 = 0
    var h: I32 = 0
    
    new create() => None

struct TextEditingEvent
    // TODO
    
    new create() => None

struct TextInputEvent
    // TODO
    
    new create() => None

struct WindowEvent
    // TODO
    
    new create() => None

// Pointers

primitive Cursor
primitive Renderer
primitive Surface
primitive Texture
primitive Window

// Functions

primitive CreateRenderer
    fun apply(window: Pointer[Window], index: I32, flags: U32): Pointer[Renderer] =>
        @SDL_CreateRenderer[Pointer[Renderer]](window, index, flags)

primitive CreateSystemCursor
    fun apply(cursor: U8): Cursor =>
        @SDL_CreateSystemCursor[Cursor](cursor)

primitive CreateTextureFromSurface
    fun apply(renderer: Pointer[Renderer], surface: Pointer[Surface]): Pointer[Texture] =>
        @SDL_CreateTextureFromSurface[Pointer[Texture]](renderer, surface)

primitive CreateWindow
    fun apply(title: String, x: I32, y: I32, w: I32, h: I32, flags: U32): Pointer[Window] =>
        @SDL_CreateWindow[Pointer[Window]](title.cstring(), x, y, w, h, flags)

primitive Delay
    fun apply(ms: U32): None =>
        @SDL_Delay[None](ms)

primitive DestroyRenderer
    fun apply(renderer: Pointer[Renderer]): None =>
        @SDL_DestroyRenderer[None](renderer)

primitive DestroyWindow
    fun apply(window: Pointer[Window]): None =>
        @SDL_DestroyWindow[None](window)

primitive FreeSurface
    fun apply(surface: Pointer[Surface]): None =>
        @SDL_FreeSurface[None](surface)

primitive GetError
    fun apply(): Pointer[U8] =>
        @SDL_GetError[Pointer[U8]]()

primitive Init
    fun apply(flags: U32): U32 =>
        @SDL_Init[U32](flags)

primitive PumpEvents
    fun apply(): None =>
        @SDL_PumpEvents[None]()

primitive QueryTexture
    fun apply(texture: Pointer[Texture], format: Pointer[U32], access: Pointer[I32], rect: Rect): U32 =>
        @SDL_QueryTexture[U32](texture, Pointer[U32], Pointer[I32], addressof rect.w, addressof rect.h)

primitive RenderClear
    fun apply(renderer: Pointer[Renderer]): U32 =>
        @SDL_RenderClear[U32](renderer)

primitive RenderCopy
    fun apply(renderer: Pointer[Renderer], texture: Pointer[Texture], 
               srcrect: Pointer[Rect], dstrect: MaybePointer[Rect]): U32 =>
        @SDL_RenderCopy[U32](renderer, texture, srcrect, dstrect)

primitive RenderPresent
    fun apply(renderer: Pointer[Renderer]): None =>
        @SDL_RenderPresent[None](renderer)

primitive SetCursor
    fun apply(cursor: Cursor): None =>
        @SDL_SetCursor[None](cursor)

primitive SetRenderDrawColor
    fun apply(renderer: Pointer[Renderer], r: U8, g: U8, b: U8, a: U8): U32 =>
        @SDL_SetRenderDrawColor[U32](renderer, r, g, b, a)

primitive Quit
    fun apply(): None =>
        @SDL_Quit[None]()

// Custom (for Pony or platform specific issues)

primitive PeekEvent
    fun apply(event: MaybePointer[CommonEvent]): I32 =>
        @SDL_PeepEvents[I32](event, I32(1), EVENTACTIONPEEKEVENT(), EVENTFIRSTEVENT(), EVENTLASTEVENT())

primitive PollCommonEvent
    fun apply(event: MaybePointer[CommonEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollMouseButtonEvent
    fun apply(event: MaybePointer[MouseButtonEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollMouseMotionEvent
    fun apply(event: MaybePointer[MouseMotionEvent]): I32 =>
        @SDL_PollEvent[I32](event)
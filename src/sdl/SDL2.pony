use "lib:sdl/SDL2" if windows

use win = "../win"

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

primitive EVENTSYSWMEVENT
    fun apply(): U32 => 0x201

primitive EVENTWINDOWEVENT
    fun apply(): U32 => 0x200

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

// Flags - Key Mod

primitive KEYMODALT
    fun apply(): U16 => KEYMODLALT() or KEYMODRALT()

primitive KEYMODCAPS
    fun apply(): U16 => 0x2000

primitive KEYMODCTRL
    fun apply(): U16 => KEYMODLCTRL() or KEYMODRCTRL()

primitive KEYMODGUI
    fun apply(): U16 => KEYMODLGUI() or KEYMODRGUI()

primitive KEYMODLALT
    fun apply(): U16 => 0x0100

primitive KEYMODLCTRL
    fun apply(): U16 => 0x0040

primitive KEYMODLGUI
    fun apply(): U16 => 0x0400

primitive KEYMODLSHIFT
    fun apply(): U16 => 0x0001

primitive KEYMODMODE
    fun apply(): U16 => 0x4000

primitive KEYMODNONE
    fun apply(): U16 => 0x0000

primitive KEYMODNUM
    fun apply(): U16 => 0x1000

primitive KEYMODRALT
    fun apply(): U16 => 0x0200

primitive KEYMODRCTRL
    fun apply(): U16 => 0x0080

primitive KEYMODRESERVED
    fun apply(): U16 => 0x8000

primitive KEYMODRGUI
    fun apply(): U16 => 0x0800

primitive KEYMODRSHIFT
    fun apply(): U16 => 0x0002

primitive KEYMODSHIFT
    fun apply(): U16 => KEYMODLSHIFT() or KEYMODRSHIFT()

// Flags - Mask

primitive MASKSCANCODE
    fun apply(): I32 => 0x40000000

// Flags - Packed Layout

primitive PACKEDLAYOUT332
    fun apply(): U32 => 1

primitive PACKEDLAYOUT565
    fun apply(): U32 => 5

primitive PACKEDLAYOUT1555
    fun apply(): U32 => 3

primitive PACKEDLAYOUT4444
    fun apply(): U32 => 2

primitive PACKEDLAYOUT5551
    fun apply(): U32 => 4

primitive PACKEDLAYOUT8888
    fun apply(): U32 => 6

primitive PACKEDLAYOUT1010102
    fun apply(): U32 => 8

primitive PACKEDLAYOUT2101010
    fun apply(): U32 => 7

primitive PACKEDLAYOUTNONE
    fun apply(): U32 => 0

// Flags - Packed Order

primitive PACKEDORDERABGR
    fun apply(): U32 => 7

primitive PACKEDORDERARGB
    fun apply(): U32 => 3

primitive PACKEDORDERBGRA
    fun apply(): U32 => 8

primitive PACKEDORDERBGRX
    fun apply(): U32 => 6

primitive PACKEDORDERNONE
    fun apply(): U32 => 0

primitive PACKEDORDERRGBA
    fun apply(): U32 => 4

primitive PACKEDORDERRGBX
    fun apply(): U32 => 2

primitive PACKEDORDERXBGR
    fun apply(): U32 => 5

primitive PACKEDORDERXRGB
    fun apply(): U32 => 1

// Flags - Pixel Format

primitive PIXELFORMATBGR565
    fun apply(): U32 =>
        DefinePixelFormat(PIXELTYPEPACKED16(), PACKEDORDERXBGR(), PACKEDLAYOUT565(), 16, 2)

// TODO: Add remaining pixel formats

// Flags - Pixel Type

primitive PIXELTYPEARRAYF16
    fun apply(): U32 => 10

primitive PIXELTYPEARRAYF32
    fun apply(): U32 => 11

primitive PIXELTYPEARRAYU8
    fun apply(): U32 => 7

primitive PIXELTYPEARRAYU16
    fun apply(): U32 => 8

primitive PIXELTYPEARRAYU32
    fun apply(): U32 => 9

primitive PIXELTYPEINDEX1
    fun apply(): U32 => 1

primitive PIXELTYPEINDEX4
    fun apply(): U32 => 2

primitive PIXELTYPEINDEX8
    fun apply(): U32 => 3

primitive PIXELTYPEPACKED8
    fun apply(): U32 => 4

primitive PIXELTYPEPACKED16
    fun apply(): U32 => 5

primitive PIXELTYPEPACKED32
    fun apply(): U32 => 6

primitive PIXELTYPEUNKNOWN
    fun apply(): U32 => 0

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

// Flags - Texture Access

primitive TEXTUREACCESSSTATIC
    fun apply(): I32 => 0

primitive TEXTUREACCESSSTREAMING
    fun apply(): I32 => 1

primitive TEXTUREACCESSTARGET
    fun apply(): I32 => 2

// Flags - Window

primitive WINDOWALLOWHIGHDPI
    fun apply(): U32 => 0x00002000

primitive WINDOWALWAYSONTOP
    fun apply(): U32 => 0x00008000

primitive WINDOWBORDERLESS
    fun apply(): U32 => 0x00000010

primitive WINDOWFOREIGN
    fun apply(): U32 => 0x00000800

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

primitive WINDOWMOUSECAPTURE
    fun apply(): U32 => 0x00004000

primitive WINDOWMOUSEFOCUS
    fun apply(): U32 => 0x00000400

primitive WINDOWOPENGL
    fun apply(): U32 => 0x00000002

primitive WINDOWPOPUPMENU
    fun apply(): U32 => 0x00080000

primitive WINDOWRESIZABLE
    fun apply(): U32 => 0x00000020

primitive WINDOWSHOWN
    fun apply(): U32 => 0x00000004

primitive WINDOWSKIPTASKBAR
    fun apply(): U32 => 0x00010000

primitive WINDOWTOOLTIP
    fun apply(): U32 => 0x00040000

primitive WINDOWUTILITY
    fun apply(): U32 => 0x00020000

primitive WINDOWVULKAN
    fun apply(): U32 => 0x10000000

// Flags - Window Event

primitive WINDOWEVENTNONE
    fun apply(): U8 => 0

primitive WINDOWEVENTSHOWN
    fun apply(): U8 => 1

primitive WINDOWEVENTHIDDEN
    fun apply(): U8 => 2

primitive WINDOWEVENTEXPOSED
    fun apply(): U8 => 3

primitive WINDOWEVENTMOVED
    fun apply(): U8 => 4

primitive WINDOWEVENTRESIZED
    fun apply(): U8 => 5

primitive WINDOWEVENTSIZECHANGED
    fun apply(): U8 => 6

primitive WINDOWEVENTMINIMIZED
    fun apply(): U8 => 7

primitive WINDOWEVENTMAXIMIZED
    fun apply(): U8 => 8

primitive WINDOWEVENTRESTORED
    fun apply(): U8 => 9

primitive WINDOWEVENTENTER
    fun apply(): U8 => 10

primitive WINDOWEVENTLEAVE
    fun apply(): U8 => 11

primitive WINDOWEVENTFOCUSGAINED
    fun apply(): U8 => 12

primitive WINDOWEVENTFOCUSLOST
    fun apply(): U8 => 13

primitive WINDOWEVENTCLOSE
    fun apply(): U8 => 14

primitive WINDOWEVENTTAKEFOCUS
    fun apply(): U8 => 15

primitive WINDOWEVENTHITTEST
    fun apply(): U8 => 16

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
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var windowID: U32 = 0
    var state: U8 = 0
    var keyrepeat: U8 = 0
    var keysym: (
        I32, // scancode
        I32, // sym
        U16, // mod
        U32  // unused
    ) = (0, 0, 0, 0)
    
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

struct UserData[A: Any ref] 
    var instance: A
    
    new create(myInstance: A) =>
        instance = myInstance

struct Version
    var major: U8 = 0
    var minor: U8 = 0
    var patch: U8 = 0
    
    new create() => None

struct WindowEvent
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var windowID: U32 = 0
    var event: U8 = 0
    var data1: I32 = 0
    var data2: I32 = 0
    
    new create() => None

// Pointers

primitive Cursor
primitive Renderer
primitive Surface
primitive Texture
primitive Window

// Functions

primitive Button
    fun apply(state: U32): U32 =>
        (1 << ((state) - 1))

primitive CreateRenderer
    fun apply(window: Pointer[Window], index: I32, flags: U32): Pointer[Renderer] =>
        @SDL_CreateRenderer[Pointer[Renderer]](window, index, flags)

primitive CreateSystemCursor
    fun apply(cursor: U8): Cursor =>
        @SDL_CreateSystemCursor[Cursor](cursor)

primitive CreateTexture
    fun apply(renderer: Pointer[Renderer], format: U32, access: I32, w: I32, h: I32): Pointer[Texture] =>
        @SDL_CreateTexture[Pointer[Texture]](renderer, format, access, w, h)

primitive CreateTextureFromSurface
    fun apply(renderer: Pointer[Renderer], surface: Pointer[Surface]): Pointer[Texture] =>
        @SDL_CreateTextureFromSurface[Pointer[Texture]](renderer, surface)

primitive CreateWindow
    fun apply(title: String, x: I32, y: I32, w: I32, h: I32, flags: U32): Pointer[Window] =>
        @SDL_CreateWindow[Pointer[Window]](title.cstring(), x, y, w, h, flags)

primitive DefinePixelFormat
    fun apply(pType: U32, order: U32, layout: U32, bits: U32, bytes: U32): U32 =>
        ((1 << 28) or ((pType) << 24) or ((order) << 20) or ((layout) << 16) or ((bits) << 8) or ((bytes) << 0))

primitive Delay
    fun apply(ms: U32): None =>
        @SDL_Delay[None](ms)

primitive DestroyRenderer
    fun apply(renderer: Pointer[Renderer]): None =>
        @SDL_DestroyRenderer[None](renderer)

primitive DestroyWindow
    fun apply(window: Pointer[Window]): None =>
        @SDL_DestroyWindow[None](window)

primitive EventState
    fun apply(eventType: U32, state: U32): U8 =>
        @SDL_EventState[U8](eventType, state)

primitive FreeSurface
    fun apply(surface: Pointer[Surface]): None =>
        @SDL_FreeSurface[None](surface)

primitive GetDisplayDPI
    fun apply(displayIndex: U32, dpi: DPI): U32 =>
        @SDL_GetDisplayDPI[U32](displayIndex, addressof dpi.d, addressof dpi.h, addressof dpi.v)

primitive GetError
    fun apply(): Pointer[U8] =>
        @SDL_GetError[Pointer[U8]]()

primitive GetGlobalMouseState
    fun apply(pos: Position): U32 =>
        @SDL_GetGlobalMouseState[U32](addressof pos.x, addressof pos.y)

primitive GetMouseFocus
    fun apply(): Pointer[Window] =>
        @SDL_GetMouseFocus[Pointer[Window]]()

primitive GetMouseState
    fun apply(pos: Position): U32 =>
        @SDL_GetMouseState[U32](addressof pos.x, addressof pos.y)

primitive GetVersion
    fun apply(ver: MaybePointer[Version]): None =>
        @SDL_GetVersion[None](ver)

primitive GetWindowID
    fun apply(window: Pointer[Window]): U32 =>
        @SDL_GetWindowID[U32](window)

primitive GetWindowPosition
    fun apply(window: Pointer[Window], pos: Position): None =>
        @SDL_GetWindowPosition[None](window, addressof pos.x, addressof pos.y)

primitive HideWindow
    fun apply(window: Pointer[Window]): None =>
        @SDL_HideWindow[None](window)

primitive Init
    fun apply(flags: U32): U32 =>
        @SDL_Init[U32](flags)

primitive PumpEvents
    fun apply(): None =>
        @SDL_PumpEvents[None]()

primitive QueryTexture
    fun apply(texture: Pointer[Texture], format: Pointer[U32], access: Pointer[I32], rect: Rect): U32 =>
        @SDL_QueryTexture[U32](texture, Pointer[U32], Pointer[I32], addressof rect.w, addressof rect.h)

primitive RaiseWindow
    fun apply(window: Pointer[Window]): None =>
        @SDL_RaiseWindow[None](window)

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

primitive SetEventFilter[A: Any ref]
    fun apply(filter: @{(UserData[A], SysWMEventWindows): U32 ?}, userdata: UserData[A]): None =>
        @SDL_SetEventFilter[None](filter, userdata)

primitive SetHint
    fun apply(name: String, value: String): Bool =>
        @SDL_SetHint[Bool](name.cstring(), value.cstring())

primitive SetRenderDrawColor
    fun apply(renderer: Pointer[Renderer], r: U8, g: U8, b: U8, a: U8): U32 =>
        @SDL_SetRenderDrawColor[U32](renderer, r, g, b, a)

primitive SetWindowInputFocus
    fun apply(window: Pointer[Window]): U32 =>
        @SDL_SetWindowInputFocus[U32](window)

primitive SetWindowPosition
    fun apply(window: Pointer[Window], x: I32, y: I32): None =>
        @SDL_SetWindowPosition[None](window, x, y)

primitive SetWindowSize
    fun apply(window: Pointer[Window], w: I32, h: I32): None =>
        @SDL_SetWindowSize[None](window, w, h)

primitive ShowWindow
    fun apply(window: Pointer[Window]): None =>
        @SDL_ShowWindow[None](window)

primitive Quit
    fun apply(): None =>
        @SDL_Quit[None]()

// Custom (for Pony or platform specific issues)

struct DPI
    var d: F32 = 0
    var h: F32 = 0
    var v: F32 = 0
    
    new create() => None

struct Position
    var x: I32 = 0
    var y: I32 = 0
    
    new create() => None

struct SysWMEventWindows
    var eventType: U32 = 0
    var timestamp: U32 = 0
    var msg: SysWMmsgWindows = SysWMmsgWindows
    
    new create() => None

struct SysWMinfoWindows
    // the Version struct does not work here
    // and so we use a tuple instead
    var version: (
        U8, // major
        U8, // minor
        U8  // patch
    ) = (2, 0, 8)
    var subsystem: I32 = 0
    var windows: (
        win.HWND,     // window
        win.HDC,      // hdc
        win.HINSTANCE // hinstance
    ) = (win.HWND, win.HDC, win.HINSTANCE)
    
    new create() => None

struct SysWMmsgWindows
    // the Version struct does not work here
    // and so we use a tuple instead
    var version: (
        U8, // major
        U8, // minor
        U8  // patch
    ) = (2, 0, 8)
    var subsystem: I32 = 0
    var windows: (
        win.HWND,   // hwnd
        win.UINT,   // msg
        win.WPARAM, // wParam
        win.LPARAM  // lParam
    ) = (win.HWND, 0, 0, 0)
    
    new create() => None

primitive GetWindowWMInfoWindows
    fun apply(window: Pointer[Window], info: MaybePointer[SysWMinfoWindows]): Bool =>
        @SDL_GetWindowWMInfo[Bool](window, info)

primitive PeekEvent
    fun apply(event: MaybePointer[CommonEvent]): I32 =>
        @SDL_PeepEvents[I32](event, I32(1), EVENTACTIONPEEKEVENT(), EVENTFIRSTEVENT(), EVENTLASTEVENT())

primitive PollCommonEvent
    fun apply(event: MaybePointer[CommonEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollKeyboardEvent
    fun apply(event: MaybePointer[KeyboardEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollMouseButtonEvent
    fun apply(event: MaybePointer[MouseButtonEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollMouseMotionEvent
    fun apply(event: MaybePointer[MouseMotionEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollWindowEvent
    fun apply(event: MaybePointer[WindowEvent]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PollSysWMEventWindows
    fun apply(event: MaybePointer[SysWMmsgWindows]): I32 =>
        @SDL_PollEvent[I32](event)

primitive PushEventMouseButtonEvent
    fun apply(event: MaybePointer[MouseButtonEvent]): U32 =>
        @SDL_PushEvent[U32](event)
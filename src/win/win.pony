use "lib:shcore" if windows

// Data Types

type HANDLE    is PVOID
type HDC       is HANDLE
type HINSTANCE is HANDLE
type HRESULT   is LONG
type HWND      is HANDLE
type LONG      is I32
type LONGPTR   is I64
type LPARAM    is LONGPTR
type PVOID     is Pointer[U8] tag
type UINT      is U32
type UINTPTR   is U64
type WPARAM    is UINTPTR

// Constants - Window Messages

primitive WMENTERSIZEMOVE
    fun apply(): UINT => 0x0231

// Functions

primitive SetProcessDpiAwareness
    fun @apply(value: I32): HRESULT =>
        @SetProcessDpiAwareness[HRESULT](value)
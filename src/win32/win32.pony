use "lib:shcore" if windows

// Data Types

type HANDLE    is PVOID
type HDC       is HANDLE
type HINSTANCE is HANDLE
type HRESULT   is LONG
type HWND      is HANDLE
type LONG      is I32
type PVOID     is Pointer[U8] tag

// Functions

primitive SetProcessDpiAwareness
    fun @apply(value: I32): HRESULT =>
        @SetProcessDpiAwareness[HRESULT](value)
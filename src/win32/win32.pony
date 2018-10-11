use "lib:shcore" if windows

// Data Types

type HRESULT   is LONG
type LONG      is I32

// Functions

primitive SetProcessDpiAwareness
    fun @apply(value: I32): HRESULT =>
        @SetProcessDpiAwareness[HRESULT](value)
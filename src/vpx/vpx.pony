use "lib:vpx/vpx" if windows

// Functions

primitive CodecVersion
    fun apply(): U32 =>
        @vpx_codec_version[U32]()

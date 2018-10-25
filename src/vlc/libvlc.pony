use "lib:vlc/libvlc" if windows

use win = "../win"

// Pointers

primitive InstanceT
primitive MediaPlayerT
primitive MediaT

// Functions

primitive ErrMsg
    fun apply(): Pointer[U8] =>
        @libvlc_errmsg[Pointer[U8]]()

primitive GetVersion
    fun apply(): Pointer[U8] =>
        @libvlc_get_version[Pointer[U8]]()

primitive MediaNewPath
    fun apply(p_instance: Pointer[InstanceT], path: String): Pointer[MediaT] =>
        @libvlc_media_new_path[Pointer[MediaT]](p_instance, path.cstring())

primitive MediaPlayerNewFromMedia
    fun apply(p_md: Pointer[MediaT]): Pointer[MediaPlayerT] =>
        @libvlc_media_player_new_from_media[Pointer[MediaPlayerT]](p_md)

primitive MediaPlayerPlay
    fun apply(p_mi: Pointer[MediaPlayerT]): U32 =>
        @libvlc_media_player_play[U32](p_mi)

primitive MediaPlayerRelease
    fun apply(p_mi: Pointer[MediaPlayerT]): None =>
        @libvlc_media_player_release[None](p_mi)

primitive MediaPlayerSetHwnd
    fun apply(p_mi: Pointer[MediaPlayerT], drawable: win.HWND): None =>
        @libvlc_media_player_set_hwnd[None](p_mi, drawable)

primitive MediaPlayerStop
    fun apply(p_mi: Pointer[MediaPlayerT]): None =>
        @libvlc_media_player_stop[None](p_mi)

primitive MediaRelease
    fun apply(p_md: Pointer[MediaT]): None =>
        @libvlc_media_release[None](p_md)

primitive New
    fun apply(argc: USize = 0, argv: Array[String] = Array[String]): Pointer[InstanceT] =>
        @libvlc_new[Pointer[InstanceT]](argc, argv.cpointer())

primitive Release
    fun apply(p_instance: Pointer[InstanceT]): None =>
        @libvlc_release[None](p_instance)

use "debug"
use "../"

use vlc = "../vlc"

class Video
    var element: RenderElement
    
    new create(myElement: RenderElement) =>
        element = myElement
    
    fun ref play(): U32 =>
        let started = vlc.MediaPlayerPlay(element.videoPlayer)
        element.videoPlaying = if started == 0 then true else false end
        
        started
    
    fun ref pause(): None =>
        vlc.MediaPlayerPause(element.videoPlayer)
        element.videoPlaying = false
    
    fun ref stop(): None =>
        vlc.MediaPlayerStop(element.videoPlayer)
        element.videoPlaying = false
use "debug"
use "../"

use app2 = "../app"

class Api
    var video: RenderElement = RenderElement
    
    new create() => None
    
    fun ref apply(run: String, ge: GuiEvent, re: CanRunCommands, app: App) =>
        if video.id == "" then
            for element in app.elements.values() do
                if element.id == "video" then
                    video = element
                end
            end
        end
        
        let videoPlayer = app2.Video(video)
        
        match run
        | "pause" =>
            videoPlayer.pause()
        | "stop" =>
            videoPlayer.stop()
        end
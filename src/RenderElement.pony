use "collections"
use "debug"

use sdl = "sdl"
use vlc = "vlc"

class RenderElement is ICanRunCommands
    var guid: U32 = -1
    var id: String = ""
    var group: String = ""
    var modCode: String = ""
    var keyCode: String = ""
    var ge: GuiElement = GuiElement
    var geState: GuiElement = GuiElement
    var cursor: String = "arrow"
    var callbacks: Array[{ref (): Any val}] = []
    var texture: Pointer[sdl.Texture] = Pointer[sdl.Texture]
    var rect: sdl.Rect = sdl.Rect
    var states: Map[String, RenderElement] = Map[String, RenderElement]
    var _data: Map[String, String] = Map[String, String]
    
    var video: Pointer[sdl.Window] = Pointer[sdl.Window]
    var videoRenderer: Pointer[sdl.Renderer] = Pointer[sdl.Renderer]
    var videoInstance: Pointer[vlc.InstanceT] = Pointer[vlc.InstanceT]
    var videoPlayer: Pointer[vlc.MediaPlayerT] = Pointer[vlc.MediaPlayerT]
    
    new create() => None
    
    fun ref clone(re: RenderElement = RenderElement, cloneStates: Bool = false): RenderElement =>
        re.guid = guid
        re.id = id
        re.group = group
        re.modCode = modCode
        re.keyCode = keyCode
        re.ge = ge.clone()
        re.geState = geState.clone()
        re.cursor = cursor
        re.callbacks = callbacks.clone()
        re.texture = texture
        re.rect = rect
        
        if cloneStates then
            re.states = states.clone()
        end
        
        // this is shared among all states 
        // and should not be cloned
        re._data = _data
        
        re
    
    fun ref getId(): String =>
        id
    
    fun ref getData(): Map[String, String] =>
        _data
    
    fun ref setDataValue(key: String, value: String): None =>
        Debug.out("set " + key + " = " + value)
        
        _data.update(key, value)
    
    fun ref getDataValue(key: String, orElse: String = ""): String =>
        _data.get_or_else(key, orElse)
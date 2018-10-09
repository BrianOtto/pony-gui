use "collections"
use "debug"

class AppState is ICanRunCommands
    var id: String = "app"
    var _data: Map[String, String] = Map[String, String]
    
    new create() => None
    
    fun ref getId(): String =>
        id
    
    fun ref getData(): Map[String, String] =>
        _data
    
    fun ref setDataValue(key: String, value: String): None =>
        Debug.out("set " + key + " = " + value)
        
        _data.update(key, value)
    
    fun ref getDataValue(key: String, orElse: String = ""): String =>
        _data.get_or_else(key, orElse)
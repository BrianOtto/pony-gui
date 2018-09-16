use "collections"

interface ICanRunCommands
    fun ref getId(): String
    
    fun ref getData(): Map[String, String]
    
    fun ref setDataValue(key: String, value: String): None
    
    fun ref getDataValue(key: String): String ?
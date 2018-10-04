class Keyboard
    var app: App
    
    new create(myApp: App) =>
        app = myApp
    
    fun ref load() =>
        // TODO: add support for modifiers like CTRL, SHIFT, etc
        // TODO: add support for function and punctuation keys
        
        app.keys.update("0", '0')
        app.keys.update("1", '1')
        app.keys.update("2", '2')
        app.keys.update("3", '3')
        app.keys.update("4", '4')
        app.keys.update("5", '5')
        app.keys.update("6", '6')
        app.keys.update("7", '7')
        app.keys.update("8", '8')
        app.keys.update("9", '9')
        app.keys.update("a", 'a')
        app.keys.update("b", 'b')
        app.keys.update("c", 'c')
        app.keys.update("d", 'd')
        app.keys.update("e", 'e')
        app.keys.update("f", 'f')
        app.keys.update("g", 'g')
        app.keys.update("h", 'h')
        app.keys.update("i", 'i')
        app.keys.update("j", 'j')
        app.keys.update("k", 'k')
        app.keys.update("l", 'l')
        app.keys.update("m", 'm')
        app.keys.update("n", 'n')
        app.keys.update("o", 'o')
        app.keys.update("p", 'p')
        app.keys.update("q", 'q')
        app.keys.update("r", 'r')
        app.keys.update("s", 's')
        app.keys.update("t", 't')
        app.keys.update("u", 'u')
        app.keys.update("v", 'v')
        app.keys.update("w", 'w')
        app.keys.update("x", 'x')
        app.keys.update("y", 'y')
        app.keys.update("z", 'z')
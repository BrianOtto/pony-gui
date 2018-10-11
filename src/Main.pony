use "collections"

use win32 = "win32"

actor Main
    new create(env: Env) =>
        ifdef windows then
            win32.SetProcessDpiAwareness(2)
        end
        
        try
            var settings = Map[String, String]
            
            let args = env.args.values()
            
            args.next()? // skip the program name
            
            while args.has_next() do
                let key = args.next()?
                let value = args.next()?
                
                match key
                | "--live" =>
                    settings.update("live", value)
                end
            end
            
            App(env, settings)?.init()?
        end
actor Main
    new create(env: Env) =>
        try App(env).init()? end
use "debug"

use sdl = "sdl"
use gfx = "sdl-gfx"
use img = "sdl-image"
use ttf = "sdl-ttf"

class Render
    var app: App
    
    new create(myApp: App) =>
        app = myApp
    
    fun ref load(gui: Array[GuiRow] = Array[GuiRow]) ? =>
        app.elements.clear()
        
        var hTotal: I32 = 0
        var wTotal: I32 = 0
        
        let guiRows = if gui.size() > 0 then gui.values() else app.gui.values() end
        
        while guiRows.has_next() do
            let guiRow = guiRows.next()?
            let guiCols = guiRow.cols.values()
            
            let h: I32 = (app.windowH.f32() * guiRow.height).i32()
            
            wTotal = 0
            
            while guiCols.has_next() do
                let guiCol = guiCols.next()?
                let guiElements = guiCol.elements.values()
                
                let w: I32 = (app.windowW.f32() * guiCol.width).i32()
                
                while guiElements.has_next() do
                    let ge = guiElements.next()?
                    let re = render(ge, w, h, wTotal, hTotal)?
                    
                    app.elements.push(re)
                end
                
                wTotal = wTotal + w
            end
            
            hTotal = hTotal + h
        end
    
    fun ref render(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement ? =>
        var re = RenderElement
        
        match ge.command
        | "draw" =>
            match ge.properties("shape")?
            | "circle" =>
                re = _renderDraw(ge, w, h, wTotal, hTotal)?
                // TODO: add support for events
            end
        | "load" =>
            match ge.properties("media")?
            | "image" =>
                re = _renderImage(ge, w, h, wTotal, hTotal)?
                re.events.insert("style", re.clone())?
            end
        | "text" =>
            re = _renderText(ge, w, h, wTotal, hTotal)?
            re.events.insert("style", re.clone())?
        end
        
        let styleEvents = ge.events.values()
        
        while styleEvents.has_next() do
            let styleEvent = styleEvents.next()?
            var reForStyle = RenderElement
            
            let geNew = ge.clone()
            
            let geProps = styleEvent.properties.pairs()
            
            while geProps.has_next() do
                var geProp = geProps.next()?
                geNew.properties.update(geProp._1, geProp._2)
            end
            
            match ge.command
            | "draw" =>
                reForStyle = _renderDraw(geNew, w, h, wTotal, hTotal)?
            | "load" =>
                match ge.properties("media")?
                | "image" =>
                    reForStyle = _renderImage(geNew, w, h, wTotal, hTotal)?
                end
            | "text" =>
                reForStyle = _renderText(geNew, w, h, wTotal, hTotal)?
            end
            
            re.events.insert(styleEvent.id, reForStyle)?
        end
        
        re
    
    fun ref _renderDraw(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement ? =>
        var x: I32 = 0
        var y: I32 = 0
        
        // TODO: allow radius to be specified as a percentage of w / h (e.g "1/3")
        var radius: I32 = try ge.properties("radius")?.i32()? else 0 end
        radius = if radius > w then w else radius end
        radius = if radius > h then h else radius end
        
        if ge.properties.contains("x") then
            let geX = ge.properties("x")?
            
            if geX == "center" then
                x = wTotal + ((w - (radius * 2)) / 2) + radius
            else
                x = wTotal + try geX.i32()? else 0 end
            end
        end
        
        if ge.properties.contains("y") then
            let geY = ge.properties("y")?
            
            if geY == "center" then
                y = hTotal + ((h - (radius * 2)) / 2) + radius
            else
                y = hTotal + try geY.i32()? else 0 end
            end
        end
        
        let antiAliased: Bool = try
            if ge.properties("anti-aliased")? == "1" then true else false end
        else
            true // default to true
        end
        
        let border: Bool = try
            if ge.properties("border")? == "1" then true else false end
        else
            true // default to true
        end
        
        var borderColor: U32 = 0
        
        if border and ge.properties.contains("border-color") then
            // convert to a hexadecimal string
            var borderColorAsString = "0x" + try ge.properties("border-color")? else "" end
            
            // default to 0 for any missing RGB values
            while borderColorAsString.size() < 10 do
                borderColorAsString = borderColorAsString + 
                    if borderColorAsString.size() < 8 then "0" else "F" end
            end
            
            // convert to a unsigned integer
            borderColor = try borderColorAsString.u32()? else 0 end
        end
        
        let callbacks: Array[{ref (): Any val}] = []
        
        if ge.properties.contains("fill") then
            // convert to a hexadecimal string
            var fillAsString = "0x" + try ge.properties("fill")? else "" end
            
            // default to 0 for any missing RGB values
            while fillAsString.size() < 10 do
                fillAsString = fillAsString + 
                    if fillAsString.size() < 8 then "0" else "F" end
            end
            
            // convert to a unsigned integer
            let fill = try fillAsString.u32()? else 0 end
            
            if antiAliased and not ge.properties.contains("border-color") then
                borderColor = fill
            end
            
            callbacks.push(
                gfx.FilledCircleColor~apply(app.renderer, x.i16(), y.i16(), radius.i16(), fill)
            )
        end
        
        if antiAliased then
            callbacks.push(
                gfx.AACircleColor~apply(app.renderer, x.i16(), y.i16(), radius.i16(), borderColor)
            )
        else
            callbacks.push(
                gfx.CircleColor~apply(app.renderer, x.i16(), y.i16(), radius.i16(), borderColor)
            )
        end
        
        let re = RenderElement
        
        re.id = ge.id
        re.callbacks = callbacks
        
        re
    
    fun ref _renderImage(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement ? =>
        let image = img.Load(ge.properties("src")?)
        
        if image.is_null() then
            app.logAndExit("load image error")?
        end
        
        let texture = sdl.CreateTextureFromSurface(app.renderer, image)
        sdl.FreeSurface(image)
        
        let re = RenderElement
        
        re.id = ge.id
        re.texture = texture
        re.rect = _getRect(texture, ge, w, h, wTotal, hTotal)?
        
        re
    
    fun ref _renderText(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement ? =>
        let fontName = ge.properties("font")?
        let fontSize = ge.properties("font-size")?.i32()?
        
        // convert to a hexadecimal string
        var fontColorAsString = "0x" + try ge.properties("font-color")? else "" end
        
        // default to 0 for any missing RGB values
        while fontColorAsString.size() < 10 do
            fontColorAsString = fontColorAsString + 
                if fontColorAsString.size() < 8 then "0" else "F" end
        end
        
        // convert to a unsigned integer
        let fontColor = try fontColorAsString.u32()? else 0 end
        
        // load our font
        let font = ttf.OpenFont(fontName, fontSize)
        Debug.out("font = " + font.usize().string())
        
        if font.is_null() then
            app.logAndExit("load font error")?
        end
        
        let fontSurface = ttf.RenderUTF8Blended(font, ge.properties("value")?, fontColor)
        
        if fontSurface.is_null() then
            app.logAndExit("font surface error")?
    	end
        
        let texture = sdl.CreateTextureFromSurface(app.renderer, fontSurface)
        sdl.FreeSurface(fontSurface)
        
        ttf.CloseFont(font)
        
        let re = RenderElement
        
        re.id = ge.id
        re.texture = texture
        re.rect = _getRect(texture, ge, w, h, wTotal, hTotal)?
        
        re
        
    fun ref _getRect(texture: Pointer[sdl.Texture], guiElement: GuiElement, 
                     w: I32, h: I32, wTotal: I32, hTotal: I32): sdl.Rect ? =>
        
        let rect = sdl.Rect
        
        sdl.QueryTexture(texture, Pointer[U32], Pointer[I32], rect)
        
        if guiElement.properties.contains("x") then
            let guiElementX = guiElement.properties("x")?
            
            if guiElementX == "center" then
                rect.w = if rect.w > w then w else rect.w end
                rect.x = wTotal + ((w - rect.w) / 2)
            else
                rect.x = wTotal + try guiElementX.i32()? else 0 end
            end
        end
        
        if guiElement.properties.contains("y") then
            let guiElementY = guiElement.properties("y")?
            
            if guiElementY == "center" then
                rect.h = if rect.h > h then h else rect.h end
                rect.y = hTotal + ((h - rect.h) / 2)
            else
                rect.y = hTotal + try guiElementY.i32()? else 0 end
            end
        end
        
        rect
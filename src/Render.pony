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
    
    fun ref recalc(id: String, reRender: RenderElement = RenderElement) ? =>
        var hTotal: I32 = 0
        var wTotal: I32 = 0
        
        let guiRows = app.gui.values()
        
        while guiRows.has_next() do
            let guiRow = guiRows.next()?
            let guiCols = guiRow.cols.values()
            
            var guiRowHeight = guiRow.height
            
            if (reRender.id == "") and guiRow.states.contains(id) then
                let guiRowState = try guiRow.states(id)? else error end
                guiRowHeight = guiRowState.height
            end
            
            let h: I32 = (app.windowH.f32() * guiRowHeight).i32()
            
            wTotal = 0
            
            while guiCols.has_next() do
                let guiCol = guiCols.next()?
                let guiElements = guiCol.elements.values()
                
                var guiColWidth = guiCol.width
                
                if (reRender.id == "") and guiCol.states.contains(id) then
                    let guiColState = try guiCol.states(id)? else error end
                    guiColWidth = guiColState.width
                end
                
                let w: I32 = (app.windowW.f32() * guiColWidth).i32()
                
                while guiElements.has_next() do
                    let ge = guiElements.next()?
                    let reElements = app.elements.values()
                    
                    while reElements.has_next() do
                        let re = reElements.next()?
                        
                        if re.id == ge.id then
                            if reRender.id == "" then
                                if ge.command == "draw" then
                                    var reNew = render(ge, w, h, wTotal, hTotal)?
                                    
                                    re.callbacks = reNew.callbacks
                                    re.states = reNew.states
                                else
                                    re.rect = _getRect(re.texture, re.ge, w, h, wTotal, hTotal)
                                    
                                    let reStates = re.states.values()
                            
                                    while reStates.has_next() do
                                        let reState = reStates.next()?
                                        reState.rect = _getRect(reState.texture, reState.ge, w, h, wTotal, hTotal)
                                    end
                                end
                            elseif re.id == id then
                                // get the properties the state was originally rendered with
                                let geProps = reRender.geState.properties.pairs()
                                
                                // and make them permanent by merging them with the GUI element
                                while geProps.has_next() do
                                    var geProp = geProps.next()?
                                    ge.properties.update(geProp._1, geProp._2)
                                end
                                
                                // get the previous state id that was being displayed
                                var rePrevId = re.geState.id
                                
                                // re-render all the GUI element states with these new properties
                                let reNew = render(ge, w, h, wTotal, hTotal)?
                                reNew.clone(re, true)
                                
                                // go back to displaying the previous state
                                re.states(rePrevId)?.clone(re)
                            end
                        end
                    end
                end
                
                wTotal = wTotal + w
            end
            
            hTotal = hTotal + h
        end
        
    fun ref render(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement ? =>
        var re = RenderElement
        
        match ge.command
        | "draw" =>
            // TODO: add support for mouse events
            match ge.properties("shape")?
            | "circle" =>
                re = _renderCircle(ge, w, h, wTotal, hTotal)
            | "rectangle" =>
                re = _renderRectangle(ge, w, h, wTotal, hTotal)
            end
        | "load" =>
            match ge.properties("media")?
            | "image" =>
                re = _renderImage(ge, w, h, wTotal, hTotal)?
            end
        | "text" =>
            re = _renderText(ge, w, h, wTotal, hTotal)?
        end
        
        if ge.properties.contains("cursor") then
            re.cursor = ge.properties("cursor")?
        end
        
        re.ge = ge
        re.geState = ge.clone()
        re.geState.id = "default"
        
        re.states.insert(re.geState.id, re.clone())?
        
        let styleStates = ge.states.values()
        
        while styleStates.has_next() do
            let styleState = styleStates.next()?
            var reForStyle = RenderElement
            
            let geNew = ge.clone()
            
            let geProps = styleState.properties.pairs()
            
            while geProps.has_next() do
                var geProp = geProps.next()?
                geNew.properties.update(geProp._1, geProp._2)
            end
            
            match ge.command
            | "draw" =>
                match ge.properties("shape")?
                | "circle" =>
                    reForStyle = _renderCircle(geNew, w, h, wTotal, hTotal)
                | "rectangle" =>
                    reForStyle = _renderRectangle(geNew, w, h, wTotal, hTotal)
                end
            | "load" =>
                match ge.properties("media")?
                | "image" =>
                    reForStyle = _renderImage(geNew, w, h, wTotal, hTotal)?
                end
            | "text" =>
                reForStyle = _renderText(geNew, w, h, wTotal, hTotal)?
            end
            
            if geNew.properties.contains("cursor") then
                reForStyle.cursor = geNew.properties("cursor")?
            end
            
            reForStyle.ge = geNew
            reForStyle.geState = styleState
            
            re.states.insert(reForStyle.geState.id, reForStyle)?
        end
        
        re
    
    fun ref _renderCircle(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement =>
        var x: I32 = 0
        var y: I32 = 0
        
        // TODO: allow radius to be specified as a percentage of w / h (e.g "1/3")
        var radius: I32 = try ge.properties("radius")?.i32()? else 0 end
        radius = if radius > w then w else radius end
        radius = if radius > h then h else radius end
        
        let guiElementX = try ge.properties("x")? else "0" end
        
        // TODO: add support for left / right
        if guiElementX == "center" then
            x = wTotal + ((w - (radius * 2)) / 2) + radius
        else
            x = wTotal + try guiElementX.i32()? else 0 end
        end
        
        let guiElementY = try ge.properties("y")? else "0" end
        
        // TODO: add support for top / bottom
        if guiElementY == "center" then
            y = hTotal + ((h - (radius * 2)) / 2) + radius
        else
            y = hTotal + try guiElementY.i32()? else 0 end
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
        
        var borderColor: U32 = try "0x000000FF".u32()? else 0 end
        
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
        re.rect = _getRect(texture, ge, w, h, wTotal, hTotal)
        
        re
    
    fun ref _renderRectangle(ge: GuiElement, w: I32, h: I32, wTotal: I32, hTotal: I32): RenderElement =>
        var x1: I32 = 0
        var x2: I32 = 0
        var y1: I32 = 0
        var y2: I32 = 0
        
        var width: I32 = 0
        let widthProp = try ge.properties("width")? else "1/1" end
        
        if widthProp.contains("/") then
            let widthParts = widthProp.split_by("/")
            let widthAsPct = try widthParts(0)?.f32() / widthParts(1)?.f32() else 1 end
            width = (w.f32() * widthAsPct).i32()
        else
            width = try ge.properties("width")?.i32()? else w end
        end
        
        width = if width > w then w else width end
        
        var height: I32 = 0
        let heightProp = try ge.properties("height")? else "1/1" end
        
        if heightProp.contains("/") then
            let heightParts = heightProp.split_by("/")
            let heightAsPct = try heightParts(0)?.f32() / heightParts(1)?.f32() else 1 end
            height = (h.f32() * heightAsPct).i32()
        else
            height = try ge.properties("height")?.i32()? else h end
        end
        
        height = if height > h then h else height end
        
        let guiElementX = try ge.properties("x")? else "0" end
        
        // TODO: add support for left / right
        if guiElementX == "center" then
            x1 = wTotal + ((w - width) / 2)
        else
            x1 = wTotal + try guiElementX.i32()? else 0 end
        end
        
        x2 = x1 + width
        
        let guiElementY = try ge.properties("y")? else "0" end
        
        // TODO: add support for top / bottom
        if guiElementY == "center" then
            y1 = hTotal + ((h - height) / 2)
        else
            y1 = hTotal + try guiElementY.i32()? else 0 end
        end
        
        y2 = y1 + height
        
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
        
        var borderColor: U32 = try "0x000000FF".u32()? else 0 end
        
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
                gfx.BoxColor~apply(app.renderer, x1.i16(), y1.i16(), x2.i16(), y2.i16(), fill)
            )
        end
        
        // TODO: does GFX provide an anti-aliased function ?
        if antiAliased then
            callbacks.push(
                gfx.RectangleColor~apply(app.renderer, x1.i16(), y1.i16(), x2.i16(), y2.i16(), borderColor)
            )
        else
            callbacks.push(
                gfx.RectangleColor~apply(app.renderer, x1.i16(), y1.i16(), x2.i16(), y2.i16(), borderColor)
            )
        end
        
        let re = RenderElement
        
        re.id = ge.id
        re.callbacks = callbacks
        
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
        re.rect = _getRect(texture, ge, w, h, wTotal, hTotal)
        
        re
        
    fun ref _getRect(texture: Pointer[sdl.Texture], guiElement: GuiElement, 
                     w: I32, h: I32, wTotal: I32, hTotal: I32): sdl.Rect =>
        
        let rect = sdl.Rect
        
        sdl.QueryTexture(texture, Pointer[U32], Pointer[I32], rect)
        
        let guiElementX = try guiElement.properties("x")? else "0" end
        
        // TODO: add support for left / right
        if guiElementX == "center" then
            rect.w = if rect.w > w then w else rect.w end
            rect.x = wTotal + ((w - rect.w) / 2)
        else
            rect.x = wTotal + try guiElementX.i32()? else 0 end
        end
        
        let guiElementY = try guiElement.properties("y")? else "0" end
        
        // TODO: add support for top / bottom
        if guiElementY == "center" then
            rect.h = if rect.h > h then h else rect.h end
            rect.y = hTotal + ((h - rect.h) / 2)
        else
            rect.y = hTotal + try guiElementY.i32()? else 0 end
        end
        
        rect
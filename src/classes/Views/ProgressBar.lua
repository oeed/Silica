
class "ProgressBar" extends "View" {
    
    height = Number( 7 );
    width = Number( 100 );

    isEnabled = Boolean( true );
    isIndeterminate = Boolean( true );

    animationStep = Number( 0 );

    value = 0.3;
    maximum = 1;

}

--[[
    @desc Sets up the canvas and it's graphics objects
]]
-- function ProgressBar:initialiseCanvas()
--     self:super()
--     local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.theme.fillColour, self.theme.outlineColour, self.theme.cornerRadius ) )
--     local stripesObject = self.canvas:insert( ProgressBarStripes( 1, 1, math.floor( ( self.value/self.maximum ) * self.width + 0.5 ), self.height, self.theme.barColour, self.theme.barColour, self.theme.stripeColour, self.theme.cornerRadius ) )
--     self.theme:connect( backgroundObject, "fillColour" )
--     self.theme:connect( backgroundObject, "outlineColour" )
--     self.theme:connect( backgroundObject, "radius", "cornerRadius" )
--     self.theme:connect( stripesObject, "fillColour", "barColour" )
--     self.theme:connect( stripesObject, "outlineColour", "barColour" )
--     self.theme:connect( stripesObject, "stripeColour" )
--     self.theme:connect( stripesObject, "radiusLeft", "cornerRadius" )

--     self.backgroundObject = backgroundObject
--     self.stripesObject = stripesObject
-- end

function ProgressBar:onDraw()
    local start = collectgarbage("count")
    -- print("start "..start)
    local width, height, theme, canvas, isPressed = self.width, self.height, self.theme, self.canvas
    local isIndeterminate, value = self.isIndeterminate, self.value
    local barWidth = isIndeterminate and width or math.floor( ( value / self.maximum ) * width + 0.5 )
    isIndeterminate = isIndeterminate or barWidth >= width

    -- background shape
    local roundedRectangle = RoundedRectangleMask( 1, 1, width, height, theme:value( "cornerRadius" ) )
    local stripeMask = barWidth > 0 and StripeMask( 1, 1, barWidth, height, self.animationStep, theme:value( "stripeWidth" ) )

    if not isIndeterminate then
        canvas:fill( theme:value( "fillColour" ), roundedRectangle )
    end

    if isIndeterminate then
        canvas:fill( theme:value( "barColour" ), roundedRectangle )
    end


    local rectOne = RectangleMask( 6, 1, 5, 5 )
    local rectTwo = RectangleMask( 8, 3, 5, 5 )
    canvas:fill( colours.red, rectOne )
    canvas:fill( colours.green, rectTwo )
    canvas:fill( colours.yellow, rectOne:exclude( rectTwo ) )

    -- canvas:fill( theme:value( "stripeColour" ), stripeMask )

    if isIndeterminate then
        -- canvas:outline( theme:value( "barOutlineColour" ), roundedRectangle, theme:value( "outlineThickness" ) )
    end
    -- canvas:outline( theme:value( "outlineColour" ), roundedRectangle, theme:value( "outlineThickness" ) )


    -- local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    -- text
    -- canvas:fill( theme:value( "textColour" ),  TextMask( leftMargin + shadowX + 1, topMargin + 1 + shadowOffset, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, self.font ) )
    -- log("Draw stop "..collectgarbage("count") - start)
end
 
-- function ProgressBar:updateWidth( width )
--     self.backgroundObject.width = width
--     self.stripesObject.width = math.floor( ( self.value/self.maximum ) * width + 0.5 )
-- end

-- function ProgressBar:updateHeight( height )
--     self.backgroundObject.height = height
--     self.stripesObject.height = height
-- end

function ProgressBar.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self.theme.style = self.isEnabled and "default" or "disabled"
end

--[[
    @desc Set the value of the progress bar
    @param [number] value -- the value
]]
function ProgressBar.value:set( value )
    self.value = math.min( math.max( value, 0 ), self.maximum )
    -- self.stripesObject.width = math.floor( ( self.value / self.maximum ) * self.width + 0.5 )
end

--[[
    @desc Set the maximum value of the progress bar
    @param [number] maximum -- the maximum value
]]
function ProgressBar.maximum:set( maximum )
    self.maximum = math.max( maximum, 0 )
    -- self.stripesObject.width = math.floor( ( self.value / self.maximum ) * self.width + 0.5 )
end

function ProgressBar.animationStep:set( animationStep )
    animationStep = math.floor( animationStep + 0.5 )
    local oldAnimationStep = self.animationStep
    if oldAnimationStep ~= animationStep then
        self.animationStep = animationStep
        self.needsDraw = true
    end
    -- self.stripesObject.width = math.floor( ( self.value / self.maximum ) * self.width + 0.5 )
end

--[[
    @desc Fired on a screen update. Animates the stripes
    @param [number] deltaTime -- the time since last update
]]
function ProgressBar:update( deltaTime )
    if self.value > 0 or self.isIndeterminate then
        self.animationStep = self.animationStep + deltaTime * 20
    end
end

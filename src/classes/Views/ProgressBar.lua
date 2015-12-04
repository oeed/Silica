
class "ProgressBar" extends "View" {
    
    height = Number( 7 );
    width = Number( 100 );

    isEnabled = Boolean( true );
    isIndeterminate = Boolean( true );

    animationStep = Number( 0 );

    value = 0.3;
    maximum = 1;

}

function ProgressBar:onDraw()
    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local isIndeterminate = self.isIndeterminate

    -- background shape
    local outlineThickness, cornerRadius = theme:value( "outlineThickness" ), theme:value( "cornerRadius" )
    local roundedRectangle = RoundedRectangleMask( 1, 1, width, height, cornerRadius )

    if isIndeterminate then
        canvas:fill( theme:value( "indeterminateFillColour" ), roundedRectangle )
        canvas:fill( theme:value( "indeterminateStripeColour" ), roundedRectangle:subtract( StripeMask( 1, 1, width, height, self.animationStep, theme:value( "indeterminateStripeWidth" ) ) ) )
        canvas:outline( theme:value( "indeterminateOutlineColour" ), roundedRectangle, outlineThickness )
    else
        local barWidth = math.floor( ( self.value / self.maximum ) * width + 0.5 )
        if barWidth >= width then
            canvas:fill( theme:value( "barFillColour" ), roundedRectangle )
            canvas:outline( theme:value( "barOutlineColour" ), roundedRectangle, outlineThickness )
        else
            canvas:fill( theme:value( "fillColour" ), roundedRectangle )
            canvas:outline( theme:value( "outlineColour" ), roundedRectangle, outlineThickness )

            if barWidth > 0 then
                local barMask = RoundedRectangleMask( 1, 1, barWidth, height, cornerRadius, 0 )
                canvas:fill( theme:value( "barFillColour" ), barMask )
                canvas:outline( theme:value( "barOutlineColour" ), barMask, outlineThickness, outlineThickness, 0 )
            end
        end
    end
end
 
function ProgressBar.isEnabled:set( isEnabled )
    self.isEnabled = isEnabled
    self.theme.style = isEnabled and "default" or "disabled"
end

--[[
    @desc Set the value of the progress bar
    @param [number] value -- the value
]]
function ProgressBar.value:set( value )
    self.value = math.min( math.max( value, 0 ), self.maximum )
end

--[[
    @desc Set the maximum value of the progress bar
    @param [number] maximum -- the maximum value
]]
function ProgressBar.maximum:set( maximum )
    self.maximum = math.max( maximum, 0 )
end

function ProgressBar.animationStep:set( animationStep )
    animationStep = math.floor( animationStep + 0.5 )
    local oldAnimationStep = self.animationStep
    if oldAnimationStep ~= animationStep then
        self.animationStep = animationStep
        self.needsDraw = true
    end
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

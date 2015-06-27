
class "ProgressBar" extends "View" {
    
    height = 7;
    width = 100;

    isEnabled = true;
    isIndeterminate = true;
    cornerRadius = 4;
    stripeWidth = 8;

    value = 0.3;
    maximum = 1;

    backgroundObject = nil;
    stripesObject = nil;

}

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function ProgressBar:initCanvas()
    local backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.theme.fillColour, self.theme.outlineColour, self.theme.cornerRadius ) )
    local stripesObject = self.canvas:insert( ProgressBarStripes( 1, 1, math.floor( (self.value/self.maximum) * self.width + 0.5 ), self.height, self.theme.barColour, self.theme.barColour, self.theme.stripeColour, self.theme.cornerRadius ) )
    self.theme:connect( backgroundObject, 'fillColour' )
    self.theme:connect( backgroundObject, 'outlineColour' )
    self.theme:connect( backgroundObject, 'radius', 'cornerRadius' )
    self.theme:connect( stripesObject, 'fillColour', 'barColour' )
    self.theme:connect( stripesObject, 'outlineColour', 'barColour' )
    self.theme:connect( stripesObject, 'stripeColour' )
    self.theme:connect( stripesObject, 'radiusLeft', 'cornerRadius' )

    self.backgroundObject = backgroundObject
    self.stripesObject = stripesObject
end

function ProgressBar:setWidth( width )
    self.width = width
    self.backgroundObject.width = width
    self.stripesObject.width = math.floor( (self.value/self.maximum) * width + 0.5 )
end

function ProgressBar:setHeight( height )
    self.height = height
    self.backgroundObject.height = height
    self.stripesObject.height = height
end

function ProgressBar:setIsEnabled( isEnabled )
    self.isEnabled = isEnabled
    self.themeStyle = self.isEnabled and "default" or "disabled"
end

--[[
    @instance
    @desc Set the value of the progress bar
    @param [number] value -- the value
]]
function ProgressBar:setValue( value )
    self.value = math.min( math.max( value, 0 ), self.maximum )
    self.stripesObject.width = math.floor( (self.value/self.maximum) * self.width + 0.5 )
end

--[[
    @instance
    @desc Set the maximum value of the progress bar
    @param [number] maximum -- the maximum value
]]
function ProgressBar:setMaximum( maximum )
    self.maximum = math.max( maximum, 0 )
    self.stripesObject.width = math.floor( (self.value/self.maximum) * self.width + 0.5 )
end

--[[
    @instance
    @desc Fired on a screen update. Animates the stripes
    @param [number] deltaTime -- the time since last update
]]
function ProgressBar:update( deltaTime )
    if self.value > 0 or self.isIndeterminate then
        -- self.stripesObject.animationStep = self.stripesObject.animationStep + deltaTime * 20
    end
end


class "ProgressBar" extends "View" {
    
    height = 7;
    width = 100;

    isEnabled = true;
    isIndeterminate = true;
    cornerRadius = 4;
    stripeWidth = 8;

    value = 0.3;
    maximum = 1;

    fillColour = Graphics.colours.WHITE;
    barColour = Graphics.colours.BLUE;
    stripeColour = Graphics.colours.LIGHT_BLUE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    disabledFillColour = Graphics.colours.WHITE;
    disabledBarColour = Graphics.colours.GREY;
    disabledStripeColour = Graphics.colours.LIGHT_GREY;
    disabledOutlineColour = Graphics.colours.LIGHT_GREY;

    backgroundObject = nil;
    stripesObject = nil;

}

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function ProgressBar:initCanvas()
    self.backgroundObject = self.canvas:insert( RoundedRectangle( 1, 1, self.width, self.height, self.fillColour, self.outlineColour, self.cornerRadius ) )
    self.stripesObject = self.canvas:insert( ProgressBarStripes( 1, 1, math.floor( (self.value/self.maximum) * self.width + 0.5 ), self.height, self.barColour, self.barColour, self.stripeColour, self.cornerRadius ) )
end

--[[
    @instance
    @desc Returns the current fill colour for the current style
    @return [Graphics.colours] colour -- the fill colour
]]
function ProgressBar:getFillColour()
    return self:themeValue( "fillColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current outline colour for the current style
    @return [Graphics.colours] colour -- the outline colour
]]
function ProgressBar:getOutlineColour()
    return self:themeValue( "outlineColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current bar colour for the current style
    @return [Graphics.colours] colour -- the bar colour
]]
function ProgressBar:getBarColour()
    return self:themeValue( "barColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current stripe colour for the current style
    @return [Graphics.colours] colour -- the stripe colour
]]
function ProgressBar:getStripeColour()
    return self:themeValue( "stripeColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current bar outline colour for the current style
    @return [Graphics.colours] colour -- the bar outline colour
]]
function ProgressBar:getBarOutlineColour()
    return self:themeValue( "barOutlineColour", self.themeStyle )
end

--[[
    @instance
    @desc Returns the current corner radius for the current style
    @return [number] cornerRadius -- the corner radius
]]
function ProgressBar:getCornerRadius()
    return self:themeValue( "cornerRadius", self.themeStyle )
end

--[[
    @instance
    @desc Update the canvas appearance.
]]
function ProgressBar:updateCanvas()
    local backgroundObject = self.backgroundObject
    if self.canvas and backgroundObject then
        self.themeStyle = self.isEnabled and "default" or "disabled"
        local stripesObject = self.stripesObject
        local width, height = self.width, self.height
        backgroundObject.width = width
        backgroundObject.fillColour = self.fillColour
        backgroundObject.outlineColour = self.outlineColour
        stripesObject.width = math.floor( (self.value/self.maximum) * width + 0.5 )
        stripesObject.fillColour = self.barColour
        stripesObject.outlineColour = self.barColour
        stripesObject.stripeColour = self.stripeColour
    end
end

--[[
    @instance
    @desc Set the value of the progress bar
    @param [number] value -- the value
]]
function ProgressBar:setValue( value )
    self.value = math.min( math.max( value, 0 ), self.maximum )
    self:updateCanvas()
end

--[[
    @instance
    @desc Set the maximum value of the progress bar
    @param [number] maximum -- the maximum value
]]
function ProgressBar:setMaximum( maximum )
    self.maximum = math.max( maximum, 0 )
    self:updateCanvas()
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
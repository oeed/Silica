
class "ProgressBar" extends "View" {

    isEnabled = true;
    isIndeterminate = false;
    cornerRadius = 2;
    animationStep = 0;
    stripeWidth = 8;

    value = 0;
    maximum = 1;

    backgroundColour = Graphics.colours.WHITE;
    barColour = Graphics.colours.BLUE;
    stripeColour = Graphics.colours.LIGHT_BLUE;
    outlineColour = Graphics.colours.LIGHT_GREY;

    disabledBackgroundColour = Graphics.colours.WHITE;
    disabledBarColour = Graphics.colours.GREY;
    disabledStripeColour = Graphics.colours.LIGHT_GREY;
    disabledOutlineColour = Graphics.colours.LIGHT_GREY;

}

--[[
    @instance
    @desc Sets the height and changes the corner radius
    @return [number] height -- the new height
]]
function ProgressBar:setHeight( height )
    if self.canvas then
        local cornerRadius = math.min( height / 2, self.cornerRadius )
        self.cornerRadius = cornerRadius
        self.shadowObject.radius = cornerRadius
        self.backgroundObject.radius = cornerRadius
        self.canvas.height = height
    end
    self.height = height
end

--[[
	@instance
	@desc Fired on a screen update. Animates the stripes
	@param [number] deltaTime -- the time since last update
]]
function ProgressBar:update( deltaTime )
	if self.value > 0 or self.isIndeterminate then
		self.animationStep = self.animationStep + deltaTime * 20
	end
end

--[[
    @instance
    @desc Draws the progress bar to the canvas
]]
--[[
function ProgressBar:draw()
    local radius = self.cornerRadius
    local isEnabled = self.isEnabled

    local path = Path.rectangle( self.width, self.height, radius )

    local backgroundColour = isEnabled and self.backgroundColour or self.disabledBackgroundColour
    local outlineColour = isEnabled and self.outlineColour or self.disabledOutlineColour

    self:drawPath( 1, 1, path, backgroundColour, outlineColour )

    -- TODO: progress bar stripes
    -- First thing needed is somehow masking the stripes
    -- Second thing is actually drawing them

    -- TODO: we need either to make some sort of math class or add .round to the math API
    local width = round( self.isIndeterminate and self.width or self.width * self.value / self.maximum )
end
]]
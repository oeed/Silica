
class "Canvas" {
    
    x = Number;
    y = Number;
    width = Number;
    height = Number;
    owner = View.allowsNil;

    pixels = Table( {} );

}

function Canvas:initialise( Number x, Number y, Number width, Number height, View.allowsNil owner )
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.owner = owner
end

--[[
    @desc Fills an area in the given mask with the given colour
]]
function Canvas:fill( Mask mask, Graphics.colours colour )
end

--[[
    @desc Draws an outline around the given mask
]]
function Canvas:outline( Mask mask, Graphics.colours colour, Number( 1 ) thickness )
end

--[[
    @desc Draws the canvas to another canvas at the specified location
    @return Any returnedValue
]]

--[[
    @desc Description
]]
function Canvas:drawTo( Number x, Number y, Canvas destinationCanvas, Mask.allowsNil mask )
end

--[[
    @desc Draws an image to the canvas, scaling the image if needed
]]
function Canvas:image( Number x, Number y, Image image, Number( image.width ) width, Number( image.height ) height )
end
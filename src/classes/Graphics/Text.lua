
class "Text" extends "GraphicsObject" {
	font = nil;
	text = nil;
	textColour = nil;
}

function Text:init( x, y, width, height, text, font, textColour )
	self.super:init( x, y, width, height )
	self.text = text
	self.font = font
	self.textColour = textColour
end

--[[
	@instance
	@desc Draws a the text to the canvas
	@param [Canvas] canvas -- the canvas to draw to
	@return self
]]
function Text:drawTo( canvas )
	if self.isVisible then
		local font = self.font
		local width = self.width

		if false then
		local fontWidth = font:getWidth( self.text )
		local x = 1
		if self.alignment == Font.alignments.CENTRE then
			x = math.floor( width / 2 - fontWidth / 2 + 1 )
		elseif self.alignment == Font.alignments.RIGHT then
			x = width - fontWidth + 1
		end
		end
        font:render( canvas, self.text, self.x, self.y, self.textColour )
	end
	return self
end
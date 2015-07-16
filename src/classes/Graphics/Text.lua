
class "Text" extends "GraphicsObject" {
	font = nil;
	text = nil;
	textColour = nil;
	alignment = Font.alignments.LEFT
}

function Text:initialise( x, y, width, height, text, font, textColour )
	self.super:initialise( x, y, width, height )
	self.text = text
	self.font = font
	self.textColour = textColour
end

--[[
	@instance
	@desc Sets the font of the text object
	@param [number] font -- the font of the text object
]]
function GraphicsObject:setFont( font )
	self.hasChanged = true
	self.font = font
end

--[[
	@instance
	@desc Sets the text of the text object
	@param [number] text -- the text of the text object
]]
function GraphicsObject:setText( text )
	self.hasChanged = true
	self.text = text
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

		-- TODO: font alignment
		local fontWidth = font:getWidth( self.text )
		local x = 1
		local alignment = self.alignment
		if alignment == Font.alignments.CENTRE then
			error( "TODO: Font.alignments.CENTRE" )
			-- x = math.floor( width / 2 - fontWidth / 2 + 1 )
		elseif alignment == Font.alignments.RIGHT then
			x = width - fontWidth + 1
		end
        font:render( canvas, self.text, self.x + x - 1, self.y, self.textColour )
	end
	return self
end


class "Text" extends "GraphicsObject" {
	font = false;
	text = false;
	textColour = false;
	alignment = false;
}

function Text:initialise( x, y, width, height, text, alignment, font )
	self:super( x, y, width, height )
	self.text = text or ""
	self.font = font or Font.systemFont
	self.alignment = alignment or Font.alignments.LEFT
end

--[[
	@instance
	@desc Sets the font of the text object
	@param [number] font -- the font of the text object
]]
function Text.font:set( font )
	self.hasChanged = true
	self.font = font
end

--[[
	@instance
	@desc Sets the text of the text object
	@param [number] text -- the text of the text object
]]
function Text.text:set( text )
	self.hasChanged = true
	self.text = text or ""
end

--[[
	@instance
	@desc Draws a the text to the canvas
	@param [Canvas] canvas -- the canvas to draw to
	@return self
]]
function Text:drawTo( canvas, isShadow )
	if self.isVisible and ( not isShadow or ( isShadow and self.drawsShadow ) ) then
		local font = self.font
		local width = self.width
		local text = self.text
		local hasEllipsis = false

		local fontWidth = font:getWidth( text )
		while fontWidth > width and #text > 1 do
			text = text:sub( 1, #text - 1 )
			fontWidth = font:getWidth( text .. "..." )
			hasEllipsis = true
		end

		if hasEllipsis then
			text = text .. "..."
		end

		local x = 1
		local alignment = self.alignment
		if alignment == Font.alignments.CENTRE then
			x = 1 + math.floor( (width - fontWidth ) / 2 )
		elseif alignment == Font.alignments.RIGHT then
			x = width - fontWidth + 1
		end
        font:render( canvas, text, self.x + x - 1, self.y, width, self.height, self.textColour )
	end
	return self
end

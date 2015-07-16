
 -- will probably need to rework fonts slightly

class "BasicTextRenderer" extends "GenericRenderer" {
	textColour = 1;
	alignment = Font.alignments.LEFT
}

function BasicTextRenderer:initialise( x, y, width, height, text, font )
	self.super:initialise( x, y, width, height )
	self.text = text
	self.font = font
end

function BasicTextRenderer:setFont( font )
	self.font = font
	self.hasChanged = true
end

function BasicTextRenderer:setAlignment( alignment )
	self.alignment = alignment
	self.hasChanged = true
end

function BasicTextRenderer:setText( text )
	self.text = text
	self.hasChanged = true
end

function FilledRenderer:getRenderer()
	local renderer = GenericRenderer.getRenderer( self )
	renderer.textColour = self.textColour
	renderer.text = self.text
	renderer.font = self.font
	renderer.alignment = self.alignment
	return renderer
end

function BasicTextRenderer:setWidth( width )
	self.width = width
	self.hasChanged = true
	self.fillCache = nil
end

function BasicTextRenderer:setHeight( height )
	self.height = height
	self.hasChanged = true
	self.fillCache = nil
end

function BasicTextRenderer:setFillColour( colour )
	self.fillColour = colour
	self.hasChanged = true
end

function BasicTextRenderer:setOutlineColour( colour )
	self.outlineColour = colour
	self.hasChanged = true
end

function BasicTextRenderer:getFill()
	if self.fillcache then return self.fillcache end

	local renderer = self.renderer -- getting fill isn't rendering, dumbass

	local font = renderer.font
	local width = renderer.width

	--[[local fontWidth = font:getWidth( self.text )
	local x = 1
	if renderer.alignment == Font.alignments.CENTRE then
		x = math.floor( width / 2 - fontWidth / 2 + 1 )
	elseif renderer.alignment == Font.alignments.RIGHT then
		x = width - fontWidth + 1
	end]]
	-- font:render( renderer, renderer.text, x, 1, renderer.textColour )
	-- need to think about how font rendering works
end

function BasicTextRenderer:drawTo( canvas, x, y )
	if self.hasChanged then
		local renderer = self.renderer

		self:clear()
		
		-- I really don't know
		-- fonts need to just return a fill map I think

		renderer:drawOutline()

		renderer:finish()
		self.hasChanged = false
	end
	self:drawBufferTo( canvas, x, y )
end

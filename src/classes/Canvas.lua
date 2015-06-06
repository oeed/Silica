class 'Canvas' {
    x = 1;
    y = 1;
    width = 1;
    height = 1;

    isVisible = true;
}

function Canvas:init()
	
end

function Canvas:set( key, value )
	self:needsDraw()
end

function Canvas:needsDraw()
	-- do what ever needs to be done to tell the Canvas it needs to be redrawn

end

function Canvas:tryDraw()
	-- called whenever the canvas needs to be written to the screen
	-- so, either draw the buffer or call self:draw()
end

function Canvas:draw()
	-- this is only called when these functions are actually called
	self.drawRectangle( 1, 1, 10, 10, colours.green )
end

-- Do this later
-- function Canvas:drawText( x, y, text, [Font]font, colour)

function Canvas:drawRectangle( x, y, width, height, colour)
end

function Canvas:drawPath( path, fillColour, strokeColour, strokeWidth )
	-- for now just make a test bezier path, we'll make the Path class based on it
end


function Canvas:drawImage( x, y, image, width, height) -- width and height are optional, be default they are taken from the [Image]
	-- for now just make the image a table of colours (or whatever you want really). no characters, just colour
end
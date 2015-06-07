class 'Canvas' {
    width = 1;
    height = 1;
    x1 = 1;
    y1 = 1;
    x2 = 1;
    y2 = 1;
    overwrite = false;
    changed = false;
    buffer = { };
}

function Canvas:init(width, height, colour)
    self.width = width
    self.height = height
    self.x2 = width
    self.y2 = height
    for i=1,width*height do
        buffer[i] = colour
    end
end

function Canvas:drawPixel(x, y, colour)
    if x < self.x1 or x > self.x2 or y < self.y1 or y > self.y2 then return end
    if colour or self.overwrite then
        self.buffer[(j - 1) * width + i] = colour
        self.changed = true
    end
end

function Canvas:drawLine(x1, y1, x2, y2, colour)
    local delta_x = x2 - x1
	local ix = delta_x > 0 and 1 or -1
	delta_x = 2 * math.abs(delta_x)
	local delta_y = y2 - y1
	local iy = delta_y > 0 and 1 or -1
	delta_y = 2 * math.abs(delta_y)
	self:drawPixel(x1, y1, char, backcolor, textcolor)
	if delta_x >= delta_y then
		local error = delta_y - delta_x / 2
		while x1 ~= x2 do
			if (error >= 0) and ((error ~= 0) or (ix > 0)) then
				error = error - delta_x
				y1 = y1 + iy
			end
			error = error + delta_y
			x1 = x1 + ix
			self:drawPixel(x1, y1, char, backcolor, textcolor)
		end
	else
		local error = delta_x - delta_y / 2
		while y1 ~= y2 do
			if (error >= 0) and ((error ~= 0) or (iy > 0)) then
				error = error - delta_y
				x1 = x1 + ix
			end
			error = error + delta_x
			y1 = y1 + iy
			self:drawPixel(x1, y1, char, backcolor, textcolor)
		end
	end
end

-- Do this later
-- function Canvas:drawText( x, y, text, [Font]font, colour)

function Canvas:drawRect(x1, y1, x2, y2, colour)
    Canvas:drawLine(x1, y1, x2, y1, colour)
    Canvas:drawLine(x1, y1, x1, y2, colour)
    Canvas:drawLine(x1, y2, x2, y2, colour)
    Canvas:drawLine(x2, y1, x2, y2, colour)
end

function Canvas:fillRect(x1, y1, x2, y2, colour)
	if colour or self.overwrite then
    	if x1 > x2 then
	    	local temp = x1
    		x1, x2 = x2, temp
    	end
    	if y1 > y2 then
    		local temp = y1
    		y1, y2 = y2, temp
    	end
	    if x2 < self.x1 or x1 > self.x2 or y2 < self.y1 or y1 > self.y2 then return end
    	if x1 < self.x1 then x1 = self.x1 end
    	if x2 > self.x2 then x2 = self.x2 end
    	if y1 < self.y1 then y1 = self.y1 end
       	if y2 > self.y2 then y2 = self.y2 end
    	for j=y1,y2 do
    	    for i=x1,x2 do
    	        self.buffer[(j - 1) * self.width + i] = colour
    	    end
        end
        self.changed = true
	end
end

function Canvas:drawPath( path, fillColour, strokeColour, strokeWidth )
	-- for now just make a test bezier path, we'll make the Path class based on it
end


function Canvas:drawCanvas(x, y, canvas) -- Draws a canvas
    for j=1,canvas.height do
        for i=1,canvas.width do
            self:drawPixel(x + i - 1, y + j - 1, canvas.buffer[(j - 1) * canvas.width + i])
        end
    end
end

function Canvas:drawText( x, y, width, height, text, font, colour ) -- width and height are for wordwrapping

end

function Canvas:drawFormattedText( x, y, width, height, text )

end

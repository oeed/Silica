
class "Line" extends "GraphicsObject" {
	
	isFromTopLeft = true; -- if true the line looks like: \ (from top left to bottom right), if false it is: /

}

--[[
	@static
	@desc Creates an object with a line going from corner to corner 
	@param [number] x -- the x coordinate of the line
	@param [number] y -- the y coordinate of the line
	@param [number] width -- the width of the line
	@param [number] height -- the height of the line
	@param [number] isFromTopLeft -- whether the line is from the top left to bottom right
]]
function Line:initialise( x, y, width, height, isFromTopLeft )
	self:super( x, y, width, height )
	self.isFromTopLeft = isFromTopLeft ~= nil and isFromTopLeft or true
end

--[[
    @instance
    @desc Gets the pixes to be filled
    @return [table] fill -- the pixels to fill
]]
function Line.fill:get()
	-- TODO: why was this commented out?
	if self.fill then return self.fill end

	local fill = {{true}}
	local isFromTopLeft = self.isFromTopLeft
	local startX = 1
	local startY = isFromTopLeft and 1 or self.height
	local endX = self.width
	local endY = isFromTopLeft and self.height or 1

    if startX == endX and startY == endY then
        fill[startX] = { [startY] = true }
        return
    end

    for x = 1, self.width do
    	fill[x] = {}
    end
    
    local minX = math.min( startX, endX )
    if minX == startX then
        minY = startY
        maxX = endX
        maxY = endY
    else
        minY = endY
        maxX = startX
        maxY = startY
    end

    local xDiff = maxX - minX
    local yDiff = maxY - minY
            
    if xDiff > math.abs(yDiff) then
        local y = minY
        local dy = yDiff / xDiff
        for x=minX,maxX do
            fill[x][math.floor( y + 0.5 )] = true
            y = y + dy
        end
    else
        local x = minX
        local dx = xDiff / yDiff
        if maxY >= minY then
            for y=minY,maxY do
                fill[math.max(math.min(math.floor( x + 0.5 ), endX), startX)][y] = true
                x = x + dx
            end
        else
            for y=minY,maxY,-1 do
                fill[math.max(math.min(math.floor( x + 0.5 ), endX), startX)][y] = true
                x = x - dx
            end
        end
    end


	return fill
end

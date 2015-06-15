local function round( num )
	return math.floor( num + 0.5 )
end
class "PathView" extends "View" {
	path = nil;
	angle = math.pi / 2;
}

function PathView:init()
	self.super:init()
	
	local start = os.clock()
	-- for i = 1, 2000 do
	local path = Path:new( 200, 50 )
	-- TRIANGLE
	-- path:lineTo( 40, 5 )
	-- path:lineTo( 20, 12 )

	-- ARC
	path:arcTo( 0, math.pi / 2, 6 )

	-- BEZIER
	
	-- path:curveTo( 40, 17, 50, 5, 50, 17  )
	-- path:curveTo( 20, 7, 20, 17, 20, 10 )

	-- path:close()
	-- print(textutils.serialize(path.points))

-- end
-- 	print((os.clock() - start) / 2000)

end

-- function PathView:update()
-- 	term.setBackgroundColour(colours.black)
-- 	term.clear()
-- 	self.angle = self.angle + 0.1
-- 	local path = Path:new( 150, 50 )
-- 	path:arcTo( 0, self.angle, 30 )
-- end

-- function PathView:draw()
-- 	term.setBackgroundColour(colours.black)
-- 	term.clear()

-- 	local outline = self.path.outline
--         for x, col in pairs( outline ) do
--             for y, pixel in pairs( col ) do
--                 paintutils.drawPixel( x, y, colours.blue )
--             end
--         end


--     local fill = self.path.fill
--     for x, col in pairs( fill ) do
--         for y, pixel in pairs( col ) do
--             paintutils.drawPixel( x, y, colours.green )
--         end
--     end

-- end

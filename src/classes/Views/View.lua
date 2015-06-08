
local DEFAULT_TIME = .3
local DEFAULT_EASING = "inOutSine"

local function newAnimation( self, label, time, values, easing, onFinish )
	local animation = AnimationA( time, self, values, easing )
	for i = #self.animations, 1, -1 do
		if self.animations[i].label == label then
			table.remove( self.animations, i )
		end
	end
	self.animations[#self.animations + 1] = { label = label, animation = animation, onFinish = onFinish }
end

class "View" {
	x = 0;
	y = 0;
	parent = nil;
	animations = nil;
	event = nil;
}

--[[
	@instance
	@desc Initialise a view instance
	@param [table] properties -- the properties for the view
]]
function View:init( properties )
	self.animations = { names = {} }

	if properties and type( properties ) == "table" then
		self:properties( properties )
	end

	self:initEventManager()
end

--[[
	@instance
	@desc Initialises the view's event manager (used for overriding)
]]
function View:initEventManager( arg1, arg2, arg3 )
	self.event = EventManager( self )
end

--[[
	@instance
	@desc Draws the contents of the view
	@param [number] x -- the x cordinate to draw from
	@param [number] y -- the y cordinate to draw from
]]
function View:draw( x, y )
	
end


--[[
	@instance
	@desc Hit test the view realative to the parents coordinates (or globally if not specified)
	@param [number] x -- the x coordinate to hit test
	@param [number] y -- the y coorindate to hit test
	@param [View] parent -- the parent
	@return [boolean] isHit -- whether the hit test hit
]]
function View:hitTest( x, y, parent )
	-- TODO: view hit test
	-- this should simply check if it's between x, y, width and height. subclasses with non-rectangle shapes will do the following:
	-- 		if super:hitTest( x, y, parent ) then
	-- 			if isHittingSelf then
	-- 				...
	-- 			end
	-- 		end
	return isHit
end

--[[
	@instance
	@desc Hit tests the view with an event relative to the parent, uses the coordinates if it's a MouseEvent, otherwise it will always return true
	@param [Event] event -- the event
	@param [View] parent -- the parent
	@return [boolean] isHit -- whether the hit test hit
]]
function View:hitTestEvent( event, parent )
	if event:typeOf( MouseEvent ) then
		local x, y = event.x, event.y
		return self:hitTest( x, y, parent )
	else
		return true
	end
end

--[[
	@instance
	@desc Update the animation
	@param [table] properties -- the properties for the view
]]
function View:update( dt )
	for i = #self.animations, 1, -1 do
		self.animations[i].animation:update( dt )
		if self.animations[i].clock >= self.animations[i].duration then
			if self.animations[i].onFinish then
				self.animations[i].onFinish( self )
			end
			table.remove( self.animations, i )
		end
	end
end

--[[
	@instance
	@desc Animate a change in the x coordinate
	@param [number] x -- the target x coordinate
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]
function View:animateX( x, time, onFinish, easing )
	newAnimation( self, "x", time or DEFAULT_TIME, { x = x }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

--[[
	@instance
	@desc Animate a change in the y coordinate
	@param [number] y -- the target y coordinate
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]
function View:animateY( y, time, onFinish, easing )
	newAnimation( self, "y", time or DEFAULT_TIME, { y = y }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

--[[
	@instance
	@desc Animate a change in the width
	@param [number] width -- the target width
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]
function View:animateWidth( width, time, onFinish, easing )
	newAnimation( self, "width", time or DEFAULT_TIME, { width = width }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

--[[
	@instance
	@desc Animate a change in the height
	@param [number] height -- the target height
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]
function View:animateHeight( height, time, onFinish, easing )
	newAnimation( self, "height", time or DEFAULT_TIME, { height = height }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

--[[
	@instance
	@desc Animate a change in the position
	@param [number] x -- the target x coordinate
	@param [number] y -- the target y coordinate
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]
function View:move( x, y, time, onFinish, easing )
	local d = false
	local function f()
		if not d then d = true return onFinish() end -- stops the function being called twice
	end
	self:animateX( x, time, type( onFinish ) == "function" and f, easing )
	self:animateY( y, time, type( onFinish ) == "function" and f, easing )
end

--[[
	@instance
	@desc Animate a change in the size
	@param [number] width -- the target width
	@param [number] height -- the target height
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]

function View:resize( width, height, time, onFinish, easing )
	local d = false
	local function f()
		if not d then d = true return onFinish() end -- stops the function being called twice
	end
	self:animateWidth( width, time, type( onFinish ) == "function" and f, easing )
	self:animateHeight( height, time, type( onFinish ) == "function" and f, easing )
end

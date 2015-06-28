
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
	x = 1;
	y = 1;
	width = 1;
	height = 1;
	index = nil;
	parent = nil;
	animations = nil;
	event = nil;
	siblings = nil;
	identifier = nil;
	canvas = nil;
	isCanvasHitTested = true;
	isVisible = true;
	theme = nil;
	isEnabled = true;
}

--[[
	@instance
	@desc Initialise a view instance
	@param [table] properties -- the properties for the view
]]
function View:init( properties )
	self.animations = { names = {} }
	self.theme = ThemeOutlet( self )
	self:initCanvas()

	if properties and type( properties ) == "table" then
		self:properties( properties )
	end

	self:initEventManager()
end

--[[
	@instance
	@desc Initialises the view's event manager (used for overriding)
]]
function View:initEventManager()
	self.event = EventManager( self )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function View:initCanvas()
	self.canvas = Canvas( self.x, self.y, self.width, self.height )
end

--[[
	@instance
	@desc Returns the view's siblings in it's container
	@return [table] siblings -- an array of the siblings
]]
function View:getSiblings()
	local siblings = {}

	if self.parent then
		for i, child in ipairs( self.parent.children ) do
			if child ~= self then
				table.insert( siblings, child )
			end
		end
	end

	return siblings
end

--[[
	@instance
	@desc Returns whether the control is enabled, rising up to the parent containers as well
	@return [boolean] isEnabled -- whether the view is enabled
]]
function View:getIsEnabled()
	if not self.isEnabled then
		return false
	else
		local parent = self.parent
		if parent and not parent.isEnabled then
			return false
		else
			return true
		end
	end
end

--[[
	@instance
	@desc Returns the index of the view in it's parent. 1 is the bottom most view
	@return [number] index -- an array of the siblings
]]
function View:getIndex()
	if self.parent then
		for i, child in ipairs( self.parent.children ) do
			if child == self then
				return i
			end
		end
	end
end

--[[
	@instance
	@desc Returns the view's siblings in it's container that are of or inherit from the given class
	@param [class] _class -- the class type
	@return [table] siblings -- an array of the siblings
]]
function View:siblingsOfType( _class )
	local siblings = {}

	for i, sibling in ipairs( self.siblings ) do
		if sibling:typeOf( _class ) then
			table.insert( siblings, sibling )
		end
	end

	return siblings
end

function View:setX( x )
	if self.hasInit then
		self.canvas.x = x
	end
	self.x = x
end

function View:setY( y )
	if self.hasInit then
		self.canvas.y = y
	end
	self.y = y
end

function View:setIsVisible( isVisible )
	if self.hasInit then
		self.canvas.isVisible = isVisible
	end
	self.isVisible = isVisible
end

function View:getIsVisible()
	-- if we don't have a parent we're effectively not visible
	return self.parent and self.isVisible
end

function View:setWidth( width )
	if self.hasInit then
		self.canvas.width = width
	end
	self.width = width
end

function View:setHeight( height )
	if self.hasInit then
		self.canvas.height = height
	end
	self.height = height
end

--[[
	@instance
	@desc Draws the contents of the view
	@param [number] x -- the x cordinate to draw from
	@param [number] y -- the y cordinate to draw from
]]

--[[
	@instance
	@desc Converts the local coordinates to local coordinates of a parent (or global if nil) to.
	@param [number] x -- the local x coordinate
	@param [number] y -- the local y coordinate
	@param [View] parent -- the parent to convert to
	@return [number] x -- the x coordinate in the parent's coordinate system
	@return [number] y -- the x coordinate in the parent's coordinate system
]]
function View:coordinatesTo( x, y, parent )
	parent = parent or self.application.container

	local currentParrent = { parent = self }
	while currentParrent.parent and currentParrent.parent ~= parent do
		currentParrent = currentParrent.parent
		x = x + currentParrent.x - 1
		y = y + currentParrent.y - 1
	end
	return x, y
end

--[[
	@instance
	@desc Converts the position of the view to the coordinates in a parent (or global if nil)
	@param [View] parent -- the parent to convert to
	@return [number] x -- the x coordinate in the parent's coordinate system
	@return [number] y -- the x coordinate in the parent's coordinate system
]]
function View:position( parent )
	if not self.parent or parent == self.parent then
		return self.x, self.y
	else
		local x, y = self:coordinatesTo( 1, 1, parent )
		return x, y
	end
end

--[[
	@instance
	@desc Converts the coordinates of a parent (or global if nil) to local coordinates.
	@param [number] x -- the x coordinate
	@param [number] y -- the y coordinate
	@param [View] parent -- the parent to convert from
	@return [number] x -- the local x coordinate
	@return [number] y -- the local x coordinate
]]
function View:coordinates( x, y, parent )
	parent = parent or self.application.container
	
	local currentParrent = self
	while currentParrent and currentParrent ~= parent do
		x = x - currentParrent.x + 1
		y = y - currentParrent.y + 1
		currentParrent = currentParrent.parent
	end

	return x, y
end

--[[
	@instance
	@desc Hit test the view realative to the parent's coordinates (or globally if not specified)
	@param [number] x -- the x coordinate to hit test
	@param [number] y -- the y coorindate to hit test
	@param [View] parent -- the parent
	@return [boolean] isHit -- whether the hit test hit
]]
function View:hitTest( x, y, parent )
	return self.isVisible and self.x <= x
	   and x <= self.x + self.width - 1
	   and self.y <= y and y <= self.y + self.height - 1
	   and ( not self.isCanvasHitTested or self.canvas:hitTest( x - self.x + 1, y - self.y + 1 ))
end

--[[
	@instance
	@desc Hit tests the view with an event relative to the parent, uses the coordinates if it's a MouseEvent, otherwise it will always return true
	@param [Event] event -- the event
	@param [View] parent -- the parent
	@return [boolean] isHit -- whether the hit test hit
]]
function View:hitTestEvent( event, parent )
	parent = parent or self.parent
	if not parent then return false
	elseif event:typeOf( MouseEvent ) then
		event:makeRelative( parent )
		local x, y = event.x, event.y
		return self:hitTest( x, y, parent )
	else
		return true
	end
end

--[[
	@instance
	@desc Update the animation
	@param [number] deltaTime -- time since last update
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

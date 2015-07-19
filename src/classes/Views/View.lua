
local DEFAULT_TIME = .3
local DEFAULT_EASING = Animation.easing.IN_OUT_SINE

local function newAnimation( self, label, time, values, easing, onFinish )
	local animation = Animation( time, self, values, easing, true )
	for i = #self.animations, 1, -1 do
		if self.animations[i].label == label then
			table.remove( self.animations, i )
		end
	end
	self.animations[#self.animations + 1] = { label = label, animation = animation, onFinish = onFinish }
end

class "View" {
	x = false;
	y = false;
	width = false;
	height = false;
	index = false; -- its index in its parent
	parent = false;
	siblings = false;
	identifier = false;
	interfaceProperties = false; -- the properties the view was given in the interface XML file

	animations = {};

	event = false;
	canvas = false;
	theme = false;
	isCanvasHitTested = true;
	isVisible = true;
	isFocusDismissable = true; -- whether clicking away from the view when focused will unfocus it
	isEnabled = true;

	stringConstraints = {}; -- the constraints strings
	loadedConstraints = {}; -- the parsed constraints
	constraintsNeedingUpdate = {}; -- the constraints that need to be refreshed next update
	needsConstraintUpdate = {}; -- whether the constraint values have changed and the view needs to be informed
	references = {};
	--[[ format:
		{
			[property] = {
				[reference1 (string)] = true;
				[reference2 (string)] = true;
			}
		}
	]]
}

--[[
	@constructor
	@desc Initialise a view instance
	@param [table] properties -- the properties for the view
]]
function View:initialise( properties )
	self.animations.names = {} 
	self:initialiseEventManager()
	self:initialiseTheme()
	self:initialiseCanvas()

	setmetatable( self.stringConstraints, {
		__index = { parent = self }, __newindex = function( t, k, v )
			if t.parent.identifier == "testview" then
				-- log( "Setting " .. k .. " to " .. tostring( v ) )
				-- logtraceback()
			end
			rawset( t, k, v )
		end
	} )
	
	if properties and type( properties ) == "table" then
		self:properties( properties )
	end

    self:event( Event.PARENT_RESIZED, self.onParentResizedConstraintUpdate )
    self:event( Event.PARENT_CHANGED, self.onParentChangedConstraintUpdate )
    self:event( Event.INTERFACE_READY, self.onReadyConstraintUpdate )
end

function View:initialiseTheme()
	self.theme = ThemeOutlet( self )
end

--[[
	@instance
	@desc Initialises the view's event manager (used for overriding)
]]
function View:initialiseEventManager()
	self.event = EventManager( self )
end

--[[
    @instance
    @desc Sets up the canvas and it's graphics objects
]]
function View:initialiseCanvas()
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
				siblings[#siblings + 1] = child
			end
		end
	end

	return siblings
end

--[[
	@instance
	@desc Returns true if the view is the first child of it's parent
	@return [boolean] isFirst -- whether  the view is the first child of it's parent
]]
function View:getIsFirst()
    return self.index == 1
end

--[[
	@instance
	@desc Returns true if the view is the last child of it's parent
	@return [boolean] isLast -- whether  the view is the last child of it's parent
]]
function View:getIsLast()
    local parent = self.parent
    return parent and (self.index == #parent.children) or false
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
	return 1
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
			siblings[#siblings + 1] = sibling
		end
	end

	return siblings
end

View:alias( "x", "left" )
View:alias( "y", "top" )

-- object.left is the raw left value (i.e. a number, or nil if not yet calculated)
-- object.loadedConstraints.left is the parsed and simplified left value
-- object.stringConstraints.left is the string constraint

--[[
	@instance
	@desc Parses a constraint and simplifies it
	@param [string] property - the constraint to parse and simplify
	@return [table] parsed - the parsed and simplified constraint
]]
function View:parseConstraint( property )
	local loaded = self.loadedConstraints
	if loaded[property] then return loaded[property] end

	local constraints = self.stringConstraints
	local constraintString = constraints[property]
	
	if not constraintString then
		-- solve it based on other constraints
		local left, right, top, bottom, width, height = constraints.left or "1", constraints.right or "1", constraints.top or "1", constraints.bottom or "1", constraints.width or "1", constraints.height or "1"

		if property == "width" then
			constraintString = "(" .. right .. ")-(" .. left .. ")+1"
		elseif property == "height" then
			constraintString = "(" .. bottom .. ")-(" .. top .. ")+1"
		elseif property == "left" then
			constraintString = "(" .. right .. ")-(" .. width .. ")+1"
		elseif property == "right" then
			constraintString = "(" .. width .. ")+(" .. left .. ")-1"
		elseif property == "top" then
			constraintString = "(" .. bottom .. ")-(" .. height .. ")+1"
		elseif property == "bottom" then
			constraintString = "(" .. top .. ")+(" .. height .. ")-1"
		else
			constraintString = "0"
		end
	end

	local parsed = MathParser.parseString( tostring( constraintString ) )
	MathParser.simplify( parsed )

	loaded[property] = parsed
	return parsed
end

--[[
	@instance
	@desc Evaluates the numerical value of a constraint
	@param [string] property -- the name of the property (i.e. left, width, etc.)
	@return [number] value -- the numerical value
]]
function View:evalConstraint( property )
	local references = {}
	local parsed = self:parseConstraint( property )
	local resolved = MathParser.resolve( parsed, self, property, references )
	local value = MathParser.eval( resolved )

	self.raw[property] = value
	self.references[property] = references
	
	self.needsConstraintUpdate[self:updateConstraint( property, value )] = true
	return value
end

function View:updateConstraint( property, value )
	local stringConstraints = self.stringConstraints
	local canvas = self.canvas
	if property == "top" then
		self.raw.y = value
		if canvas then canvas.y = value end
		return "y"
	elseif property == "bottom" then
		if stringConstraints.height then
			value = value - self.height + 1
			self.raw.y = value
			if canvas then canvas.y = value end
			return "y"
		else
			value = value - self.y + 1
			self.raw.height = value
			if canvas then canvas.height = value end
			return "height"
		end
	elseif property == "left" then
		self.raw.x = value
		if canvas then canvas.x = value end
		return "x"
	elseif property == "right" then
		if stringConstraints.width then
			value = value - self.width + 1
			self.raw.x = value
			if canvas then canvas.x = value end
			return "x"
		else
			value = value - self.x + 1
			self.raw.width = value
			if canvas then canvas.width = value end
			return "width"
		end
	elseif property == "width" then
		self.raw.width = value
		if canvas then canvas.width = value end
		return "width"
	elseif property == "height" then
		self.raw.height = value
		if canvas then canvas.height = value end
		return "height"
	end
end

--[[
	@instance
	@desc Called when the parent changes. This updates constraints.
	@param [ParentChangedInterfaceEvent] event -- the event
]]
function View:onParentChangedConstraintUpdate( event )
	for k, v in pairs( self.stringConstraints ) do
		self.constraintsNeedingUpdate[k] = true
	end
end

--[[
	@instance
	@desc Called when the interface is loaded and ready. This updates constraints.
	@param [ReadyInterfaceEvent] event -- the event
]]
function View:onReadyConstraintUpdate( event )
	if event.isInit then
		for k, v in pairs( self.stringConstraints ) do
			self.constraintsNeedingUpdate[k] = true
		end
	end
end

--[[
	@instance
	@desc Called when the parent resizes. This updates constraints.
	@param [ParentResizeInterfaceEvent] event -- the event
]]
function View:onParentResizedConstraintUpdate( event )
	local isHorizontal = event.isHorizontal
	local isVertical = event.isVertical
	local ident = self.identifier
	for k, v in pairs( self.stringConstraints ) do
		local isKHorizontal = ( k == "left" or k == "right" or k == "width" )
		if isHorizontal and isKHorizontal then
			self.constraintsNeedingUpdate[k] = true
		elseif isVertical and not isKHorizontal then
			self.constraintsNeedingUpdate[k] = true
		end
	end
end

--[[
	@instance
	@desc Re-evaluates a constraint, reparsing if necessary.
	@param [string] property -- the name of the property (i.e. left, width, etc.)
	@param [boolean] isReferenceChange -- false if it should re-parse the constraint
	@return [number] value

	@note - call when a reference changes with true
	@note - call when the constraint changes with false
]]
function View:reloadConstraint( property, isReferenceChange )
	if not isReferenceChange then
		self.loadedConstraints[property] = nil
	end
	return self:evalConstraint( property )
end

-- @instance
function View:getTop()
	return self.top or self:evalConstraint "top"
end

-- @instance
function View:setTop( top )
	if top then
		self.stringConstraints.top = top
		self:reloadConstraint "top"
	else
		self.stringConstraints.top = nil
	end
end

-- @instance
function View:getBottom()
	return self.bottom or self:evalConstraint "bottom"
end

-- @instance
function View:setBottom( bottom )
	if bottom then
		local stringConstraints = self.stringConstraints
		stringConstraints.bottom = bottom
		self:reloadConstraint "bottom"
		if stringConstraints.height then
			stringConstraints.top = nil
		elseif stringConstraints.top then
			stringConstraints.height = nil
		end
	else
		self.stringConstraints.top = nil
	end
end

-- @instance
function View:getLeft()
	return self.left or self:evalConstraint "left"
end

-- @instance
function View:setLeft( left )
	local value
	if left then
		local stringConstraints = self.stringConstraints
		stringConstraints.left = left
		value = self:reloadConstraint "left"
		if stringConstraints.width then
			stringConstraints.right = nil
		elseif stringConstraints.right then
			stringConstraints.width = nil
		end
	else
		self.stringConstraints.left = nil
	end
	return value
end

-- @instance 
function View:getRight()
	return self.right or self:evalConstraint "right"
end

-- @instance 
function View:setRight( right )
	local value
	if right then
		local stringConstraints = self.stringConstraints
		stringConstraints.right = right
		value = self:reloadConstraint "right"
		if stringConstraints.width then
			stringConstraints.left = nil
		elseif stringConstraints.left then
			stringConstraints.width = nil
		end
	else
		self.stringConstraints.right = nil
	end
	return value
end

-- @instance 
function View:getWidth()
	return self.width or self:evalConstraint "width"
end

-- @instance 
function View:setWidth( width )
	local value
	if width then
		local stringConstraints = self.stringConstraints
		stringConstraints.width = width
		value = self:reloadConstraint "width"
		if stringConstraints.left then
			stringConstraints.right = nil
		elseif stringConstraints.right then
			stringConstraints.left = nil
		end
	else
		self.stringConstraints.width = nil
	end
	return value
end

-- @instance 
function View:getHeight()
	return self.height or self:evalConstraint "height"
end

-- @instance 
function View:setHeight( height )
	local value
	if height then
		local stringConstraints = self.stringConstraints
		stringConstraints.height = height
		value = self:reloadConstraint "height"
		if stringConstraints.top then
			stringConstraints.bottom = nil
		elseif stringConstraints.bottom then
			stringConstraints.top = nil
		end
	else
		self.stringConstraints.height = nil
	end
	return value
end

function View:setIsVisible( isVisible )
	self.canvas.isVisible = isVisible
	self.isVisible = isVisible
end

function View:getIsVisible()
	return self.parent and self.isVisible -- if we don't have a parent we're effectively not visible
end

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
	local animations = self.animations
	for i = #animations, 1, -1 do
		local animation = animations[i]
		animation.animation:update( dt )
		if animation.animation.time >= animation.animation.duration then
			if animation.onFinish then
				animation.onFinish( self )
			end
			table.remove( animations, i )
		end
	end

	local constraintsNeedingUpdate = self.constraintsNeedingUpdate
	local constraintOrder = { "width", "height", "left", "top", "bottom", "right" }
	for i, v in ipairs( constraintOrder ) do
		if constraintsNeedingUpdate[v] then
			self:reloadConstraint( v, true )
			constraintsNeedingUpdate[v] = nil
		end
	end

	if self.hasInitialised then
		local needsConstraintUpdate = self.needsConstraintUpdate
		for k, isChanged in pairs( needsConstraintUpdate ) do
			if isChanged then
				local constraintUpdate = self[k == "x" and "updateX" or k == "y" and "updateY" or k == "width" and "updateWidth" or k == "height" and "updateHeight"]
				if constraintUpdate then
					constraintUpdate( self, self.raw[k] )
				end
				needsConstraintUpdate[k] = false
			end
		end
	end
end

--[[
	@instance
	@desc Animate a change in a certain property
	@param [string] propertyName -- the name of the property
	@param [number] value -- the target value
	@param [number] time -- the duration of the animation
	@param [function] onFinish -- the function called on completion of the animation
	@param [Animation.easing] easing -- the easing function of the animation
]]
function View:animate( propertyName, value, time, onFinish, easing )
	newAnimation( self, propertyName, time or DEFAULT_TIME, { [propertyName] = value }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
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

function View:dispose()
	self.event:dispose()
end

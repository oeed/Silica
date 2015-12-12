
local MAX_DOUBLE_CLICK_TIME = 0.8
local MIN_MOUSE_HOLD_TIME = 0.3

local ANIMATION_DEFAULT_TIME = 0.3
local DEFAULT_EASING = Animation.easings.IN_OUT_SINE

local function newAnimation( self, label, time, values, easing, onFinish, round )
	local animations = self.animations
	for i = #animations, 1, -1 do
		if animations[i].label == label then
			table.remove( animations, i )
		end
	end
	
	-- prevent values that won't change from being animated
	local hasValue = false
	for k, v in pairs( values ) do
		if self[k] == v then
			values[k] = nil
		else
			hasValue = true
		end
	end
	if not hasValue then return end
	local animation = Animation( time, self, values, easing, round == nil and true or round )
	animations[#animations + 1] = { label = label, animation = animation, onFinish = onFinish }
end

class "View" {

	x = Number( 1 );
	y = Number( 1 );
	width = Number( 1 );
	height = Number( 1 );
	index = Number.allowsNil; -- the z index in its parent
	parent = Any.allowsNil; -- TODO: if this is Container it loads the Container class before View is loaded so it creates another View class table
	siblings = Table.allowsNil;
	identifier = String.allowsNil;
	isFirst = Boolean.allowsNil;
	isLast = Boolean.allowsNil; -- TODO: .isReadOnly

	animations = Table( { names = {} } );

	event = EventManager;

	canvas = Canvas;
	shadowMask = Mask.allowsNil; -- TODO: .isReadOnly
	shadowSize = Number( 0 );
	needsDraw = Boolean( true );
	isVisible = Boolean( true );
	theme = ThemeOutlet;

	isCanvasHitTested = Boolean( true );
	isFocused = Boolean( false );
	isSingleFocusOnly = Boolean( false ); -- whether only this view can be in-focus when focused (i.e. so 3 textboxes aren't focused at the same time)
	isFocusDismissable = Boolean( true ); -- whether clicking away from the view when focused will unfocus it
	isEnabled = Boolean( true );

	lastMouseDown = Table( {} );
	lastMouseUp = Table( {} );

}

--[[
	@constructor
	@desc Initialise a view instance
]]
function View:initialise( Table.allowsNil properties )
	self:initialiseEventManager()
	self.theme = ThemeOutlet( self )
	self:initialiseCanvas()

	if properties then
		for k, v in pairs(properties) do
			self[k] = v
		end
	end

    self:event( MouseDownEvent, self.onMouseDownMetaEvents )
    self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUpMetaEvents )
end

--[[
	@desc Initialises the view's event manager (used for overriding)
]]
function View:initialiseEventManager()
	self.event = EventManager( self )
end

--[[
    @desc Sets up the canvas and it's graphics objects (used for overriding)
]]
function View:initialiseCanvas()
	self.canvas = Canvas( self.width, self.height, self )
end

--[[
	@desc The Mask to use for the View's shadow
]]
function View.shadowMask:get()
	return self.canvas.contentMask -- self.canvas.mask is the mask of the currently drawn pixels to the canvas, i.e. everything will cast a shadow
end

function View.shadowSize:set( shadowSize )
	self.shadowSize = shadowSize
	self.needsDraw = true 
end

--[[
	@desc Called when a parent Container wants the Canvas to be redraw
]]
function View:draw()
	self.canvas:clear()
	self:onDraw() -- we have no children, just draw our own content
end

--[[
	@desc Called when the contents of the View's Canvas needs to be updated
]]
function View:onDraw()

end

function View.needsDraw:set( needsDraw )
	self.needsDraw = needsDraw
	if needsDraw then
		local parent = self.parent
		if parent then
			parent.needsDraw = needsDraw -- if we need to draw the parent also has to redraw
		end
	end
end

-- Location --

--[[
	@desc Returns the view's siblings in it's container
	@return [table] siblings -- an array of the siblings
]]
function View.siblings:get()
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
	@desc Returns true if the view is the first child of it's parent
	@return [boolean] isFirst -- whether  the view is the first child of it's parent
]]
function View.isFirst:get()
    return self.index == 1
end

--[[
	@desc Returns true if the view is the last child of it's parent
	@return [boolean] isLast -- whether  the view is the last child of it's parent
]]
function View.isLast:get()
    local parent = self.parent
    return parent and (self.index == #parent.children) or false
end

--[[
	@desc Returns whether the control is enabled, rising up to the parent containers as well
	@return [boolean] isEnabled -- whether the view is enabled
]]
function View.isEnabled:get()
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
	@desc Returns the index of the view in it's parent. 1 is the bottom most view
	@return [number] index -- an array of the siblings
]]
function View.index:get()
	local parent = self.parent
	if parent then
		for i, child in ipairs( parent.children ) do
			if child == self then
				return i
			end
		end
	end
	return 1
end

--[[
	@desc Sets the z index of the view in it's parent container
]]
function View.index:set( index )
	local parent = self.parent
	if parent then
		local containerChildren = parent.children
		index = math.max( math.min( index, #containerChildren), 1 )

		local currentIndex
		for i, child in ipairs( containerChildren ) do
			if child == self then
				currentIndex = i
				break
			end
		end

		if currentIndex ~= index then
			table.remove( containerChildren, currentIndex )
			table.insert( containerChildren, index, self )
		end
	end
end

--[[
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

function View.height:set( height )
	self.height = height
    self.canvas.height = height
    self.needsDraw = true
end

function View.width:set( width )
	self.width = width
    self.canvas.width = width
    self.needsDraw = true
end

function View.x:set( x )
	self.x = x
	local parent = self.parent
	if parent then
	    parent.needsDraw = true
	end
end

function View.y:set( y )
	self.y = y
	local parent = self.parent
	if parent then
	    parent.needsDraw = true
	end
end

function View.isVisible:get()
	return self.parent and self.isVisible -- if we don't have a parent we're effectively not visible
end

function View.isVisible:set( isVisible )
	self.isVisible = isVisible
	local parent = self.parent
	if parent then
		self.parent.needsDraw = true
	end
end

--[[
	@desc Converts the local coordinates to local coordinates of a parent (or global if nil) to.
	@return Number x -- the x coordinate in the parent's coordinate system
	@return Number y -- the x coordinate in the parent's coordinate system
]]
--									TODO: Any should be Container. If it is it loads another View class, so there are two different ones
function View:coordinatesTo( Number x, Number y, Any( self.application.container ) parent )
	local currentParrent = { parent = self }
	while currentParrent.parent and currentParrent.parent ~= parent do
		currentParrent = currentParrent.parent
		x = x + currentParrent.x - 1
		y = y + currentParrent.y - 1
	end
	return x, y
end

--[[
	@desc Converts the position of the view to the coordinates in a parent (or global if nil)
	@param [View] parent -- the parent to convert to
	@return [number] x -- the x coordinate in the parent's coordinate system
	@return [number] y -- the x coordinate in the parent's coordinate system
]]
--					TODO: Any should be Container. If it is it loads another View class, so there are two different ones
function View:position( Any( self.application.container ) parent )
	local selfParent = self.parent
	if not selfParent or parent == selfParent then
		return self.x, self.y
	else
		local x, y = self:coordinatesTo( 1, 1, parent )
		return x, y
	end
end

--[[
	@desc Converts the coordinates of a parent (or global if nil) to local coordinates.
	@return [number] x -- the local x coordinate
	@return [number] y -- the local x coordinate
]]
--							TODO: Any should be Container. If it is it loads another View class, so there are two different ones
function View:coordinates( Number x, Number y, Any( self.application.container ) parent )
	local currentParrent = self
	while currentParrent and currentParrent ~= parent do
		x = x - currentParrent.x + 1
		y = y - currentParrent.y + 1
		currentParrent = currentParrent.parent
	end

	return x, y
end

--[[
	@desc Hit test the view realative to its parent's coordinates
	@param [number] x -- the x coordinate to hit test
	@param [number] y -- the y coorindate to hit test
	@return [boolean] isHit -- whether the hit test hit
]]
function View:hitTest( Number x, Number y )
	local _x, _y = self.x, self.y
	return self.isVisible and _x <= x
	   and x <= _x + self.width - 1
	   and _y <= y and y <= _y + self.height - 1
	   and ( not self.isCanvasHitTested or self.canvas:hitTest( x - _x + 1, y - _y + 1 ) )
end

--[[
	@desc Hit tests the view with an event relative to the parent, uses the coordinates if it's a MouseEvent, otherwise it will always return true
	@param [Event] event -- the event
	@param [View] parent -- the parent
	@return [boolean] isHit -- whether the hit test hit
]]
--							TODO: Any should be Container. If it is it loads another View class, so there are two different ones
function View:hitTestEvent( Event event, Any( self.parent ) parent )
	if not parent then
		return false
	elseif event:typeOf( MouseEvent ) then
		event:makeRelative( parent )
		local x, y = event.x, event.y
		return self:hitTest( x, y )
	else
		return true
	end
end

--[[
	@desc Update the animation
	@param [number] deltaTime -- time since last update
]]
function View:update( dt )
	local animations = self.animations
	for i = #animations, 1, -1 do
		local animation = animations[i]
		animation.animation:update( dt )
		if animation.animation.time >= animation.animation.duration then
			table.remove( animations, i )
			if animation.onFinish then
				animation.onFinish( self )
			end
		end
	end
end

--[[
	@desc Animate a change in a certain property
]]
function View:animate( String propertyName, Number value, Number( ANIMATION_DEFAULT_TIME ) time, Function.allowsNil onFinish, Animation.easings( DEFAULT_EASING ) easing, Number( 0 ) delay, Boolean( true ) round )
	local addAnimation = function()
		newAnimation( self, propertyName, time, { [propertyName] = value }, easing or DEFAULT_EASING, onFinish, round )
	end
	if delay <= 0 then
		addAnimation()
	else
		self.application:schedule( addAnimation, delay )
	end
end

--[[
	@desc Animate a change in the position
]]
function View:animateMove(  Number x, Number y, Number( ANIMATION_DEFAULT_TIME ) time, Function.allowsNil onFinish, Animation.easings( DEFAULT_EASING ) easing, Number( 0 ) delay )
	self:animate( "x", x, time, onFinish, easing, delay )
	self:animate( "y", y, time, nil, easing, delay )
end

--[[
	@desc Animate a change in the size
]]
function View:animateResize( Number width, Number height, Number( ANIMATION_DEFAULT_TIME ) time, Function.allowsNil onFinish, Animation.easings( DEFAULT_EASING ) easing, Number( 0 ) delay )
	self:animate( "width", width, time, onFinish, easing, delay )
	self:animate( "height", height, time, nil, easing, delay )
end

--[[
	@desc Detects when the mouse is pressed. Used to fire mouse held and double click
]]
function View:onMouseDownMetaEvents( MouseDownEvent event, Event.phases phase )
	local mouseButton, time = event.mouseButton, os.time()
	local lastMouseDown, lastMouseUp = self.lastMouseDown, self.lastMouseUp

	local thisLastMouseDown = lastMouseDown[mouseButton]
	if thisLastMouseDown and time - thisLastMouseDown < MAX_DOUBLE_CLICK_TIME then
		-- double click
		if self.event:handleEvent( MouseDoubleClickEvent( mouseButton, event.x, event.y, event.globalX, event.globalY ) ) then
			return true
		end
	else
		
		-- start a held timer
		local application = self.application 
		if lastMouseDown.timer then
			application:unschedule( lastMouseDown.timer )
		end

		local x, y, globalX, globalY = event.x, event.y, event.globalX, event.globalY
		local n
		lastMouseDown.timer = application:schedule( function()
			lastMouseDown.timer = nil
			local thisLastMouseUp = lastMouseUp[mouseButton]
			if not thisLastMouseUp or thisLastMouseUp < time then
				if self.event:handleEvent( MouseHeldEvent( mouseButton, x, y, globalX, globalY ) ) then
					return true
				end
			end
		end, MIN_MOUSE_HOLD_TIME )
		n = lastMouseDown.timer
	end
	lastMouseDown[mouseButton] = time
end

--[[
	@desc Detects when the mouse is released. Used to fire mouse held and double click
]]
function View:onGlobalMouseUpMetaEvents( MouseUpEvent event, Event.phases phase )
	self.lastMouseUp[event.mouseButton] = os.time()
end

--[[
	@desc Starts a drag and drop for the view
]]
function View:startDragDrop( MouseDownEvent event, ClipboardData data, Boolean( true ) hideSource, Function.allowsNil completion, Table.allowsNil views )
    self.application.dragDropManager:start( views or { self }, data, event.globalX, event.globalY, hideSource, completion )
end

function View.isFocused:set( isFocused )
    local wasFocused = self.isFocused
    if wasFocused ~= isFocused then
        self.isFocused = isFocused
        self:updateThemeStyle()
    end
end

function View:focus( filter )
    self.application:focus( self, filter )
end

function View:addFocus()
    self.application:addFocus( self )
end

function View:unfocus()
    self.application:unfocus( self )
end

function View:clearFocus( filter )
    self.application:clearFocus( filter )
end

function View:dispose()
	self.event:dispose()

	local parent = self.parent
	if parent then
		parent:remove( self )
	end

	if self.isFocused then
		self:unfocus()
	end
end


-- need to fix scheduling ... cancelling them won't work right now
-- each one needs to have its own ID and return that ID

class "Application" {

	name = false;
	path = false;
	updateTimer = false;
	lastUpdate = 0;
	arguments = {};
	isRunning = false;
	container = false;
	document = false;
	event = false;
	schedules = {};
	resourceDirectories = { _ = true }; -- the folders in which the applications resources are
	resourceTables = false; -- the tables of files where resources are
	keyboardShortcutManager = false;
	dragDropManager = false;
	focuses = {};

	interfaceName = false;

	-- TODO: exit codes
	exitCode = {
		OKAY = 1;
	ERROR = 2;
		-- etc
	};
}

--[[
	@static
	@desc Adds the given directory to the resource listing and loads any classes
	@param [string] path -- the path to the directory of resources
]]
function Application.load( path )
	-- TODO: path tidying
	path = path:gsub( "/$", "/" )

	table.insert( Application.resourceDirectories, path )
	local loaded = {}
	local loadClass
	function _G.__loadClassNamed( name )
		local function checkDir( _path )
			if fs.exists( _path .. "/" .. name .. ".lua" ) then
				loadClass( _path .. "/" .. name .. ".lua" )
				return true
			end

			local list = fs.list( _path )
			for i, v in ipairs( list ) do
				if fs.isDir( _path .. '/' .. v ) then
					if checkDir( _path .. '/' .. v) then return true end
				end
			end
		end
		checkDir( path .. "/classes" )
	end

	loadClass = function( _path, content )
		local name = fs.getName( _path )
		if not loaded[name] then
			local f, err = loadfile( _path )
			if err then error( err, 0 ) end
			local ok, err = pcall( f )
			if err then error( err, 0 ) end
			loaded[name] = true
			local _class = class.get( name:gsub(".lua", ""))
            if _class then 
                _class:cement()
            else
                local _interface = interface.get( name:gsub(".lua", ""))
                if _interface then
                    _interface:cement()
                else
                    error( "File '" .. name .. "' did not define class or interface '" .. name:gsub(".lua", "") .. "'. Check your syntax/spelling or remove it from the classes folder if it does not define a class.", 0)
                end
            end
		end
	end

	if fs.exists( path .. "/loadfirst.scfg") then
		local f = fs.open( path .. "/loadfirst.scfg", "r" )
		if not f then error( "Failed to read loadfirst.scfg", 2 ) end

		local line
		repeat
			line = h.readLine()
			if line and #line > 0 then
				__loadClassNamed( line )
			end
		until not line
		f.close()
	end

	local function loadDir( _path )
		local list = fs.list( _path )
		for i, v in ipairs( list ) do
			if v ~= ".DS_Store" and v ~= ".metadata" then
				local fpath = _path .. '/' .. v
				if fs.isDir( fpath ) then
					loadDir( fpath )
				else
					loadClass( fpath )
				end
			end
		end
	end

	loadDir( path .. "/classes" )

	_G.__loadClassNamed = nil
end

--[[
	@constructor
	@desc Creates the application runtime for the Silica program. Call :run() on this to start it.
	@param [table] resourceDirectories -- a table of paths in which the applications resources are (classes, themes, etc.)
]]
function Application:initialise()
	log('initialised')
	self.resourceTables = __resourceTables or {}
	_G.__resourceTables = nil
	class.application = self

	self.event = ApplicationEventManager( self )
	self.keyboardShortcutManager = KeyboardShortcutManager( self )
	self.dragDropManager = DragDropManager( self )


	Font.initialisePresets()
	
	self:reloadInterface()

	self.event:connect( TimerEvent, self.onTimer )

end

--[[
	@instance
	@desc Changes the interface name, reloading the interface
	@param [string] interfaceName -- the name of the interface (the file name without extension)
]]
function Application:setInterfaceName( interfaceName )
	if interfaceName and self.interfaceName ~= interfaceName then
		self.interfaceName = interfaceName
		self:reloadInterface()
	end
end

--[[
	@instance
	@desc Loads the application container or changes it if there is one.
]]
function Application:reloadInterface()
	local interfaceName = self.interfaceName

	local oldContainer = self.container
	if oldContainer then
		oldContainer:dispose()
	end

	if interfaceName then		
		self.container = Interface( interfaceName ).container
	else
		self.container = ApplicationContainer()
	end
	self.event:handleEvent( ReadyInterfaceEvent( true ) )
end

function Application:setContainer( container )
	self.container = container
end

--[[
	@instance
	@desc Update all application's views
]]
function Application:update()
	-- TODO: not exactally sure how to handle deltaTime for the first one. for now it's one 60th
	local lastUpdate = self.lastUpdate or 1/60
	local deltaTime = os.clock() - lastUpdate
	self.updateTimer = os.startTimer( 1/20 )
	self.lastUpdate = os.clock()

	self:checkScheduled( lastUpdate )
	local container = self.container
	container:update( deltaTime )
	container:draw()
end

--[[
	@instance
	@desc Returns a table of the views in focus that are of the given type
	@param [class] type -- the type
	@param [table{View}] searchFocuses -- the focuses to look through, i.e. from the focuses changed event (defaults to the current ones)
	@return [table{View}] focuses -- the focuses
]]
function Application:focusesOfType( _type, searchFocuses )
	local focuses = {}
	for view, _ in pairs( searchFocuses or self.focuses ) do
		if view:typeOf( _type ) then
			table.insert( focuses, view )
		end
	end
	return focuses
end

--[[
	@instance
	@desc Returns true if there is at least one focused view
	@return [boolean] hasFocus
]]
function Application:hasFocus()
	return next( self.focuses ) ~= nil
end

--[[
	@instance
	@desc Unfocuses everything else and makes the given view the only focused view
	@param [View] newFocus -- the view that is to be focused upon
	@param [class] filter -- the filter class. any other views that are focused that extend this class will be unfocused, all others will be untouched
]]
function Application:focus( newFocus, filter )
	local focuses = self.focuses
	local oldFocuses = {}
	local hadOtherFocus = false
	for oldFocus, _ in pairs( focuses ) do
		if oldFocus ~= newFocus then
			oldFocuses[oldFocus] = true
			if (not filter or oldFocus:typeOf( filter )) then
				hadOtherFocus = true
				focuses[oldFocus] = nil
				oldFocus.isFocused = false
			end
		end
	end
	if hadOtherFocus or not focuses[newFocus] then
		if not focuses[newFocus] then
			focuses[newFocus] = true
			newFocus.isFocused = true
		end
		self.event:handleEvent( FocusesChangedInterfaceEvent( focuses, oldFocuses ) )
	end
end

--[[
	@instance
	@desc Adds the given view to the list of focused views, unfocusing single focus only views
	@param [view] newFocus -- the view that is to be focused upon
]]
function Application:addFocus( newFocus )
	local focuses = self.focuses
	local oldFocuses = {}
	if not focuses[newFocus] then
		for focusedView, _ in pairs( focuses ) do
			oldFocuses[focusedView] = true
			if focusedView.isSingleFocusOnly then
				focuses[focusedView] = nil
			end
		end
		focuses[newFocus] = true
		newFocus.isFocused = true
		self.event:handleEvent( FocusesChangedInterfaceEvent( focuses, oldFocuses ) )
	end
end

--[[
	@instance
	@desc Removes the given view from the list of focused views
	@param [view] oldFocus -- the view that is to be focused upon
]]
function Application:unfocus( oldFocus )
	local focuses = self.focuses
	if focuses[oldFocus] then
		local oldFocuses = {}
		for k, _ in pairs( focuses ) do
			oldFocuses[k] = true
		end
		focuses[oldFocus] = nil
		oldFocus.isFocused = false
		self.event:handleEvent( FocusesChangedInterfaceEvent( focuses, oldFocuses ) )
	end
end

--[[
	@instance
	@desc Unfocuses the view that is currently focused (i.e. the selected text box)
	@param [class] filter -- the filter class. views that are focused that extend this class will be unfocused, all others will be untouched. if nil all are unfocused
]]
function Application:unfocusAll( filter )
	local focuses = self.focuses
	local oldFocuses = {}
	for oldFocus, _ in pairs( focuses ) do
		if not filter or oldFocus:typeOf( filter ) then
			oldFocuses[oldFocus] = true
			focuses[oldFocus] = nil
			oldFocus.isFocused = false
		end
	end
	self.event:handleEvent( FocusesChangedInterfaceEvent( focuses, oldFocuses ) )
end

--[[
	@instance
	@desc Schedules a function to be called at a specified time in the future
	@param [number] time -- in how many seconds the function should be run
	@param [function] func -- the function to call (self is always passed as first argument)
	@param [class] _class -- the class to call the function on ( optional )
	@param ... -- any values you want. will be passed as the parameters (other than self)
	@return [number] scheduleId -- the ID of the scheduled task
]]
function Application:schedule( func, time, ... )
	time = time or 0.05
	local schedules = self.schedules
	table.insert( schedules, { func, os.clock() + time, ... } )
	return #schedules
end

--[[
	@instance
	@desc Unschedule a scheduled task
	@param [number] scheduleId -- the ID of the scheduled task
	@return [boolean] didUnschedule -- whether the task was unscheduled. this is only false if the task no longer exists or never existed
]]
function Application:unschedule( scheduleId )
	local schedules = self.schedules
	if schedules[scheduleId] then
		schedules[scheduleId] = nil
		return true
	else return false end
end

--[[
	@instance
	@desc Run any scheduled tasks that need to be run
	@param [number] lastUpdate -- the time of the last update
]]
function Application:checkScheduled( lastUpdate )
	local now = os.clock()
	local schedules = self.schedules
	for scheduleId, task in pairs( schedules ) do
		if task[2] <= now then
			local func = task[1]
			table.remove( task, 2 )
			table.remove( task, 1 )
			func( unpack( task ) )
			schedules[scheduleId] = nil
		end
	end
end

--[[
	@instance
	@desc Called when a timer is fired
	@param [TimerEvent] event -- the timer event
	@return [boolean] stopPropagation -- whether following handlers should not recieve this event
]]
function Application:onTimer( event )
	if event.timer and event.timer == self.updateTimer then
		self:update()
		return true
	end
end

--[[
	@instance
	@desc Runs the application runtime with the supplied arguments
	@param ... -- the arguments feed to the program (simply use ... for the arguments)
	@return [number] exitCode -- returns the exit code of the application
]]
function Application:run( ... )
	self.arguments = { ... }
	self.isRunning = true

	self:update()

	while self.isRunning do
		local event = Event.create( coroutine.yield() )
		event.relativeView = self.container
		self.event:handleEvent( event )
	end
end

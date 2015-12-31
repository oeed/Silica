
-- need to fix scheduling ... cancelling them won't work right now
-- each one needs to have its own ID and return that ID

class "Application" {

	name = String;
	path = String.allowsNil;
	userDataPath = String( "userdata" );
	userDataFolder = Folder;
	updateTimer = Number.allowsNil;
	lastUpdate = Number.allowsNil;
	arguments = Table.allowsNil;
	isRunning = Boolean( false );
	container = Container;
	document = Document.allowsNil;
	event = ApplicationEventManager;
	schedules = Table( {} );
	keyboardShortcutManager = KeyboardShortcutManager;
	dragDropManager = DragDropManager;
	focuses = Table( {} );
	settings = Settings.allowsNil;

	interfaceName = String.allowsNil;

	-- TODO: exit codes
	-- exitCode = {
	-- 	OKAY = 1;
	-- ERROR = 2;
	-- 	-- etc
	-- };

    static = {
        resourceFolders = {}; -- the folders in which the applications resources are
        resourceTables = false; -- the tables of files where resources are
    }

}

function Application.static:initialise( ... )
    self.resourceTables = __resourceTables or {}
    _G.__resourceTables = nil
end

--[[
    @desc Adds the given directory to the resource listing and loads any classes
    @param [string] path -- the path to the directory of resources
]]
function Application.static:load( path )
    local folder = Folder( path )
    if folder then
        table.insert( self.resourceFolders, folder )
        local classesFolder = folder:folderFromPath( "classes" )
        if classesFolder then
            table.insert( class.folders, classesFolder )
            local LUA = Metadata.mimes.LUA
            local function loadFolder( folder )
                for i, fileSystemItem in ipairs( folder.items ) do
                    if fileSystemItem.metadata.mime == LUA then
                        class.get( fileSystemItem.name, fileSystemItem.contents )
                    elseif fileSystemItem:typeOf( Folder ) then
                        loadFolder( fileSystemItem )
                    end
                end
            end
            loadFolder( classesFolder )
        end
    end
end

function Application:initialise( ... )
	class.setApplication( self )
	if Quartz then
		Quartz.silicaApplication = self
	end
	local userDataParentFolder
	local userDataPath
	if Quartz then
		userDataPath = Quartz.userDataPath
		self.userDataPath = userDataPath
	else
		userDataPath = self.userDataPath
	end
	self.userDataFolder = Folder( userDataPath ) or Folder.static:make( userDataPath )
	self:initialiseSettings()
	self.event = ApplicationEventManager( self )
	self.keyboardShortcutManager = KeyboardShortcutManager( self )
	self.dragDropManager = DragDropManager( self )

	Font.static:initialisePresets()
	
	self:reloadInterface()

	self.event:connect( TimerEvent, self.onTimer )
end

function Application:initialiseSettings()
end

--[[
	@desc Runs the application runtime with the supplied arguments
	@param ... -- the arguments feed to the program (simply use ... for the arguments)
	@return [number] exitCode -- returns the exit code of the application
]]
function Application:run( ... )
	self.arguments = { ... }
	self.isRunning = true
	try( function()
		self:update()

		while self.isRunning do
			local event = Event.static:create( coroutine.yield() )
			event.relativeView = self.container
			self.event:handleEvent( event )
		end
	end ) {

		catch( FatalException, function( extension )
			print( extension.message )
		end )

	}
end

--[[
	@desc Changes the interface name, reloading the interface
	@param [string] interfaceName -- the name of the interface (the file name without extension)
]]
function Application.interfaceName:set( interfaceName )
	if interfaceName and self.interfaceName ~= interfaceName then
		self.interfaceName = interfaceName
		self:reloadInterface()
	end
end

--[[
	@desc Loads the application container or changes it if there is one.
]]
function Application:reloadInterface()
	local interfaceName = self.interfaceName

	local oldContainer = self.container
	if oldContainer then
		oldContainer:dispose()
	end

	if interfaceName then
		local interface = Interface( interfaceName )
		self.container = interface.container
		interface:ready()
	else
		local container = ApplicationContainer()
		self.container = container
		container:handleEvent( ReadyInterfaceEvent() )
	end
end

--[[
	@desc Update all application's views
]]
function Application:update()
	-- TODO: not exactally sure how to handle deltaTime for the first one. for now it's one 60th
	local lastUpdate = self.lastUpdate or ( os.clock() - 1/60 )
	local deltaTime = os.clock() - lastUpdate
	self.lastUpdate = os.clock()
	if not Quartz then
		self.updateTimer = os.startTimer( 1/20 )
	end

	self:checkScheduled( lastUpdate )
	self.container:update( deltaTime )
end

--[[
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
	@desc Returns true if there is at least one focused view
	@return [boolean] hasFocus
]]
function Application:hasFocus()
	return next( self.focuses ) ~= nil
end

--[[
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
	@desc Called when a timer is fired
	@param [TimerEvent] event -- the timer event
	@return [boolean] stopPropagation -- whether following handlers should not recieve this event
]]
function Application:onTimer( Event event, Event.phases phase )
	if event.timer and event.timer == self.updateTimer then
		self:update()
		return true
	end
end

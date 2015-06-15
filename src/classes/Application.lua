
-- need to fix scheduling ... cancelling them won't work right now
-- each one needs to have its own ID and return that ID

class "Application" {
	name = nil;
	path = nil;
	updateTimer = nil;
	lastUpdate = 0;
	arguments = {};
	isRunning = false;
	container = nil;
	event = nil;
	schedules = {};

	interfaceName = nil;

	-- TODO: exit codes
	exitCode = {
		OKAY = 1;
		ERROR = 2;
		-- etc
	};
}

--[[
	@instance
	@desc Creates the application runtime for the Silica program. Call :run() on this to start it.
]]
function Application:init()
	self.event = ApplicationEventManager( self )
	class.application = self.instance
	
	if self.interfaceName then
		self.container = Interface( self.interfaceName ).container
	else
		self.container = ApplicationContainer()
	end

	self.event:connect( Event.TIMER, self.onTimer )

end

--[[
	@instance
	@desc Update all application's views
]]
function Application:update()
	-- not exactally sure how to handle deltaTime for the first one. for now it's zero
	local lastUpdate = self.lastUpdate or 0
	local deltaTime = os.clock() - lastUpdate
	self.updateTimer = os.startTimer( 0.05 )
	self.lastUpdate = os.clock()

	self:checkScheduled( lastUpdate )

	self.container:update( deltaTime )
	self.container:draw()
	
end

--[[
	@instance
	@desc Schedules a function to be called at a specified time in the future
	@param [number] time -- in how many seconds the function should be run
	@param [function] func -- the function to call
	@param [class] _class -- the class to call the function on (optional)
	@param tag -- any unique value you want to be associated with the tag. will be passed as the only parameter (other than self)
	@return [number] scheduleId -- the ID of the scheduled task
]]
function Application:schedule( func, time, ... )
	time = time or 0.05
	table.insert( self.schedules, { func, os.clock() + time, ... } )
end

--[[
	@instance
	@desc Unschedule a scheduled task
	@param [number] scheduleId -- the ID of the scheduled task
	@return [boolean] didUnschedule -- whether the task was unscheduled. this is only false if the task no longer exists or never existed
]]
function Application:unschedule( scheduleId, arg2, arg3 )
	if self.schedules[scheduleId] then
		self.schedules[scheduleId] = nil
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
	for scheduleId, task in ipairs( self.schedules ) do
		if task[2] <= now then
			local func = task[1]
			table.remove( task, 2 )
			table.remove( task, 1 )
			func( unpack(task) )
			self.schedules[scheduleId] = nil
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
		local args = { coroutine.yield() }
		local event = Event.create( args )
		event.relativeView = self.container
		self.event:handleEvent( event )
	end
end

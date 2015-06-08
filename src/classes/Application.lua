class "Application" {
	name = nil;
	path = nil;
	timers = {};
	arguments = {};
	isRunning = false;
	container = nil;
	event = nil;

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
	self.container = ApplicationContainer( { x = 1; y = 1; width = 52; height = 19 } ) -- we'll make this auto-stretch later
	class.application = self
end

--[[
	@instance
	@desc Draws the all application's views
]]
function Application:draw()
	self.container:draw()
	self.container:render( term )
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

	while self.isRunning do
		local args = { coroutine.yield() }
		local event = Event.create( args )
		self.event:handleEvent( event )
	end
end
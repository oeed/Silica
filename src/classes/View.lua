
local DEFAULT_TIME = .3
local DEFAULT_EASING = "inOutSine"

local function newAnimation( self, label, time, values, easing, onFinish )
	local animation = Animation.new( time, self, values, easing )
	for i = #self.animations, 1, -1 do
		if self.animations[i].label == label then
			table.remove( self.animations, i )
		end
	end
	self.animations[#self.animations + 1] = { label = label, animation = animation, onFinish = onFinish }
end

class "View" {
	
}

function View:init()
	self.animations = { names = {} }
end

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

function View:animateX( x, time, onFinish, easing )
	newAnimation( self, "x", time or DEFAULT_TIME, { x = x }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

function View:animateY( y, time, onFinish, easing )
	newAnimation( self, "y", time or DEFAULT_TIME, { y = y }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

function View:animateWidth( width, time, onFinish, easing )
	newAnimation( self, "width", time or DEFAULT_TIME, { width = width }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

function View:animateHeight( height, time, onFinish, easing )
	newAnimation( self, "height", time or DEFAULT_TIME, { height = height }, easing or DEFAULT_EASING, type( onFinish ) == "function" and onFinish )
end

function View:move( x, y, time, onFinish, easing )
	local d = false
	local function f()
		if not d then d = true return onFinish() end -- stops the function being called twice
	end
	self:animateX( x, time, type( onFinish ) == "function" and f, easing )
	self:animateY( y, time, type( onFinish ) == "function" and f, easing )
end

function View:resize( width, height, time, onFinish, easing )
	local d = false
	local function f()
		if not d then d = true return onFinish() end -- stops the function being called twice
	end
	self:animateWidth( width, time, type( onFinish ) == "function" and f, easing )
	self:animateHeight( height, time, type( onFinish ) == "function" and f, easing )
end

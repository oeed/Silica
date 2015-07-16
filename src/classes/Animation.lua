
local math, assert, tostring, type = math, assert, tostring, type
local pow, sin, cos, pi, sqrt, abs, asin = math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin

local function copyTables(destination, keysTable, valuesTable)
    valuesTable = valuesTable or keysTable
    local mt = getmetatable( keysTable )
    if mt and getmetatable( destination ) == nil then
        setmetatable(destination, mt)
    end
    for k,v in pairs( keysTable ) do
        if type( v ) == "table" then
            destination[k] = copyTables({}, v, valuesTable[k])
        else
            destination[k] = valuesTable[k]
        end
    end
    return destination
end

local function performEasingOnSubject(subject, targetValues, initialValues, time, duration, easingFunc, round)
    local t,b,c,d
    for k,v in pairs( targetValues ) do
        if type( v ) == "table" then
            performEasingOnSubject(subject[k], v, initialValues[k], time, duration, easingFunc)
        else
            t,b,c,d = time, initialValues[k], v - initialValues[k], duration
            if round then
                subject[k] = math.floor( easingFunc( t,b,c,d ) + 0.5 )
            else
                subject[k] = easingFunc( t,b,c,d )
            end
        end
    end
end

class "Animation" {
	easing = {};
	duration = nil;
	subject = nil;
	targetValues = nil;
	easingFunc = nil;
	initialValues = nil;
	time = nil;
}

--[[
    @constructor
    @desc Creates an animation instance for internal use
    @param [number] duration -- the duration of the animation
    @param [class] subject -- the subject of the animation
    @param [class] targetValues -- the targetValues of the animation
    @param [Animation.easing] easingFunc -- the easing function of the animation
]]
function Animation:initialise( duration, subject, targetValues, easingFunc, round )
    self.duration = duration
    self.subject = subject
    self.targetValues = targetValues
    self.easingFunc = easingFunc
    self.round = round
    self.initialValues = copyTables( {}, targetValues, subject )
    self.time = 0
end

--[[
	@instance
	@desc Sets the animation to the specificed time point
	@param [number] time -- the time point
	@return [boolean] isComplete -- whether the animation is complete
]]
function Animation:setTime( time )
	assert( type(time ) == "number", "time must be a positive number or 0")

	self.time = time

	if self.time <= 0 then
		self.time = 0
		copyTables(self.subject, self.initialValues)
	elseif self.time >= self.duration then -- the tween has expired
		self.time = self.duration
		copyTables(self.subject, self.targetValues)
	else
		performEasingOnSubject(self.subject, self.targetValues, self.initialValues, self.time, self.duration, self.easingFunc, self.round)
	end

	return self.time >= self.duration
end

--[[
	@instance
	@desc Resets the animation back to the start
	@return [boolean] isComplete -- whether the animation is complete
]]
function Animation:reset()
	return self:setTime( 0 )
end

--[[
	@instance
	@desc Updates the animation given a change in time, returning true if the animation is complete
	@param [number] deltaTime -- the change in time since the last update
	@return [boolean] isComplete -- whether the animation is complete
]]
function Animation:update( deltaTime )
	return self:setTime( self.time + deltaTime )
end
	

-- easing functions --

-- linear
function Animation.easing.LINEAR( t, b, c, d )
	return c * t / d + b
end

-- quad
function Animation.easing.IN_QUAD( t, b, c, d )
	return c * pow(t / d, 2) + b
end

function Animation.easing.OUT_QUAD( t, b, c, d )
	t = t / d
	return -c * t * (t - 2) + b
end

function Animation.easing.IN_OUT_QUAD( t, b, c, d )
	t = t / d * 2
	if t < 1 then return c / 2 * pow(t, 2) + b end
	return -c / 2 * ((t - 1) * (t - 3) - 1) + b
end

function Animation.easing.OUT_IN_QUAD( t, b, c, d )
	if t < d / 2 then return outQuad(t * 2, b, c / 2, d) end
	return inQuad((t * 2) - d, b + c / 2, c / 2, d)
end

-- cubic
function Animation.easing.IN_CUBIC ( t, b, c, d )
	return c * pow(t / d, 3) + b
end

function Animation.easing.OUT_CUBIC( t, b, c, d )
	return c * (pow(t / d - 1, 3) + 1) + b
end

function Animation.easing.IN_OUT_CUBIC( t, b, c, d )
	t = t / d * 2
	if t < 1 then return c / 2 * t * t * t + b end
	t = t - 2
	return c / 2 * (t * t * t + 2) + b
end

function Animation.easing.OUT_IN_CUBIC( t, b, c, d )
	if t < d / 2 then return outCubic(t * 2, b, c / 2, d) end
	return inCubic((t * 2) - d, b + c / 2, c / 2, d)
end

-- quart
function Animation.easing.IN_QUART( t, b, c, d )
	return c * pow(t / d, 4) + b
end

function Animation.easing.OUT_QUART( t, b, c, d )
	return -c * (pow(t / d - 1, 4) - 1) + b
end

function Animation.easing.IN_OUT_QUART( t, b, c, d )
	t = t / d * 2
	if t < 1 then return c / 2 * pow(t, 4) + b end
	return -c / 2 * (pow(t - 2, 4) - 2) + b
end

function Animation.easing.OUT_IN_QUART( t, b, c, d )
	if t < d / 2 then return outQuart(t * 2, b, c / 2, d) end
	return inQuart((t * 2) - d, b + c / 2, c / 2, d)
end

-- quint
function Animation.easing.IN_QUINT( t, b, c, d )
	return c * pow(t / d, 5) + b
end

function Animation.easing.OUT_QUINT( t, b, c, d )
	return c * (pow(t / d - 1, 5) + 1) + b
end

function Animation.easing.IN_OUT_QUINT( t, b, c, d )
	t = t / d * 2
	if t < 1 then return c / 2 * pow(t, 5) + b end
	return c / 2 * (pow(t - 2, 5) + 2) + b
end

function Animation.easing.OUT_IN_QUINT( t, b, c, d )
	if t < d / 2 then return outQuint(t * 2, b, c / 2, d) end
	return inQuint((t * 2) - d, b + c / 2, c / 2, d)
end

-- sine
function Animation.easing.IN_SINE( t, b, c, d )
	return -c * cos(t / d * (pi / 2)) + c + b
end

function Animation.easing.OUT_SINE( t, b, c, d )
	return c * sin(t / d * (pi / 2)) + b
end

function Animation.easing.IN_OUT_SINE( t, b, c, d )
	return -c / 2 * (cos(pi * t / d) - 1) + b
end

function Animation.easing.OUT_IN_SINE( t, b, c, d )
	if t < d / 2 then return outSine(t * 2, b, c / 2, d) end
	return inSine((t * 2) -d, b + c / 2, c / 2, d)
end

-- expo
function Animation.easing.IN_EXPO( t, b, c, d )
	if t == 0 then return b end
	return c * pow(2, 10 * (t / d - 1)) + b - c * 0.001
end

function Animation.easing.OUT_EXPO( t, b, c, d )
	if t == d then return b + c end
	return c * 1.001 * (-pow(2, -10 * t / d) + 1) + b
end

function Animation.easing.IN_OUT_EXPO( t, b, c, d )
	if t == 0 then return b end
	if t == d then return b + c end
	t = t / d * 2
	if t < 1 then return c / 2 * pow(2, 10 * (t - 1)) + b - c * 0.0005 end
	return c / 2 * 1.0005 * (-pow(2, -10 * (t - 1)) + 2) + b
end

function Animation.easing.OUT_IN_EXPO( t, b, c, d )
	if t < d / 2 then return outExpo(t * 2, b, c / 2, d) end
	return inExpo((t * 2) - d, b + c / 2, c / 2, d)
end

-- circ
function Animation.easing.IN_CIRC( t, b, c, d )
	return(-c * (sqrt(1 - pow(t / d, 2)) - 1) + b)
end

function Animation.easing.OUT_CIRC( t, b, c, d )
	return(c * sqrt(1 - pow(t / d - 1, 2)) + b)
end

function Animation.easing.IN_OUT_CIRC( t, b, c, d )
	t = t / d * 2
	if t < 1 then return -c / 2 * (sqrt(1 - t * t) - 1) + b end
	t = t - 2
	return c / 2 * (sqrt(1 - t * t) + 1) + b
end

function Animation.easing.OUT_IN_CIRC( t, b, c, d )
	if t < d / 2 then return outCirc(t * 2, b, c / 2, d) end
	return inCirc((t * 2) - d, b + c / 2, c / 2, d)
end

-- elastic
function Animation.easing.CALCULATE_P_A_S( p,a,c,d )
	p, a = p or d * 0.3, a or 0
	if a < abs( c ) then return p, c, p / 4 end -- p, a, s
	return p, a, p / (2 * pi) * asin( c/a ) -- p,a,s
end

function Animation.easing.IN_ELASTIC( t, b, c, d, a, p )
	local s
	if t == 0 then return b end
	t = t / d
	if t == 1 then return b + c end
	p,a,s = calculatePAS( p,a,c,d )
	t = t - 1
	return -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b
end

function Animation.easing.OUT_ELASTIC( t, b, c, d, a, p )
	local s
	if t == 0 then return b end
	t = t / d
	if t == 1 then return b + c end
	p,a,s = calculatePAS( p,a,c,d )
	return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p) + c + b
end

function Animation.easing.IN_OUT_ELASTIC( t, b, c, d, a, p )
	local s
	if t == 0 then return b end
	t = t / d * 2
	if t == 2 then return b + c end
	p,a,s = calculatePAS( p,a,c,d )
	t = t - 1
	if t < 0 then return -0.5 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * pi) / p)) + b end
	return a * pow(2, -10 * t) * sin((t * d - s) * (2 * pi) / p ) * 0.5 + c + b
end

function Animation.easing.OUT_IN_ELASTIC( t, b, c, d, a, p )
	if t < d / 2 then return outElastic(t * 2, b, c / 2, d, a, p) end
	return inElastic((t * 2) - d, b + c / 2, c / 2, d, a, p)
end

-- back
function Animation.easing.IN_BACK( t, b, c, d, s )
	s = s or 1.70158
	t = t / d
	return c * t * t * ((s + 1) * t - s) + b
end

function Animation.easing.OUT_BACK( t, b, c, d, s )
	s = s or 1.70158
	t = t / d - 1
	return c * (t * t * ((s + 1) * t + s) + 1) + b
end

function Animation.easing.IN_OUT_BACK( t, b, c, d, s )
	s = (s or 1.70158) * 1.525
	t = t / d * 2
	if t < 1 then return c / 2 * (t * t * ((s + 1) * t - s)) + b end
	t = t - 2
	return c / 2 * (t * t * ((s + 1) * t + s) + 2) + b
end

function Animation.easing.OUT_IN_BACK( t, b, c, d, s )
	if t < d / 2 then return outBack(t * 2, b, c / 2, d, s) end
	return inBack((t * 2) - d, b + c / 2, c / 2, d, s)
end

-- bounce
function Animation.easing.OUT_BOUNCE( t, b, c, d )
	t = t / d
	if t < 1 / 2.75 then return c * (7.5625 * t * t) + b end
	if t < 2 / 2.75 then
		t = t - (1.5 / 2.75)
		return c * (7.5625 * t * t + 0.75) + b
	elseif t < 2.5 / 2.75 then
		t = t - (2.25 / 2.75)
		return c * (7.5625 * t * t + 0.9375) + b
	end
	t = t - (2.625 / 2.75)
	return c * (7.5625 * t * t + 0.984375) + b
end

function Animation.easing.IN_BOUNCE( t, b, c, d )
	return c - outBounce(d - t, 0, c, d) + b
end

function Animation.easing.IN_OUT_BOUNCE( t, b, c, d )
	if t < d / 2 then return inBounce(t * 2, 0, c, d) * 0.5 + b end
	return outBounce(t * 2 - d, 0, c, d) * 0.5 + c * .5 + b
end

function Animation.easing.OUT_IN_BOUNCE( t, b, c, d )
	if t < d / 2 then return outBounce(t * 2, b, c / 2, d) end
	return inBounce((t * 2) - d, b + c / 2, c / 2, d)
end

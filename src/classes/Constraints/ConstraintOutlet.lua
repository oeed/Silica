
class "ConstraintOutlet" {
	identifier = false;
	property = false;
	owner = false;
	constraint = false; -- the constraint this represents
}

--[[
	@constructor
	@desc Creates a constraint outlet
	@param [Constraint] owner -- the constraint that owns this outlet
	@param [string] identifier -- the identifier of the outlet view
	@param [string] property -- the property to follow (i.e. width or left)
]]
function ConstraintOutlet:init( owner, identifier, property )
	if not owner then error( "Constraint with identifier: '" .. identifier .. "' and property: '" .. property .. "' was given a nil owner!") end
	self.owner = owner
	self.identifier = identifier
	if identifier == "self" then
		self.constraint = owner
	else
		-- TODO: make this follow the identifier
		self:connect()
	end
	self.property = property
end

--[[
	@instance
	@desc Connect to the first found constraint with the outlet's specified identifier
	@return [Constraint] constraint -- the connected constraint
]]
function ConstraintOutlet:connect( ignoreCheck )
	if ignoreCheck or not self.constraint then
		local identifier = self.identifier
		local owner = self.owner
		if owner.parent then
			local view = owner.parent:findChild( identifier )
			if not view then
				error( "Contraint for: '" .. owner .. "' failed to find view with identifier: '" .. identifier .. "'")
			end

			local constraint = view.constraint
			self.constraint = constraint
			return constraint
		end
	end
end

--[[
	@instance
	@desc Connect to the first found constraint with the outlet's specified identifier
]]
function ConstraintOutlet:disconnect()
	self.constraint = false
end

function ConstraintOutlet:setConstraint( constraint )
	local oldConstraint = self.raw.constraint
	local owner = self.owner
	if oldConstraint then
		oldConstraint:onUntrack( owner )
		owner:onConnect( oldConstraint )
	end

	self.constraint = constraint
	if constraint then
		constraint:onTrack( owner )
		owner:onConnect( constraint )
	end
end

function ConstraintOutlet:getConstraint()
	local constraint = self.constraint
	if not constraint and self.hasInit then
		return self:connect( true )
	else
		return constraint
	end
end
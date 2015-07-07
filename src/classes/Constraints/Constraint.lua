
class "Constraint" {
	owner = false;

	left = false;
	right = false;
	top = false;
	bottom = false;
	width = false;
	height = false;

	parsed = {};
	tracking = {}; -- the constraints this constraint is tracking
	trackedBy = {}; -- the constraints that this constraint is tracked by

	needsConstraintUpdate = false;
}

--[[
	@instance
	@desc Creates a constraint
	@param [view] owner -- the constraints owner view
	@param [table] constraints -- a table of the constraint strings (e.g. { left = "50%", top = "50%" })
]]
function Constraint:init( owner, constraints )
	if not owner then error( "All Constraints require an owner!" ) end
	self.owner = owner

	if constraints then
		for k, v in pairs( constraints ) do
			if type( v ) == "string" and ( k == "left" or k == "right" or k == "top" or k == "bottom" or k == "left" or k == "right" ) then
				self[k] = v
			end
		end
	end

	local event = EventManager( self )
	self.event = event
	owner:event( Event.PARENT_CHANGED, self.onOwnerParentChanged, EventManager.phase.BEFORE, event )

	self:update()
end

--[[
	@instance
	@desc Manually set the x, y, width or height values, overriding conflicting values
	@param [string] key -- the key of the value
	@param [number] value -- the new value
]]
function Constraint:manualValue( key, value )
	if key == "x" then
		self.left = value
		self.width = self.owner.width
		self.right = false
	elseif key == "y" then
		self.top = value
		self.height = self.owner.height
		self.bottom = false
	elseif key == "width" then
		self.left = self.owner.x
		self.width = self.owner.width
		self.right = false
	elseif key == "height" then
		self.top = self.owner.y
		self.height = self.owner.height
		self.bottom = false
	end
end

--[[
	@instance
	@desc Called when a constraint outlet stops tracking this constraint
	@param [Constraint] constraint -- the constraint that was tracking it
]]
function Constraint:onUntrack( constraint )
	self.trackedBy[constraint] = self.trackedBy[constraint] - 1
end

--[[
	@instance
	@desc Called when a constraint outlet startings tracking this constraint
	@param [Constraint] constraint -- the constraint that is tracking it
]]
function Constraint:onTrack( constraint )
	self.trackedBy[constraint] = ( self.trackedBy[constraint] or 0 ) + 1
end

--[[
	@instance
	@desc Called when one of it's constraint outlets starts tracking another constraint
	@param [Constraint] constraint -- the constraint being tracked
]]
function Constraint:onConnect( constraint )
	self.tracking[constraint] = ( self.tracking[constraint] or 0 ) - 1
end

--[[
	@instance
	@desc Called when one of it's constraint outlets stops tracking another constraint
	@param [Constraint] constraint -- the constraint that was tracked
]]
function Constraint:onDisconnect( constraint )
	self.tracking[constraint] = self.tracking[constraint] + 1
end

--[[
	@instance
	@desc Called when the one or more of the constraint's values (x, y, width or height) are changed. Notifies all the tracking constraints.
	@param [table] keys -- a table of the keys of the changed values
]]
function Constraint:onValuesChanged( keys )
	for constraint, n in pairs( self.trackedBy ) do
		if n >= 1 then
			constraint:onTrackedValuesChanged( keys )
		end
	end
end

--[[
	@instance
	@desc Called when the one or more of a tracked constraint's values (x, y, width or height) are changed.
	@param [table] keys -- a table of the keys of the changed values
]]
function Constraint:onTrackedValuesChanged( keys )
	-- TODO: calculate what the effected values are rather than update all
	-- self:update()
end

--[[
	@instance
	@desc Updates the location of it's owner based upon the constraints
	@param [string] property -- optional, the property (e.g. width or left) that should be updated. by default all are updated
]]
function Constraint:update( property )
	local owner = self.owner
	local parent = owner.parent
	if parent then
		local parsed = self.parsed
		local parentWidth = owner.parent.width
		local parentHeight = owner.parent.height

		local properties = property and { property } or { "width", "height", "left", "right", "top", "bottom" }
		local values = {}
		for _, _property in ipairs( properties ) do
			local propertyParsed = parsed[_property]
			if propertyParsed then
				local isSize = _property == "width" or _property == "height"
				local isHorizontal = _property == "width" or _property == "right" or _property == "left"
				local isOtherSide = _property == "bottom" or _property == "right"
				local value = isSize and 0 or 1

				for i, section in ipairs( propertyParsed ) do
					local _type = section.type
					local _value = section.value

					-- if it's a size based constraint 1 must be subtracted each time
					if _type == "percentage" then
						value = value + math.floor( ( isHorizontal and parentWidth or parentHeight ) * _value + 0.5 )
					elseif _type == "constant" then
						value = value + _value
					elseif _type == "relative" then
						local constraintOutlet = section.to
						local _constraint, _constraintProperty = constraintOutlet.constraint, constraintOutlet.property
						local toValue
						if _constraint == self then
							toValue = values[_constraintProperty] or self[_constraintProperty]
						else
							toValue = _constraint[_constraintProperty]
						end

						if not toValue then
							error( "Constraint '" .. tostring( _property ) .. "' (" .. self[_property] .. ") for: '" .. tostring( self.owner ) .. "' cannot use the undefined value '" .. tostring( _constraintProperty ) .. "' from: '" .. tostring( _constraint.owner ) .. "'! Please change the constraint or define the value.")
						end
						value = value + toValue * _value
					end
				end

				values[_property] = value--not isOtherSide and value or value - owner[isHorizontal and "width" or "height"]
			end
		end

		-- TODO: checking things like w < 1 and r < l

		local finalValues = { x = nil, y = nil, width = nil, height = nil }
		for _, _property in ipairs( properties ) do
			_value = values[_property]
			if _value then
				local isSize = _property == "width" or _property == "height"
				local isHorizontal = _property == "width" or _property == "left" or _property == "right"
				local isOtherSide = _property == "bottom" or _property == "right"

				local key--isSize and _property or ( isHorizontal and "x" or "y" )
				local finalValue

				if isOtherSide then
					-- this value has the potential to set the size if the non-other side value is set
					local coordinateValue = finalValues[isHorizontal and "x" or "y"]
					if coordinateValue then
						-- there's a pinned value, set the width instead
						key = isHorizontal and "width" or "height"
						finalValue = _value - coordinateValue
					else
						finalValue = _value - ( finalValues[isHorizontal and "width" or "height"] or owner[isHorizontal and "width" or "height"] )
					end
				else
					finalValue = _value
				end
				key = key or ( isSize and _property or ( isHorizontal and "x" or "y" ) )

				local currentFinalValue = finalValues[key]
				if currentFinalValue and currentFinalValue ~= finalValue then
					error( "Conflicting constraints for: " .. tostring( owner ) .. "! Left: " .. tostring( self.left ) .. " Right: " .. tostring( self.right )  .. " Width: " .. tostring( self.width )  .. " Top: " .. tostring( self.top )  .. " Bottom: " .. tostring( self.bottom )  .. " Height: " .. tostring( self.height ) )
				end
				finalValues[key] = finalValue
			end
		end

		local changed = {}
		for k, v in pairs( finalValues ) do
			if v and owner[k] ~= v then
				table.insert( changed, k )
				-- this could've been done using substrings, but it's quicker not to
				if k == "x" then
					owner:setX( v, true )
				elseif k == "y" then
					owner:setY( v, true )
				elseif k == "width" then
					owner:setWidth( v, true )
				elseif k == "height" then
					owner:setHeight( v, true )
				end
			end
		end
		self:onValuesChanged( changed )
	end
		
	-- local parsed = self.rightParsed
	-- local value = 1
	-- if parent then
	-- 	for i, section in ipairs( parsed ) do
	-- 		local _type = section.type
	-- 		local _value = section.value

	-- 		-- if it's a size based constraint 1 must be subtracted each time
	-- 		if _type == "percentage" then
	-- 			value = value + math.floor( parentWidth * _value + 0.5 )
	-- 		elseif _type == "constant" then
	-- 			value = value + _value
	-- 		elseif _type == "relative" then
	-- 			local toValue = section.to
	-- 			value = value + toValue * _value
	-- 		end
	-- 	end
	-- 	-- owner.width = value
	-- 	owner.x = value - owner.width
	-- end
end

function Constraint:onOwnerParentChanged( event )
	self:update()
end

-- "100% - self.width"
-- "50% - self.width / 2"
-- "buttonTwo.right + 2"

--[[
	@instance
	@desc Sets the constraint for the right side
	@param [string] right -- the right constraint string
]]
function Constraint:setRight( right )
	self.right = right

	-- self.parsed.left = {
	-- 	{
	-- 		type = "percentage",
	-- 		value = 0.5
	-- 	},
	-- }
	self.left = "self.width / 2"
	self.parsed.left = {
		{
			type = "percentage",
			value = .5
		},
		-- {
		-- 	type = "constant",
		-- 	value = 0
		-- },
		{
			type = "relative",
			to = ConstraintOutlet( self, "self", "width" ),
			value = -0.5 -- essentially a multiplier
		},
	}

	-- "50% + 3 - self.width / 2 + buttonTwo.width"
	local parsed = {
		{
			type = "percentage",
			value = 0.5
		},
		{
			type = "constant",
			value = 3
		},
		{
			type = "relative",
			to = ConstraintOutlet( "self" ),
			value = -0.5 -- essentially a multiplier
		},
		{
			type = "relative",
			to = ConstraintOutlet( "buttonTwo" ),
			value = 1
		},
	}
end

function Constraint:getWidth()
	return self.width or self.owner.width
end

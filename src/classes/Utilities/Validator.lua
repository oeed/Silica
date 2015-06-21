
-- validates and parses values (so BLUE becomes Graphics.colours.BLUE)
class "Validator" {}

--[[
	@instance
	@desc Gets a validation table from the given type name
	@param [string] typeName -- the type to validate against
	@return [Validator.validatorType] validatorType -- the table of valid values
]]
function Validator.validatorType( typeName )
	-- TODO: make validator types dynamic
	if typeName == 'Graphics.colours' then
		return function(k) return Graphics.colours[k] end
	elseif typeName == 'number' then
		return tonumber
	elseif typeName == 'string' then
		return tostring
	end
end

--[[
	@instance
	@desc Validate a value against the given type
	@param value -- the value to validate
	@param [string] typeName -- the type to validate against
	@return [boolean] isValid -- whether the value is valid
]]
function Validator.isValid( value, typeName )
	local validatorType = Validator.validatorType( typeName )
	return validatorType(value) ~= nil
end

--[[
	@instance
	@desc Parse a value to the given type
	@param value -- the value to parse
	@param [string] typeName -- the type to parse to
	@return parsedValue -- the parsed value
]]
function Validator.parse( value, typeName )
	local validatorType = Validator.validatorType( typeName )
	return validatorType(value)
end

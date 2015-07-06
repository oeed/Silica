
class "Theme" {
	name = nil;
	classes = {};
	active = nil; -- @static  the current theme
}

--[[
	@constructor
	@desc Loads a theme from name
	@param [string] themeName -- the name of the theme
]]
function Theme:init( themeName )
	self.name = themeName

	-- TODO: dynamic path resolving for interfaces and other files
	local path = "/src/interface/" .. themeName .. ".stheme"
	if fs.exists( path ) then
		local nodes, err = XML.fromFile( path )
		if not nodes then
			error( path .. err, 0 )
		end
		local err = self:initTheme( nodes[1] )
		if err then
			error( "Theme XML invaid: " .. self.name .. ".stheme. Error: " .. err, 0 )
		end
	else
		error( "Theme file not found: " .. themeName .. ".stheme", 0 )
	end
end

--[[
	@instance
	@desc Creates the container from the interface file
]]
function Theme:initTheme( nodes )
	if not nodes then
		return "Format invalid."
	elseif nodes.type ~= "Theme" then
		return "Root element must be 'Theme', got '" .. tostring( nodes.type ) .. "'."
	end

	local classes = {}
	for i, classNode in ipairs( nodes.body ) do
		local classTheme = {}
		for i2, propertyNode in ipairs( classNode.body ) do
			local propertyTheme = {}
			local validationTypeName = propertyNode.attributes.type
			for styleName, styleValue in pairs( propertyNode.attributes ) do
				if styleName ~= "type" then
					if Validator.isValid( styleValue, validationTypeName ) then
						propertyTheme[styleName] = Validator.parse( styleValue, validationTypeName )
					else
						return "Style value is invalid: '" .. styleName .. "' (of property: " .. propertyNode.name .. " and of class: " .. classNode.name .. ")" 
					end
				end
			end
			classTheme[propertyNode.type] = propertyTheme
		end
		classes[classNode.type] = classTheme
	end
	self.classes = classes
end

--[[
	@instance
	@desc Gets a value from the theme with the given style for the given class
	@param [string] _class -- the name of the class to get the value for
	@param [string] propertyName -- the name of the property
	@param [string] styleName -- default is "default", the style of the value (e.g. disabled, pressed, etc.)
	@param [boolean] noError -- whether the function should return false instead of erroring
	@return themeValue -- the theme value
]]
function Theme:value( _class, propertyName, styleName, noError )
	if styleName == "type" then
		error( "Reserverd style name: " .. styleName )
	end
	styleName = styleName or "default"
	local className = _class.className

	local err
	local classTheme = self.classes[className]
	if classTheme then
		local propertyTheme = classTheme[propertyName]
		if propertyTheme then
			local styleValue = propertyTheme[styleName] or propertyTheme["default"]
			if styleValue then
				return styleValue
			else
				err = "Theme '" .. self.name .. "' does not have any definition for style: '" .. styleName .. "' or 'default' (of property: " .. propertyName .. " and of class: " .. _class.className .. ")"
			end
		else
			err = "Theme '" .. self.name .. "' does not have any definitions for property: '" .. propertyName .. " '(of class: " .. className .. ")"
		end
	else
		err = "Theme '" .. self.name .. "' does not have any definitions for class: '" .. className .. "'"
	end

	-- an error occured, try to see if the value was defined for a super class
	if _class._extends then
		local themeValue = self:value( _class._extends, propertyName, styleName, true )
		if themeValue then
			return themeValue
		end
	end

	-- there was no value defined for a super class
	if noError then
		return false
	else
		error( "Theme '" .. self.name .. "' does not have any definition for style: '" .. styleName .. "' or 'default' (of property: " .. propertyName .. " and of class: " .. _class.className .. ")" )
	end
end

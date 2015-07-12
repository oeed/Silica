
class "Theme" {
	name = false;
	extends = false; -- the name of the theme this one extends
	classes = {};
	active = false; -- @static  the current theme
	themes = { 1 }; -- @static  a cache of already created themes
}

--[[
	@constructor
	@desc Loads a theme from name
	@param [string] themeName -- the name of the theme
	@table [table] cantExtend -- a table of the theme names that the theme can't extend (as they are currently extending, which would cause recussursion)
]]
function Theme:init( themeName, cantExtend )
	cantExtend = cantExtend or {}
	if cantExtend[themeName] then
		error( "Unabled to extend with theme: " .. themeName .. ". It is already extended higher up, which would cause recussursion.", 0 )
	end
	
	self.name = themeName

	-- TODO: dynamic path resolving for interfaces and other files
	local resource = Resource( "themes/" .. themeName, "stheme" )
	local path = resource.path
	if path then
		local nodes, err = XML.fromFile( path )
		if not nodes then
			error( path .. err, 0 )
		end
		cantExtend[themeName] = true
		local err = self:initTheme( nodes[1], cantExtend )
		if err then
			error( "Theme XML invaid: " .. self.name .. ".stheme. Error: " .. err, 0 )
		end
	else
		error( "Theme file not found: " .. themeName .. ".stheme", 0 )
	end

	Theme.themes[themeName] = self
end

--[[
	@static
	@desc Returns the theme with the given name. This retireves the theme from a cache if it's already been defined and should be used instead of just Theme()
	@param [string] themeName -- the name of the theme
	@table [table] cantExtend -- a table of the theme names that the theme can't extend (as they are currently extending, which would cause recussursion)
	@return [Theme] theme -- the theme with the given name
]]
function Theme.named( themeName, cantExtend )
	return Theme.themes[themeName] or Theme( themeName, cantExtend )
end

--[[
	@instance
	@desc Creates the container from the interface file
	@param [table] nodes -- the nodes from the XML file
	@table [table] cantExtend -- a table of the theme names that the theme can't extend (as they are currently extending, which would cause recussursion)
]]
function Theme:initTheme( nodes, cantExtend )
	if not nodes then
		return "Format invalid."
	elseif nodes.type ~= "Theme" then
		return "Root element must be 'Theme', got '" .. tostring( nodes.type ) .. "'."
	end

	local extends = nodes.attributes.extends

	local classes = {}
	if extends then
		local extendingTheme = Theme.named( extends, cantExtend )
		if not extendingTheme then return "Tried to extend a non-existant theme: " .. extends
		elseif extendingTheme == self.name then return "Tried to extend self" end
		local extendsClasses = extendingTheme.classes

		for className, classNode in pairs( extendsClasses ) do
			local classTheme = {}
			for propertyName, propertyNode in pairs( classNode ) do
				local propertyTheme = {}
				for styleName, styleValue in pairs( propertyNode ) do
					propertyTheme[styleName] = styleValue
				end
				classTheme[propertyName] = propertyTheme
			end
			classes[className] = classTheme
		end
		self.extends = extends
	end

	for i, classNode in ipairs( nodes.body ) do
		local classTheme = classes[classNode.type] or {}
		for i2, propertyNode in ipairs( classNode.body ) do
			local propertyTheme = classTheme[propertyNode.type] or {}
			local validationTypeName = propertyNode.attributes.type
			for styleName, styleValue in pairs( propertyNode.attributes ) do
				if styleName ~= "type" then
					if Validator.isValid( styleValue, validationTypeName ) then
						propertyTheme[styleName] = Validator.parse( styleValue, validationTypeName )
					else
						return "Style value '" .. tostring( styleValue ) .. "' is invalid: '" .. styleName .. "' (of property: " .. propertyNode.name .. " and of class: " .. classNode.name .. ")" 
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
		error( "Reserverd style name: " .. styleName, 0 )
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
		error( err, 0 )
	end
end

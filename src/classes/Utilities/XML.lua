local function fromXmlString( value )
  	value = string.gsub(value, "&#x([%x]+)%;",
      	function(h) 
      		return string.char(tonumber(h,16)) 
      	end);
  	value = string.gsub(value, "&#([0-9]+)%;",
      	function(h) 
      		return string.char(tonumber(h,10)) 
      	end);
	value = string.gsub (value, "&quot;", "\"");
	value = string.gsub (value, "&apos;", "'");
	value = string.gsub (value, "&gt;", ">");
	value = string.gsub (value, "&lt;", "<");
	value = string.gsub (value, "&amp;", "&");
	return value;
end
   
local function parseArgs( s )
  local arg = {}
  string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
    	arg[w] = fromXmlString(a);
  	end)
  return arg
end

class "XML" {}


--[[
	@static
	@desc Loads XML from source text
	@param [string] xmlText -- the XML text to parse
	@return [table] xmlNodes -- the parsed XML nodes
]]
function XML.fromText( xmlText )
	local stack = {}
	local top = {name=nil,value=nil,attributes={},childNodes={}}
	table.insert(stack, top)
	local ni,c,label,xarg, empty
	local i, j = 1, 1
	while true do
		ni,j,c,label,xarg, empty = string.find(xmlText, "<(%/?)([%w:]+)(.-)(%/?)>", i)
		if not ni then break end
		local text = string.sub(xmlText, i, ni-1);
		if not string.find(text, "^%s*$") then
			top.value=(top.value or "")..fromXmlString(text);
		end
		if empty == "/" then  -- empty element tag
			table.insert(top.childNodes, {name=label,value=nil,attributes=parseArgs(xarg),childNodes={}})
		elseif c == "" then   -- start tag
			top = {name=label, value=nil, attributes=parseArgs(xarg), childNodes={}}
			table.insert(stack, top)   -- new level
		else  -- end tag
			local toclose = table.remove(stack)  -- remove top
			top = stack[#stack]
			if #stack < 1 then
				error("XmlParser: nothing to close with "..label)
			end

			if toclose.name ~= label then
				error("XmlParser: trying to close "..toclose.name.." with "..label)
			end
			table.insert(top.childNodes, toclose)
		end
		i = j+1
	end

	local text = string.sub(xmlText, i);
	if not string.find(text, "^%s*$") then
		stack[#stack].value=(stack[#stack].value or "")..fromXmlString(text);
	end

	if #stack > 1 then
		error("XmlParser: unclosed "..stack[stack.n].name)
	end

	-- print(textutils.serialize(stack))

	return stack[1].childNodes[1];
end

--[[
	@static
	@desc Loads an XML file
	@param [string] filePath -- the path to the XML file
	@return [table] xmlNodes -- the parsed XML nodes
]]
function XML.fromFile( filePath )
	local h = fs.open( filePath, "r" )
	if not h then
		error( "Failed to open XML file: " .. filePath )
	end

	local text = h.readAll()
	h.close()
	return XML.fromText( text )
end
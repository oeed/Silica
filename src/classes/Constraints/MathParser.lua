
local symbols = {
	["+"] = true;
	["-"] = true;
	["*"] = true;
	["/"] = true;
	["("] = true;
	[")"] = true;
	[","] = true;
	["^"] = true;
	["%"] = true;
}

local operatorLevels = {
	["+"] = 1;
	["-"] = 1;
	["*"] = 2;
	["/"] = 2;
	["%"] = 2;
	["^"] = 3;
}

local functionParameterCounts = {
	min = 2;
	max = 2;
	sqrt = 1;
	sin = 1;
	cos = 1;
	tan = 1;
	abs = 1;
	random = 2;
	pow = 2;
	exp = 1;
	floor = 1;
	ceil = 1;
	log = 1;
	ran = 0;
	degrees = 1;
	radians = 1;
}

local functions = {
	min = math.min;
	max = math.max;
	sqrt = math.sqrt;
	sin = math.sin;
	cos = math.cos;
	tan = math.tan;
	abs = math.abs;
	random = math.random;
	pow = math.pow;
	exp = math.exp;
	floor = math.floor;
	ceil = math.ceil;
	log = math.log;
	ran = math.random;
	degrees = function( n )
		return n * 180 / math.pi
	end;
	radians = function( n )
		return n / 180 * math.pi
	end;
}

local allowedIndices = { left = true, right = true, top = true, bottom = true, width = true, height = true }

local parse, eval = nil, {}

local function getpos( token )
	return token and "[" .. token.pos .. "]: "
end

local function getClosingBracket( tokens, pos )
	local level = 1
	while pos <= #tokens do
		if tokens[pos].type == "symbol" and tokens[pos].value == "(" then
			level = level + 1
		elseif tokens[pos].type == "symbol" and tokens[pos].value == ")" then
			level = level - 1
			if level == 0 then
				return pos
			end
		end
		pos = pos + 1
	end
end

local function getBracketContents( tokens, start )
	local close = getClosingBracket( tokens, start )
	if close then
		local t = {}
		for i = 1, close - start do
			t[#t + 1] = tokens[start]
			table.remove( tokens, start )
		end
		table.remove( tokens, start )
		return t
	end
end

local function lex( str )
	local tokens = {}
	local pos = 1
	local lpos = 1
	local function push( t, v )
		tokens[#tokens + 1] = {
			type = t;
			value = v;
			pos = lpos;
		}
	end
	while pos <= #str do
		local c = str:sub( pos, pos )
		if str:find( "^%d*%.?%d+", pos ) then
			local num = str:match( "^%d*%.?%d+", pos )
			pos = pos + #num
			local exp = str:match( "^e%-?%d+", pos )
			if exp then
				pos = pos + #exp
			end
			local percentage = false
			if str:sub( pos, pos ) == "%" then
				percentage = true
				pos = pos + 1
			end
			local n = tonumber( num )
			if exp then
				n = n * 10 ^ tonumber( exp )
			end
			if percentage then
				push( "percentage", n / 100 )
			else
				push( "constant", n )
			end
		elseif c:find "%s" then
			pos = pos + #str:match( "^%s+", pos  )
		elseif c == "." then
			push "dot"
			pos = pos + 1
		elseif c:find "[a-zA-Z_]" then
			local word = str:match( "^[_%w]+", pos )
			push( "word", word )
			pos = pos + #word
		elseif symbols[c] then
			push( "symbol", c )
			pos = pos + 1
		else
			error( "shit", 0 ) -- more descriptive error? :P
		end
		lpos = pos
	end
	return tokens
end

local function parseRelativeIndexes( tokens )
	local i = 1
	while i <= #tokens do
		if tokens[i].type == "dot" then
			if not tokens[i-1] or tokens[i-1].type ~= "word" then
				error( getpos( tokens[i] ) .. "expected super before '.', got " .. ( tokens[i-1] and tokens[i-1].type or "nothing" ), 0 )
			end
			if not tokens[i+1] or tokens[i+1].type ~= "word" then
				error( getpos( tokens[i] ) .. "expected super after '.' (trying to index " .. tokens[i-1].value .. "), got " .. ( tokens[i-1] and tokens[i-1].type or "nothing" ), 0 )
			end
			tokens[i-1].type = "relative"
			local index = string.lower( tokens[i+1].value )
			if not allowedIndices[index] then
				error( "Illegal relative index: " .. index .. ". Possible indices are: left, right, top, bottom, width or height.", 0 )
			end
			tokens[i-1].value = {
				parent = tokens[i-1].value;
				index = index;
			}
			table.remove( tokens, i )
			table.remove( tokens, i )
		end
		i = i + 1
	end
end

local function parseFunctionCalls( tokens )
	local i = 1
	while i <= #tokens do
		if tokens[i].type == "word" and tokens[i + 1] and tokens[i + 1].type == "symbol" and tokens[i + 1].value == "(" then
			local content = getBracketContents( tokens, i + 2 )
			if content then
				table.remove( tokens, i + 1 )

				local parameters = {}
				if content[1] then
					parameters[1] = {}
				end

				for p = 1, #content do
					if content[p].type == "symbol" and content[p].value == "," then
						parameters[#parameters + 1] = {}
					else
						parameters[#parameters][#parameters[#parameters] + 1] = content[p]
					end
				end

				for i = 1, #parameters do
					if #parameters[i] == 0 then
						error( getpos( tokens[i] ) .. "function parameter is empty", 0 )
					end
					parse( parameters[i] )
				end

				tokens[i].type = "call"
				tokens[i].value = {
					func = tokens[i].value;
					parameters = parameters;
				}
			else
				error( getpos( tokens[i + 1] ) .. "expected ')' to close '('", 0 )
			end
		end
		i = i + 1
	end
end

local function parseBrackets( tokens )
	local i = 1
	while i <= #tokens do
		if tokens[i].type == "symbol" and tokens[i].value == "(" then
			local contents = getBracketContents( tokens, i + 1 )
			if contents then
				tokens[i] = {
					type = "bracket";
					value = parse( contents );
					pos = tokens[i].pos;
				}
			else
				error( getpos( tokens[i] ) .. "expected ')' to close '('", 0 )
			end
		elseif tokens[i].type == "symbol" and tokens[i].value == ")" then
			error( getpos( tokens[i] ) .. "unexpected ')' with no opening '('", 0 )
		else
			i = i + 1
		end
	end
end

local function parseUnaryMinuses( tokens )
	for i = #tokens, 1, -1 do
		if tokens[i].type == "symbol" and tokens[i].value == "-" and ( not tokens[i-1] or tokens[i-1].type == "symbol" ) then
			local n = tokens[i+1]
			if not n or n.type == "symbol" then
				error( getpos( tokens[i] ) .. "expected constant (number) or percentage after '-'", 0 )
			end
			tokens[i].type = "constant"
			tokens[i].value = -1
			table.insert( tokens, i + 1, {
				type = "symbol";
				value = "*";
				pos = tokens[i].pos;
			} )
		end
	end
end

local function parseMathConstants( tokens )
	for i = 1, #tokens do
		if tokens[i].type == "word" and tokens[i].value:lower() == "pi" then
			tokens[i].type = "constant"
			tokens[i].value = math.pi
		elseif tokens[i].type == "word" and tokens[i].value:lower() == "phi" then
			tokens[i].type = "constant"
			tokens[i].value = 1.61803398875 -- can support 2 extra numbers on the end, checked in lua prompt, need to get more precise version
		end
	end
end

function parse( tokens )
	if #tokens == 0 then
		error( "no values in tokens", 0 )
	end
	parseFunctionCalls( tokens )
	parseBrackets( tokens )
	parseUnaryMinuses( tokens )
	for i = 1, #tokens do
		if i % 2 == 1 and tokens[i].type == "symbol" then
			error( getpos( tokens[i] ) .. "unexpected symbol, expected operand", 0 )
		elseif i % 2 == 0 and tokens[i].type ~= "symbol" then
			error( getpos( tokens[i] ) .. "expected symbol between operands", 0 )
		end
		if tokens[i].type == "symbol" and tokens[i].value == "," then
			error( getpos( tokens[i] ) .. "unexpected ','", 0 )
		end
	end
	if #tokens % 2 == 0 then
		error( getpos( tokens[#tokens] ) .. "expected operand", 0 )
	end
	return tokens
end

local function checkFunctionCalls( tokens )
	for i = 1, #tokens do
		if tokens[i].type == "call" then
			local f = tokens[i].value.func
			local count = functionParameterCounts[f]
			if not count then
				error( getpos( tokens[i] ) .. "no such function '" .. f .. "'", 0 )
			end
			local p = tokens[i].value.parameters
			if #p ~= count then
				error( getpos( tokens[i] ) .. "expected " .. count .. " parameters, got " .. #p, 0 )
			end
			for i = 1, count do
				checkFunctionCalls( p[i] )
			end
			tokens[i].value.func = functions[f]
		elseif tokens[i].type == "bracket" then
			checkFunctionCalls( tokens[i].value )
		end
	end
	return tokens
end

local function isKnownValue( t )
	if type( t ) == "number" then return true end
	if t.type == "bracket" then
		for i = 1, #t.value do
			if type( t.value[i] ) ~= "string" and not isKnownValue( t.value[i] ) then
				return false
			end
		end
		return true
	elseif t.type == "call" then
		for p = 1, #t.value.parameters do
			for i = 1, #t.value.parameters[p] do
				if type( t.value.parameters[p][i] ) ~= "string" and not isKnownValue( t.value.parameters[p][i] ) then
					return false
				end
			end
		end
		return true
	end
	return t.type == "constant"
end

local function groupByLevel( terms, operators, level )
	local i = 1
	while i <= #operators do
		local t = { terms[i] }
		while operatorLevels[operators[i]] == level do
			t[#t + 1] = operators[i]
			table.remove( operators, i )
			t[#t + 1] = terms[i + 1]
			table.remove( terms, i + 1 )
		end
		if #t > 1 then
			terms[i] = {
				type = "bracket";
				pos = terms[i].pos;
				value = t;
			}
		end
		i = i + 1
	end
end

local function group( tokens )
	local levels = {}
	for i = 1, #tokens do
		tokens[i].pos = nil
		if tokens[i].type == "symbol" then
			levels[operatorLevels[tokens[i].value]] = true
		elseif tokens[i].type == "bracket" then
			tokens[i].value = group( tokens[i].value )
		elseif tokens[i].type == "call" then
			local p = tokens[i].value.parameters
			for i = 1, #p do
				p[i] = group( p[i] )
			end
		end
	end
	local terms = {}
	local operators = {}
	for i = 1, #tokens do
		local t = i % 2 == 1 and terms or operators
		t[#t + 1] = i % 2 == 0 and tokens[i].value or tokens[i]
	end

	if next( levels, next( levels ) ) then
		groupByLevel( terms, operators, 3 )
		groupByLevel( terms, operators, 2 )
	end

	local tokens = { terms[1] }
	for i = 1, #operators do
		tokens[#tokens + 1] = operators[i]
		tokens[#tokens + 1] = terms[i + 1]
	end

	return tokens
end

function eval.knownList( list )
	local n = eval.knownValue( list[1] )
	for i = 1, ( #list - 1 ) / 2 do
		local n2 = eval.knownValue( list[i * 2 + 1] )
		local op = list[i * 2]
		if op == "+" then
			n = n + n2
		elseif op == "-" then
			n = n - n2
		elseif op == "*" then
			n = n * n2
		elseif op == "/" then
			n = n / n2
		elseif op == "%" then
			n = n % n2
		elseif op == "^" then
			n = n ^ n2
		end
	end
	return n
end

function eval.knownValue( token )
	if type( token ) == "number" then
		return math.floor( token + .5 )
	elseif token.type == "bracket" then
		return math.floor( eval.knownList( token.value ) + .5 )
	elseif token.type == "call" then
		local p = token.value.parameters
		for i = 1, #p do
			p[i] = eval.knownList( p[i] )
		end
		return math.floor( token.value.func( unpack( p ) ) + .5 )
	elseif token.type == "constant" then
		return math.floor( token.value + .5 )
	else
		error( "Unknown value for token type: " .. tostring( token.type ), 0 )
	end
end

class "MathParser" {} -- I think it's best just to make it a class so it's loaded properly (when we make the loader). Happy to change it though.

function MathParser.parseString( str )
	local tokens = lex( str )
	parseRelativeIndexes( tokens )
	parseMathConstants( tokens )
	return group( checkFunctionCalls( parse( tokens ) ) )
end

function MathParser.simplify( tokens )
	for i = 1, #tokens do
		if type( tokens[i] ) ~= "string" then
			if isKnownValue( tokens[i] ) then
				tokens[i] = eval.knownValue( tokens[i] )
			elseif tokens[i].type == "bracket" then
				tokens[i].value = MathParser.simplify( tokens[i].value )
			elseif tokens[i].type == "call" then
				local p = tokens[i].value.parameters
				for i = 1, #p do
					p[i] = MathParser.simplify( p[i] )
				end
			end
		end
	end
	for i = 1, #tokens do
		if type( tokens[i] ) == "table" and tokens[i].type == "constant" then
			tokens[i] = tokens[i].value
		end
	end
	for i = 1, #tokens do
		if i % 2 == 1 and not isKnownValue( tokens[i] ) then
			return tokens
		end
	end
	return { eval.knownList( tokens ) }
end

-- solve percentages
-- plug in relative indexes
function MathParser.resolve( tokens, object, property, references )
	references = references or {}
	local parent = object.parent
	local parentSize = parent and ( ( property == "left" or property == "right" or property == "width" ) and parent.width or parent.height ) or 0
	local t = {}
	for i = 1, #tokens do
		if type( tokens[i] ) == "number" or type( tokens[i] ) == "string" then -- these will be raw numbers
			t[#t + 1] = tokens[i]
		elseif tokens[i].type == "constant" then -- these will be raw numbers
			t[#t + 1] = tokens[i].value
		elseif tokens[i].type == "percentage" then -- these will be raw numbers
			t[#t + 1] = tokens[i].value * parentSize
		elseif tokens[i].type == "bracket" then -- this will be a bracket token
			t[#t + 1] = {
				type = "bracket";
				value = MathParser.resolve( tokens[i].value, object, property, references )
			}
		elseif tokens[i].type == "call" then -- this will be a call token
			local parameters = {}
			for i, v in ipairs( tokens[i].value.parameters ) do
				parameters[i] = MathParser.resolve( v, object, property, references )
			end
			t[#t + 1] = {
				type = "call";
				value = {
					func = tokens[i].value.func;
					parameters = parameters;
				}
			}
		elseif tokens[i].type == "relative" then -- this will be a bracket token
			local identifier, index = token.value.parent, token.value.index
			local value = { 0 }

			if identifier == "parent" then
				error( "Constraint can not use 'parent' for a relative value. Use percentages for getting parent width or height (100%)", 0 )
			elseif identifier == "self" and property == index then
				error( "Cannot use recursive constraint index. (tried to use self." .. index .. " within self." .. index .. ")", 0 )
			else
				references[identifier] = true
				local view = identifier == "self" and object or parent:findChild( identifier, false )
				if view then
					value = view:parseConstraint( index ) or value
				else
					error( "Could not find view '" .. identifier .. "'", 0 )
				end
			end
			t[#t + 1] = {
				type = "bracket";
				value = value;
			}
		end
	end
	return t, references
end

function MathParser.eval( list )
	return eval.knownList( list )
end

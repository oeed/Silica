
# Coding style of Silica

#### The case of variables and methods.

Variables should be camel case, starting with a lower case letter.

```lua
Object.variable
Object.variableTwo
```

All names of self functions, values and APIs must use British spelling. (i.e. colour not color, centre not center)

Methods should follow the same pattern, and use colon syntax.

```lua
Object:method()
Object:methodTwo()
```

Enums should be capitalised and words should be separated using underscores.

```lua
Enum.VARIABLE
Enum.VARIABLE_TWO'
```

Classes should be camel case and start with a capital letter.

```lua
class "Class"
class "ClassTwo"
```

### Function call/definition syntax

All function calls and definitions must have spaces on either side of the arguments.
```lua
function Class:hello( name, age )
	print( "Hello, " .. name .. "! You're " .. age .. " years old." )
end
```

Static methods should be defined with dot syntax, and use camel case starting with a lower case letter.

```lua
function Class.static()
function Class.staticFunction()
```

### Doc comments

All public functions (and private if you feel like it or it's not obvious) must have comments above them in the structure below. If no return value or arguments are specificed simply ommit the line.
```lua
--[[
	@instance
	@desc A reasonable description of what the function does
	@param [number] arg1 -- a description of what the variable is
	@param [View] arg2 -- a description of what the variable is
	@param [class] arg3 -- a description of what the variable is
	@return [type] returnedValue -- a description of what the variable is
]]
function Class:functionName( arg1 )
	return returnedValue
end
```

Enum values in doc comments should be specified by the name of the table that holds it. Using ... should simply be writte as such.
```lua
--[[
	@param [Animation.easing] easing -- the easing function of the animation
	@param ... -- the arguments
]]
```

### File structure

In source files, locals should be defined at the top, followed by classes, then the class' methods. Class methods should be defined using colon syntax. For example,

```lua
local function printInfo( ... )
	print( "Info: ", ... )
end

class "MyClass" {
	name = "Object";
}

function MyClass:printInfo()
	printInfo( self.name )
end
```

### Miscellaneous things

`"` should be used to define strings, not `'`

A blank line should be left at the top and bottom of files, just to make it look a bit 'prettier'.

English spelling should be used (not American-English), so "colour" instead of "color", "grey" instead of "gray".

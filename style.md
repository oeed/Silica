
# Coding style of Silica

#### The case of variables and methods.

Variables should be camel case, starting with a lower case letter.

```lua
Object.variable
Object.variableTwo
```

Methods should follow the same pattern, and use colon syntax.

```lua
Object:method()
Object:methodTwo()
```

Enums should be capitalised and words should be separated using underscores.

```lua
Enum.VARIABLE
Enum.VARIABLE_TWO
```

Classes should be camel case and start with a capital letter.

```lua
class "Class"
class "ClassTwo"
```

All function calls and definitions must have spaces on either side of the arguments.
```lua
function Class:hello( name, age )
	print( "Hello, " .. name .. "! You're " .. age .. " years old." )
end
```

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

`"` should be used to define strings, not `'`

A blank line should be left at the top and bottom of files, just to make it look a bit 'prettier'.

Static methods should be defined with dot syntax, and use camel case starting with a lower case letter.

```lua
function Class.static()
function Class.staticFunction()
```

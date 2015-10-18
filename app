local files = {themes = {["red.stheme"] = "<Theme extends=\"default\">\
\
\9<Button>\
\9\9<fillColour type=\"Graphics.colours\" pressed=\"RED\" focused=\"RED\"/>\
\9</Button>\
\
\9<MenuButton>\
\9\9<arrowColour type=\"Graphics.colours\" pressed=\"ORANGE\"/>\
\9</MenuButton>\
\9\
\9<MenuItem>\
\9\9<fillColour type=\"Graphics.colours\" pressed=\"RED\"/>\
\9</MenuItem>\
\
\9<MenuBarItem>\
\9\9<fillColour type=\"Graphics.colours\" pressed=\"RED\" />\
\9</MenuBarItem>\
\
\9<Radio>\
\9\9<fillColour type=\"Graphics.colours\" pressed=\"ORANGE\" checked=\"RED\"/>\
\9\9<outlineColour type=\"Graphics.colours\" pressed=\"RED\"/>\
\9</Radio>\
\
\9<Checkbox>\
\9\9<fillColour type=\"Graphics.colours\" pressed=\"ORANGE\" checked=\"RED\"/>\
\9\9<outlineColour type=\"Graphics.colours\" pressed=\"RED\"/>\
\9</Checkbox>\
\
\9<ProgressBar>\
\9\9<barColour type=\"Graphics.colours\" default=\"RED\"/>\
\9\9<stripeColour type=\"Graphics.colours\" default=\"ORANGE\"/>\
\9\9<barOutlineColour type=\"Graphics.colours\" default=\"RED\"/>\
\9</ProgressBar>\
\
\9<Scrollbar>\
\9\9<fillColour type=\"Graphics.colours\" />\
\9\9<scrollerColour type=\"Graphics.colours\" pressed=\"RED\" />\
\9\9<outlineColour type=\"Graphics.colours\" />\
\9\9<grabberColour type=\"Graphics.colours\" />\
\9\9<cornerRadius type=\"number\" default=\"2\" />\
\9</Scrollbar>\
\
\9<TextBox>\
\9\9<outlineColour type=\"Graphics.colours\" focused=\"RED\" pressed=\"ORANGE\" />\
\9</TextBox>\
\
\9<ApplicationContainer>\
\9\9<fillColour type=\"Graphics.colours\" default=\"YELLOW\"/>\
\9</ApplicationContainer>\
\
</Theme>",["redplus.stheme"] = "<Theme extends=\"red\">\
\9\
\9<Button>\
\9\9<fillColour type=\"Graphics.colours\" default=\"ORANGE\" />\
\9\9<outlineColour type=\"Graphics.colours\" default=\"RED\" />\
\9\9<textColour type=\"Graphics.colours\" default=\"RED\" />\
\9</Button>\
\
\9<ApplicationContainer>\
\9\9<fillColour type=\"Graphics.colours\" default=\"WHITE\"/>\
\9</ApplicationContainer>\
\
</Theme>",},classes = {["ExampleApplication.lua"] = "\
class \"ExampleApplication\" extends \"Application\" {\
\9name = \"Example\";\
\9interfaceName = \"first\";\
}\
\
-- For the demo the below code isn't really needed, it's just for debug\
\
--[[\
\9@constructor\
\9@desc Initialise the custom application\
]]\
function ExampleApplication:initialise()\
\9self.super:initialise()\
\9self:event( Event.CHARACTER, self.onChar )\
end\
\
--[[\
\9@instance\
\9@desc React to a character being fired\
\9@param [Event] event -- description\
\9@return [boolean] stopPropagation\
]]\
function ExampleApplication:onChar( event )\
\9if not self.focus and event.character == '\\\\' then\
\9\9os.reboot()\
\9end\
end",["FileMenu.lua"] = "\
class \"FileMenu\" extends \"Menu\" {\
\9newMenuItem = InterfaceOutlet( \"newMenuItem\" );\
\9alertMenuItem = InterfaceOutlet( \"alertMenuItem\" );\
\9rebootMenuItem = InterfaceOutlet( \"rebootMenuItem\" );\
}\
\
function FileMenu:onAlertMenuItem( event )\
\9-- log( path:gsub( \"[^/]+/%.%.\", \"\" ):gsub( \"/%.\", \"\" ):gsub( \"//+\", \"/\" ) )\
\9-- local alert = AlertWindow()\
\9-- self.application.container:insert( alert )\
\9-- alert:center()\
\9-- alert:focus()\
end\
\
function FileMenu:onRebootMenuItem( event )\
\9os.reboot()\
end",["SecondApplicationContainer.lua"] = "\
class \"SecondApplicationContainer\" extends \"ApplicationContainer\" {\
\9secondButton = InterfaceOutlet( \"secondButton\" )\
}\
\
function SecondApplicationContainer:onSecondButton( event )\
\9self.application.interfaceName = \"first\"\
end",["TestView.lua"] = "\
class \"TestView\" extends \"View\" {\
\9width = nil;\
\9height = nil;\
}\
\
function TestView:initialise( ... )\
\9self.super:initialise( ... )\
end\
\
function TestView:initialiseCanvas( ... )\
\9self.super:initialiseCanvas( ... )\
\9self.canvas.fillColour = Graphics.colours.RED\
end\
\
function TestView:setWidth( width )\
\9self.super:setWidth( width )\
    width = self.width\
end",["FirstApplicationContainer.lua"] = "\
class \"FirstApplicationContainer\" extends \"ApplicationContainer\" {\
\9firstButton = InterfaceOutlet( \"firstButton\" )\
}\
\
function FirstApplicationContainer:initialise( ... )\
\9self.super:initialise( ... )\
\9self:event( Event.INTERFACE_READY, self.onReady)\
end\
\
function FirstApplicationContainer:onReady( event )\
\9-- self.firstButton:focus()\
\
\
\9-- Document.open()\
\
\9-- local document = self.application.document--Document( \"test.txt\" )\
\9-- log(document.contents)\
\9-- document.contents = \"Hello!\"\
\9-- document:save()\
end\
\
function FirstApplicationContainer:onFirstButton( event )\
\9self.application.interfaceName = \"second\"\
end",["PathView.lua"] = "\
class \"PathView\" extends \"View\" {\
\
    height = 100; -- the default height\
    width = 100;\
\
}\
\
--[[\
    @constructor\
    @desc Creates a button object and connects the event handlers\
]]\
function PathView:initialise( ... )\
    self.super:initialise( ... )\
    self:event( Event.MOUSE_DOWN, self.onMouseDown )\
end\
\
function PathView:onMouseDown( event )\
\9log(event.y)\9\
end\
\
\
--[[\
    @instance\
    @desc Sets up the canvas and it's graphics objects\
]]\
function PathView:initialiseCanvas()\
\9self.super:initialiseCanvas()\
\9self.canvas.fillColour = Graphics.colours.WHITE\
\
\9local path = Path( 1, 1, self.width - 20, self.height - 20, 1, 1 )\
\9path:curveTo( 20, 60, 50, 35 + 12.5, 0, 40 )\
\9path:lineTo( 50, 40 )\
\9path:lineTo( 1, 30 )\
\9path:lineTo( 40, 15 )\
\9path:lineTo( 40, 25 )\
\9path:lineTo( 60, 20 )\
\9path:lineTo( 50, 10 )\
\
\9local size = 3\
\9\
\9path:close()\
\9path.fillColour = Graphics.colours.BLUE\
\9path.outlineColour = Graphics.colours.RED\
\
\9-- local path2 = Path( 40, 40, 60, 60, 40, 40 )\
\9-- path2:lineTo( 1, 40 )\
\9-- path2:arc( math.pi * 3/2, math.pi * 2, 39 )\
\9-- path2:lineTo( 60, 20 )\
\9-- path2:close()\
\
\9local path3 = Path( 50, 50, 60, 60 )\
\9path3:lineTo( 20, 2 )\
\9path3:lineTo( 30, 25 )\
\9path3:arc( math.pi / 2, math.pi * 2, 15 )\
\9path3:lineTo( 15, 0 )\
\9path3:close( false )\
\9path3.outlineColour = Graphics.colours.BLACK\
\
\9self.canvas:insert( Shader( 1, 1, self.canvas.width, self.canvas.height, function( x, y )\
\9\9return ( math.ceil( x / size ) + math.ceil( y / size ) ) % 2 == 0 and Graphics.colours.LIGHT_GREY or Graphics.colours.WHITE\
\9end ) )\
\
\9self.canvas:insert( path )\
\9-- self.canvas:insert( path2 )\
\9self.canvas:insert( path3 )\
end\
\
--[[\
m = .3\
c = -10\
]]",},interfaces = {["file.sinterface"] = "<FileMenu>\
\9<MenuItem identifier=\"newMenuItem\" text=\"New\" />\
\9<SeparatorMenuItem/>\
\9<MenuItem identifier=\"alertMenuItem\" text=\"Alert\" />\
\9<SeparatorMenuItem/>\
\9<MenuItem identifier=\"rebootMenuItem\" text=\"Reboot\" shortcut=\"ctrl alt x\" />\
</FileMenu>",["edit.sinterface"] = "<Menu>\
\9<MenuItem text=\"Undo\" isEnabled=false shortcut=\"ctrl z\" />\
\9<MenuItem text=\"Redo\" isEnabled=false shortcut=\"ctrl shift z\" />\
\9<SeparatorMenuItem/>\
\9<MenuItem text=\"Cut\" isEnabled=false shortcut=\"ctrl x\" />\
\9<MenuItem text=\"Copy\" isEnabled=false shortcut=\"ctrl c\" />\
\9<MenuItem text=\"Paste\" isEnabled=false shortcut=\"ctrl v\" />\
</Menu>",["test.sinterface"] = "<Container width=100 height=50>\
\9<Button x=1 y=1 text=\"Yeah\" />\
</Container>",["first.sinterface"] = "<FirstApplicationContainer>\
\9<MenuBar width=\"100%\" >\
\9\9<MenuBarItem text=File menuName=file />\
\9\9<MenuBarItem text=Edit menuName=edit />\
\9</MenuBar>\
\
\9<Button identifier=firstButton x=100 y=20 text=\"Open Second\" />\
\
\
\9<MenuButton x=190 y=20 text=\"Menu Button\" menuName=file />\
\9\
\9<TextBox width=130 x=100 y=50 text=\"I'm a text box!\" />\
\9<MaskedTextBox width=130 x=100 y=80 placeholder=\"Password\" />\
\
\9<SegmentContainer x=100 y=110>\
\9\9<SegmentButton text=One isChecked=true />\
\9\9<SegmentButton text=Two isChecked=true />\
\9\9<SegmentButton text=Three isChecked=true />\
\9</SegmentContainer>\
\
\9<!-- <TestView identifier=testview left=\"10%\" right=\"100% - 10\" top=20 height=100/> -->\
\
\9<!-- <Window x=50 y=100 width=100 height=60 >\
\9\9<WindowContainer>\
\9\9\9<ProgressBar x=6 y=35 />\
\9\9\9<Button x=5 y=5 text=Okay />\
\9\9\9<Checkbox identifier=agreeCheckbox x=5 y=25 isChecked=true />\
\9\9\9<Container x=50 y=5 width=20 height=40>\
\9\9\9\9<Radio y=1 isChecked=true />\
\9\9\9\9<Radio y=11/>\
\9\9\9\9<Radio y=21/>\
\9\9\9</Container>\
\9\9</WindowContainer>\
\9</Window> -->\
\
<!-- <AlertWindow></AlertWindow> -->\
\9<!-- <Button identifier=okayButton x=10 y=10 text=Okay />\
\
\9<MenuButton x=60 y=10 text=\"Test\" />\
\
\9<SegmentContainer x=120 y=10>\
\9\9<SegmentButton text=One isChecked=true />\
\9\9<SegmentButton text=Two isChecked=true />\
\9\9<SegmentButton text=Three isChecked=true />\
\9</SegmentContainer>\
\
\9<Label x=10 y=30 text=\"I'm a good ol' label!\" />\
\9<TextBox width=130 x=10 y=50 text=\"I'm a text box!\" />\
\9<TextBox width=130 x=10 y=70 text=\"I'm another text box!\" />\
\
\9<ScrollView x=200 y=35 width=100 height=100 >\
\9\9<ScrollContainer width=90 height=600 >\
\9\9\9<PathView x=10 width=80 y=35 />\
\9\9</ScrollContainer>\
\9</ScrollView>\
\
\9 -->\
\
\
\9<!-- <ProgressBar  x=70 y=150 /> -->\
\9<!-- <ProgressBar  x=70 y=130 />\
\9<ProgressBar  x=70 y=110 />\
\9<ProgressBar  x=70 y=90 />\
\9<ProgressBar  x=70 y=70 />\
\9<ProgressBar  x=70 y=140 />\
\9<ProgressBar  x=70 y=120 />\
\9<ProgressBar  x=70 y=100 />\
\9<ProgressBar  x=70 y=80 />\
\9<ProgressBar  x=70 y=60 /> -->\
\
\9\
\
</FirstApplicationContainer>",["second.sinterface"] = "<SecondApplicationContainer themeName=redplus>\
\
\9<Label x=7 y=15 text=\"Animated scrolling, bezier curves, arcs and linear paths :D\" />\
\
\9<ScrollView x=200 y=35 width=100 height=100 >\
\9\9<ScrollContainer width=90 height=150 >\
\9\9\9<PathView x=10 width=80 y=35 />\
\9\9</ScrollContainer>\
\9</ScrollView>\
\
\9<Button identifier=secondButton x=230 y=\"100% - 25\" text=\"Open First\" />\
\
\9<Label x=7 y=50 text=\"And all sörtß of mägical characters.\" />\
 \
</SecondApplicationContainer>",},}
_G.__resourceTables = _G.__resourceTables or {}
_G.__resourceTables[#_G.__resourceTables + 1] = files
local loaded = {}
local classes = files["classes"]
local loadClass

function _G.__loadClassNamed( name )
	loadClass( name .. ".lua" )
end

loadClass = function( name, content )
	if not loaded[name] then
		content = content or classes[name]
		local f, err = loadstring( content, name )
		if err then error( err, 0 ) end
		local ok, err = pcall( f )
		if err then error( err, 0 ) end
		loaded[name] = true
	end
end

if classes then
	local loadFirst = files["loadfirst.scfg"]
	if loadFirst then
		for name in loadFirst:gmatch( "[^\n]+" ) do
			loadClass( name )
		end
	end

	for name, contents in pairs( classes ) do
		loadClass( name, content )
	end
end

_G.__loadClassNamed = nil



-- written in love2d so I'll port it over at some point

class "TextFormatter" {
	width = 0;
	height = 0;

	text = "";

	-- this stuff is actually controlled by the Font class
	-- might be better to make it a table of fonts and the range of the string
	-- but up to you, i'm not really sure how it works

	-- these are defaults, since they can change
	colour = Graphics.colours.GREY;
	underline = false;
	strikethrough = false;

	font_name = "default";
	font_size = 5;
	font_mode = "default"; -- italic, bold, bolditalic

	xAlignment = "left"; -- alignment.LEFT ?
	yAlignment = "top"; -- alignment.TOP?

	changed = false;
	stream = nil;
	wrappedStream = nil;
}

function TextFormatter:init( text, width, height )
	self.text = text
	self.width = width
	self.height = height
end

function TextFormatter:set() -- this is called when a variable is set right?:  Yes, arguments are key, value if you want them
	self.changed = true
end

function TextFormatter:tostream()
	if not self.changed and self.stream then
		return self.stream
	end
	-- convert text into a formatted stream of characters
end

function TextFormatter:wrapstream( display_width, display_height, stream )
	if not self.changed and self.wrappedStream then
		return self.wrappedStream
	end
	stream = stream or self:tostream()
	-- wordwrap the stream and sort out alignment
end

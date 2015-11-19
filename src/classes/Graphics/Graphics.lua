
class "Graphics" {
	
	colours = Enum( Number, {
		TRANSPARENT = 0;
		WHITE = colours.white;
		ORANGE = colours.orange;
		MAGENTA = colours.magenta;
		LIGHT_BLUE = colours.lightBlue;
		YELLOW = colours.yellow;
		LIME = colours.lime;
		PINK = colours.pink;
		GREY = colours.grey;
		LIGHT_GREY = colours.lightGrey;
		CYAN = colours.cyan;
		PURPLE = colours.purple;
		BLUE = colours.blue;
		BROWN = colours.brown;
		GREEN = colours.green;
		RED = colours.red;
		BLACK = colours.black;

		-- For those who can't spell.
		GRAY = colours.grey;
		LIGHT_GRAY = colours.lightGrey;
	} );

}

-- TODO: alias
-- Graphics:alias( Graphics.colours, "colors" )
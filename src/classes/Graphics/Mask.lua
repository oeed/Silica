
class "Mask" {
    
    x = Number;
    y = Number;
    width = Number;
    height = Number;

    pixels = Table;

}

function Mask:initialise( Number x, Number y, Number width, Number height, Table( {} ) pixels )
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.pixels = pixels    
end

class "Mask" {
    
    x = Number;
    y = Number;

    pixels = Table;

}

function Mask:initialise( Number x, Number y, Table( {} ) pixels )
    self.x = x    
    self.y = y    
    self.pixels = pixels    
end

class PathMask extends Mask {
    
}

function PathMask:initialise( Number x, Number y, Path path, Number( path.width ) width,  Number( path.height ) height )
    local pixels = {}
    local scaleX, scaleY = width / path.width, height / path.height
    local fill = path:getFill( scaleX, scaleY )
    self:super( x, y, width, height, fill )
end
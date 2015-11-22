
class "ScreenCanvas" extends "Canvas" {
    
    drawsCorners = Boolean( true );
    screenBuffer = Table( {} );

}

function ScreenCanvas:initialise( ... )
    self:super( ... )
    self:fill( Graphics.colours.RED )
end

function ScreenCanvas:drawToScreen( screen )
    local pixels, width, height, screenBuffer = self.pixels, self.width, self.height, self.screenBuffer

    -- draw the blacked out corners. this could be done using a Mask if the performance isn't too bad (considering it will be called every single draw)
    local corner = { 
        [1] = { [1] = true, [2] = true, [3] = true, [4] = true, [height - 3] = true, [height - 2] = true, [height - 1] = true, [height] = true },
        [2] = { [1] = true, [2] = true, [height - 1] = true, [height] = true },
        [3] = { [1] = true, [height] = true },
        [4] = { [1] = true, [height] = true },
        [width - 3] = { [1] = true, [height] = true },
        [width - 2] = { [1] = true, [height] = true },
        [width - 1] = { [1] = true, [2] = true, [height - 1] = true, [height] = true },
        [width] = { [1] = true, [2] = true, [3] = true, [4] = true, [height - 3] = true, [height - 2] = true, [height - 1] = true, [height] = true },
    }
    local blackColour = Graphics.colours.BLACK
    for x, v in pairs( corner ) do
        for y, v in pairs( v ) do
            pixels[ ( y - 1 ) * width + x ] = blackColour
        end
    end

    local blit = term.blit
    local hexes = { 
        [2^0] = "0",
        [2^1] = "1",
        [2^2] = "2",
        [2^3] = "3",
        [2^4] = "4",
        [2^5] = "5",
        [2^6] = "6",
        [2^7] = "7",
        [2^8] = "8",
        [2^9] = "9",
        [2^10] = "a",
        [2^11] = "b",
        [2^12] = "c",
        [2^13] = "d",
        [2^14] = "e",
        [2^15] = "f"
    }

    for y = 1, self.height do
        local changed = false
        local str = ""
        for x = 1, width do
            local p = ( y - 1 ) * width + x
            local c = pixels[p] or blackColour
            str = str .. hexes[c]
            if not changed and c ~= screenBuffer[p] then
                changed = true
            end
        end
        if changed then
            term.setCursorPos(1,y)
            blit("e"..str)
        end
    end
end
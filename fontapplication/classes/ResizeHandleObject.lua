
local HANDLE_SIZE = 3

class "ResizeHandleObject" extends "GraphicsObject" {

    isLeft = false;
    isTop = false;
    
}

function ResizeHandleObject:initialise( x, y, isLeft, isTop )
    self.super:initialise( x, y, HANDLE_SIZE, HANDLE_SIZE )
    self.isLeft = isLeft
    self.isTop = isTop
end

function ResizeHandleObject:getFill()
    if self.fill then return self.fill end

    local fill = {}
        
    local horizontalY = self.isTop and 1 or HANDLE_SIZE
    for x = 1, HANDLE_SIZE do
        fill[x] = fill[x] or {}
        fill[x][horizontalY] = true
    end

    local verticalX = self.isLeft and 1 or HANDLE_SIZE
    for y = 1, HANDLE_SIZE do
        fill[verticalX] = fill[verticalX] or {}
        fill[verticalX][y] = true
    end

    self.fill = fill
end

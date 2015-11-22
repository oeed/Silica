
class "MouseHeldEvent" extends "MouseEvent" {
    eventType = "mouse_held";
    mouseButton = false;
    isSentToChildren = Boolean( false );
}

--[[
    @desc Creates a mouse held event from the arguments
    @param [MouseEvent.mouseButtons] mouseButton -- the mouse button (left, right, etc.)
    @param [number] x -- the x screen coordinate
    @param [number] y -- the y screen coordinate
    @param [number] globalX -- the global x screen coordinate
    @param [number] globalY -- the global y screen coordinate
]]
function MouseHeldEvent:initialise( mouseButton, x, y, globalX, globalY )
    self.mouseButton = mouseButton
    self.x = x
    self.y = y
    self.globalX = globalX
    self.globalY = globalY
end

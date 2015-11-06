
class "ShadowObject" extends "GraphicsObject" {

    views = {};

}

function ShadowObject:initialise( x, y, width, height, views )
    self.super:initialise( x, y, width, height )
    self.views = views or {}
end

function ShadowObject:setViews( views )
    self.hasChanged = true
    self.views = views
end

function ShadowObject:getFill()
    if self.fill then return self.fill end
    log('update fill')
    local fill = {}
    local width = self.width
    local height = self.height
    for i, object in ipairs( self.views ) do
        local objectFill = object.fill
        local objectX, objectY = object.x, object.y
        for x, row in pairs( objectFill ) do
            local fillX = fill[x + objectX - 1]
            if not fillX then
                fillX = {}
                fill[x + objectX - 1] = fillX
            end

            for y, isFilled in pairs( row ) do
                fillX[y + objectY - 1] = isFilled
            end
        end
    end

    self.fill = fill
    return fill
end

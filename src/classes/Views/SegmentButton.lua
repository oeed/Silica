
local SHADOW_RATIO = Canvas.shadows.SHADOW_RATIO

class "SegmentButton" extends "Button" {
	
}

function SegmentButton:initialise( ... )
    self:super( ... )
    self:event( ParentChangedInterfaceEvent, self.onSiblingOrParentChanged )
    self:event( SiblingAddedInterfaceEvent, self.onSiblingOrParentChanged )
end

function SegmentButton:onDraw()
    local width, height, theme, canvas, isPressed, isFirst, isLast = self.width, self.height, self.theme, self.canvas, self.isPressed, self.isFirst, self.isLast

    -- get all the shadow size details so we can adjust the compression as needed
    local defaultShadowSize = theme:value( "shadowSize", "default" )
    local shadowPressedSize = theme:value( "shadowSize", "pressed" )
    local shadowSize = theme:value( "shadowSize" )
    local shadowOffset = defaultShadowSize - shadowSize
    local shadowPressedOffset = defaultShadowSize - shadowPressedSize
    local shadowX = math.floor( shadowOffset * SHADOW_RATIO + 0.5 )

    local cornerRadius, outlineThickness, fillColour, outlineColour = theme:value( "cornerRadius" ), theme:value( "outlineThickness" ), theme:value( "fillColour" ), theme:value( "outlineColour" )
    -- background shape
    local roundedRectangle = RoundedRectangleMask( shadowX + 1, shadowOffset + 1, width - math.floor( shadowPressedOffset * SHADOW_RATIO + 0.5 ), height - shadowPressedOffset, isFirst and cornerRadius or 0, isLast and cornerRadius or 0 )
    canvas:fill( fillColour, roundedRectangle )
    canvas:outline( outlineColour, roundedRectangle, isFirst and outlineThickness or 0, outlineThickness, isLast and outlineThickness or 0 )

    if not isLast then
        local separatorTopMargin, separatorBottomMargin = theme:value( "separatorTopMargin" ), theme:value( "separatorBottomMargin" )
        local separatorHeight = height - shadowPressedOffset - separatorBottomMargin - separatorTopMargin
        local separatorX = width - 1
        local backgroundMask = RectangleMask( separatorX, 1, 1, height - shadowPressedOffset )
        canvas:fill( theme:value( "fillColour", "default" ), backgroundMask )
        canvas:outline( theme:value( "outlineColour", "default" ), backgroundMask, 0, outlineThickness, 0 )
        canvas:fill( theme:value( "separatorColour" ), theme:value( "separatorIsDashed" ) and SeparatorMask( separatorX, 1 + separatorTopMargin, 1, separatorHeight ) or RectangleMask( separatorX, 1 + separatorTopMargin, 1, separatorHeight ) )
    end

    local leftMargin, rightMargin, topMargin, bottomMargin = theme:value( "leftMargin" ), theme:value( "rightMargin" ), theme:value( "topMargin" ), theme:value( "bottomMargin" )
    -- text
    canvas:fill( theme:value( "textColour" ),  TextMask( leftMargin + shadowX + 1, topMargin + 1 + shadowOffset, width - leftMargin - rightMargin, height - topMargin - bottomMargin, self.text, theme:value( "font" ) ) )

    self.shadowSize = shadowSize
end

function SegmentButton.width:set( width )
    self:super( width + ( self.isLast and 0 or 1 ) ) -- add extra room for the separator
end

--[[
    @desc Fired when it's siblings changed or it is added/removed from it's parent
    @param [Event] event -- the event
]]
function SegmentButton:onSiblingOrParentChanged( InterfaceEvent event, Event.phases phase )
    self.needsDraw = true
end
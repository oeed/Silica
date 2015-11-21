
local LARGE_ICON_SIZE = 32
local SMALL_ICON_SIZE = 10
local FOCUS_PADDING = 5
local FOCUS_GAP = 2
local TEXT_MARGIN = FOCUS_PADDING + FOCUS_GAP
local SIDE_MARGIN = 1
local DRAG_COPY_KEY = "alt"
-- local ADD_FOCUS_KEY = "shift"
local ADD_FOCUS_KEY = "ctrl"

local folderIcon, folderSmallIcon

class "FileItem" extends "View" implements "IDraggableView" implements "IFlowItem" implements "IDragDropDestination" {
    
    titleObject = false;
    subtitleObject = false;
    imageObject = false;
    focusObject = false;
    isFocused = false;
    isCanvasHitTested = false;

    title = false;
    subtitle = false;
    isFolder = true;

    minWidth = 85;
    idealWidth = 1;
    idealHeight = 32;
    contentWidth = 32;
    maxWidth = 1;
    height = 32;
    style = 2;

    styles = {
        LIST = 1;
        THUMBNAIL = 2;
    };

    dropStyle = DragDropManager.dropStyles.SHRINK;
    isDropHovering = false;

}

function FileItem:initialise( ... )
    self:super( ... )

    self:event( MouseDownEvent, self.onMouseDown )
    self:event( MouseHeldEvent, self.onMouseHeld )
    self:event( MouseDoubleClickEvent, self.onMouseDoubleClick )
    -- self:event( Event.KEY_DOWN, self.onKeyDown )
    -- self:event( Event.KEY_UP, self.onKeyUp )
    -- self.event:connectGlobal( MouseUpEvent, self.onGlobalMouseUp, Event.phases.BEFORE )

    folderIcon = Image.fromPath( "folder" )
    folderSmallIcon = Image.fromPath( "folder-small" )
end

function FileItem:initialiseCanvas()
    self:super()

    local width, height, canvas, theme = self.width, self.height, self.canvas, self.theme
    local focusObject = canvas:insert( RoundedRectangle( SIDE_MARGIN + LARGE_ICON_SIZE + 3, 7, 2 * FOCUS_PADDING, 12 ) )
    local titleObject = canvas:insert( Text( SIDE_MARGIN + LARGE_ICON_SIZE + TEXT_MARGIN + 1, 9, width - LARGE_ICON_SIZE - TEXT_MARGIN, 8, self.title ) )
    local subtitleObject = canvas:insert( Text( SIDE_MARGIN + LARGE_ICON_SIZE + TEXT_MARGIN + 1, 20, width - LARGE_ICON_SIZE - TEXT_MARGIN, 8, self.subtitle ) )
    local imageObject = canvas:insert( ImageObject( SIDE_MARGIN + 1, 1, LARGE_ICON_SIZE, LARGE_ICON_SIZE, folderIcon ) )
    imageObject.drawsShadow = true
    
    theme:connect( focusObject, "fillColour", "focusFillColour" )
    theme:connect( focusObject, "outlineColour", "focusOutlineColour" )
    theme:connect( focusObject, "radius", "focusRadius" )
    theme:connect( titleObject, "textColour", "titleColour" )
    theme:connect( subtitleObject, "textColour", "subtitleColour" )

    self.titleObject = titleObject
    self.subtitleObject = subtitleObject
    self.focusObject = focusObject
    self.imageObject = imageObject
end

function FileItem:updateIdealSize()
    local style = self.style
    local styles = self.styles
    local parent = self.parent

    local titleObject, subtitleObject = self.titleObject, self.subtitleObject
    local titleFont, subtitleFont = titleObject.font, subtitleObject.font

    local titleWidth = titleFont:getWidth( self.title )
    local subtitleWidth = subtitleFont:getWidth( self.subtitle )

    local contentWidth = LARGE_ICON_SIZE + FOCUS_GAP + math.max( subtitleWidth, titleWidth ) + 2 * FOCUS_PADDING + 2 * SIDE_MARGIN
    self.contentWidth = contentWidth

    if style == styles.LIST then
        if parent then
            local parentWidth = parent.width
            self.minWidth = parentWidth
            self.idealWidth = parentWidth
            self.maxWidth = parentWidth
        end
        self.idealHeight = SMALL_ICON_SIZE + 2
    elseif style == styles.THUMBNAIL then
        self.idealWidth = contentWidth
        self.maxWidth = contentWidth * 1.5
        self.minWidth = 85
        self.idealHeight = LARGE_ICON_SIZE + 2
    end

    if parent then
        self.parent.needsLayoutUpdate = true
    end
end

function FileItem.title:set( title )
    self.title = title
    self.titleObject.text = title
    self:updateIdealSize()
end

function FileItem.subtitle:set( subtitle )
    self.subtitle = subtitle
    self.subtitleObject.text = subtitle
    self:updateIdealSize()
end

function FileItem:updateWidth( width )
    local titleObject, subtitleObject = self.titleObject, self.subtitleObject
    local contentWidth = math.min( width, self.contentWidth )
    self.focusObject.width = contentWidth - LARGE_ICON_SIZE - FOCUS_GAP - 2 * SIDE_MARGIN
    self.titleObject.width = contentWidth - LARGE_ICON_SIZE - FOCUS_GAP - 2 * FOCUS_PADDING - 2 * SIDE_MARGIN
    self.subtitleObject.width = contentWidth - LARGE_ICON_SIZE - FOCUS_GAP - 2 * FOCUS_PADDING - 2 * SIDE_MARGIN
end

function FileItem:updateHeight( height )
    local imageObject, titleObject, focusObject = self.imageObject, self.titleObject, self.focusObject
    local iconSize = math.min( height - 2, LARGE_ICON_SIZE )
    imageObject.width = iconSize
    imageObject.height = iconSize
    local icon = ( iconSize > (LARGE_ICON_SIZE - SMALL_ICON_SIZE) / 2 + SMALL_ICON_SIZE ) and "folder" or "folder-small"
    if imageObject.image ~= icon then
        imageObject.image = icon
    end
    titleObject.x = iconSize + SIDE_MARGIN + TEXT_MARGIN + 1
    local textY = math.max( math.floor( ( iconSize - 8 --[[ FONT_HEIGHT == 8 ]] ) / 3 + 0.5 ) + 1, 3 )
    titleObject.y = textY
    focusObject.x = SIDE_MARGIN + iconSize + 3
    focusObject.y = textY - 2
end

function FileItem.style:set( style )
    self.style = style
    self:updateIdealSize()
end

function FileItem:updateThemeStyle()
    self.theme.style = self.isEnabled and ( self.isDropHovering and "hover" or (self.isFocused and "focused" or "default") ) or "disabled"
end

function FileItem:onMouseDown( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        if self.application.keyboardShortcutManager:isKeyDown( ADD_FOCUS_KEY ) then
            if self.isFocused then
                self:unfocus()
            else
                self:addFocus()
            end
        elseif #self.application:focusesOfType( FileItem ) > 1 then
            self:addFocus()
        else
            self:focus()
        end
    end
    return true
end

function FileItem:onMouseHeld( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        self:addFocus()
        local isMove = not self.application.keyboardShortcutManager:isKeyDown( DRAG_COPY_KEY )
        local views = self.application:focusesOfType( FileItem )
        self:startDragDrop( event, FileClipboardData( "" ), isMove, function( destination )
                if destination and isMove then
                    for i, view in ipairs( views ) do
                        view:dispose()
                    end
                end
            end, views )
    end
    return true
end

function FileItem:onMouseDoubleClick( Event event, Event.phases phase )
    if self.isEnabled and event.mouseButton == MouseEvent.mouseButtons.LEFT then
        -- error('oepn')
    end
    return true
end

function FileItem.isDropHovering:set( isDropHovering )
    self.isDropHovering = isDropHovering
    self:updateThemeStyle()
end

function FileItem:canAcceptDragDrop( data )
    return self.isFolder and data:typeOf( FileClipboardData )
end

function FileItem:dragDropEntered( data, dragView )
    self.isDropHovering = true
    self.imageObject.image = "folder-open"
end

function FileItem:dragDropMoved( data, dragView )
end

function FileItem:dragDropExited( data, dragView )
    self.isDropHovering = false
    self.imageObject.image = "folder"
end

function FileItem:dragDropDropped( data )
end
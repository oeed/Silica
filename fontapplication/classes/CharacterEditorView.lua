
local HANDLE_SIZE = 3
local RESIZE_MARGIN_SIZE = 5
local RESIZE_PADDING_SIZE = 1

class "CharacterEditorView" extends "View" {
    
    scale = 8;
    character = false;
    nextCharacter = false;
    scaledCharacterObject = false;
    artboardObject = false;
    resizeHandleObjects = false;
    borderLeftObject = false;
    borderRightObject = false;
    gridObject = false;
    dragStart = {};
    startWidth = false;
    endWidth = false;

}

function CharacterEditorView:initialise( ... )
    self:super( ... )

    self:event( MouseDownEvent, self.onMouseDownOrMove )
    self:event( MouseDragEvent, self.onMouseDownOrMove )
    self.event:connectGlobal( MouseDownEvent, self.onGlobalMouseDownOrMove, Event.phases.BEFORE )
    self.event:connectGlobal( MouseDragEvent, self.onGlobalMouseDownOrMove, Event.phases.BEFORE )
    self:event( ReadyInterfaceEvent, self.onReady)
end

function CharacterEditorView:onReady()
    local parent = self.parent
    self.x = math.ceil( ( parent.width - self.width ) / 2 )
    self.y = math.ceil( ( parent.height - self.height ) / 2 )
end

function CharacterEditorView:initialiseCanvas()
    self:super()

    local width, height, theme, canvas = self.width, self.height, self.theme, self.canvas
    local artboardObject = canvas:insert( Rectangle( 1 + RESIZE_MARGIN_SIZE - RESIZE_PADDING_SIZE, 1 + RESIZE_MARGIN_SIZE - RESIZE_PADDING_SIZE, 1, 1 ) )
    local scaledCharacterObject = canvas:insert( ScaledCharacterObject( 1 + RESIZE_MARGIN_SIZE, 1 + RESIZE_MARGIN_SIZE, self.character, self.scale ) )
    local borderLeftObject = canvas:insert( Rectangle( 1, 1, RESIZE_MARGIN_SIZE - RESIZE_PADDING_SIZE, height ) )
    local borderRightObject = canvas:insert( Rectangle( 1 + width - RESIZE_MARGIN_SIZE + RESIZE_PADDING_SIZE, 1, RESIZE_MARGIN_SIZE - RESIZE_PADDING_SIZE, height ) )
    local resizeHandleObjects = {}

    for x = 0, 1 do
        local isLeft = x == 0
        local _x = isLeft and 2 or width - HANDLE_SIZE
        for y = 0, 1 do
            local isTop = y == 0
            local object = ResizeHandleObject( _x, isTop and 2 or height - HANDLE_SIZE, isLeft, isTop )
            canvas:insert( object )
            theme:connect( object, "fillColour", "resizeHandleColour" )
            table.insert( resizeHandleObjects, object )
        end
    end

    theme:connect( scaledCharacterObject, "fillColour", "pixelColour" )
    theme:connect( artboardObject, "fillColour", "artboardColour" )
    theme:connect( borderLeftObject, "fillColour" )
    theme:connect( borderRightObject, "fillColour" )
    theme:connect( canvas, "fillColour" )

    self.scaledCharacterObject = scaledCharacterObject
    self.artboardObject = artboardObject
    self.resizeHandleObjects = resizeHandleObjects
    self.borderLeftObject = borderLeftObject
    self.borderRightObject = borderRightObject
end

function CharacterEditorView.animationPercentage:set( animationPercentage )

    if animationPercentage == 0 then
        self.scaledCharacterObject.x = 1 + RESIZE_MARGIN_SIZE
        self.width = self.character.width * self.scale + 2 * RESIZE_MARGIN_SIZE
        return
    end

    local startWidth, endWidth = self.startWidth, self.endWidth

    if animationPercentage < 1 and not startWidth then
        local scale = self.scale
        startWidth = self.character.width * scale + 2 * RESIZE_MARGIN_SIZE
        endWidth = self.nextCharacter.width * scale + 2 * RESIZE_MARGIN_SIZE
        self.startWidth = startWidth
        self.endWidth = endWidth
    end

    if animationPercentage <= 0.5 then
        local scaledCharacterObject = self.scaledCharacterObject
        local endX = -scaledCharacterObject.width + 1 + RESIZE_MARGIN_SIZE
        scaledCharacterObject.x = math.floor( endX * animationPercentage * 2 + 0.5 ) + 1 + RESIZE_MARGIN_SIZE
    elseif animationPercentage <= 1 then
        local nextCharacter = self.nextCharacter
        local scaledCharacterObject = self.scaledCharacterObject
        if nextCharacter then
            self.character = nextCharacter
            self.nextCharacter = false
            scaledCharacterObject.character = nextCharacter
        end

        local startX = 1 + scaledCharacterObject.width
        scaledCharacterObject.x = math.floor( startX * (1 - (animationPercentage - 0.5) * 2) + 0.5 ) + 1 + RESIZE_MARGIN_SIZE
    end

    if animationPercentage >= 1 then
        self.startWidth = false
        self.endWidth = false
    else
        self.width = startWidth + ( endWidth - startWidth ) * animationPercentage
    end
end

function CharacterEditorView:updateWidth( width )
    self.artboardObject.width = width - 2 * RESIZE_MARGIN_SIZE + 2 * RESIZE_PADDING_SIZE

    local resizeHandleObjects = self.resizeHandleObjects
    for i = 3, 4 do
        resizeHandleObjects[i].x = width - HANDLE_SIZE
    end

    self.borderRightObject.x = 1 + width - RESIZE_MARGIN_SIZE + RESIZE_PADDING_SIZE
    self.x = math.ceil( ( self.parent.width - width ) / 2 )
end

function CharacterEditorView:updateHeight( height )
    self.artboardObject.height = height - 2 * RESIZE_MARGIN_SIZE + 2 * RESIZE_PADDING_SIZE

    local resizeHandleObjects = self.resizeHandleObjects
    for i = 2, 4, 2 do
        resizeHandleObjects[i].y = height - HANDLE_SIZE
    end

    self.borderLeftObject.height = height
    self.borderRightObject.height = height
    self.y = math.ceil( ( self.parent.height - height ) / 2 )
end

function CharacterEditorView.scale:set( scale )
    self.scale = scale
    local scaledCharacterObject = self.scaledCharacterObject
    scaledCharacterObject.scale = scale
    self.width = scaledCharacterObject.width + 2 * RESIZE_MARGIN_SIZE
    self.height = scaledCharacterObject.height + 2 * RESIZE_MARGIN_SIZE
end

function CharacterEditorView.character:set( character )
    self.character = character
    local scaledCharacterObject = self.scaledCharacterObject
    scaledCharacterObject.character = character
    self.width = scaledCharacterObject.width + 2 * RESIZE_MARGIN_SIZE
    self.height = scaledCharacterObject.height + 2 * RESIZE_MARGIN_SIZE
end

function CharacterEditorView:onGlobalMouseUp( Event event, Event.phases phase )
    local dragStart = self.dragStart
    if #dragStart == 4 then
        dragStart[1] = nil
        dragStart[2] = nil
        dragStart[3] = nil
        dragStart[4] = nil
    end
end

function CharacterEditorView:onGlobalMouseDownOrMove( Event event, Event.phases phase )
    local dragStart = self.dragStart
    local isDragging = ( event.eventType == MouseDragEvent and #dragStart == 4 )
    if isDragging or self:hitTestEvent( event ) then
        local scale, ceil, width, height = self.scale, math.ceil, self.width, self.height
        local eventX, eventY = event.x, event.y
        local oldRelative = event.relativeView
        event:makeRelative( self )
        if isDragging or (eventX <= RESIZE_MARGIN_SIZE or eventX > width - RESIZE_MARGIN_SIZE) and (eventY <= RESIZE_MARGIN_SIZE or eventY > height - RESIZE_MARGIN_SIZE) then
            local globalX, globalY = event.globalX, event.globalY
            if event.eventType == MouseDownEvent then
                dragStart[1] = globalX
                dragStart[2] = globalY
                dragStart[3] = width
                dragStart[4] = height
            elseif #dragStart == 4 then
                local deltaX = globalX - dragStart[1]
                local deltaY = globalY - dragStart[2]

                local character = self.character
                local floor = math.floor

                local width = floor( ( dragStart[3] + 2 * deltaX ) / scale + 0.5 )
                local height = floor( ( dragStart[4] + 2 * deltaY ) / scale + 0.5 )

                self.application.document:resizeCharacter( character, width, height )

                local scaledCharacterObject = self.scaledCharacterObject
                scaledCharacterObject:updateSize()
                self.width = scaledCharacterObject.width + 2 * RESIZE_MARGIN_SIZE
                self.height = scaledCharacterObject.height + 2 * RESIZE_MARGIN_SIZE

            end
            event:makeRelative( oldRelative )
            log('false')
            return false
        end
        event:makeRelative( oldRelative )
        if not isDragging then
            return true
        else
            log('false')
            return false
        end
    end
end

function CharacterEditorView:onMouseDownOrMove( Event event, Event.phases phase )
    local scale, ceil, width, height = self.scale, math.ceil, self.width, self.height
    local eventX, eventY = event.x, event.y
    local characterX, characterY = ceil( (eventX - RESIZE_MARGIN_SIZE) / scale ), ceil( (eventY - RESIZE_MARGIN_SIZE) / scale )
    local mouseButton = event.mouseButton
    if mouseButton == MouseEvent.mouseButtons.LEFT then
        local character = self.character
        if character[characterY] then
            character[characterY][characterX] = true
        end
        self.scaledCharacterObject:setIsFilled( true, characterX, characterY )
    else
        local character = self.character
        if character[characterY] then
            character[characterY][characterX] = false
        end
        self.scaledCharacterObject:setIsFilled( false, characterX, characterY )
    end
end

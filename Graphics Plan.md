
# Graphics Plan

## Canvas

Each `View` has a `Canvas`. The `Canvas` is drawn to every time something changes.

There is an `ApplicationCanvas` class. Every update ApplicationCanvas:draw is called. If any of the sub-Canvases within it changed it will redraw. This checking and redrawing applies for all canvases that have changed. If the canvas didn't change it will not redraw and the old contents will be used.

If a View's content has changed the following function is called. Name change pending.

```lua
function View:onDraw()
    
end
```

Unlike the previous system nothing within here is cached, everything is done from scratch.

If any property is changed `Boolean .hasChanged` is set to true.

## Mask class

A `Mask` is a table of pixels that can be used to draw shapes. They can be filled or outlined

```lua
local circleMask = CircleMask( Number x, Number y, Number diameter )
canvas:fill( circleMask, colour )
canvas:outline( circleMask, colour, Number( 1 ) thickness )
```

This could potentially also allow for things like gradients or patterns in the future.

Text is also a `Mask`. Essentially anything drawn on-screen is from a Mask except for images.

```lua
local textMask = TextMask( Number x, Number y, String text, Font( Font.static.systemFont ) font )
canvas:fill( textMask, colour )
canvas:outline( textMask, colour, Number( 1 ) thickness )
```

`Mask`s can also be used to draw a canvas to another canvas with sections not draw.

```lua
local canvas -- the parent canvas
local childCanvas -- the child canvas

childCanvas:drawTo( Canvas canvas, Mask.allowsNil mask ) -- if mask is nil it doesn't mask it, it will just draw it directly
```

## Images

Images are the main thing that can't be drawn using a mask. Masks are generally vector graphics while images are obviously raster. Whenever possible you should use a Mask rather than an Image.


```lua
canvas:image( Number x, Number y, Image image, Number( image.width ) width, Number( image.height ) height ) -- draws the image, if width and/or height are given the image will be scaled
```

## Shadows

A `View` can cast a shadow. This is controlled by the `Number( 0 ) shadowSize` property.

The following function returns the Mask of the shadow. Any pixels in the mask that would be filled if it were drawn will be the shadow. This is called immediately after :onDraw().

```lua
function View:shadowMask( Mask canvasMask ) -- canvasMask is a mask of the drawn content of View
    -- by default the entire view will cast a shadow, you only need to change this if you want a custom shadow (generally if you want to ommit something)
    -- you can add and subtract masks from each other
    return canvasMask
end
```
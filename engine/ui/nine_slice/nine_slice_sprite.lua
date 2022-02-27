local NineSliceSprite = Class {
    init = function(self, image, border)
        self.image = image
        if type(border) == 'table' and type(border.x) == 'number' and type(border.y) == 'number' then
            self.borders = border
        elseif type(border) == 'number' then
            self.borders = { x = border, y = border }
        else
            error("NineSliceSprite border must be a number or a Vector")
        end

        --TODO: memoize slices
        self.slices = self:splitToSlices(image, self.borders)
        self.quads = self:_initQuads()
        self:setSize(image:getDimensions())
    end
}

function NineSliceSprite:splitToSlices(image, borders)
    local width, height = image:getDimensions()
    local slices = { left = {}, center = {}, right = {} }

    local coords = {
        x = {
            left = 0,
            center = borders.x,
            right = width - borders.x
        },
        y = {
            up = 0,
            center = borders.y,
            down = height - borders.y
        }
    }

    local cornerSize = Vector(borders.x, borders.y)
    slices.left.up    = self:renderToTexture(image, Vector(coords.x.left,  coords.y.up),   cornerSize)
    slices.right.up   = self:renderToTexture(image, Vector(coords.x.right, coords.y.up),   cornerSize)
    slices.left.down  = self:renderToTexture(image, Vector(coords.x.left,  coords.y.down), cornerSize)
    slices.right.down = self:renderToTexture(image, Vector(coords.x.right, coords.y.down), cornerSize)

    local horSideSize = Vector(width - borders.x * 2, borders.y)
    slices.center.up   = self:renderToTexture(image, Vector(coords.x.center, coords.y.up),   horSideSize)
    slices.center.down = self:renderToTexture(image, Vector(coords.x.center, coords.y.down), horSideSize)

    local vertSideSize = Vector(borders.x, height - borders.y * 2)
    slices.left.center  = self:renderToTexture(image, Vector(coords.x.left,  coords.y.center), vertSideSize)
    slices.right.center = self:renderToTexture(image, Vector(coords.x.right, coords.y.center), vertSideSize)

    local centerSize = Vector(width - borders.x * 2, height - borders.y * 2)
    slices.center.center = self:renderToTexture(image, Vector(coords.x.center, coords.y.center), centerSize)

    return slices
end

function NineSliceSprite:renderToTexture(image, fromPoint, size)
    local canvas = love.graphics.newCanvas(size.x, size.y)
    canvas:setWrap("repeat", "repeat")
    canvas:renderTo(function()
        love.graphics.push()
        love.graphics.translate(-(fromPoint.x), -(fromPoint.y))
        love.graphics.draw(image)
        love.graphics.pop()
    end)
    return canvas
end

function NineSliceSprite:_initQuads()
    local quads = {}
    local horSideSize = Vector(self.slices.center.up:getDimensions())
    local vertSideSize = Vector(self.slices.left.center:getDimensions())
    local centerSize = Vector(self.slices.center.center:getDimensions())
    quads.up   = love.graphics.newQuad(0, 0, horSideSize.x, horSideSize.y, horSideSize.x, horSideSize.y)
    quads.down = love.graphics.newQuad(0, 0, horSideSize.x, horSideSize.y, horSideSize.x, horSideSize.y)
    quads.left  = love.graphics.newQuad(0, 0, vertSideSize.x, vertSideSize.y, vertSideSize.x, vertSideSize.y)
    quads.right = love.graphics.newQuad(0, 0, vertSideSize.x, vertSideSize.y, vertSideSize.x, vertSideSize.y)
    quads.center = love.graphics.newQuad(0, 0, centerSize.x, centerSize.y, centerSize.x, centerSize.y)
    return quads
end

function NineSliceSprite:setSize(width, height)
    local newSpriteSize = Vector(width, height)
    newSpriteSize.x = math.max(newSpriteSize.x, self.borders.x * 2)
    newSpriteSize.y = math.max(newSpriteSize.y, self.borders.y * 2)
    self:_updateQuads(newSpriteSize)
    self.size = newSpriteSize
    return self
end

function NineSliceSprite:_updateQuads(newSpriteSize)
    local imageSize = Vector(self.image:getDimensions())
    if newSpriteSize == self.size then
        return
    end

    local horSideImgSize = Vector(self.slices.center.up:getDimensions())
    local vertSideImgSize = Vector(self.slices.left.center:getDimensions())
    local centerImgSize = Vector(self.slices.center.center:getDimensions())
    local newHorQuadSize = newSpriteSize.x - self.borders.x * 2
    local newVertQuadSize = newSpriteSize.y - self.borders.y * 2

    self.quads.up    :setViewport(0, 0, newHorQuadSize, self.borders.y,  horSideImgSize.x,  horSideImgSize.y)
    self.quads.down  :setViewport(0, 0, newHorQuadSize, self.borders.y,  horSideImgSize.x,  horSideImgSize.y)
    self.quads.left  :setViewport(0, 0, self.borders.x, newVertQuadSize, vertSideImgSize.x, vertSideImgSize.y)
    self.quads.right :setViewport(0, 0, self.borders.x, newVertQuadSize, vertSideImgSize.x, vertSideImgSize.y)
    self.quads.center:setViewport(0, 0, newHorQuadSize, newVertQuadSize, centerImgSize.x,   centerImgSize.y)
end

function NineSliceSprite:draw(x, y)
    x = x or 0
    y = y or 0
    local sizes = {
        x = {
            left = self.borders.x,
            center = self.size.x - self.borders.x * 2,
            right = self.borders.x
        },
        y = {
            up = self.borders.y,
            center = self.size.y - self.borders.y * 2,
            down = self.borders.y
        }
    }

    love.graphics.push()
        love.graphics.translate(x, y)
        love.graphics.push()
            love.graphics.draw(self.slices.left.up)
            love.graphics.translate(sizes.x.left, 0)
            love.graphics.draw(self.slices.center.up, self.quads.up)
            love.graphics.translate(sizes.x.center, 0)
            love.graphics.draw(self.slices.right.up)
        love.graphics.pop()

        love.graphics.translate(0, sizes.y.up)
        love.graphics.push()
            love.graphics.draw(self.slices.left.center, self.quads.left)
            love.graphics.translate(sizes.x.left, 0)
            love.graphics.draw(self.slices.center.center, self.quads.center)
            love.graphics.translate(sizes.x.center, 0)
            love.graphics.draw(self.slices.right.center, self.quads.right)
        love.graphics.pop()

        love.graphics.translate(0, sizes.y.center)
        love.graphics.push()
            love.graphics.draw(self.slices.left.down)
            love.graphics.translate(sizes.x.left, 0)
            love.graphics.draw(self.slices.center.down, self.quads.down)
            love.graphics.translate(sizes.x.center, 0)
            love.graphics.draw(self.slices.right.down)
        love.graphics.pop()
    love.graphics.pop()
end

return NineSliceSprite
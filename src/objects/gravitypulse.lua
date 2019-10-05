local WIDTH = 32
local HEIGHT = 32

return Class{
    init = function (self, position, world)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.world = world
        self.world:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)
        self.type = 'gravity'
    end,

    collide = function (self)
        print('boom')
        Signal.emit('explode', self.position)
        self.world:remove(self)
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(255, 0, 255)
        love.graphics.translate(self.position:unpack())
        love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
        love.graphics.pop()
    end
}
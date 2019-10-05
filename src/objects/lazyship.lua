local WIDTH = 32
local HEIGHT = 32
local MAX_VELOCITY = Vector(100, 100)

return Class{
    init = function (self, position)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.velocity = Vector(
            love.math.random(-MAX_VELOCITY.x, MAX_VELOCITY.x),
            love.math.random(-MAX_VELOCITY.y, MAX_VELOCITY.y))
    end,

    move = function (self, dt)
        return self.position.x + self.velocity.x * dt,
            self.position.y + self.velocity.y * dt
    end,

    collide = function (self, other)
        if other.isWall then return 'bounce'
        else return false end
    end,

    setPosition = function (self, x, y)
        self.position.x, self.position.y = x, y
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(0, 255, 255)
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.rectangle('line', 0, 0, WIDTH, HEIGHT)
        love.graphics.pop()
    end
}
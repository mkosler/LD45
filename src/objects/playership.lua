local WIDTH = 64
local HEIGHT = 64
local MAX_VELOCITY = Vector(300, 300)

return Class{
    init = function (self, position)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        -- BUMP_WORLD:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)
    end,

    -- Instant acceleration
    -- Direction relative to the screen
    move = function (self, dt, xAxis, yAxis)
        return self.position.x + (MAX_VELOCITY.x * xAxis) * dt,
            self.position.y + (MAX_VELOCITY.y * yAxis) * dt
    end,

    collide = function (self, other)
        return 'slide'
    end,

    setPosition = function (self, x, y)
        self.position.x, self.position.y = x, y
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(255, 0, 0)
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
        love.graphics.pop()
    end
}
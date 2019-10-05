local WIDTH = 16
local HEIGHT = 16
local MAX_VELOCITY = Vector(200, 200)

return Class{
    init = function (self, position, world)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.world = world
        self.world:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)
    end,

    -- Instant acceleration
    -- Direction relative to the screen
    move = function (self, dt, xAxis, yAxis)
        local goalX = self.position.x + (MAX_VELOCITY.x * xAxis) * dt
        local goalY = self.position.y + (MAX_VELOCITY.y * yAxis) * dt

        local actualX, actualY, cols, len =
            self.world:move(self, goalX, goalY, self.filter)

        self:setPosition(actualX, actualY)
    end,

    filter = function (self, other)
        if other.isWall then return 'slide'
        else return 'cross' end
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
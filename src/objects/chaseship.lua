local WIDTH = 32
local HEIGHT = 32
local THRUST = 100

return Class{
    init = function (self, position, world, player)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.velocity = Vector(0, 0)
        self.player = player
        self.world = world
        self.world:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)
        self.shipType = 'chase'
    end,

    move = function (self, dt)
        self.velocity = THRUST * (self.player.position - self.position):normalized()

        local goalX = self.position.x + self.velocity.x * dt
        local goalY = self.position.y + self.velocity.y * dt

        local actualX, actualY, cols, len =
            self.world:move(self, goalX, goalY, self.filter)

        self:setPosition(actualX, actualY)
    end,
    
    filter = function (self, other)
        if other.shipType == 'chase' then return 'slide'
        else return false end
    end,

    setPosition = function (self, x, y)
        self.position.x, self.position.y = x, y
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(255, 255, 0)
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.circle('line', WIDTH / 2, HEIGHT / 2, WIDTH / 2)
        love.graphics.pop()
    end
}
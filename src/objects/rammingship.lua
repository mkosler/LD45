local WIDTH = 32
local HEIGHT = 32
local THRUST = 300
local TURN_RADIUS = 1.5

return Class{
    init = function (self, position, world, player)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.player = player
        self.world = world
        self.world:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)
        self.shipType = 'ramming'
        self.velocity = THRUST * (self.player.position - self.position):normalized()
        self.angle = self.velocity:angleTo() * 180 / math.pi
    end,

    move = function (self, dt)
        local angle = self.velocity:angleTo(self.player.position - self.position) * 180 / math.pi
        if angle < 0 then angle = angle + 360 end
        -- print(('angle to: %.02f, self angle: %.02f'):format(angle, self.angle))

        if angle > 185 then self.angle = self.angle + TURN_RADIUS
        elseif angle < 175 then self.angle = self.angle - TURN_RADIUS
        end

        -- if angle > 0.1 then self.angle = self.angle - 0.01
        -- elseif angle < -0.1 then self.angle = self.angle + 0.01
        -- end

        local rad = self.angle * math.pi / 180

        self.velocity.x = math.cos(rad) * THRUST
        self.velocity.y = math.sin(rad) * THRUST

        local goalX = self.position.x + self.velocity.x * dt
        local goalY = self.position.y + self.velocity.y * dt

        local actualX, actualY, cols, len =
            self.world:move(self, goalX, goalY, self.filter)

        self:setPosition(actualX, actualY)
    end,

    filter = function (self, other)
        if other.isWall then return 'bounce'
        else return false end
    end,

    setPosition = function (self, x, y)
        self.position.x, self.position.y = x, y
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(255, 0, 0)
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.rectangle('line', 0, 0, WIDTH, HEIGHT)
        love.graphics.pop()
    end
}
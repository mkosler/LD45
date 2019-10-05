local WIDTH = 32
local HEIGHT = 32
local THRUST = 100

return Class{
    init = function (self, position, world)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.velocity = Vector(
            love.math.random(-THRUST, THRUST),
            love.math.random(-THRUST, THRUST))
        self.world = world
        self.world:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)
        self.type = 'lazy'

        Signal.register('explode', function (bombPosition)
            self.pushed = true

            local len = self.velocity:len()
            local normal = (bombPosition - self.position):normalized()
            local recoilVector = normal * len

            local dist = self.position:dist(bombPosition) / 500
            self.velocity.x = Utils.clamp(-recoilVector.x / dist, -THRUST, THRUST)
            self.velocity.y = Utils.clamp(-recoilVector.y / dist, -THRUST, THRUST)
        end)
    end,

    move = function (self, dt)
        local goalX = self.position.x + self.velocity.x * dt
        local goalY = self.position.y + self.velocity.y * dt

        local actualX, actualY, cols, len =
            self.world:move(self, goalX, goalY, self.filter)

        self:setPosition(actualX, actualY)

        for i = 1, len do
            local col = cols[i]
            if col.bounce then
                if col.normal.x ~= 0 then self.velocity.x = self.velocity.x * -1 end
                if col.normal.y ~= 0 then self.velocity.y = self.velocity.y * -1 end
            end
        end
    end,

    filter = function (self, other)
        if other.isWall then return 'bounce'
        else return false end
    end,

    setPosition = function (self, x, y)
        self.position.x, self.position.y = x, y
    end,

    explosionReaction = function (self, bombPosition)
        self.pushed = true

        local dist = self.position:dist(bombPosition)
        self.velocity = -self.velocity / dist

        Timer.after(2, function () self.pushed = false end)
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(0, 255, 255)
        love.graphics.translate(self.position.x, self.position.y)
        love.graphics.rectangle('line', 0, 0, WIDTH, HEIGHT)
        love.graphics.pop()
    end
}
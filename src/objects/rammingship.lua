local WIDTH = 32
local HEIGHT = 32
local THRUST = 300
local TURN_RADIUS = 1.0

return Class{
    init = function (self, position, world, player)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.player = player
        self.world = world
        self.world:add(self, self.position.x - WIDTH / 2, self.position.y - HEIGHT / 2, WIDTH * 0.8, HEIGHT * 0.8)
        self.type = 'ramming'
        self.velocity = THRUST * (self.player.position - self.position):normalized()
        self.angle = self.velocity:angleTo() * 180 / math.pi

        Signal.register('explode', function (bombPosition)
            self.pushed = true

            local len = self.velocity:len()
            local normal = (bombPosition - self.position):normalized()
            local recoilVector = normal * len

            local dist = self.position:dist(bombPosition)
            if dist < 200 then
                self.dead = true
                self.world:remove(self)
            end
            dist = dist / 500
            self.velocity = -recoilVector / dist

            Timer.tween(1, self.velocity, {x = 0, y = 0}, 'out-sine',
                function () self.pushed = false end)
        end)
    end,

    move = function (self, dt)
        if self.dead then return end

        if not self.pushed then
            local angle = self.velocity:angleTo(self.player.position - self.position) * 180 / math.pi
            if angle < 0 then angle = angle + 360 end

            if angle > 185 then self.angle = self.angle + TURN_RADIUS
            elseif angle < 175 then self.angle = self.angle - TURN_RADIUS
            end

            local rad = self.angle * math.pi / 180

            self.velocity.x = math.cos(rad) * THRUST
            self.velocity.y = math.sin(rad) * THRUST
        end

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

    explosionReaction = function (self, bombPosition)
        self.pushed = true

        local dist = self.position:dist(bombPosition)
        self.velocity = -self.velocity / dist

        Timer.after(2, function () self.pushed = false end)
    end,

    draw = function (self)
        if self.dead then return end

        love.graphics.push('all')
        love.graphics.setColor(255, 0, 0)
        love.graphics.translate(self.position.x, self.position.y)
        local vertices = {
            0, -HEIGHT / 2,
            WIDTH / 2, HEIGHT / 2,
            -WIDTH / 2, HEIGHT / 2
        }
        -- local normalVelocity = self.velocity:normalized()
        -- love.graphics.line(0, 0, 20 * normalVelocity.x, 20 * normalVelocity.y)
        love.graphics.rotate(math.pi / 2 + self.angle * math.pi / 180)
        love.graphics.polygon('line', vertices)
        -- love.graphics.circle('line', WIDTH / 2, HEIGHT / 2, WIDTH, 8)
        love.graphics.pop()
    end
}
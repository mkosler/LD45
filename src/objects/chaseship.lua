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
        self.type = 'chase'

        self.explodeHandle = Signal.register('explode', function (bombPosition)
            self.pushed = true

            local len = self.velocity:len()
            local normal = (bombPosition - self.position):normalized()
            local recoilVector = normal * len

            local dist = self.position:dist(bombPosition)
            if dist < 200 then
                self.dying = true
                Signal.remove('explode', self.explodeHandle)
                Timer.after(0.5, function () self.dead = true end)
                self.world:remove(self)

                self.debris = {}
                for i = 1, love.math.random(10, 25) do
                    local pl = love.math.random(len / 2, len * 1.5)
                    local p = Vector(
                        love.math.random(self.position.x - 10, self.position.x + 10),
                        love.math.random(self.position.y - 10, self.position.y + 10)
                    )
                    local pnorm = (bombPosition - p):normalized()
                    local prv = pnorm * pl

                    table.insert(self.debris, {
                        position = p,
                        velocity = -prv
                    })
                end
            end
            dist = dist / 500
            self.velocity = -recoilVector / dist

            Timer.tween(1, self.velocity, {x = 0, y = 0}, 'out-sine',
                function () self.pushed = false end)
        end)
    end,

    move = function (self, dt)
        if self.dead then return end

        if self.dying then
            for _,v in pairs(self.debris) do
                v.position = v.position + v.velocity * dt
            end
            return
        end

        if not self.pushed then
            self.velocity = THRUST * (self.player.position - self.position):normalized()
        end

        local goalX = self.position.x + self.velocity.x * dt
        local goalY = self.position.y + self.velocity.y * dt

        local actualX, actualY, cols, len =
            self.world:move(self, goalX, goalY, self.filter)

        self:setPosition(actualX, actualY)
    end,
    
    filter = function (self, other)
        if other.type == 'chase' then return 'slide'
        else return false end
    end,

    setPosition = function (self, x, y)
        self.position.x, self.position.y = x, y
    end,

    draw = function (self)
        if self.dead then return end

        love.graphics.push('all')
        love.graphics.setColor(255, 255, 0)
        love.graphics.translate(self.position.x, self.position.y)
        if self.dying then
            love.graphics.push('all')
            love.graphics.origin()
            for _,v in pairs(self.debris) do
                love.graphics.points(v.position:unpack())
            end
            love.graphics.pop()
        else
            love.graphics.circle('line', WIDTH / 2, HEIGHT / 2, WIDTH / 2)
        end
        love.graphics.pop()
    end
}
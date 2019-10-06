local WIDTH = 32
local HEIGHT = 32
local THRUST = 350
local TURN_RADIUS = 1.0

return Class{
    init = function (self, position, world, player)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.player = player
        self.world = world
        self.bbox = {
            x = -WIDTH / 2,
            y = -HEIGHT / 2,
            w = WIDTH,
            h = HEIGHT
        }
        self.world:add(self, self.position.x + self.bbox.x, self.position.y + self.bbox.y, self.bbox.w, self.bbox.h)
        self.type = 'ramming'
        self.velocity = THRUST * (self.player.position - self.position):normalized()
        self.angle = self.velocity:angleTo() * 180 / math.pi
        self.explosionSound = ASSETS['explosion-sfx']:clone()

        self.explodeHandle = Signal.register('pulseExplode', function (bombPosition)
            self.pushed = true

            local len = self.velocity:len()
            local normal = (bombPosition - self.position):normalized()
            local recoilVector = normal * len

            local dist = self.position:dist(bombPosition)
            if dist < 200 then
                self.dying = true
                Signal.emit('shipExplode')
                self.explosionSound:play()
                Signal.remove('pulseExplode', self.explodeHandle)
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
            self.world:move(self, goalX + self.bbox.x, goalY + self.bbox.y, self.filter)

        self:setPosition(actualX - self.bbox.x, actualY - self.bbox.y)
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
        -- Debug bbox
        -- love.graphics.push('all')
        -- love.graphics.setLineWidth(1)
        -- love.graphics.rectangle('line', self.bbox.x, self.bbox.y, self.bbox.w, self.bbox.h)
        -- love.graphics.pop()
        if self.dying then
            love.graphics.push('all')
            love.graphics.origin()
            for _,v in pairs(self.debris) do
                love.graphics.points(v.position:unpack())
            end
            love.graphics.pop()
        else
            local vertices = {
                0, -HEIGHT / 2,
                WIDTH / 2, HEIGHT / 2,
                -WIDTH / 2, HEIGHT / 2
            }
            love.graphics.rotate(math.pi / 2 + self.angle * math.pi / 180)
            love.graphics.polygon('line', vertices)
        end
        love.graphics.pop()
    end
}
local WIDTH = 32
local HEIGHT = 32

return Class{
    init = function (self, position, world)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.world = world
        self.world:add(self, self.position.x - WIDTH / 2, self.position.y - HEIGHT / 2, WIDTH, HEIGHT)
        self.type = 'gravity'

        self.pulseEffectWidth = WIDTH / 2
        self.pulseEffectHeight = HEIGHT / 2
        self.pulseEffectAlpha = 255

        self:pulseEffect()

        self.radius = 0
        self.shockWaveColor = 255
        self.explodeHandle = Signal.register('explode', function ()
            self.isExploding = true
            self.world:remove(self)

            Timer.tween(1, self, { radius = 200, shockWaveColor = 0 }, 'linear', function ()
                Signal.remove('explode', self.explodeHandle)
                Signal.emit('explodeEnd')
            end)
        end)
    end,

    pulseEffect = function (self)
        Timer.script(function (wait)
            Timer.tween(0.25, self,
                {
                    pulseEffectWidth = 1.5 * WIDTH,
                    pulseEffectHeight = 1.5 * HEIGHT,
                    pulseEffectAlpha = 0
                })
            wait(1)
            self.pulseEffectWidth = WIDTH / 2
            self.pulseEffectHeight = HEIGHT / 2
            self.pulseEffectAlpha = 255
            self:pulseEffect()
        end)
    end,

    collide = function (self)
        Signal.emit('explode', self.position)
    end,

    draw = function (self)
        love.graphics.push('all')
        love.graphics.setColor(255, 0, 255)
        love.graphics.translate(self.position:unpack())
        love.graphics.translate(-WIDTH / 2, -HEIGHT / 2)
        if not self.isExploding then
            love.graphics.push('all')
            love.graphics.setColor(200, 0, 200, self.pulseEffectAlpha)
            vertices = {
                0, -self.pulseEffectHeight / 2,
                self.pulseEffectWidth / 2, 0,
                0, self.pulseEffectHeight / 2,
                -self.pulseEffectWidth / 2, 0
            }
            love.graphics.polygon('line', vertices)
            love.graphics.pop()
            local vertices = {
                0, -HEIGHT / 2,
                WIDTH / 2, 0,
                0, HEIGHT / 2,
                -WIDTH / 2, 0
            }
            love.graphics.polygon('fill', vertices)
        else
            love.graphics.push('all')
            love.graphics.setColor(0, 0, 0, 240)
            love.graphics.circle('fill', WIDTH / 2, HEIGHT / 2, self.radius)
            love.graphics.setColor(self.shockWaveColor, self.shockWaveColor, self.shockWaveColor)
            love.graphics.circle('line', WIDTH / 2, HEIGHT / 2, self.radius)
            love.graphics.pop()
        end
        love.graphics.pop()
    end
}
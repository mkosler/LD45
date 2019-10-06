local WIDTH = 16
local HEIGHT = 16
local MAX_VELOCITY = Vector(250, 250)

return Class{
    init = function (self, position, world)
        self.position = position or Vector(0, 0)
        self.width = WIDTH
        self.height = HEIGHT
        self.world = world
        self.world:add(self, self.position.x, self.position.y, WIDTH, HEIGHT)

        Signal.register('dying', function ()
            self.isDead = true
            ASSETS['player-death-sfx']:play()
            Timer.after(2.5, function ()
                Signal.emit('death')
            end)
        end)

        -- Particle system for death
        self.particle = love.graphics.newCanvas(4, 4)
        love.graphics.setCanvas(self.particle)
            love.graphics.push('all')
            love.graphics.setColor(0, 255, 0)
            love.graphics.rectangle('fill', 0, 0, 4, 4)
            love.graphics.pop()
        love.graphics.setCanvas()

        self.particleSystem = love.graphics.newParticleSystem(self.particle, 32)
        self.particleSystem:setParticleLifetime(0.5, 1.5)
        self.particleSystem:setEmissionRate(25)
        self.particleSystem:setSizeVariation(1)
        self.particleSystem:setLinearAcceleration(-200, -200, 200, 200)
    end,

    -- Instant acceleration
    -- Direction relative to the screen
    move = function (self, dt, xAxis, yAxis)
        if self.isDead then
            self.particleSystem:update(dt)
            return
        end

        local goalX = self.position.x + (MAX_VELOCITY.x * xAxis) * dt
        local goalY = self.position.y + (MAX_VELOCITY.y * yAxis) * dt

        local actualX, actualY, cols, len =
            self.world:move(self, goalX, goalY, self.filter)

        self:setPosition(actualX, actualY)

        for i = 1, len do
            self:collide(cols[i].other)
        end
    end,

    collide = function (self, other)
        if other.type == 'gravity' then
            other:collide()
        elseif not other.isWall then
            Signal.emit('dying')
        end
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
        love.graphics.translate(self.position.x, self.position.y)
        if not self.isDead then
            love.graphics.setColor(0, 255, 0)
            local vertices = {
                WIDTH * 0.25, 0,
                WIDTH * 0.75, 0,
                WIDTH,        HEIGHT * 0.25,
                WIDTH,        HEIGHT * 0.75,
                WIDTH * 0.75, HEIGHT,
                WIDTH * 0.25, HEIGHT,
                0,            HEIGHT * 0.75,
                0,            HEIGHT * 0.25
            }
            love.graphics.polygon('line', vertices)
        else
            love.graphics.draw(self.particleSystem, 0, 0)
        end
        love.graphics.pop()
    end
}
local Retry = {}

local BOX_WIDTH = 400
local BOX_HEIGHT = 300

function Retry:enter(prev, time)
    self.prev = prev
    self.time = time

    local _, min, sec = Utils.toClockTime(self.time)
    self.uiText = love.graphics.newText(ASSETS['font-retry'])
    self.uiText:set(
        ('Game over...\nScore: %02d:%02d\nPress ENTER to continue...'):format(min, sec))
end

function Retry:draw()
    self.prev:draw()

    love.graphics.push('all')
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill',
        love.graphics.getWidth() / 2 - (BOX_WIDTH / 2),
        love.graphics.getHeight() / 2 - (BOX_HEIGHT / 2),
        BOX_WIDTH, BOX_HEIGHT)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('line',
        love.graphics.getWidth() / 2 - (BOX_WIDTH / 2),
        love.graphics.getHeight() / 2 - (BOX_HEIGHT / 2),
        BOX_WIDTH, BOX_HEIGHT)
    love.graphics.draw(self.uiText,
        love.graphics.getWidth() / 2 - self.uiText:getWidth() / 2,
        love.graphics.getHeight() / 2 - self.uiText:getHeight() / 2)
    love.graphics.pop()
end

function Retry:keypressed(key)
    if key == 'return' then
        Gamestate.switch(STATES.TITLE)
    end
end

return Retry
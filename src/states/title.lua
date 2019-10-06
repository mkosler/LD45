local Title = {}

local BOX_WIDTH = 400
local BOX_HEIGHT = 230

local openingText = [[Press ENTER to play
Press ESC to see tutorial]]

local tutorialText = {
    { 0, 255, 0, 255 },
    [[You]],
    { 255, 255, 255, 255 },
    [[ are lost in cyberspace and your weapons are malfunctioning! Try and survive as long as you can!

The ]],
    { 0, 255, 255, 255 },
    [[blue squares]],
    { 255, 255, 255, 255 },
    [[ are the remains of other helpless souls. They waste out their days lazily floating along.

The ]],
    { 255, 255, 0, 255 },
    [[yellow circles]],
    { 255, 255, 255, 255 },
    [[ attack you directly, but move methodically, and mass together into unstoppable blobs! Lure them into the gravity pulses to clear them out in large chunks!

The ]],
    { 255, 0, 0, 255 },
    [[red triangles]],
    { 255, 255, 255, 255 },
    [[ are viruses that charge at you! Dodge them and take advantage of their poor turning!

The ]],
    { 255, 0, 255, 255 },
    [[gravity pulses]],
    { 255, 255, 255, 255 },
    [[ are your only offense, but be warned: every time you use one, the next one takes longer to spawn. Strategize your movement and usage!

Press ENTER to play]]
}

-- local tutorialText = [[You are lost in cyberspace and your weapons are malfunctioning! Try and survive as long as you can!

-- The blue squares are the remains of other helpless souls. They waste out their days lazily floating along.

-- The yellow circles attack you directly, but move methodically, and mass together into unstoppable blobs! Lure them into the gravity pulses to clear them out in large chunks!

-- The red triangles are viruses that charge at you! Dodge them and take advantage of their poor turning!

-- The gravity pulses are your only offense, but be warned: every time you use one, the next one takes longer to spawn. Strategize your movement and usage!

-- Press ENTER to play]]

function Title:enter(prev)
    BOX_WIDTH = 400
    BOX_HEIGHT = 230
    self.uiText = love.graphics.newText(ASSETS['font-retry'])
    self.uiText:set(openingText)
end

function Title:draw()
    love.graphics.push('all')
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle('fill',
        love.graphics.getWidth() / 2 - BOX_WIDTH / 2,
        love.graphics.getHeight() / 2 - BOX_HEIGHT / 2,
        BOX_WIDTH, BOX_HEIGHT)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle('line',
        love.graphics.getWidth() / 2 - BOX_WIDTH / 2,
        love.graphics.getHeight() / 2 - BOX_HEIGHT / 2,
        BOX_WIDTH, BOX_HEIGHT)
    love.graphics.draw(self.uiText,
        love.graphics.getWidth() / 2 - self.uiText:getWidth() / 2,
        love.graphics.getHeight() / 2 - self.uiText:getHeight() / 2)
    love.graphics.pop()
end

function Title:keypressed(key)
    if key == 'return' then
        Gamestate.switch(STATES.PLAY, PLAYFIELD_LEFT, PLAYFIELD_TOP, PLAYFIELD_RIGHT, PLAYFIELD_BOTTOM)
    elseif key == 'escape' then
        BOX_WIDTH = 800
        BOX_HEIGHT = 600
        self.uiText:setFont(ASSETS['font-gravity'])
        self.uiText:setf(tutorialText, BOX_WIDTH - 100, 'left')
    end
end

return Title
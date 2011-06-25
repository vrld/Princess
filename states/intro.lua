require 'textfader'

local st = GS.new()

function st:enter()
	love.graphics.setBackgroundColor(.15,.1,.1)

	Timer.add( 0, function() Textfader("WAKE UP",    Font[100], 2.5, .2, .2) end)
	Timer.add( 2, function() Textfader("MY PRINCE",  Font[100], 2.5, .2, .2) end)
	Timer.add( 4, function() Textfader("WAKE UP...", Font[120], 2.5, .2, .2) end)
	Timer.add( 8, function() Textfader("FIND ME...", Font[150], 3.5, .2, .2) end)
	Timer.add(10.5, function() Textfader("FIND ME...", Font[150], 3.5, .2, .2) end)
	Timer.add(16, function() Textfader("I NEED YOU", Font[170], 3.5, .2, .2) end)
	Timer.add(20, function() GS.switch(State.game) end)
end

function st:leave()
	Entities.clear()
end

function st:draw()
	Entities.draw()
end

function st:update(dt)
	Entities.update(dt)
end

return st

require 'textfader'

local st = GS.new()

local fader
function st:enter(pre)
	self.pre = pre

	local t = 3.5
	Timer.add(t, function() Textfader("YOU", Font[100], 4, .4, .3) end) t = t + 5
	Timer.add(t, function() Textfader("YOU CAME FOR ME", Font[120], 4, .4, .3) end) t = t + 5
	Timer.add(t, function() Textfader("I WILL NEVER LET YOU GO", Font[170], 5, .4, .3) end) t = t + 5
	Timer.add(t+10, function() GS.switch(State.title) end)

	fader = Timer.Interpolator(3, function(s)
		love.graphics.setColor(.15,.1,.1,math.sin(s * math.pi/2))
		love.graphics.rectangle('fill',0,0,WIDTH,HEIGHT)
	end)
	Timer.add(3, function() Entities.clear(); fader = nil end)
end

function st:leave()
	Entities.clear()
end

function st:draw()
	if fader then
		self.pre:draw()
		fader(DT())
	else
		Entities.draw()
	end
end

function st:update(dt)
	if fader then
		self.pre:update(dt)
	else
		Entities.update(dt)
	end
end

return st

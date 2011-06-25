require 'textfader'

local st = GS.new()

local fader,alphafade
function st:enter(pre)
	self.pre = pre

	local t = 3.5
	Timer.add(t, function() Textfader("EOG", Font[170], 6, .4, .3) end) t = t + 5

	local forever_a_magnet = {}
	function forever_a_magnet:draw()
		love.graphics.setColor(1,1,1)
		love.graphics.draw(Image.forever_a_magnet, WIDTH/2,HEIGHT/2, 0,2,2, 46,60)
	end
	Timer.add(4.5, function() Entities.add(forever_a_magnet, Entities.FG) end)
	Timer.add(4.6, function() Entities.remove(forever_a_magnet) end)

	fader = Timer.Interpolator(3, function(s)
		love.graphics.setColor(.15,.1,.1,math.sin(s * math.pi/2))
		love.graphics.rectangle('fill',0,0,WIDTH,HEIGHT)
	end)
	Timer.add(3, function() Entities.clear(); fader = nil end)

	alphafade = Timer.Interpolator(10, function(s)
		love.graphics.setFont(Font[120])
		love.graphics.setColor(1,1,1,math.sin(s * math.pi/2) ^ 10)
		local text = "Again?"
		love.graphics.print(text, (WIDTH-Font[120]:getWidth(text))/2, 4/5 * HEIGHT)
	end)
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
	alphafade(DT())
end

function st:update(dt)
	if fader then
		self.pre:update(dt)
	else
		Entities.update(dt)
	end
end

function st:keypressed(key)
	if key == 'return' then GS.switch(State.game) end
end

return st

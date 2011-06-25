Textfader = Class{name = "Textfader", function(self, text, font, length, attack, release, pos)
	self.text = text
	self.font = font
	self.pos = pos or vector(WIDTH/2,HEIGHT/2)
	self.pos = self.pos - vector(font:getWidth(text), font:getHeight(text))/2
	self.dir = vector(1,0):rotate_inplace(math.random() * 2 * math.pi)

	rlen = 1 - release
	self.alpha = Timer.Interpolator(length, function(s)
		if s <= attack then return s / attack end
		if s <= rlen then return 1 end
		return 1 - (s - rlen) / release
	end)

	Timer.add(length, function() Entities.remove(self) end)
	Entities.add(self, Entities.FG)
end}

function Textfader:draw()
	local a = self.alpha(DT()) or 0
	love.graphics.setFont(self.font)
	love.graphics.setColor(1,1,1,a)
	love.graphics.print(self.text, self.pos:unpack())
end

function Textfader:update(dt)
	self.pos = self.pos + self.dir * dt * 5
end

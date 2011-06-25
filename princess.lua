Princess = Class{function(self, x,y)
	self.shape = HC.addCircle(x,y, 220)
	self.shape.object = self
	self.group = "Princess"
	self.scaler = Timer.Oscillator(5, function(t) return math.sin(t * 2 * math.pi) * .1 + 2 end)
	Image.princess:setFilter('nearest','nearest')

	Entities.add(self, Entities.MID)
end}
make_collidable(Princess)

function Princess:draw()
	love.graphics.setColor(1,1,1)
	local x,y = self.shape:center()
	love.graphics.draw(Princess.img, x,y, self.shape:rotation(),1,1, 256,256)
	local s = self.scaler(DT())
	love.graphics.draw(Image.princess, x,y, self.shape:rotation(),s,s, 32,32)
end

function Princess:update(dt)
	self.shape:rotate(dt / 5)
end

Princess:onCollide("Magnet", function(self, other)
	Princess:onCollide("Magnet", nil)
	GS.switch(State.outro)
end)

local fb = love.graphics.newFramebuffer(512,512)
fb:renderTo(function()
	love.graphics.push()
	love.graphics.translate(256,256)
	for i = 1,1200 do
		local rand = (1 - math.random() * math.random())
		if math.random() > .9 then
			rand = math.random()
		end
		local p = vector(rand * 220,0):rotate_inplace(math.random()*2*math.pi)
		local s = math.random() * .2 + .9
		local r = math.random()*2*math.pi
		if math.random() > .9 then
			love.graphics.draw(Image.magnet, p.x,p.y, r,s,s, 16,32)
		elseif math.random() > .95 then
			love.graphics.draw(Image.umagnet, p.x,p.y, r,s,s, 32,32)
		else
			local f = math.random(1,#Scrap.sprites.frames)
			Scrap.sprites:drawFrame(f, p.x,p.y, r,s,s, 16,16)
		end
	end
	love.graphics.pop()
end)
Princess.img = love.graphics.newImage(fb:getImageData())

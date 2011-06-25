Bomb = Class{function(self, x,y)
	self.shape = HC.addCircle(x,y, 22)
	self.shape.object = self
	self.group = "Bomb"

	self.rotvel = (math.random() * 2 - 1) * .5
	self.shape:rotate(math.random() * 2 * math.pi)

	Entities.add(self, Entities.MID)
end}
make_collidable(Bomb)

function Bomb:draw()
	love.graphics.setColor(1,1,1)
	local x,y = self.shape:center()
	love.graphics.draw(Image.bomb, x,y, self.shape:rotation(),1,1, 32,32)
end

function Bomb:update(dt)
	self.shape:rotate(dt * self.rotvel)
end

Bomb:onCollide("*", function(self, other, dx,dy)
	HC.remove(self.shape)
	Entities.remove(self, Entities.MID)
	Explosion(vector(self.shape:center()))
	love.audio.play(Sound.Explode)
end)

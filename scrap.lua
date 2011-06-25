require 'AnAL'
require 'textfader'

Scrap = Class{function(self, x,y)
	self.sprite = math.random(1, #Scrap.sprites.frames)
	self.shape = HC.addCircle(x,y,12)
	self.shape.object = self
	self.group = "Scrap"

	self.rotvel = (math.random() * 2 - 1) * .5
	self.velocity = vector(10,0):rotate_inplace(math.random() * 2 * math.pi)
	self.velocity = vector(0,0)

	HC.setPassive(self.shape)
	Entities.add(self, Entities.MID)
end}
Scrap.sprites = newAnimation(Image.scrap, 32,32, 0,6)
make_collidable(Scrap)

function Scrap:draw()
	love.graphics.setColor(1,1,1)
	local x,y = self.shape:center()
	Scrap.sprites:drawFrame(self.sprite, x,y, self.shape:rotation(),1,1, 16,16)
end

function Scrap:update(dt)
	self.shape:move((self.velocity * dt):unpack())
	self.shape:rotate(self.rotvel * dt)
end

local spoken = {}
local messages = {
	"don't listen to her",
	"it's a trap!",
	"she only wants consume you",
	"stay here",
	"stay with us",
	"all the others are dead",
}

local bag = Randombag(1,#messages)
bag.bag = {2,1}
Scrap:onCollide("Magnet", function(self)
	if not spoken[self] then
		local t = Textfader(messages[bag:next()], Font[60], 2.5, .1, .2, vector(self.shape:center()))
		spoken[self] = true
	end
end)

Scrap:onCollide("Bomb", function(self,other,dx,dy)
	if not self.magnet then return end

	self.magnet:scrapHitBomb(vector(other.shape:center()), vector(dx,dy))
end)

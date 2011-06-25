MAX_VEL = 500

Magnet = Class{function(self, pos, princess)
	self.velocity = vector(0,0)
	self.rotvel = math.random() * 2 - 1 -- [-1;1]
	self.rotvel = self.rotvel * .5

	self.shape = HC.addRectangle(0,0,30,62)
	self.shape.object = self
	self.group = "Magnet"

	self.shape:moveTo(pos.x,pos.y)
	self.shape:rotate(math.random() * math.pi * 2)

	self.princess = princess
	self.scrap = {}

	Entities.add(self, Entities.MID)

	self.lifes = 4

	local arrow = {}
	arrow.alpha = Timer.Oscillator(4, function(t) return math.sin(t*2*math.pi) * .2 + .4 end)
	function arrow.draw()
		local pos = vector(self.shape:center())
		local ppos = vector(self.princess.shape:center())
		local angle = math.atan2((ppos - pos):unpack())
		local dir = (ppos - pos):normalize_inplace() * 80
		local alpha = arrow.alpha(DT())
		for i = 1,3 do
			local apos = pos + dir * (i * (alpha + .6))
			love.graphics.setColor(.5,1,.4,alpha - i * (alpha / 4))
			love.graphics.draw(Image.arrow, apos.x,apos.y, -angle, 1.1-i/10,1.1-i/10, 16,16)
		end
	end
	Entities.add(arrow, Entities.FG)
end}
make_collidable(Magnet)

function Magnet:remove()
	Entities.remove(self, Entities.MID)
end

function Magnet:draw()
	local pos = vector(self.shape:center())
	love.graphics.setColor(1,1,1)
	love.graphics.draw(Image.magnet, pos.x,pos.y, self.shape:rotation(),1,1, 16,32)

--	love.graphics.setColor(1,1,1,.6)
--	love.graphics.push()
--		love.graphics.translate(pos.x, pos.y+50)
--		love.graphics.draw(Image.key_up,     0, 0, 0,.5,.5, 32,32)
--		love.graphics.draw(Image.key_left, -32,32, 0,.5,.5, 32,32)
--		love.graphics.draw(Image.key_down,   0,32, 0,.5,.5, 32,32)
--		love.graphics.draw(Image.key_right, 32,32, 0,.5,.5, 32,32)
--	love.graphics.pop()
end

function Magnet:update(dt)
	local abs_vel = self.velocity:len()
	if abs_vel > MAX_VEL then self.velocity = self.velocity / abs_vel * MAX_VEL end
	local pos = vector(self.shape:center())

	-- princess attraction
	local ppos = vector(self.princess.shape:center())
	local dir = ppos - pos
	local dist = dir:len()
	dir = dir / dist * math.exp(-math.pow((1+dist)/HEIGHT, 4)) * 220

	local dx,dy = ((self.velocity + dir) * dt):unpack()
	local r = self.rotvel * dt
	self.shape:move(dx,dy)
	self.shape:rotate(r)

	for scrap in pairs(self.scrap) do
		scrap.shape:move(dx,dy)
		scrap.shape:rotate(r, self.shape:center())
	end

	self.velocity = self.velocity * .99
end

local function magnetize(self, other)
	self.scrap[other] = other
	HC.setActive(other.shape)
	other.rotvel = 0
	other.velocity = vector(0,0)
	other.group = "Magnet"

	other.magnet = self
	other:onCollide("Scrap", function(scrap, other)
		scrap.contact_up = other
		magnetize(self, other)
	end)
	love.audio.play(Sound.Collide)
end

local function unmagnetize(magnet, scrap, bombpos, unscrap)
	if not scrap then return end
	unscrap[#unscrap+1] = scrap
	scrap.velocity = (vector(scrap.shape:center()) - bombpos):normalize_inplace() * 100
	scrap.rotvel = (math.random() * 2 - 1) * .5
	scrap.group = "Scrap"
	scrap.magnet = nil
	scrap:onCollide("Scrap", nil)
	unmagnetize(magnet, scrap.contact_up, bombpos, unscrap)
end

Magnet:onCollide("Scrap", magnetize)

function Magnet:playerControl(camera)
	self.update = function(self,dt)
		local dir = vector(0,0)

		if love.keyboard.isDown('up') or love.keyboard.isDown('w') then
			dir.y = dir.y - 1 end
		if love.keyboard.isDown('down') or love.keyboard.isDown('s') then
			dir.y = dir.y + 1 end

		if love.keyboard.isDown('left') or love.keyboard.isDown('a') then
			dir.x = dir.x - 1 end
		if love.keyboard.isDown('right') or love.keyboard.isDown('d') then
			dir.x = dir.x + 1 end

		local rotdir = 0
		if love.keyboard.isDown('q') or love.keyboard.isDown('x') then
			rotdir = rotdir - 1 end
		if love.keyboard.isDown('e') or love.keyboard.isDown('c') then
			rotdir = rotdir + 1 end

		if dir.x ~= 0 or dir.y ~= 0 then
			self.velocity = self.velocity + dir:normalize_inplace() * dt * 100
		end
		self.rotvel = math.max(-math.pi * 2, math.min(math.pi * 2, self.rotvel + rotdir * dt * 5))

		Magnet.update(self, dt)
	end

	camera:follow(self)
end

local health_text = {
	"please no more",
	"that hurt",
	"ouch",
}
function bomb_collide(self, _, dx,dy)
	self.lifes = self.lifes - 1
	if self.lifes < 1 then
		GS.switch(State.died)
		Entities.remove(self)
		return
	end
	Textfader(health_text[self.lifes] or "", Font[120], 1, .1,.1, vector(self.shape:center()))
	self.velocity = self.velocity + vector(dx,dy):normalize_inplace() * 200
end
Magnet:onCollide("Bomb", bomb_collide)

function Magnet:scrapHitBomb(bombpos, dir)
	self.velocity = self.velocity + dir:normalize_inplace() * 200
	if bombpos:dist( vector(self.shape:center()) ) < 200 then
		bomb_collide(self, nil, dir:unpack())
	end

	local unscrap = {}
	for scrap in pairs(self.scrap) do
		local spos = vector(scrap.shape:center())
		if spos:dist(bombpos) < 75 then
			if scrap.contact_up then
				unmagnetize(self, scrap.contact_up, bombpos, unscrap)
			end
		end
	end

	for _,s in ipairs(unscrap) do
		self.scrap[s] = nil
	end
end

Magnet:onCollide("Princess", function(self, other)
	Entities.remove(self)
end)

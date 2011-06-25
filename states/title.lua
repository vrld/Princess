local st = GS.new()

local star = love.image.newImageData(3, 3)
local sprite = {0,.7, 0, .7, 1,.7, 0,.7, 0}
star:mapPixel(function(x,y) return 255,255,255,255*sprite[x+y*3+1] end)
Image.star = love.graphics.newImage(star)
Image.star:setFilter('nearest','nearest')

Star = Class{name = "Star", function(self,x,y)
	self.pos = vector(x,y)
	self.alpha = Timer.Oscillator(math.random(5,30)/10, function(s)
		return math.sin(s * math.pi) * .3 + .7
	end)
	self.scale = Timer.Oscillator(math.random(30,50)/10, function(s)
		return math.sin(s * math.pi * 2) * 1 + 1.5
	end)
	Entities.add(self, Entities.BG)
end}

function Star:draw()
	love.graphics.setColor(1,1,1,self.alpha(DT()))
	love.graphics.draw(Image.star, self.pos.x,self.pos.y, 0,self.scale(DT()))
end

local Magnet = Class{name = "Magnet", function(self,x,y)
	self.pos = vector(x or -10, y or math.random(10,HEIGHT-10))
	self.vel = vector(1,0):rotate_inplace((math.random()-.5)*math.pi / 16)
	self.speed = math.random(80,120) / 100
	self.rot = 0
	Entities.add(self, Entities.MID)
end}

function Magnet:draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(Image.magnet, self.pos.x, self.pos.y, self.rot,1,1, 16,32)
end

function Magnet:update(dt)
	dt = dt * self.speed
	self.pos = self.pos + self.vel * dt * 100
	self.rot = self.rot + dt
	if self.pos.x > WIDTH + 50 or self.pos.y < -50 or self.pos.y > HEIGHT + 50 then
		Entities.remove(self)
		Magnet()
	end
end

function st:init()
	HC.init(100, function(_,a,b,dx,dy)
		a.object:collideWith(b.object, dx,dy)
		b.object:collideWith(a.object, dx,dy)
	end, function(_,a,b,dx,dy)
	a.object:stopCollideWith(b.object, dx,dy)
	b.object:stopCollideWith(a.object, -dx,-dy)
end)
end

local fader, switching
function st:enter()
	switching = false
	Entities.clear()
	for i=1,13 do
		Magnet(math.random(-1.5*WIDTH,0))
	end

	for i = 1,100 do
		Star(math.random(0,WIDTH), math.random(0,HEIGHT))
	end

	fader = Timer.Interpolator(1.5, function(s)
		love.graphics.setColor(0,0,0,math.cos(s * math.pi/2))
		love.graphics.rectangle('fill',0,0,WIDTH,HEIGHT)
	end)
	Timer.add(1.5, function() fader = nil end)

	love.graphics.setBackgroundColor(.15,.1,.1)
end

function st:leave()
	Entities.clear()
end

function st:draw()
	love.graphics.setColor(1,1,1)
	Entities.draw()

	love.graphics.setColor(1,1,1)
	love.graphics.setFont(Font[200])
	love.graphics.print("PRINCESS*", 50,50)

	love.graphics.setFont(Font[100])
	love.graphics.print("-press return-", WIDTH-350,HEIGHT-100)

	love.graphics.setColor(1,1,1,.8)
	love.graphics.setFont(Font[80])
	love.graphics.print("*indie as shit", 50,HEIGHT-100)

	if fader then fader(DT()) end
end

function st:update(dt)
	Entities.update(dt)
	HC.update(dt)
end

function st:keypressed(key)
	if key == 'return' and not switching then
		fader = Timer.Interpolator(3, function(s)
			love.graphics.setColor(0,0,0,math.sin(s * math.pi/2))
			love.graphics.rectangle('fill',0,0,WIDTH,HEIGHT)
		end)
		Timer.add(3, function() GS.switch(State.intro) end)
		switching = true
	end
end

return st

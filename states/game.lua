local st = State.title

local st = GS.new()

local cam = Camera()
--cam.zoom = .1 * .9 * .9 * .9
function cam:follow(target)
	cam.target = target
end

function cam:update(dt)
	if not self.target then return end
	local tpos = vector(self.target.shape:center())

	local dir = tpos - self.pos
	local correction = vector(0,0)
	if self.centering or math.abs(dir.x) > WIDTH/4 then
		correction.x = dir.x
		self.centering = true
	end
	if self.centering or math.abs(dir.y) > HEIGHT/4 then
		correction.y = dir.y
		self.centering = true
	end

	self.pos = self.pos + correction * 2 * dt
	self.centering = self.centering and self.pos:dist(tpos) > 10
end

function st:init()
	HC.init(250, function(_,a,b,dx,dy)
		a.object:collideWith(b.object, dx,dy)
		b.object:collideWith(a.object, -dx,-dy)
	end, function(_,a,b,dx,dy)
		a.object:stopCollideWith(b.object, dx,dy)
		b.object:stopCollideWith(a.object, -dx,-dy)
	end)
end

function Boundary(x1,y1,x2,y2)
	local p = vector(x1,y1)
	local q = vector(x2,y2)
	local d = vector(x2-x1,y2-y1):normalize_inplace() * 96
	while p:dist(q) > 48 do
		Bomb( p:unpack() )
		p = p + d
	end
end

local fader
function st:enter()
	love.graphics.setBackgroundColor(.15,.1,.1)
	Entities.clear()
	HC.clear()

	---- big chamber
	--Boundary(-4474,-2315, 5848,-2315)
	--Boundary( 5848,-2315, 5848, 4555)
	--Boundary( 5848, 4555,-4474, 4555)
	--Boundary(-4474, 4555,-4474,-2315)

	-- start chamber
	Boundary(-4474,-1322,-2475, -104)
	Boundary(-2475, -104, -757, -104)
	Boundary( -757, -104, -757,-2047)

	-- princess chamber
	Boundary( 3654, 4555, 3654, 3765)
	Boundary( 3654, 3765, 4598, 3053)
	Boundary( 4598, 3053, 4848, 3053)
	Boundary( 4848, 3053, 5848, 4555)
	Boundary( 5848, 4555, 3654, 4555)

	-- big wall
	Boundary(-3251,  189,-3165, 2310)
	Boundary(-3164, 2310, 2510, 1977)
	Boundary( 2510, 1977, 3387,  275)
	Boundary( 3387,  275, 3387,-2315)

	-- annoying wall
	Boundary(    0, 3128,    0, 4555)

	local function randcoord(x1,y1,x2,y2)
		return math.random(x1,x2), math.random(y1,y2)
	end

	for i = 1,20 do
		Scrap(randcoord(-3485,-440, -2840,287))
	end
	for i = 1,20 do
		Scrap(randcoord(-1043,-2315, -439,-1619))
	end
	for i = 1,50 do
		Scrap(randcoord(-4474,-2315, 5848,4555))
	end
	for i = 1,20 do
		Scrap(randcoord(-4454,-2295, -4074,-1895))
	end

	m = Magnet(vector(-4321,-2140), Princess(5020, 3950))
	m:playerControl(cam)
	cam.pos = vector(m.shape:center())

	for i = 1,100 do
		local star = Star( math.random(-WIDTH/2,1.5*WIDTH), math.random(-HEIGHT/2,1.5*HEIGHT) )
		function star:update()
			local dx,dy = self.pos.x - cam.pos.x, self.pos.y - cam.pos.y
			if math.abs(dx) > 1.5 * WIDTH or math.abs(dy) > 1.5 * HEIGHT then
				self.pos = cam:toWorldCoords( vector(math.random(-WIDTH/2,1.5*WIDTH), math.random(-HEIGHT/2,1.5*HEIGHT)) )
			end
		end
	end

	fader = Timer.Interpolator(1.5, function(s)
		love.graphics.setColor(.15,.1,.1,math.cos(s * math.pi/2))
		love.graphics.rectangle('fill',0,0,WIDTH,HEIGHT)
	end)
	Timer.add(1.5, function() fader = nil end)
end

function st:draw()
	cam:predraw()
	Entities.draw()
	cam:postdraw()
	if fader then fader(DT()) end
end

function st:update(dt)
	Entities.update(dt)
	HC.update(dt)
	cam:update(dt)
end

function st:keypressed(key)
	if key == 'c' then
		m.shape:moveTo(5020-1000, 3950-1000)
	end
end

--function st:mousepressed(x,y,btn)
--	if btn == 'r' then
--		if love.keyboard.isDown('g') then
--			cam.zoom = cam.zoom * .9
--		elseif love.keyboard.isDown('h') then
--			cam.zoom = cam.zoom * 1.1
--		else
--			cam.pos = cam:mousepos()
--		end
--	elseif btn == 'l' then
--		local p = {}
--		local v = cam:mousepos()
--		v.x,v.y = math.floor(v.x),math.floor(v.y)
--		function p:draw()
--			love.graphics.setFont(Font[100])
--			love.graphics.setColor(1,1,1)
--			love.graphics.circle('fill', v.x,v.y, 4/cam.zoom)
--			love.graphics.print(tostring(v), v.x-5/cam.zoom,v.y-5/cam.zoom, 0,1/cam.zoom)
--		end
--		Entities.add(p, Entities.FG+1)
--	else
--		cam.zoom = 1
--	end
--end


return st

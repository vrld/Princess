HC     = require 'hardoncollider'
Timer  = require 'hump.timer'
Class  = require 'hump.class'
GS     = require 'hump.gamestate'
vector = require 'hardoncollider.vector'
Camera = require 'hump.camera'


DT = love.timer.getDelta
_NULL_ = function() end

--[[ RESOURCE MANAGEMENT ]]--
local function Proxy(f)
	return setmetatable({}, {__index = function(self, k)
		local v = f(k)
		rawset(self, k, v)
		return v
	end})
end

State = Proxy(function(k) return assert(love.filesystem.load('states/'..k..'.lua'))() end)
Font  = Proxy(function(k) return love.graphics.newFont('font/game_over.ttf', k) end)
Image = Proxy(function(k) return love.graphics.newImage('img/' .. k .. '.png') end)
Sound = Proxy(function(k) return love.sound.newSoundData('sound/' .. k .. '.ogg') end)
Music = Proxy(function(k) return k, 'stream' end)

--[[ SOUND MANAGER ]]--
do
	local sources = {}

	function love.audio.update()
		local remove = {}
		for _,s in pairs(sources) do
			if s:isStopped() then
				remove[#remove + 1] = s
			end
		end

		for i,s in ipairs(remove) do
			sources[s] = nil
		end
	end

	local play = love.audio.play
	function love.audio.play(what, how, loop)
		local src = what
		if type(what) ~= "userdata" or not what:typeOf("Source") then
			src = love.audio.newSource(what, how)
			src:setLooping(loop or false)
		end

		play(src)
		sources[src] = src
		return src
	end

	local stop = love.audio.stop
	function love.audio.stop(src)
		if not src then return end
		stop(src)
		sources[src] = nil
	end
end

do
	local setColor = love.graphics.setColor
	local setBG = love.graphics.setBackgroundColor
	function love.graphics.setColor(r,g,b,a)
		if r <= 1 and g <= 1 and b <= 1 then
			r,g,b,a = 255*r,255*g,255*b,255*(a or 1)
		end
		setColor(r,g,b,a)
	end
	function love.graphics.setBackgroundColor(r,g,b,a)
		if r <= 1 and g <= 1 and b <= 1 then
			r,g,b,a = 255*r,255*g,255*b,255*(a or 1)
		end
		setBG(r,g,b,a)
	end
end

--[[ RANDOM BAG ]]--
Randombag = Class{function(self, a,b)
	self.bag = {}
	self.interval = {a,b}
end}

function Randombag:next()
	if #self.bag == 0 then
		self:refill()
	end
	return table.remove(self.bag)
end

function Randombag:refill()
	for i = self.interval[1],self.interval[2] do
		self.bag[#self.bag+1] = i
	end

	for i = #self.bag,1,-1 do
		local k = math.random(1,i)
		self.bag[i],self.bag[k] = self.bag[k],self.bag[i]
	end
end

require 'collidable'
require 'entities'

require 'explosion'
require 'boundary'
require 'magnet'
require 'scrap'
require 'bomb'
require 'princess'

--[[ HOLY DUALITY ]]--
function love.load()
	math.randomseed(os.time()) math.random()
	WIDTH  = love.graphics.getWidth()
	HEIGHT = love.graphics.getHeight()

	local f = Font[100]
	local f = Font[120]
	local f = Font[150]
	local f = Font[170]

	GS.registerEvents()
	--GS.switch(State.game)
	GS.switch(State.title)
end

function love.update(dt)
	Timer.update(dt)
	love.audio.update()
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.push('q')
	end
end

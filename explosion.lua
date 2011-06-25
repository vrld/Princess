Explosion = Class{function(self, pos)
	local function sprite()
		local life = math.random(3,7) / 10
		local peak_groth = math.random() * .2 + .5
		local init_rot = math.random() * math.pi
		return {
			pos = pos + vector(math.random() * 16,0):rotate_inplace(math.random()*2*math.pi),
			alpha = Timer.Interpolator(life, function(t)
				if t < .1 then return t/.1 end
				if t > .8 then return 1 - (t-.8)/.2 end
				return 1
			end),
			size = Timer.Interpolator(life, function(t)
				if t <= peak_groth then
					return math.sin(t / peak_groth * math.pi / 2) * 1.4
				end
				return math.cos((t-peak_groth)/(1-peak_groth) * math.pi / 2) * 1.4
			end),
			rot = Timer.Interpolator(life, function(t) return init_rot + t * math.pi end)
		}
	end

	self.sprites = {}
	for i=1,5 do self.sprites[i] = sprite() end
	Timer.add(math.random(1,3) / 10, function()
		for i=1,5 do self.sprites[5+i] = sprite() end
	end)
	
	Entities.add(self, Entities.FG)
	Timer.add(2, function() Entities.remove(self, Entities.FG) end)
end}

function Explosion:draw()
	love.graphics.setBlendMode("additive")
	for _,e in ipairs(self.sprites) do
		love.graphics.setColor(1,1,1, e.alpha(DT()) or 0)
		local s = e.size(DT())
		love.graphics.draw(Image.explosion, e.pos.x,e.pos.y, e.rot(DT()),s,s, 32,32)
	end
	love.graphics.setBlendMode("alpha")
end

Image.wall:setWrap('repeat','repeat')
Boundary = Class{function(self,x1,y1,x2,y2)
	self.len = math.sqrt( (x2-x1)^2 + (y2-y1)^2 )
	self.shape = HC.addRectangle(0,0,self.len,16)
	self.shape:moveTo((x1+x2)/2, (y1+y2)/2)
	self.shape:rotate(math.atan2(y2-y1, x2-x1) - math.pi)
	self.shape.object = self
	self.group = "Boundary"
	HC.addToGroup(Boundary, self.shape)
	HC.setPassive(self.shape)
	self.quad = love.graphics.newQuad(0,0, self.len,16, 32,16)
	Entities.add(self,Entities.MID)
end}
make_collidable(Boundary)

Boundary:onCollide("*", function(self, other, dx,dy)
	other.shape:move(-dx,-dy)
	if other.velocity then
		local surface = vector(-dy, dx)
		local mirrored = 2 * other.velocity:projectOn(surface) - other.velocity
		other.velocity = mirrored * .9
	end
end)

function Boundary:draw()
	love.graphics.setColor(1,1,1)
	local x,y = self.shape:center()
	love.graphics.drawq(Image.wall, self.quad, x,y, self.shape:rotation(),1,1, self.len/2,8)
end

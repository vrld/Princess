function make_collidable(class)
	class._onCollide = {}
	class._onStopCollide = {}

	function class:onCollide(group, reaction)
		self._onCollide[group] = reaction
	end

	function class:onStopCollide(group, reaction)
		self._onStopCollide[group] = reaction
	end

	function class:register(group, onCollide, onStop)
		class:onCollide(group, onCollide)
		class:onStopCollide(group, onStop)
	end

	function class:collideWith(other,dx,dy)
		(self._onCollide[other.group] or self._onCollide["*"] or _NULL_)(self, other, dx,dy)
	end

	function class:stopCollideWith(other,dx,dy)
		(self._onStopCollide[other.group] or self._onStopCollide["*"] or _NULL_)(self, other, dx,dy)
	end
end

require "collisions"

local shuriken = {}
shuriken.__index = shuriken

function newShuriken()
	local n = {}
	n.y = ninja.y + 10
	if ninja.direction == "right" then
		n.speed = 6
		n.x = ninja.x + 16
	else
		n.speed = -6
		n.x = ninja.x
	end
	n.width = 8
	n.height = 8

	n.anim = newAnimation(lutro.graphics.newImage(
				"assets/shuriken.png"), 8, 8, 1, 60)
	return setmetatable(n, shuriken)
end

function shuriken:update(dt)
	self.anim:update(dt)
	self.x = self.x + self.speed
end

function shuriken:draw()
	self.anim:draw(self.x, self.y)
end

function shuriken:on_collide(e1, e2, dx, dy)

end

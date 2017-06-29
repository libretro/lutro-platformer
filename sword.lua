require "collisions"

local sword = {}
sword.__index = sword

function newSword(parent)
	local n = {}
	n.type = "sword"
	n.y = parent.y - 16
	n.direction = parent.direction
	if n.direction == "left" then
		n.x = parent.x - 16 - 6
	else
		n.x = parent.x - 16 + 6
	end
	n.width = 48
	n.height = 48
	n.die = 0

	n.animations = {
		left  = newAnimation(lutro.graphics.newImage(
			"assets/sword_left.png"),  48, 48, 1, 15),
		right = newAnimation(lutro.graphics.newImage(
			"assets/sword_right.png"), 48, 48, 1, 15)
	}

	n.anim = n.animations[n.direction]

	return setmetatable(n, sword)
end

function sword:update(dt)
	self.anim:update(dt)
end

function sword:draw()
	self.anim:draw(self.x, self.y)
end

function sword:on_collide(e1, e2, dx, dy)

end

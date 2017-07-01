require "collisions"

local sword = {}
sword.__index = sword

function newSword(parent)
	local n = {}
	n.type = "sword"
	n.y = parent.y - 16 + 14
	n.parent = parent
	n.direction = n.parent.direction
	if n.direction == "left" then
		n.x = n.parent.x - 16 - 6
	else
		n.x = n.parent.x - 16 + 6
	end
	n.width = 48
	n.height = 27
	n.die = 0

	n.animations = {
		left  = newAnimation(lutro.graphics.newImage(
			"assets/sword_left.png"),  48, 48, 1, 30),
		right = newAnimation(lutro.graphics.newImage(
			"assets/sword_right.png"), 48, 48, 1, 30)
	}

	n.anim = n.animations[n.direction]

	return setmetatable(n, sword)
end

function sword:update(dt)

	self.y = self.parent.y - 16 + 14
	self.direction = self.parent.direction
	if self.direction == "left" then
		self.x = self.parent.x - 16 - 6
	else
		self.x = self.parent.x - 16 + 6
	end

	if self.parent.hit > 0 then
		entities_remove(self)
	end

	self.anim:update(dt)
end

function sword:draw()
	self.anim:draw(self.x, self.y - 14)
end

require "collisions"

local shuriken = {}
shuriken.__index = shuriken

function newShuriken()
	local n = {}
	n.type = "shuriken"
	n.y = ninja.y + 10 - ninja.yoffset/2
	if ninja.direction == "right" then
		n.speed = 6
		n.x = ninja.x + 16
	else
		n.speed = -6
		n.x = ninja.x
	end
	n.width = 8
	n.height = 8
	n.die = 0

	n.anim = newAnimation(lutro.graphics.newImage(
				"assets/shuriken.png"), 8, 8, 1, 60)
	return setmetatable(n, shuriken)
end

function shuriken:update(dt)
	if self.die > 0 then
		self.die = self.die - 1
	end
	if self.die == 1 then
		entities_remove(self)
	end

	self.anim:update(dt)
	self.x = self.x + self.speed

	if self.x > SCREEN_WIDTH - camera_x
	or self.x < - camera_x
	then
		entities_remove(self)
	end
end

function shuriken:draw()
	self.anim:draw(self.x, self.y)
end

function shuriken:on_collide(e1, e2, dx, dy)
	if e2.type == "ground" and self.die == 0 then
		self.speed = 0
		self.anim.speed = 0
		self.die = 30
		lutro.audio.play(sfx_shurikencollide)
	end
end

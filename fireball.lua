require "collisions"

local fireball = {}
fireball.__index = fireball

function newFireball(parent)
	local n = {}
	n.type = "fireball"
	n.y = parent.y + 10
	if parent.direction == "right" then
		n.speed = 3
		n.direction = "right"
		n.x = parent.x + 22 + 16
	else
		n.speed = -3
		n.direction = "left"
		n.x = parent.x - 16
	end
	n.width = 16
	n.height = 16

	n.animations = {
		left  = newAnimation(lutro.graphics.newImage(
			"assets/fireball_left.png"),  16, 16, 2, 60),
		right = newAnimation(lutro.graphics.newImage(
			"assets/fireball_right.png"), 16, 16, 2, 60)
	}
	n.anim = n.animations[n.direction]
	return setmetatable(n, fireball)
end

function fireball:update(dt)
	self.anim:update(dt)
	self.x = self.x + self.speed
end

function fireball:draw()
	self.anim:draw(self.x, self.y)
end

function fireball:on_collide(e1, e2, dx, dy)
	if (e2.type == "ground"
	 or e2.type == "slopeleft"
	 or e2.type == "sloperight") then
		entities_remove(self)
		lutro.audio.play(sfx_fireballcollide)
	elseif e2.type == "ninja" then
		entities_remove(self)
		lutro.audio.play(sfx_fireballcollide)

		lutro.audio.play(sfx_hit)
		screen_shake = 15
		e2.hit = 60
		if dx < 0 then
			e2.xspeed = 200
		else
			e2.xspeed = -200
		end
		e2.y = e2.y - 1
		e2.yspeed = -1
		hp = hp - 1
	end
end

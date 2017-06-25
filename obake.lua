require "collisions"

local obake = {}
obake.__index = obake

function newObake()
	local n = {}
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.x = (SCREEN_WIDTH - n.width)
	n.y = 180
	n.direction = "left"
	n.stance = "fly"
	n.t = 0

	n.animations = {
		fly = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/obake_fly_left.png"),  48, 48, 100, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/obake_fly_right.png"), 48, 48, 100, 10)
		},
	}

	n.anim = n.animations[n.stance][n.direction]
	return setmetatable(n, obake)
end

function obake:update(dt)
	self.t = self.t + dt

	-- apply speed
	self.x = self.x + self.xspeed * dt;

	self.x = self.x + math.cos(self.t/2.0) / 2.0
	self.y = self.y + math.cos(self.t*2.0) / 4.0

	if self.x > ninja.x then
		self.direction = "left"
	else
		self.direction = "right"
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame 
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim;

	self.anim:update(dt)
end

function obake:draw()
	self.anim:draw(self.x - 16, self.y - 16)
end

function obake:on_collide(e1, e2, dx, dy)

end

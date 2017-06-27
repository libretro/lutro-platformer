require "collisions"

local obake = {}
obake.__index = obake

function newObake(object)
	local n = object
	n.width = 16
	n.height = 16
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 0
	n.direction = "left"
	n.stance = "fly"
	n.type = "obake"
	n.t = 0
	n.hit = 0
	n.die = 0
	n.hp = 3

	n.animations = {
		fly = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/obake_fly_left.png"),  48, 48, 5, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/obake_fly_right.png"), 48, 48, 5, 10)
		},
		hit = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/obake_hit_left.png"),  48, 48, 1, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/obake_hit_right.png"), 48, 48, 1, 10)
		},
	}

	n.anim = n.animations[n.stance][n.direction]
	return setmetatable(n, obake)
end

function obake:update(dt)

	if self.hit > 0 then
		self.hit = self.hit - 1
	else
		self.xaccel = 0
		self.xspeed = 0
	end

	if self.die > 0 then
		self.die = self.die - 1
	end

	if self.die == 1 then
		entities_remove(self)
	end

	self.t = self.t + dt

	-- apply speed
	self.xspeed = self.xspeed + self.xaccel * dt;
	self.x = self.x + self.xspeed * dt;

	if self.stance == "fly" then
		self.x = self.x + math.cos(self.t/2.0) / 2.0
		self.y = self.y + math.cos(self.t*2.0) / 4.0
	end

	if self.x > ninja.x then
		self.direction = "left"
	else
		self.direction = "right"
	end

	if self.hit > 0 then
		self.stance = "hit"
	else
		self.stance = "fly"
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
	if e2.type == "shuriken" and self.hit == 0 and self.die == 0 then
		self.hit = 30
		if e2.speed > 0 then
			self.xspeed = 100
			self.xaccel = -100
		else
			self.xspeed = -100
			self.xaccel = 100
		end

		lutro.audio.play(sfx_enemyhit)
		self.hp = self.hp - 1

		entities_remove(e2)

		if self.hp <= 0 then
			lutro.audio.play(sfx_enemydie)
			self.die = 30
		end
	end
end

require "collisions"

local ninja = {}
ninja.__index = ninja

function newNinja(object)
	local n = object
	n.width = 16
	n.height = 32
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 200
	n.yaccel = 1000
	n.direction = "right"
	n.stance = "fall"
	n.type = "ninja"
	n.DO_JUMP = 0
	n.DO_THROW = 0
	n.hit = 0
	n.dying = 0
	n.throw = 0

	n.animations = {
		stand = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_stand_left.png"),  48, 48, 100, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_stand_right.png"), 48, 48, 100, 10)
		},
		run = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_run_left.png"),  48, 48, 1, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_run_right.png"), 48, 48, 1, 10)
		},
		jump = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_jump_left.png"),  48, 48, 1, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_jump_right.png"), 48, 48, 1, 10)
		},
		fall = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_fall_left.png"),  48, 48, 1, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_fall_right.png"), 48, 48, 1, 10)
		},
		duck = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_duck_left.png"),  48, 48, 1, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_duck_right.png"), 48, 48, 1, 10)
		},
		hit = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_hit_left.png"),  48, 48, 1, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_hit_right.png"), 48, 48, 1, 10)
		},
		dead = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_dead_left.png"),  48, 48, 100, 10),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_dead_right.png"), 48, 48, 100, 10)
		},
		throw = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_throw_left.png"),  48, 48, 1, 30),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_throw_right.png"), 48, 48, 1, 30)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, ninja)
end

function ninja:on_the_ground()
	return (solid_at(self.x + 1, self.y + 32, self)
		or solid_at(self.x + 15, self.y + 32, self))
		and self.yspeed >= 0
		and hp > 0
end

function ninja:update(dt)

	if hp <= 0 then
		self.dying = self.dying + 1
		self.anim = self.animations["dead"][self.direction]
		self.anim:update(dt)
		if self.dying == 1 then
			lutro.audio.play(sfx_dead)
		end
		if self.dying == 100 then
			lutro.audio.play(sfx_gameover)
			self.yspeed = -300
		end
		if self.dying >= 100 then
			self.yspeed = self.yspeed + self.yaccel * dt
			self.y = self.y + dt * self.yspeed
		end
		return
	end

	if self.throw > 0 then
		self.throw = self.throw - 1
	else
		self.throw = 0
	end

	if self.hit > 0 then
		self.hit = self.hit - 1
	end

	-- gravity
	if not self:on_the_ground() then
		self.yspeed = self.yspeed + self.yaccel * dt
		self.y = self.y + dt * self.yspeed
	end

	-- jumping
	if JOY_A then
		self.DO_JUMP = self.DO_JUMP + 1
	else
		self.DO_JUMP = 0
	end

	if self.DO_JUMP == 1 and JOY_DOWN
	and not solid_at(self.x + 8, self.y + 32 + 3) then
		self.y = self.y + 3
	elseif self.DO_JUMP == 1 and self:on_the_ground() then
		self.y = self.y - 1
		self.yspeed = -330
		lutro.audio.play(sfx_jump)
	end

	-- variable jump height
	-- if self.DO_JUMP > 1 and self. DO_JUMP <= 50 and self.yspeed < 0 then
	-- 	self.yspeed = self.yspeed - 10
	-- end

	-- throwing
	if JOY_B then
		self.DO_THROW = self.DO_THROW + 1
	else
		self.DO_THROW = 0
	end

	if self.DO_THROW == 1 and self.throw == 0 then
		lutro.audio.play(sfx_throw)
		self.throw = 15
		table.insert(entities, newShuriken())
	end

	-- moving
	if JOY_LEFT then
		self.xspeed = self.xspeed - self.xaccel * dt;
		if self.xspeed < -200 then
			self.xspeed = -200
		end
		self.direction = "left";
	end

	if JOY_RIGHT then
		self.xspeed = self.xspeed + self.xaccel * dt;
		if self.xspeed > 200 then
			self.xspeed = 200
		end
		self.direction = "right";
	end

	-- apply speed
	self.x = self.x + self.xspeed * dt;

	-- decelerating
	if  not (JOY_RIGHT and self.xspeed > 0)
	and not (JOY_LEFT  and self.xspeed < 0)
	and self:on_the_ground()
	then
		if self.xspeed > 0 then
			self.xspeed = self.xspeed - 10
			if self.xspeed < 0 then
				self.xspeed = 0;
			end
		elseif self.xspeed < 0 then
			self.xspeed = self.xspeed + 10;
			if self.xspeed > 0 then
				self.xspeed = 0;
			end
		end
	end

	-- animations
	if self:on_the_ground() then
		if self.xspeed == 0 then
			self.stance = "stand"
		else
			self.stance = "run"
		end
	else
		if self.yspeed > 0 then
			self.stance = "fall"
		else
			self.stance = "jump"
		end
	end

	if JOY_DOWN then
		if self:on_the_ground() then
			self.xspeed = 0
			self.stance = "duck"
		end
	end

	if self.throw > 0 then
		self.stance = "throw"
	end

	if self.hit > 0 then
		self.stance = "hit"
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame 
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim;

	self.anim:update(dt)
end

function ninja:draw()
	self.anim:draw(self.x - 16, self.y - 16)
end

function ninja:on_collide(e1, e2, dx, dy)

	if hp <= 0 then
		return
	end

	if e2.type == "ground" then

		if math.abs(dy) < math.abs(dx) and dy ~= 0 then
			if self.yspeed > 200 then
				lutro.audio.play(sfx_step)
			end
			self.yspeed = 0
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx
		end

	elseif e2.type == "bridge" or e2.type == "elevator" then

		if math.abs(dy) < math.abs(dx) and dy ~= 0 and self.yspeed > 0
		and not JOY_DOWN
		and self.y + self.height > e2.y
		then
			self.yspeed = 0
			self.y = self.y + dy
			lutro.audio.play(sfx_step)
		end

	elseif e2.type == "spikes" then

		hp = 0

	elseif (e2.type == "obake" or e2.type == "porc") and self.hit == 0 then

		lutro.audio.play(sfx_hit)
		screen_shake = 0.25
		self.hit = 60
		if dx > 0 then
			self.xspeed = 200
		else
			self.xspeed = -200
		end
		self.y = self.y - 1
		self.yspeed = -1
		hp = hp - 1

	end
end

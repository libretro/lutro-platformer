require "collisions"

local ninja = {}
ninja.__index = ninja

function newNinja(object)
	local n = object
	n.width = 16
	n.height = 32
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 900
	n.yaccel = 600
	n.max_xspeed = 150
	n.max_yspeed = 280
	n.friction = 20
	n.groundfriction = 20
	n.airfriction = 2
	n.direction = "right"
	n.stance = "fall"
	n.type = "ninja"
	n.DO_JUMP = 0
	n.DO_THROW = 0
	n.DO_SWORD = 0
	n.hit = 0
	n.dying = 0
	n.throw = 0
	n.sword = 0
	n.yoffset = 0

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
		sword = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/ninja_sword_left.png"),  48, 48, 1, 30),
			right = newAnimation(lutro.graphics.newImage(
				"assets/ninja_sword_right.png"), 48, 48, 1, 30)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, ninja)
end

function ninja:on_the_ground()
	return (solid_at(self.x + 1, self.y + self.height, self)
		or solid_at(self.x + self.width - 1, self.y + self.height, self))
		and self.yspeed >= 0
		and hp > 0
end

function ninja:update(dt)

	local on_the_ground = self:on_the_ground()

	if hp <= 0 then
		self.dying = self.dying + 1
		self.anim = self.animations["dead"][self.direction]
		self.anim:update(dt)
		if self.dying == 1 then
			lutro.audio.play(sfx_dead)
		end
		if self.dying == 40 then
			lutro.audio.play(sfx_gameover)
			self.yspeed = -300
		end
		if self.dying >= 40 then
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

	if self.sword > 0 then
		self.sword = self.sword - 1
	else
		self.sword = 0
	end
	if self.sword == 1 then
		entities_remove(sword)
	end

	if self.hit > 0 then
		self.hit = self.hit - 1
	end

	-- gravity
	if not on_the_ground then
		self.yspeed = self.yspeed + self.yaccel * dt
		self.yspeed = math.min(self.yspeed, self.max_yspeed)
		self.y = self.y + dt * self.yspeed
	end

	-- jumping
	if JOY_B and self.hit == 0 then
		self.DO_JUMP = self.DO_JUMP + 1
	else
		self.DO_JUMP = 0
	end

	if self.DO_JUMP == 1 and JOY_DOWN
	and not solid_at(self.x + 8, self.y + self.height + 3) then
		self.y = self.y + 3
	elseif self.DO_JUMP == 1 and on_the_ground then
		self.y = self.y - 1 - self.yoffset
		self.yspeed = -210
		lutro.audio.play(sfx_jump)
	end

	-- variable jump height
	if self.DO_JUMP > 1 and self.DO_JUMP <= 50 and self.yspeed < 0 then
		self.yspeed = self.yspeed - 4
	end

	-- additionnal frames of hang time at the top of a high jump
	if not on_the_ground and self.DO_JUMP > 1 and math.abs(self.yspeed) <= 20 then
		self.y = self.y - dt * self.yspeed
	end

	-- throwing
	if JOY_A and self.hit == 0 then
		self.DO_THROW = self.DO_THROW + 1
	else
		self.DO_THROW = 0
	end

	if self.DO_THROW == 1 and self.throw == 0 then
		lutro.audio.play(sfx_throw)
		self.throw = 15
		table.insert(entities, newShuriken())
	end

	-- sword swinging
	if JOY_Y and self.hit == 0 then
		self.DO_SWORD = self.DO_SWORD + 1
	else
		self.DO_SWORD = 0
	end

	if self.DO_SWORD == 1 and self.sword == 0 then
		lutro.audio.play(sfx_throw)
		self.sword = 15
		sword = newSword(self)
		table.insert(entities, sword)
	end

	-- moving
	if JOY_LEFT and self.hit == 0 and self.sword == 0 and not JOY_DOWN then
		self.xspeed = self.xspeed - self.xaccel * dt;
		self.xspeed = math.max(self.xspeed, -self.max_xspeed)
		self.direction = "left";
	end

	if JOY_RIGHT and self.hit == 0 and self.sword == 0 and not JOY_DOWN then
		self.xspeed = self.xspeed + self.xaccel * dt;
		self.xspeed = math.min(self.xspeed, self.max_xspeed)
		self.direction = "right";
	end

	-- apply speed
	self.x = self.x + self.xspeed * dt;

	-- decelerating
	self.friction = on_the_ground and self.groundfriction or self.airfriction

	if  not JOY_RIGHT and not JOY_LEFT
	then
		if self.xspeed > 0 then
			self.xspeed = self.xspeed - self.friction
			if self.xspeed < 0 then
				self.xspeed = 0;
			end
		elseif self.xspeed < 0 then
			self.xspeed = self.xspeed + self.friction;
			if self.xspeed > 0 then
				self.xspeed = 0;
			end
		end
	end

	-- animations
	if on_the_ground then
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

	if on_the_ground and JOY_DOWN then
		self.xspeed = 0
		self.stance = "duck"
	end

	if self.throw > 0 then
		self.stance = "throw"
	end

	if self.sword > 0 then
		self.stance = "sword"
	end

	if self.hit > 0 then
		self.stance = "hit"
	end

	if self.stance == "duck" then
		if self.yoffset == 0 then
			self.y = self.y + 16
		end
		self.yoffset = 16
		self.height = 16
	else
		self.yoffset = 0
		self.height = 32
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
	self.anim:draw(self.x - 16, self.y - 16 - self.yoffset)
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

	elseif (e2.type == "obake" or e2.type == "porc" or e2.type == "demon")
	and self.hit == 0 and e2.die == 0 then

		lutro.audio.play(sfx_hit)
		screen_shake = 15
		self.hit = 60
		if dx > 0 then
			self.xspeed = 200
		else
			self.xspeed = -200
		end
		self.y = self.y - 1
		self.yspeed = -1
		hp = hp - 1

	elseif (e2.type == "fireball")
	and self.hit == 0 and e2.die == 0 then

		lutro.audio.play(sfx_hit)
		screen_shake = 15
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

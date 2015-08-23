require "collisions"

local ninja = {}
ninja.__index = ninja

function newNinja()
	local n = {}
	n.width = 16
	n.height = 32
	n.xspeed = 0
	n.yspeed = 0
	n.xaccel = 200
	n.yaccel = 1000
	n.x = (SCREEN_WIDTH - n.width) / 2
	n.y = (SCREEN_HEIGHT - n.height) / 2
	n.direction = "left"
	n.stance = "fall"
	n.DO_JUMP = 0

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
	}

	n.anim = n.animations[n.stance][n.direction]
	n.sfx = {
		jump = lutro.audio.newSource("assets/jump.wav"),
		step = lutro.audio.newSource("assets/step.wav")
	}
	return setmetatable(n, ninja)
end

function ninja:on_the_ground()
	return solid_at(self.x + 1, self.y + 32, self)
		or solid_at(self.x + 15, self.y + 32, self)
end

function ninja:update(dt)
	local JOY_LEFT  = lutro.input.joypad("left")
	local JOY_RIGHT = lutro.input.joypad("right")
	local JOY_A     = lutro.input.joypad("a")

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

	if self.DO_JUMP == 1 and self:on_the_ground() then
		self.y = self.y - 1
		self.yspeed = -300
		lutro.audio.play(self.sfx.jump)
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

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame 
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim;

	self.anim:update(dt)

	-- camera
	camera_x = - self.x + SCREEN_WIDTH/2 - self.width/2;
	if camera_x > 0 then
		camera_x = 0
	end
	if camera_x < -(map.width * map.tilewidth) + SCREEN_WIDTH then
		camera_x = -(map.width * map.tilewidth) + SCREEN_WIDTH
	end
end

function ninja:draw()
	self.anim:draw(self.x - 16, self.y - 16)
end

function ninja:on_collide(e1, e2, dx, dy)
	if math.abs(dy) < math.abs(dx) and dy ~= 0 then
		self.yspeed = 0
		self.y = self.y + dy
		lutro.audio.play(self.sfx.step)
	end

	if math.abs(dx) < math.abs(dy) and dx ~= 0 then
		self.xspeed = 0
		self.x = self.x + dx
	end
end

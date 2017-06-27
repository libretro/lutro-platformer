require "collisions"

local porc = {}
porc.__index = porc

function newPorc(object)
	local n = object
	n.width = 32
	n.height = 32
	n.xspeed = 0
	n.yspeed = 0
	n.yaccel = 0.05
	n.direction = "left"
	n.stance = "run"
	n.DO_JUMP = 0
	n.hit = 0
	n.die = 0
	n.hp = 3
	n.c = 0
	n.GOLEFT = false

	n.animations = {
		run = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/porc_run_left.png"),  32, 32, 2, 20),
			right = newAnimation(lutro.graphics.newImage(
				"assets/porc_run_right.png"), 32, 32, 2, 20)
		},
		hit = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/porc_hit_left.png"),  32, 32, 1, 60),
			right = newAnimation(lutro.graphics.newImage(
				"assets/porc_hit_right.png"), 32, 32, 1, 60)
		},
		die = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/porc_hit_left.png"),  32, 32, 1, 60),
			right = newAnimation(lutro.graphics.newImage(
				"assets/porc_hit_right.png"), 32, 32, 1, 60)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	return setmetatable(n, porc)
end

function porc:on_the_ground()
	return solid_at(self.x + 0, self.y+32, self)
		or solid_at(self.x + 32, self.y+32, self)
end

function porc:update(dt)
	self.c = self.c + 1
	if self.c % 100 == 0 and math.abs(self.x - ninja.x) < 160 then
		lutro.audio.play(sfx_porc)
	end

	if self.hit > 0 then
		self.hit = self.hit - 1
	end

	if self.die > 0 then
		self.die = self.die - 1
	end

	if self.die == 0 and self.hp == 0 then
		-- lutro.audio.play(sfx_explode)
		-- table.insert(entities, newBattery(
		-- 		{x = self.x + self.width/2, y = self.y + self.height / 2}))
		-- for i=1,32 do
		-- 	table.insert(entities, newPart(
		-- 		{x = self.x + self.width/2, y = self.y + self.height / 2}))
		-- end
		entities_remove(self)

	end

	-- gravity
	if not self:on_the_ground() then
		self.yspeed = self.yspeed + self.yaccel
		self.y = self.y + self.yspeed
	end

	if not solid_at(self.x     , self.y+32, self) and self.GOLEFT 
	or not solid_at(self.x + 32, self.y+32, self) and not self.GOLEFT 
	then
		self.GOLEFT = not self.GOLEFT
	end

	-- moving
	if self.GOLEFT and self.hit == 0 and self.die == 0 then
		self.xspeed = -0.85
		self.direction = "left"
	elseif self.hit == 0 and self.die == 0 then
		self.xspeed = 0.85
		self.direction = "right"
	end

	if self.hit > 0 then
		if self.xspeed > 0 then
			self.xspeed = self.xspeed - 0.05
			if self.xspeed < 0 then
				self.xspeed = 0
			end
		elseif self.xspeed < 0 then
			self.xspeed = self.xspeed + 0.05;
			if self.xspeed > 0 then
				self.xspeed = 0
			end
		end
	end

	-- apply speed
	self.x = self.x + self.xspeed;

	if self.die > 0 then
		self.stance = "die"
	elseif self.hit > 0 then
		self.stance = "hit"
	else
		self.stance = "run"
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame 
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim

	self.anim:update(1/60)
end

function porc:draw()
	self.anim:draw(self.x, self.y)
end

function porc:on_collide(e1, e2, dx, dy)
	if e2.type == "ground"
	then
		if math.abs(dy) < math.abs(dx) and dy ~= 0 then
			self.yspeed = 0
			self.y = self.y + dy
			--lutro.audio.play(sfx_step)
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx
			self.GOLEFT = not self.GOLEFT
		end
	elseif e2.type == "ninja" then
		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.GOLEFT = not self.GOLEFT
		end
	elseif e2.type == "shuriken" and (self.hit == 0 or self.hit < 20) and self.die == 0 then
		entities_remove(e2)
		self.hp = self.hp - 1
		if self.hp <= 0 then 
			lutro.audio.play(sfx_porcdie)
			self.die = 60
			self.xspeed = 0
		else
			lutro.audio.play(sfx_porchit)
			self.hit = 60
			if dx > 0 then
				self.xspeed = 2
			else
				self.xspeed = -2
			end
		end
	end
end

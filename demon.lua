require "collisions"

local demon = {}
demon.__index = demon

function newDemon(object)
	local n = object
	n.width = 14
	n.height = 32
	n.speed = 1
	n.xspeed = 0
	n.yspeed = 0
	n.yaccel = 0.05
	n.direction = "left"
	n.stance = "run"
	n.DO_JUMP = 0
	n.hit = 0
	n.die = 0
	n.hp = 2
	n.GOLEFT = false
	n.spit = 0
	n.nospit = 0
	n.t = 0

	n.animations = {
		run = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/demon_run_left.png"),  32, 32, 2, 20),
			right = newAnimation(lutro.graphics.newImage(
				"assets/demon_run_right.png"), 32, 32, 2, 20)
		},
		hit = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/demon_hit_left.png"),  32, 32, 1, 60),
			right = newAnimation(lutro.graphics.newImage(
				"assets/demon_hit_right.png"), 32, 32, 1, 60)
		},
		die = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/demon_hit_left.png"),  32, 32, 1, 60),
			right = newAnimation(lutro.graphics.newImage(
				"assets/demon_hit_right.png"), 32, 32, 1, 60)
		},
		spit = {
			left  = newAnimation(lutro.graphics.newImage(
				"assets/demon_spit_left.png"),  32, 32, 15, 30),
			right = newAnimation(lutro.graphics.newImage(
				"assets/demon_spit_right.png"), 32, 32, 15, 30)
		},
	}

	n.anim = n.animations[n.stance][n.direction]

	n.dotanim = newAnimation(lutro.graphics.newImage(
		"assets/dot.png"), 3, 3, 1, 30)

	return setmetatable(n, demon)
end

function demon:on_the_ground()
	return solid_at(self.x + 1, self.y + self.height, self)
		or solid_at(self.x + self.width - 1, self.y + self.height, self)
end

function demon:update(dt)
	self.t = self.t + 1

	if self.hit > 0 then
		self.hit = self.hit - 1
		self.spit = 0
	end

	if self.die > 0 then
		self.die = self.die - 1
	end

	if self.die == 0 and self.hp == 0 then
		entities_remove(self)
	end

	if self.spit > 0 then
		self.spit = self.spit - 1
	end

	if self.nospit > 0 then
		self.nospit = self.nospit - 1
	end

	if self.spit == 30 then
		table.insert(entities, newFireball(self))
		lutro.audio.play(sfx_fireballspit)
	end

	if self.spit == 1 then
		self.speed = 1
		self.nospit = 80
	end

	-- gravity
	if not self:on_the_ground() then
		self.yspeed = self.yspeed + self.yaccel
		self.y = self.y + self.yspeed
	end

	if not solid_at(self.x             , self.y + self.height+14, self) and self.GOLEFT 
	or not solid_at(self.x + self.width, self.y + self.height+14, self) and not self.GOLEFT 
	then
		self.GOLEFT = not self.GOLEFT
	end

	-- spitting fire
	if math.abs(self.x - ninja.x) < 128
	and self.spit == 0 and self.nospit == 0 and self.hit == 0 and self.die == 0 and self.hp > 0
	and ((self.direction == "left"  and ninja.x < self.x)
	or   (self.direction == "right" and ninja.x > self.x))
	then
		self.spit = 60
		lutro.audio.play(sfx_airgather)
		self.xspeed = 0
	end 

	-- moving
	if self.GOLEFT and self.hit == 0 and self.die == 0 and self.spit == 0 then
		self.xspeed = -self.speed
		self.direction = "left"
	elseif self.hit == 0 and self.die == 0 and self.spit == 0 then
		self.xspeed = self.speed
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
	elseif self.spit > 0 then
		self.stance = "spit"
	else
		self.stance = "run"
	end

	local anim = self.animations[self.stance][self.direction]
	-- always animate from first frame 
	if anim ~= self.anim then
		anim.timer = 0
	end
	self.anim = anim

	self.anim:update(dt)
	self.dotanim:update(dt)
end

function demon:draw()
	self.anim:draw(self.x - 9, self.y)

	local ox = 10
	if self.direction == "left" then
		ox = 0
	end

	if self.spit > 30 and self.spit < 60 then
		for i=1,8 do
			local r = math.max(0, self.spit*2 - 60)
			local x = math.cos(self.t+i)*r
			local y = math.sin(self.t+i)*r
			self.dotanim:draw(self.x + ox + x, self.y + 12 + y)
		end
	end
end

function demon:on_collide(e1, e2, dx, dy)
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
	elseif e2.type == "slopeleft" and self.DO_JUMP == 0 then
		self.yspeed = 0
		self.y = e2.y - self.height + e2.height -((self.x + self.width - e2.x) / (e2.width / e2.height))
		if self.x + self.width >= e2.x + e2.width then
			self.y = e2.y - self.height
		end
		if self.x + self.width < e2.x + 4 then
			self.y = e2.y + e2.height - self.height
		end

	elseif e2.type == "sloperight" and self.DO_JUMP == 0 then
		self.yspeed = 0
		self.y = e2.y - self.height +((self.x + 0 - e2.x) / (e2.width / e2.height))
		if self.x <= e2.x then
			self.y = e2.y - self.height
		end
		if self.x > e2.x + e2.width then
			self.y = e2.y + e2.height - self.height
		end

	elseif e2.type == "ninja" then
		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = 0
			self.GOLEFT = not self.GOLEFT
		end
	elseif e2.type == "shuriken" and self.hit == 0 and self.die == 0 then
		entities_remove(e2)
		self.hp = self.hp - 1
		if self.hp <= 0 then
			lutro.audio.play(sfx_enemydie)
			--lutro.audio.play(sfx_demondie)
			self.die = 60
			self.xspeed = 0
		else
			lutro.audio.play(sfx_enemyhit)
			--lutro.audio.play(sfx_demonhit)
			self.hit = 60
			if dx > 0 then
				self.xspeed = 2
			else
				self.xspeed = -2
			end
		end
	elseif e2.type == "sword" and e2.anim.id >= 4 and e2.anim.id <= 5 and self.hit == 0 and self.die == 0 then

		if dx ~= 0 then
			self.xspeed = 0
			self.x = self.x + dx
		end

		self.hp = self.hp - 2
		screen_shake = 15
		if self.hp <= 0 then
			self.hp = 0
			lutro.audio.play(sfx_enemydie)
			--lutro.audio.play(sfx_demondie)
			self.die = 60
			self.xspeed = 0
		else
			lutro.audio.play(sfx_enemyhit)
			--lutro.audio.play(sfx_demonhit)
			self.hit = 60
			if dx > 0 then
				self.xspeed = 2
			else
				self.xspeed = -2
			end
		end
	end
end

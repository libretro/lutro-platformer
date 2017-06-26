require "collisions"

local elevator = {}
elevator.__index = elevator

function newElevator(object)
	local n = object
	n.speed = 1

	n.anim = newAnimation(lutro.graphics.newImage(
				"assets/elevator.png"), 48, 8, 1, 10)
	return setmetatable(n, elevator)
end

function elevator:update(dt)
	self.anim:update(dt)
	self.y = self.y + self.speed

	local elev = solid_at(ninja.x + ninja.width/2, ninja.y + ninja.height + self.height/2)
	if elev and elev == self then
		ninja.y = ninja.y + self.speed
	end
end

function elevator:draw()
	self.anim:draw(self.x, self.y)
end

function elevator:on_collide(e1, e2, dx, dy)
	if e2.type == "ground" or e2.type == "stopper" then

		if math.abs(dy) < math.abs(dx) and dy ~= 0 then
			self.speed = -self.speed
			self.y = self.y + dy
		end

	end
end

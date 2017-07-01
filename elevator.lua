require "collisions"

local elevator = {}
elevator.__index = elevator

function newElevator(object)
	local n = object
	n.type = "elevator"
	if object.properties.yspeed then
		n.yspeed = object.properties.yspeed
	else
		n.yspeed = 0
	end
	if object.properties.xspeed then
		n.xspeed = object.properties.xspeed
	else
		n.xspeed = 0
	end

	n.anim = newAnimation(lutro.graphics.newImage(
				"assets/elevator.png"), 48, 8, 1, 10)
	return setmetatable(n, elevator)
end

function elevator:update(dt)
	self.anim:update(dt)
	self.x = self.x + self.xspeed
	self.y = self.y + self.yspeed

	local elev = solid_at(ninja.x + ninja.width/2, ninja.y + ninja.height + self.height/2)
	if elev and elev == self then
		ninja.x = ninja.x + self.xspeed
		ninja.y = ninja.y + self.yspeed
	end
end

function elevator:draw()
	self.anim:draw(self.x, self.y)
end

function elevator:on_collide(e1, e2, dx, dy)
	if e2.type == "ground" or e2.type == "stopper" or e2.type == "elevator" then

		if math.abs(dy) < math.abs(dx) and dy ~= 0 then
			self.yspeed = -self.yspeed
			self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			self.xspeed = -self.xspeed
			self.x = self.x + dx
		end

	end
end

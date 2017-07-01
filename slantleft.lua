require "collisions"

local slantleft = {}
slantleft.__index = slantleft

function newSlantleft(object)
	local n = object

	return setmetatable(n, slantleft)
end

function slantleft:update(dt)

end

function slantleft:draw()
end

function slantleft:on_collide(e1, e2, dx, dy)
	if e2.type == "ninja" then

		if math.abs(dy) < math.abs(dx) and dy ~= 0 then
			--self.yspeed = -self.yspeed
			--self.y = self.y + dy
		end

		if math.abs(dx) < math.abs(dy) and dx ~= 0 then
			--self.xspeed = -self.xspeed
			--self.x = self.x + dx
		end

	end
end

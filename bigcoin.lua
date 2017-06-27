require "collisions"

local bigcoin = {}
bigcoin.__index = bigcoin

function newBigcoin(object)
	local n = object
	n.t = 0

	n.anim = newAnimation(lutro.graphics.newImage(
				"assets/bigcoin.png"), 32, 32, 1, 10)
	return setmetatable(n, bigcoin)
end

function bigcoin:update(dt)
	self.t = self.t + dt
	self.y = self.y + math.cos(self.t*2.0)/6.0
	self.anim:update(dt)
end

function bigcoin:draw()
	self.anim:draw(self.x, self.y)
end

function bigcoin:on_collide(e1, e2, dx, dy)
	if e2.type == "ninja" then
		lutro.audio.play(sfx_coin)
		entities_remove(self)
		gold = gold + 10
	end
end

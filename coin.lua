require "collisions"

local coin = {}
coin.__index = coin

function newCoin(object)
	local n = object

	n.anim = newAnimation(lutro.graphics.newImage(
				"assets/coin.png"), 16, 16, 1, 10)
	return setmetatable(n, coin)
end

function coin:update(dt)
	self.anim:update(dt)
end

function coin:draw()
	self.anim:draw(self.x, self.y)
end

function coin:on_collide(e1, e2, dx, dy)
	if e2.type == "ninja" then
		lutro.audio.play(sfx_coin)
		for i=1, #entities do
			if entities[i] == self then
				table.remove(entities, i)
			end
		end
	end
end

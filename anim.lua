local animation = {}
animation.__index = animation

function newAnimation(image, width, height, period, speed)
	local a = {}
	a.image = image
	a.timer = 0
	a.width = width
	a.height = height
	a.playing = true
	a.speed = speed
	a.period = period
	a.steps = a.image:getWidth() / a.width
	return setmetatable(a, animation)
end

function animation:update(dt)
	if not self.playing then return end

	self.timer = self.timer + dt * self.speed

	if self.timer > self.steps * self.period then
		self.timer = 0
	end
end

function animation:draw(x, y)
	local id = math.floor(self.timer / self.period + 1)
	local tw = self.width
	local th = self.height
	local sw = self.image:getWidth()
	local sh = self.image:getHeight()

	local q = lutro.graphics.newQuad(
		((id-1)%(sw/tw))*tw,
		math.floor((id-1)/(sw/tw))*tw,
		tw, th,
		sw, sh)

	lutro.graphics.draw(
		self.image,
		q,
		x, y
	)
end

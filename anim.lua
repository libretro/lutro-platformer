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
	a.steps = a.image.width / a.width
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
	lutro.graphics.drawq(
		x, y,
		self.width, self.height,
		self.image.width, self.image.height,
		self.image.data,
		self.timer / self.period + 1
	)
end

require "global"
require "tiled"
require "anim"
require "ninja"
require "obake"
require "coin"
require "bigcoin"
require "porc"
require "demon"
require "elevator"
require "shuriken"
require "fireball"
require "sword"

function lutro.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

local add_entity_from_map = function(object)
	if object.type == "ground" then
		table.insert(entities, object)
	elseif object.type == "slopeleft" then
		table.insert(entities, object)
	elseif object.type == "sloperight" then
		table.insert(entities, object)
	elseif object.type == "bridge" then
		table.insert(entities, object)
	elseif object.type == "stopper" then
		table.insert(entities, object)
	elseif object.type == "elevator" then
		table.insert(entities, newElevator(object))
	elseif object.type == "spikes" then
		table.insert(entities, object)
	elseif object.type == "coin" then
		table.insert(entities, newCoin(object))
	elseif object.type == "bigcoin" then
		table.insert(entities, newBigcoin(object))
	elseif object.type == "porc" then
		table.insert(entities, newPorc(object))
	elseif object.type == "demon" then
		table.insert(entities, newDemon(object))
	elseif object.type == "obake" then
		table.insert(entities, newObake(object))
	elseif object.type == "ninja" then
		ninja = newNinja(object)
		table.insert(entities, ninja)
	end
end

function entities_remove(entity)
	for i=1, #entities do
		if entities[i] == entity then
			table.remove(entities, i)
		end
	end
end

function lutro.load()
	camera_x = 0
	camera_y = 0
	camera_x_offset = 0
	camera_y_offset = 0
	gold = 0
	hp = 3
	screen_shake = 0

	lutro.graphics.setBackgroundColor(0, 0, 0)

	bg0 = lutro.graphics.newImage("assets/forestbackground0.png")
	bg1 = lutro.graphics.newImage("assets/forestbackground1.png")
	bg2 = lutro.graphics.newImage("assets/forestbackground2.png")

	barfont = lutro.graphics.newImageFont("assets/barfont.png", "0123456789 xGHh")
	lutro.graphics.setFont(barfont)

	map = tiled_load("assets/slopes.json")
	tiled_load_objects(map, add_entity_from_map)

	sfx_coin = lutro.audio.newSource("assets/coin.wav", "static")
	sfx_jump = lutro.audio.newSource("assets/jump.wav", "static")
	sfx_step = lutro.audio.newSource("assets/step.wav", "static")
	sfx_hit = lutro.audio.newSource("assets/hit.wav", "static")
	sfx_porc = lutro.audio.newSource("assets/porc.wav", "static")
	sfx_dead = lutro.audio.newSource("assets/dead.wav", "static")
	sfx_throw = lutro.audio.newSource("assets/throw.wav", "static")
	sfx_gameover = lutro.audio.newSource("assets/gameover.wav", "static")
	sfx_enemyhit = lutro.audio.newSource("assets/enemyhit.wav", "static")
	sfx_enemydie = lutro.audio.newSource("assets/enemydie.wav", "static")
	sfx_porchit = lutro.audio.newSource("assets/porchit.wav", "static")
	sfx_porcdie = lutro.audio.newSource("assets/porcdie.wav", "static")
	sfx_shurikencollide = lutro.audio.newSource("assets/shurikencollide.wav", "static")
	sfx_fireballspit = lutro.audio.newSource("assets/fireballspit.wav", "static")
	sfx_fireballcollide = lutro.audio.newSource("assets/fireballcollide.wav", "static")
	sfx_airgather = lutro.audio.newSource("assets/airgather.wav", "static")
end

RETRO_DEVICE_ID_JOYPAD_B        = 1
RETRO_DEVICE_ID_JOYPAD_Y        = 2
RETRO_DEVICE_ID_JOYPAD_SELECT   = 3
RETRO_DEVICE_ID_JOYPAD_START    = 4
RETRO_DEVICE_ID_JOYPAD_UP       = 5
RETRO_DEVICE_ID_JOYPAD_DOWN     = 6
RETRO_DEVICE_ID_JOYPAD_LEFT     = 7
RETRO_DEVICE_ID_JOYPAD_RIGHT    = 8
RETRO_DEVICE_ID_JOYPAD_A        = 9
RETRO_DEVICE_ID_JOYPAD_X        = 10
RETRO_DEVICE_ID_JOYPAD_L        = 11
RETRO_DEVICE_ID_JOYPAD_R        = 12
RETRO_DEVICE_ID_JOYPAD_L2       = 13
RETRO_DEVICE_ID_JOYPAD_R2       = 14
RETRO_DEVICE_ID_JOYPAD_L3       = 15
RETRO_DEVICE_ID_JOYPAD_R3       = 16

function lutro.update(dt)
	JOY_LEFT  = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_LEFT)
	JOY_RIGHT = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_RIGHT)
	JOY_DOWN  = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_DOWN)
	JOY_A     = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_A)
	JOY_B     = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_B)
	JOY_X     = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_X)
	JOY_Y     = lutro.joystick.isDown(1, RETRO_DEVICE_ID_JOYPAD_Y)

	if screen_shake > 0 then
		screen_shake = screen_shake - 1
	end

	if hp > 0 then
		--if screen_shake == 0 then
			for i=1, #entities do
				if entities[i] and entities[i].update then
					entities[i]:update(dt)
				end
			end
		--end
	else
		ninja:update(dt)
	end

	detect_collisions()

	-- camera
	camera_x = - ninja.x + SCREEN_WIDTH/2 - ninja.width/2;
	if ninja.direction == "right" then
		if JOY_RIGHT and camera_x_offset > -48 then
			camera_x_offset = camera_x_offset - 1
		end
	else
		if JOY_LEFT and camera_x_offset < 48 then
			camera_x_offset = camera_x_offset + 1
		end
	end
	camera_x = camera_x + camera_x_offset
	if camera_x > 0 then
		camera_x = 0
	end
	if camera_x < -(map.width * map.tilewidth) + SCREEN_WIDTH then
		camera_x = -(map.width * map.tilewidth) + SCREEN_WIDTH
	end
end

function lutro.draw()
	-- Shake camera if hit
	local shake_x = 0
	local shake_y = 0
	if screen_shake > 0 then
		shake_x = 5*(math.random()-0.5)
		shake_y = 5*(math.random()-0.5)
	end

	lutro.graphics.clear()

	for i=0, 4 do
		lutro.graphics.draw(bg2, i*bg2:getWidth() + camera_x / 8, 0)
		lutro.graphics.draw(bg1, i*bg1:getWidth() + camera_x / 4, 0)
		lutro.graphics.draw(bg0, i*bg0:getWidth() + camera_x / 2, 0)
	end

	lutro.graphics.push()

	lutro.graphics.translate(camera_x + shake_x, camera_y + shake_y)

	tiled_draw_layer(map.layers[1])
	tiled_draw_layer(map.layers[2])
	for i=1, #entities do
		if entities[i].draw then
			entities[i]:draw(dt)
		end
	end

	lutro.graphics.pop()

	local bar = ""
	for i=1, 3 do
		if i <= hp then
			bar = bar .. "H"
		else
			bar = bar .. "h"
		end
	end
	lutro.graphics.print(bar, 3, 2)
	lutro.graphics.printf(gold .. "xG", -1, 2, SCREEN_WIDTH, "right")
end

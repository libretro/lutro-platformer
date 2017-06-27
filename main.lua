require "global"
require "tiled"
require "anim"
require "ninja"
require "obake"
require "coin"
require "bigcoin"
require "porc"
require "elevator"
require "shuriken"

function lutro.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

local add_entity_from_map = function(object)
	if object.type == "ground" then
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
	lutro.graphics.setBackgroundColor(0, 0, 0)
	bg1 = lutro.graphics.newImage("assets/forestbackground.png")
	bg2 = lutro.graphics.newImage("assets/foresttrees.png")
	--font = lutro.graphics.newImageFont("assets/font.png",
	--	" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/")
	barfont = lutro.graphics.newImageFont("assets/barfont.png",
		"0123456789 xGHh")
	lutro.graphics.setFont(barfont)
	map = tiled_load("assets/level1.json")
	tiled_load_objects(map, add_entity_from_map)

	sfx_coin = lutro.audio.newSource("assets/coin.wav")
	sfx_jump = lutro.audio.newSource("assets/jump.wav")
	sfx_step = lutro.audio.newSource("assets/step.wav")
	sfx_hit = lutro.audio.newSource("assets/hit.wav")
	sfx_porc = lutro.audio.newSource("assets/porc.wav")
	sfx_dead = lutro.audio.newSource("assets/dead.wav")
	sfx_throw = lutro.audio.newSource("assets/throw.wav")
	sfx_gameover = lutro.audio.newSource("assets/gameover.wav")
	sfx_enemyhit = lutro.audio.newSource("assets/enemyhit.wav")
	sfx_enemydie = lutro.audio.newSource("assets/enemydie.wav")
	sfx_porchit = lutro.audio.newSource("assets/porchit.wav")
	sfx_porcdie = lutro.audio.newSource("assets/porcdie.wav")
	sfx_shurikencollide = lutro.audio.newSource("assets/shurikencollide.wav")
end

function lutro.update(dt)

	JOY_LEFT  = lutro.input.joypad("left")
	JOY_RIGHT = lutro.input.joypad("right")
	JOY_DOWN  = lutro.input.joypad("down")
	JOY_A     = lutro.input.joypad("a")
	JOY_B     = lutro.input.joypad("b")

	if hp > 0 then
		for i=1, #entities do
			if entities[i] and entities[i].update then
				entities[i]:update(dt)
			end
		end
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
	lutro.graphics.clear()

	for i=0, 4 do
		lutro.graphics.draw(bg1, i*bg1:getWidth() + camera_x / 6, 0)
		--lutro.graphics.draw(bg2, i*bg2:getWidth() + camera_x / 3, 0)
	end

	lutro.graphics.push()

	lutro.graphics.translate(camera_x, camera_y)

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

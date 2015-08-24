require "global"
require "tiled"
require "anim"
require "ninja"

function lutro.conf(t)
	t.width  = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

local add_entity_from_map = function(object)
	if object.type == "ground" then
		table.insert(entities, object)
	end
end

function lutro.load()
	camera_x = 0
	camera_y = 0
	lutro.graphics.setBackgroundColor(0, 0, 0)
	bg1 = lutro.graphics.newImage("assets/forestbackground.png")
	bg2 = lutro.graphics.newImage("assets/foresttrees.png")
	font = lutro.graphics.newImageFont("assets/font.png",
		" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/")
	lutro.graphics.setFont(font)
	map = tiled_load("assets/pagode.json")
	tiled_load_objects(map, add_entity_from_map)
	table.insert(entities, newNinja())
end

function lutro.update(dt)
	for i=1, #entities do
		if entities[i].update then
			entities[i]:update(dt)
		end
	end
	detect_collisions()
end

function lutro.draw()
	lutro.graphics.clear()

	for i=0, 4 do
		lutro.graphics.draw(bg1, i*bg1:getWidth() + camera_x / 6, 0)
		lutro.graphics.draw(bg2, i*bg2:getWidth() + camera_x / 3, 0)
	end

	lutro.graphics.push()

	lutro.graphics.translate(camera_x, camera_y)

	tiled_draw_layer(map.layers[1])
	for i=1, #entities do
		if entities[i].draw then
			entities[i]:draw(dt)
		end
	end
	tiled_draw_layer(map.layers[2])

	lutro.graphics.pop()

	lutro.graphics.print("Hello world!", 3, 1)
end

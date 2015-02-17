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
	bg1 = lutro.graphics.newImage(lutro.path .. "assets/forestbackground.png")
	bg2 = lutro.graphics.newImage(lutro.path .. "assets/foresttrees.png")
	map = tiled_load(lutro.path .. "assets/pagode.json")
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
	lutro.graphics.clear(0xff000000)

	for i=0, 1 do
		lutro.graphics.draw(bg1.data,
				i*bg1.width + lutro.camera_x/6, 0, bg1.width, bg1.height)
		lutro.graphics.draw(bg2.data,
				i*bg2.width + lutro.camera_x/3, 0, bg2.width, bg2.height)
	end

	tiled_draw_layer(map.layers[1])
	for i=1, #entities do
		if entities[i].draw then
			entities[i]:draw(dt)
		end
	end
	tiled_draw_layer(map.layers[2])
end

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
	tiled_draw_layer(map.layers[1])
	for i=1, #entities do
		if entities[i].draw then
			entities[i]:draw(dt)
		end
	end
	tiled_draw_layer(map.layers[2])
end

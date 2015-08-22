local json = require("dkjson")

function tiled_load(filename)
	local str = lutro.filesystem.read(filename)
	local map, pos, err = json.decode(str, 1, nil)

	for i = 1, #map.tilesets do
		local tileset = map.tilesets[i]
		tileset.surface = lutro.graphics.newImage("assets/" .. tileset.image)
	end

    return map
end

function tiled_get_tileset(map, id)
	local t
	for k = 1, #map.tilesets do
		local tileset = map.tilesets[k]
		if (id >= tileset.firstgid) then
			t = tileset
		end
	end
	return t
end

function tiled_draw_layer(layer)
	local data = layer.data
	for j = 1, #data do
		local id = data[j]
		if (id > 0) then
			local y = math.floor((j-1) / layer.width) * map.tileheight
			local x = ((j-1) % layer.width) * map.tilewidth
			local t = tiled_get_tileset(map, id)
			local tw = map.tilewidth
			local th = map.tileheight
			local sw = t.surface:getWidth()
			local sh = t.surface:getHeight()
			local tid = id - t.firstgid+1

			local q = lutro.graphics.newQuad(
				((tid-1)%(sw/tw))*tw,
				math.floor((tid-1)/(sw/tw))*tw,
				tw, th,
				sw, sh)

			lutro.graphics.draw(t.surface, q, x, y)
		end
	end
end

function tiled_draw(map)
	for i = 1, #map.layers do
		local layer = map.layers[i]
		if (layer.type == "tilelayer") then
			tiled_draw_layer(layer)
		end
	end
end

function tiled_load_objectgroup(layer, callback)
	for i = 1, #layer.objects do
		local object = layer.objects[i]
		callback(object)
	end
end

function tiled_load_objects(map, callback)
	for i = 1, #map.layers do
		local layer = map.layers[i]
		if (layer.type == "objectgroup") then
			tiled_load_objectgroup(layer, callback)
		end
	end
end
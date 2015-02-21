local json = require("dkjson")

function tiled_load(filename)
	local f = assert(io.open(filename, "r"))
    local str = f:read("*all")
    f:close()
    local map, pos, err = json.decode(str, 1, nil)

	for i = 1, #map.tilesets do
		local tileset = map.tilesets[i]
		local path = lutro.path .. "assets/" .. tileset.image
		tileset.surface = lutro.graphics.newImage(path)
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
		local y = math.floor((j-1) / layer.width) * map.tileheight
		local x = ((j-1) % layer.width) * map.tilewidth
		local t = tiled_get_tileset(map, id)

		if (id > 0) then
			lutro.graphics.drawq(t.surface, x, y,
				map.tilewidth, map.tileheight,
				id - t.firstgid+1)
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
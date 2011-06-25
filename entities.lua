--[[ ENTITY MANAGEMENT ]]--
local layers
local remove = {}
function remove_objects()
	for _,t in ipairs(remove) do
		if t.layer then -- shortcut
			layers[t.layer][t.obj] = nil
		end
		-- search for object
		for _,layer in ipairs(layers) do
			if layer[t.obj] then
				layer[t.obj] = nil
			end
		end
	end
	remove = {}
end

Entities = setmetatable({}, {__index = function(_, func)
	return function(...)
		remove_objects()
		for _, layer in ipairs(layers) do
			for o,_ in pairs(layer) do
				(o[func] or _NULL_)(o, ...)
			end
		end
	end
end})

function Entities.clear()
	layers = setmetatable({}, {__index = function(self, idx)
		for i = #self+1, idx do
			local t = {}
			rawset(self, i, t)
		end
		return rawget(self, idx)
	end})
end
Entities.clear()

Entities.BG  = 1
Entities.MID = 5
Entities.FG  = 10

function Entities.add(obj, layer)
	layers[layer or Entities.MID][obj] = obj
end

function Entities.remove(obj, layer)
	remove[#remove+1] = {obj = obj, layer = layer}
end

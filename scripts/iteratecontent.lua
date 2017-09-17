local stringy = require 'stringy'
local lfs = require 'lfs'
local queue = {}

function scan(path, fpath)
	for filename in lfs.dir(path) do
		if (filename ~= "." and filename ~= "..") then
			local mode = lfs.attributes(path .. filename, "mode")

			if (mode == "directory") then
				scan(path .. filename .. "/", fpath .. filename .. "\\\\")
			else
				if (filename ~= "readme.html") then
					table.insert(queue, fpath .. filename)
				end
			end
		end
	end
end

function starts_with(string, prefix)
	return string.sub(string, 1, #prefix) == prefix
end

scan("./", "")

table.sort(queue)

for k, v in ipairs(queue) do
	if (not v:lower():find("portrait") and not v:find("readme")) then
		if (starts_with(v, "Buildings")) then
			print(string.format("AddBuilding(\"\", \"\", \"%s\");", v))
		end

		if (starts_with(v, "Units")) then
				print(string.format("AddCustomUnit(\"\", \"\", \"%s\");", v))
		end
	end

end
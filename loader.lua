--[[ DQVape loader.lua — local/developer only (see NewMainScript.lua) ]]

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ""
end

local function rawBase()
	local base = shared.TempHubRawBase
	if type(base) ~= "string" or base == "" then
		return nil
	end
	return (base:gsub("/+$", ""))
end

local function downloadFile(path, func)
	if not isfile(path) then
		local base = rawBase()
		if not base then
			error("[TempHub] missing " .. tostring(path) .. " — sync local files or set shared.TempHubRawBase")
		end
		local rel = select(1, path:gsub("newvape/", ""))
		local suc, res = pcall(function()
			return game:HttpGet(base .. "/" .. rel, true)
		end)
		if not suc or res == "404: Not Found" then
			error(res)
		end
		if path:find(".lua") then
			res = "-- DQVape local cache\n" .. res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

for _, folder in {
	"newvape",
	"newvape/games",
	"newvape/profiles",
	"newvape/assets",
	"newvape/libraries",
	"newvape/guis",
} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

shared.VapeDeveloper = true
if not isfile("newvape/profiles/commit.txt") then
	writefile("newvape/profiles/commit.txt", "local")
end
if not isfile("newvape/profiles/asset.txt") then
	writefile("newvape/profiles/asset.txt", "1")
end

return loadstring(downloadFile("newvape/main.lua"), "main")()

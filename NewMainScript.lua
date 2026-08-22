--[[
  Temp Hub — UI library loader (based on Vape V4 / CC0, rebranded).

  Edit GUI:  guis/new.lua
  Discord:   https://discord.gg/dQg8xY2xdB

  Used by any game script via shared.VapeIndependent = true
  Set shared.TempHubRawBase = "https://raw.githubusercontent.com/YOU/TempHub/main"
]]

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ""
end

local delfile = delfile or function(file)
	writefile(file, "")
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
			error("[TempHub] missing " .. tostring(path) .. " — run tools/sync_dqvape.py or set shared.TempHubRawBase")
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

-- Always developer mode under DQ: never wipe/update from upstream.
shared.VapeDeveloper = true
if not isfile("newvape/profiles/commit.txt") then
	writefile("newvape/profiles/commit.txt", "local")
end
if not isfile("newvape/profiles/asset.txt") then
	writefile("newvape/profiles/asset.txt", "1")
end

return loadstring(downloadFile("newvape/main.lua"), "main")()

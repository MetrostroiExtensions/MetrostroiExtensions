local utils = {preset = {}}

local SCHEMA_PATH = "https://raw.githubusercontent.com/MetrostroiExtensions/MetrostroiExtensions/refs/heads/main/data_static/spawner_schema_v1.json"
local SPAWNER_FOLDER = "metrostroi_extensions/spawner"

function utils.preset.export(settings)
	-- editing same object by link. would it cause problems? it shouldn't :)
	settings["$schema"] = SCHEMA_PATH
	-- pretty print in MEL.Debug
	return util.TableToJSON(settings, MEL.IsDebug())
end

local function readPreset(path)
	settingsJson = file.Read(path)
	if not settingsJson then return end
	return util.JSONToTable(settingsJson)
end

function utils.preset.discover()
	utils.preset.presets = {}
	local foundFiles, _ = file.Find(Format("%s/*.json", SPAWNER_FOLDER), "DATA")
	for _, presetFile in pairs(foundFiles) do
		presetName = string.sub(presetFile, 1, string.find(presetFile, "%.json") - 1)
		local presetTable = readPreset(Format("%s/%s", SPAWNER_FOLDER, presetFile))
		if not utils.preset.presets[presetTable.entityClass] then
			utils.preset.presets[presetTable.entityClass] = {}
		end
		presetTable.fileName = presetFile
		utils.preset.presets[presetTable.entityClass][presetName] = presetTable
	end
end

-- We probably can use cookie library, but why when we already have preset functionality that we can reuse?
function utils.preset.saveLatest(settings)
	local path = Format("%s/latest", SPAWNER_FOLDER)
	file.CreateDir(path)
	settingsJson = utils.preset.export(settings)
	file.Write(Format("%s/%s.json", path, settings.entityClass), settingsJson)
end

function utils.preset.loadLatest(entityClass)
	local path = Format("%s/latest/%s.json", SPAWNER_FOLDER, entityClass)
	return readPreset(path)
end

function utils.preset.saveNew(fileName, settings)
	file.CreateDir(SPAWNER_FOLDER)
	settingsJson = utils.preset.export(settings)
	file.Write(Format("%s/%s.json", SPAWNER_FOLDER, fileName), settingsJson)
end

function utils.preset.delete(fileName)
	result = file.Delete(Format("%s/%s", SPAWNER_FOLDER, fileName))
	print(result, Format("%s/%s", SPAWNER_FOLDER, fileName))
end

function utils.resizeWidth(width)
	-- return ScrW() * width / 1920
	return width
end

function utils.resizeHeight(height)
	-- return ScrH() * height / 1080
	return height
end

function utils.convertToNamedFormat(spawner)
	local convertedSpawner = {}
	for i in ipairs(spawner) do
		convertedSpawner[i] = MEL.Helpers.SpawnerEnsureNamedFormat(spawner[i])
	end
	return convertedSpawner
end

return utils

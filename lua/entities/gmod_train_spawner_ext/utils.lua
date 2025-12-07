local utils = {
	preset = {}
}

local SCHEMA_PATH = "https://raw.githubusercontent.com/MetrostroiExtensions/MetrostroiExtensions/refs/heads/main/data_static/spawner_schema_v1.json"
local SPAWNER_FOLDER = "metrostroi_extensions/spawner"
local CYRILLIC_TO_LATIN = {
	["а"] = "a",
	["б"] = "b",
	["в"] = "v",
	["г"] = "g",
	["д"] = "d",
	["е"] = "e",
	["ё"] = "yo",
	["ж"] = "zh",
	["з"] = "z",
	["и"] = "i",
	["й"] = "y",
	["к"] = "k",
	["л"] = "l",
	["м"] = "m",
	["н"] = "n",
	["о"] = "o",
	["п"] = "p",
	["р"] = "r",
	["с"] = "s",
	["т"] = "t",
	["у"] = "u",
	["ф"] = "f",
	["х"] = "kh",
	["ц"] = "ts",
	["ч"] = "ch",
	["ш"] = "sh",
	["щ"] = "shch",
	["ъ"] = "", -- often omitted
	["ы"] = "y",
	["ь"] = "", -- often omitted
	["э"] = "e",
	["ю"] = "yu",
	["я"] = "ya",
}

local CYRILLIC_UPPER_TO_LOWER = {
	["А"] = "а",
	["Б"] = "б",
	["В"] = "в",
	["Г"] = "г",
	["Д"] = "д",
	["Е"] = "е",
	["Ё"] = "ё",
	["Ж"] = "ж",
	["З"] = "з",
	["И"] = "и",
	["Й"] = "й",
	["К"] = "к",
	["Л"] = "л",
	["М"] = "м",
	["Н"] = "н",
	["О"] = "о",
	["П"] = "п",
	["Р"] = "р",
	["С"] = "с",
	["Т"] = "т",
	["У"] = "у",
	["Ф"] = "ф",
	["Х"] = "х",
	["Ц"] = "ц",
	["Ч"] = "ч",
	["Ш"] = "ш",
	["Щ"] = "щ",
	["Ъ"] = "ъ",
	["Ы"] = "ы",
	["Ь"] = "ь",
	["Э"] = "э",
	["Ю"] = "ю",
	["Я"] = "я",
}

local function _is_latin(symbol)
	local code = string.byte(symbol)
	return (code > 64 and code < 91) or (code > 96 and code < 123)
end

function utils.preset.safe_name(name)
	local safe_name = ""
	for pos, code in utf8.codes(string.lower(name)) do
		local symbol = utf8.char(code)
		local transliterized_cyrillic = CYRILLIC_TO_LATIN[CYRILLIC_UPPER_TO_LOWER[symbol] or symbol]
		-- FIXME: probably not so effictive, cause we create new string on each iteration...
		-- but who cares? this function is called so rarely
		safe_name = safe_name .. (transliterized_cyrillic or (_is_latin(symbol) and symbol) or '_')
	end
	return safe_name
end

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
		if not utils.preset.presets[presetTable.entityClass] then utils.preset.presets[presetTable.entityClass] = {} end
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

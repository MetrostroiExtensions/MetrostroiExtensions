-- Copyright (c) Anatoly Raev, 2024. All right reserved
--
-- Unauthorized copying of any file in this repository, via any medium is strictly prohibited.
-- All rights reserved by the Civil Code of the Russian Federation, Chapter 70.
-- Proprietary and confidential.
-- ------------
-- Авторские права принадлежат Раеву Анатолию Анатольевичу.
--
-- Копирование любого файла, через любой носитель абсолютно запрещено.
-- Все авторские права защищены на основании ГК РФ Глава 70.
-- Автор оставляет за собой право на защиту своих авторских прав согласно законам Российской Федерации.
if SERVER then AddCSLuaFile() end
if not MetrostroiExtensionsLib then MetrostroiExtensionsLib = {} end
MEL = MetrostroiExtensionsLib -- alias. 23 symbols vs 3. and we name it MetrostroiExtensionLib because there is fly's old Metrostroi Extensions.
MEL.Debug = true -- helps with autoreload, but may introduce problems. Disable in production!
MEL.BaseRecipies = {}
MEL.Recipes = {}
MEL.DisabledRecipies = {}
MEL.InjectStack = {}
MEL.ScopedRecipies = false
MEL.RecipeSpecific = {} -- table with things, that can and should be shared between recipies
-- lookup table for train families
MEL.TrainFamilies = {
    -- for 717 we don't need to modify _custom entity, cause it's used just for spawner
    ["717"] = {"gmod_subway_81-717_lvz", "gmod_subway_81-717_mvm",},
    ["717_714"] = {"gmod_subway_81-717_lvz", "gmod_subway_81-717_mvm", "gmod_subway_81-714_lvz", "gmod_subway_81-714_mvm"},
    ["717_714_mvm"] = {"gmod_subway_81-717_mvm", "gmod_subway_81-714_mvm"},
    ["717_714_lvz"] = {"gmod_subway_81-717_lvz", "gmod_subway_81-714_lvz"},
    ["718_719"] = {"gmod_subway_81-718", "gmod_subway_81-719"},
}

MEL.InjectIntoSpawnedEnt = false -- temp global variable
MEL.EntTables = {}
MEL.MetrostroiClasses = {}
MEL.TrainClasses = {}
-- constants
-- TODO: move this to another file
MEL.Constants = {
    Spawner = {
        NAME = 1,
        TRANSLATION = 2,
        TYPE = 3,
        TYPE_LIST = "List",
        TYPE_SLIDER = "Slider",
        TYPE_BOOLEAN = "Boolean",
        List = {
            ELEMENTS = 4,
            DEFAULT_VALUE = 5,
            WAGON_CALLBACK = 6,
            CHANGE_CALLBACK = 7,
        },
        Slider = {
            DECIMALS = 4,
            MIN_VALUE = 5,
            MAX_VALUE = 6,
            DEFAULT = 7,
            WAGON_CALLBACK = 8,
        },
        Boolean = {
            DEFAULT = 4,
            WAGON_CALLBACK = 5,
            CHANGE_CALLBACK = 6,
        }
    },
    LanguageID = {
        Entity = {
            CLASS = 2,
            TYPE = 3,
            PREFIX = "Entities.",
        },
        Spawner = {
            NAME = 4,
            VALUE = 5,
            VALUE_NAME = "Name",
        },
        Buttons = {
            NAME = 4,
            ID = 5,
        },
        Weapons = {
            PREFIX = "Weapons.",
            CLASS = 2,
            TYPE = 3,
        }
    }
}

local LOG_PREFIX = "[MetrostroiExtensionsLib] "
local WARNING_COLOR = Color(255, 255, 0)
local DEBUG_COLOR = Color(255, 0, 191)
local INFO_COLOR = Color(0, 4, 255)
local WHITE = Color(255, 255, 255)
-- logger methods
local function printPrefix()
    if SERVER then
        MsgC(Color(0, 0, 255), "[Metrostroi", Color(0, 255, 0), "ExtensionsLib] ")
    else
        MsgC(Color(72, 120, 164), "[Metrostroi", Color(44, 131, 61), "ExtensionsLib] ")
    end
end

local function logDebug(msg)
    if MEL.Debug then
        printPrefix()
        MsgC(DEBUG_COLOR, "Debug: ", msg, "\n")
    end
end

function MEL._LogInfo(msg)
    printPrefix()
    MsgC(INFO_COLOR, "Info: ", WHITE, msg, "\n")
end

function MEL._LogWarning(msg)
    printPrefix()
    MsgC(WARNING_COLOR, Format("Warning: %s\n", msg))
end

function MEL._LogError(msg)
    if RECIPE then ErrorNoHaltWithStack(Format("%s Error from recipe %s!: %s\n", LOG_PREFIX, RECIPE.ClassName, msg)) end
    ErrorNoHaltWithStack(Format("%s Error!: %s\n", LOG_PREFIX, msg))
end

function MEL.LogErrorFactory()
    return function(msg) MEL._LogError("error from recipe " .. RECIPE.ClassName .. ": " .. msg) end
end

function MEL.LogWarningFactory()
    return function(msg) MEL._LogWarning("warning from recipe " .. RECIPE.ClassName .. ": " .. msg) end
end

function MEL.LogInfoFactory()
    return function(msg) MEL._LogInfo("info from recipe " .. RECIPE.ClassName .. ": " .. msg) end
end

-- helper methods
function MEL.GetEntclass(ent_or_entclass)
    if not ent_or_entclass then
        MEL._LogError("please provide ent_or_entclass in GetEntclass")
        return
    end

    -- get entclass from ent table or from str entclass
    if istable(ent_or_entclass) then return ent_or_entclass.entclass end
    if isentity(ent_or_entclass) then return ent_or_entclass:GetClass() end
    return ent_or_entclass
end

-- load all methods
local methodModules = file.Find("metrostroi/extensions/*.lua", "LUA")
for _, moduleName in pairs(methodModules) do
    if SERVER then
        include("metrostroi/extensions/" .. moduleName)
        AddCSLuaFile("metrostroi/extensions/" .. moduleName)
    else
        include("metrostroi/extensions/" .. moduleName)
    end
end

MEL.ApplyBackports()
function MEL.GetEntsByTrainType(trainType)
    if not trainType then
        MEL._LogError("trainType in GetEntsByTrainType is nil! Check your recipies.")
        return
    end

    -- firstly, check if our train_type is table
    if istable(trainType) then return trainType end
    -- then check if our trainType is all
    if trainType == "all" then return MEL.TrainClasses end
    -- then try to find it as entity class
    if table.HasValue(MEL.MetrostroiClasses, trainType) then return {trainType} end
    -- then try to check it in lookup table
    -- why? just imagine 717: we have 5p, we have some other modifications
    -- and you probably don't want to have a new default 717 cabine in 7175p
    if MEL.TrainFamilies[trainType] then return MEL.TrainFamilies[trainType] end
    -- and finally try to find by searching train family in classname
    local entclasses = {}
    for _, entclass in pairs(MEL.MetrostroiClasses) do
        local containsTrainTypes, _ = string.find(entclass, trainType)
        if containsTrainTypes then table.insert(entclasses, entclass) end
    end

    if #entclasses == 0 then MEL._LogError("no entities for " .. trainType .. ". Perhaps a typo?") end
    return entclasses
end

function MEL.DefineRecipe(name, train_type)
    if istable(train_type) then
        class_name = table.concat(train_type, "-") .. "_" .. name
    else
        class_name = train_type .. "_" .. name
    end

    if not MEL.BaseRecipies[class_name] then MEL.BaseRecipies[class_name] = {} end
    RECIPE = MEL.BaseRecipies[class_name]
    RECIPE.TrainType = train_type
    RECIPE.Name = name
    RECIPE.ClassName = class_name
end

local function findRecipeFiles(folder, recipe_files)
    local found_files, found_folders = file.Find(folder .. "/*", "LUA")
    for _, recipe_file in pairs(found_files) do
        if string.GetExtensionFromFilename(recipe_file) ~= "lua" then continue end
        table.insert(recipe_files, folder .. "/" .. recipe_file)
    end

    if found_folders and #found_folders > 0 then
        for _, found_folder in pairs(found_folders) do
            if found_folder == "disabled" then continue end
            findRecipeFiles(folder .. "/" .. found_folder, recipe_files)
        end
    end
end

local function initRecipe(recipe)
    recipe:Init()
    if not ConVarExists("metrostroi_ext_" .. recipe.ClassName) then
        -- add convar that will be able to disable that recipe on server
        CreateConVar("metrostroi_ext_" .. recipe.ClassName, 1, {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Status of Metrostroi Extensions recipe \"" .. recipe.ClassName .. "\": " .. recipe.Description .. ".", 0, 1)
    end

    if GetConVar("metrostroi_ext_" .. recipe.ClassName):GetBool() then
        -- if recipe enabled:
        -- add it to inject stack
        if recipe.BackportPriority then
            table.insert(MEL.InjectStack, 1, recipe)
        else
            table.insert(MEL.InjectStack, recipe)
        end

        -- add recipe specific things
        for key, value in pairs(recipe.Specific) do
            MEL.RecipeSpecific[key] = value
        end
    end
end

local function loadRecipe(filename, scope)
    local File = string.GetFileFromFilename(filename)
    -- load recipe
    if MEL.ScopedRecipies and SERVER and (scope == "sh" or scope == "cl") then -- тысяча проверок чтобы не дайбог вдруг если сойдётся ретроградный меркурий и сатурн в одном созвездии не улетел св файл клиенту
        AddCSLuaFile(filename)
    end

    if not MEL.ScopedRecipies and SERVER then AddCSLuaFile(filename) end
    include(filename)
    if not RECIPE then
        MEL._LogError("looks like RECIPE table for " .. filename .. " is nil. Ensure that DefineRecipe was called.")
        return
    end

    if not RECIPE.TrainType then
        MEL._LogError("looks like you forgot to specify train type for " .. filename .. ". Refusing to load it.")
        return
    end

    if RECIPE.Name ~= string.sub(File, 1, string.find(File, "%.lua") - 1) then MEL._LogWarning("recipe \"" .. RECIPE.Name .. "\" file name and name defined in DefineRecipe differs. Consider renaming your file.") end
    MEL._LogInfo("loading recipe " .. RECIPE.ClassName .. " from " .. filename)
    RECIPE.Description = RECIPE.Description or "No description"
    RECIPE.Specific = {}
    RECIPE.Init = RECIPE.Init or function() end
    RECIPE.BeforeInject = RECIPE.BeforeInject or function() end
    RECIPE.InjectNeeded = RECIPE.InjectNeeded or function() return true end
    RECIPE.Inject = RECIPE.Inject or function() end
    RECIPE.InjectSystem = RECIPE.InjectSystem or function() end
    RECIPE.InjectSpawner = RECIPE.InjectSpawner or function() end
    if MEL.Recipes[RECIPE.ClassName] then
        MEL._LogError("recipe with name \"" .. RECIPE.ClassName .. "\" already exists. Refusing to load recipe from " .. filename .. ".")
        return
    end

    MEL.Recipes[RECIPE.ClassName] = RECIPE
    -- initialize recipe
    initRecipe(RECIPE)
    RECIPE = nil
end

local function discoverRecipies()
    -- load all recipies recursively
    MEL._LogInfo("loading recipies...")
    local recipe_files = {}
    findRecipeFiles("recipies", recipe_files)
    for _, recipe_file in pairs(recipe_files) do
        if not recipe_file then -- for some reason, recipe_file can be nil...
            continue
        end

        -- todo: think about scope
        local scope = string.sub(string.GetFileFromFilename(recipe_file), 1, 2)
        if (CLIENT or not SERVER) and scope == "sv" then continue end

        if scope ~= "sv" and scope ~= "sh" and scope ~= "cl" then scope = "sh" end

        loadRecipe(recipe_file, scope)
    end
end

local prefixes = {
    ["gmod_subway"] = true,
    ["gmod_train_"] = true,
    ["gmod_track_"] = true
}

local function getEntTables()
    -- we are using this method cause default metrotroi table caused problems
    for entclass in pairs(scripted_ents.GetList()) do
        local prefix = string.sub(entclass, 1, 11)
        if prefixes[prefix] then
            table.insert(MEL.MetrostroiClasses, entclass)
            local ent_table = scripted_ents.GetStored(entclass).t
            ent_table.entclass = entclass -- add entclass for convience
            ent_table.spawner = ent_table.Spawner -- add spawner for convience
            MEL.EntTables[entclass] = ent_table
        end

        if prefix == "gmod_subway" then table.insert(MEL.TrainClasses, entclass) end
    end
end

function MEL.getEntTable(ent_class)
    if MEL.EntTables[ent_class] then return MEL.EntTables[ent_class] end
    local ent_table = scripted_ents.GetStored(ent_class).t
    ent_table.entclass = ent_class -- add entclass for convience
    MEL.EntTables[ent_class] = ent_table
    return ent_table
end

local function randomFieldHelper(wagon, entclass)
    if entclass ~= wagon:GetClass() then return end
    math.randomseed(wagon.WagonNumber + wagon.SubwayTrain.EKKType)
    local custom = true

    if table.HasValue(MEL.TrainFamilies["717_714_mvm"], entclass) then
        custom = (wagon.CustomSettings and true or false)
    end

    for name, data in pairs(MEL.RandomFields[entclass]) do
        if data.type_ == "List" then
            local elements_length = data.elements_length
            local value = wagon:GetNW2Int(name, 1)
            if not custom or value == 1 then
                if data.distribution then
                    value = MEL.Helpers.getWeightedRandomValue(data.distribution) + 1 -- +1 cause first is random, and we dont include it in distribution table
                else
                    value = math.random(2, elements_length)
                end
            end

            wagon:SetNW2Int(name, value - 1)
        elseif data.type_ == "Slider" then
            local min = data.min
            local max = data.max
            local decimals = data.decimals
            local value = wagon:GetNW2Float(name, min)
            if not custom or value == min then
                if decimals > 0 then
                    wagon:SetNW2Float(name, math.Rand(min + 1 / decimals, max))
                else
                    wagon:SetNW2Float(name, math.random(min + 1, max))
                end
            end
        end
    end

    math.randomseed(os.time())
end

local function injectRandomFieldHelper(entclass, entTable)
    if CLIENT then return end
    if not MEL.RandomFields[entclass] then return end
    -- add helper inject to server TrainSpawnerUpdate in order to automaticly handle random value
    MEL.InjectIntoServerFunction(entclass, "TrainSpawnerUpdate", function(wagon, ...) randomFieldHelper(wagon, entclass) end, -1)
    -- and inject it to interim too
    if entTable.spawner then
        -- print("field", entTable.spawner.interim == "gmod_subway_81-719")
        MEL.InjectIntoServerFunction(entTable.spawner.interim, "TrainSpawnerUpdate", function(wagon, ...) randomFieldHelper(wagon, entclass) end, -1)
    end
end

local function injectAnimationReloadHelper(entclass, entTable)
    -- add helper inject reload all animations on UpdateWagonNumber
    -- we need this cause AnimateOverrides can change things like min/max on change of some wagon parameter
    if not entTable.UpdateWagonNumber then return end
    MEL.InjectIntoClientFunction(entclass, "UpdateWagonNumber", function(wagon, ...)
        for key, value in pairs(wagon.Anims or {}) do
            if MEL.AnimateOverrides[entclass] and isfunction(MEL.AnimateOverrides[entclass][key]) then
                wagon:Animate(key, value.val < 0.5 and 1 or 0) -- we need inverted value in order to reload anim
            end
        end
    end, 1)
end

local function injectFieldUpdateHelper(entclass)
    if not MEL.ClientPropsToReload[entclass] then return end
    -- add helper inject to server UpdateWagonNumber in order to reload all models, that should be reloaded
    local entclass_inject = entclass
    if entclass == "gmod_subway_81-717_mvm_custom" then entclass_inject = "gmod_subway_81-717_mvm" end
    MEL.InjectIntoClientFunction(entclass_inject, "UpdateWagonNumber", function(wagon)
        for key, props in pairs(MEL.ClientPropsToReload[entclass]) do
            local value = wagon:GetNW2Int(key, 1)
            if MEL.Debug or wagon[key] ~= value then
                for _, prop_name in pairs(props) do
                    wagon:RemoveCSEnt(prop_name)
                end

                wagon[key] = value
            end
        end
    end)
end

--[[
local function injectFunction(key, tbl)
    if not MEL.FunctionInjectStack[key] then return end

    for functionName, priorities in pairs(MEL.FunctionInjectStack[key]) do
        local beforeStack = {}
        local afterStack = {}
        for priority, functionStack in SortedPairs(priorities) do
            if priority < 0 then
                table.insert(beforeStack, functionStack)
            elseif priority > 0 then
                table.insert(afterStack, functionStack)
            end
        end

        -- check for missing function from some table
        if not tbl[functionName] then
            MEL._LogError(Format("can't inject into %s: function %s doesn't exists!", key, functionName))
            continue
        end

        if not MEL.FunctionDefaults[key] then MEL.FunctionDefaults[key] = {} end
        if not MEL.FunctionDefaults[key][functionName] then MEL.FunctionDefaults[key][functionName] = tbl[functionName] end

        local buildedInjectString = ""
        buildedInjectString = buildedInjectString .. "local af1, af2, af3, af4, af5, bf1, bf2, bf3, bf4, bf5, orig_func = ...\n"
        buildedInjectString = buildedInjectString .. "return function(...)\n"
        buildedInjectString = buildedInjectString .. "  af1(...)\n"
        buildedInjectString = buildedInjectString .. "  af2(...)\n"
        buildedInjectString = buildedInjectString .. "  af3(...)\n"
        buildedInjectString = buildedInjectString .. "  af4(...)\n"
        buildedInjectString = buildedInjectString .. "  af5(...)\n"
        buildedInjectString = buildedInjectString .. "  local ret = orig_func(...)\n"
        buildedInjectString = buildedInjectString .. "  bf1(...)\n"
        buildedInjectString = buildedInjectString .. "  bf2(...)\n"
        buildedInjectString = buildedInjectString .. "  bf3(...)\n"
        buildedInjectString = buildedInjectString .. "  bf4(...)\n"
        buildedInjectString = buildedInjectString .. "  bf5(...)\n"
        buildedInjectString = buildedInjectString .. "  return ret\n"
        buildedInjectString = buildedInjectString .. "end\n"

        local inject_pre_func = CompileString(buildedInjectString)
        local inject_func = inject_pre_func(unpack(beforeStack), unpack(afterStack), MEL.FunctionDefaults[key][functionName])


        -- local buildedInject = function(wagon, ...)
        --     for i = #beforeStack, 1, -1 do
        --         for _, functionToInject in pairs(beforeStack[i]) do
        --             injectReturnValue = {functionToInject(wagon, unpack({...} or {}))}
        --             if injectReturnValue[#injectReturnValue] == MEL.Return then return unpack(injectReturnValue, 1, #injectReturnValue - 1) end
        --         end
        --     end

        --     local returnValue = MEL.FunctionDefaults[key][functionName](wagon, unpack({...} or {}))
        --     for i = 1, #afterStack do
        --         for _, functionToInject in pairs(afterStack[i]) do
        --             injectReturnValue = {functionToInject(wagon, returnValue, unpack({...} or {}))}
        --             if injectReturnValue[#injectReturnValue] == MEL.Return then return unpack(injectReturnValue, 1, #injectReturnValue - 1) end
        --         end
        --     end
        --     return returnValue
        -- end

        -- tbl[functionName] = buildedInject
        -- if string.StartsWith(key, "sys_") then return end
        -- -- reinject this function on already spawned wagons
        -- for _, ent in ipairs(ents.FindByClass(key) or {}) do
        --     ent[functionName] = buildedInject
        -- end
    end
end
]]
local function injectFunction(key, tbl)
    if not MEL.FunctionInjectStack[key] then return end
    -- yep, this is O(N^2). funny, cause there is probably better way to achieve priority system
    -- TODO: probably optimize it - it will cause problems if there would be a lot of ents and systems
    for functionName, priorities in pairs(MEL.FunctionInjectStack[key]) do
        local beforeStack = {}
        local afterStack = {}
        for priority, functionStack in SortedPairs(priorities) do
            if priority < 0 then
                table.insert(beforeStack, functionStack)
            elseif priority > 0 then
                table.insert(afterStack, functionStack)
            end
        end

        -- check for missing function from some table
        if not tbl[functionName] then
            MEL._LogError(Format("can't inject into %s: function %s doesn't exists!", key, functionName))
            continue
        end

        if not MEL.FunctionDefaults[key] then MEL.FunctionDefaults[key] = {} end
        if not MEL.FunctionDefaults[key][functionName] then MEL.FunctionDefaults[key][functionName] = tbl[functionName] end
        local buildedInject = function(wagon, ...)
            for i = #beforeStack, 1, -1 do
                for _, functionToInject in pairs(beforeStack[i]) do
                    injectReturnValue = {functionToInject(wagon, ...)}
                    if injectReturnValue[#injectReturnValue] == MEL.Return then return unpack(injectReturnValue, 1, #injectReturnValue - 1) end
                end
            end

            local returnValue = MEL.FunctionDefaults[key][functionName](wagon, ...)
            for i = 1, #afterStack do
                for _, functionToInject in pairs(afterStack[i]) do
                    injectReturnValue = {functionToInject(wagon, returnValue, ...)}
                    if injectReturnValue[#injectReturnValue] == MEL.Return then return unpack(injectReturnValue, 1, #injectReturnValue - 1) end
                end
            end
            return returnValue
        end

        tbl[functionName] = buildedInject
        if string.StartsWith(key, "sys_") then return end
        -- reinject this function on already spawned wagons
        for _, ent in ipairs(ents.FindByClass(key) or {}) do
            ent[functionName] = buildedInject
        end
    end
end

local function inject(isBackports)
    MEL.ResetCustomPhrases()
    MEL._LoadHelpers()
    MEL._OverrideAnimate(MEL.EntTables["gmod_subway_base"])
    MEL._OverrideSetLightPower(MEL.EntTables["gmod_subway_base"])
    MEL._OverrideHidePanel(MEL.EntTables["gmod_subway_base"])
    MEL._OverrideShowHide(MEL.EntTables["gmod_subway_base"])
    -- we do it on spawned trains too because if we will enter on server and spawn right with some wagon on PVS - this wagon would get old animate, hidepanel and showhide methods
    for _, entclass in pairs(MEL.TrainClasses) do
        for _, ent in ipairs(ents.FindByClass(entclass) or {}) do
            MEL._OverrideAnimate(ent)
            MEL._OverrideSetLightPower(ent)
            MEL._OverrideHidePanel(ent)
            MEL._OverrideShowHide(ent)
        end
    end
    -- method that finalizes inject on all trains. called after init of recipies
    for _, recipe in pairs(MEL.InjectStack) do
        if isBackports then -- TODO: Probably do something with this
            continue
        end

        recipe:BeforeInject()
    end

    for key, value in pairs(MEL.RecipeSpecific) do
        table.sort(value, function(a, b) return a.name > b.name end)
    end

    if isBackports then table.sort(MEL.InjectStack, function(a, b) return (a.BackportPriority or 9999) < (b.BackportPriority or 9999) end) end
    for _, recipe in pairs(MEL.InjectStack) do
        if isBackports and not recipe.BackportPriority then -- we do this cause all backports recipies will be in start of table
            return
        end

        if not isBackports and recipe.BackportPriority then -- TODO: Probably do something with this
            continue
        end

        logDebug(Format("injecting recipe %s", recipe.ClassName))
        -- call Inject method on every ent that recipe changes
        for _, entclass in pairs(MEL.GetEntsByTrainType(recipe.TrainType)) do
            if recipe:InjectNeeded(entclass) then
                recipe:InjectSpawner(entclass)
                recipe:Inject(MEL.EntTables[entclass], entclass)
                -- call Inject method on all alredy spawned ent that recipe changes (for example, if we are loaded on server where trains were already spawned)
                -- mark this call of inject as for entity (needed for InjectInto*Function)
                MEL.InjectIntoSpawnedEnt = true
                -- yup, this is slow
                for _, ent in ipairs(ents.FindByClass(entclass) or {}) do
                    recipe:Inject(ent, entclass)
                end

                MEL.InjectIntoSpawnedEnt = false
            end
        end

        recipe:InjectSystem()
    end

    -- inject into functions with some helpers first
    for entclass, entTable in pairs(MEL.EntTables) do
        
        injectRandomFieldHelper(entclass, entTable)
        injectFieldUpdateHelper(entclass)
        injectAnimationReloadHelper(entclass, entTable)
    end

    -- build injects second
    for entclass, entTable in pairs(MEL.EntTables) do
        injectFunction(entclass, entTable)
    end

    -- inject into systems
    for systemClass, systemTable in pairs(Metrostroi.BaseSystems) do
        injectFunction(Format("sys_%s", systemClass), systemTable)
    end

    MEL._LoadHelpers()
    MEL.ReplaceLoadLanguage()
    -- helper inject to reload all animations
    if CLIENT then 
        Metrostroi.LoadLanguage(Metrostroi.ChoosedLang)
        MEL.BuildCustomPhrases()
    end
end

discoverRecipies()
-- injection logic
hook.Add("InitPostEntity", "MetrostroiExtensionsLibInject", function()
    -- just for backports
    if Metrostroi.Version <= 1537278077 then
        getEntTables()
        inject(true)
    end

    timer.Simple(1, function()
        getEntTables()
        inject()
    end)
end)

-- reload command:
-- reloads all recipies on client and server
if SERVER then
    util.AddNetworkString("MetrostroiExtDoReload")
    concommand.Add("metrostroi_ext_reload", function(ply, cmd, args)
        net.Start("MetrostroiExtDoReload")
        net.Broadcast()
        MEL.ApplyBackports()
        MEL._LogInfo("reloading recipies...")
        -- clear all inject stacks
        MEL.FunctionInjectStack = {}
        MEL.BaseRecipies = {}
        MEL.Recipes = {}
        MEL.DisabledRecipies = {}
        MEL.InjectStack = {}
        MEL.RecipeSpecific = {}
        MEL.EntTables = {}
        MEL.TrainClasses = {}
        MEL.RandomFields = {}
        MEL.MetrostroiClasses = {}
        discoverRecipies()
        getEntTables()
        inject()
    end)
end

if CLIENT then
    net.Receive("MetrostroiExtDoReload", function(len, ply)
        MEL._LogInfo("reloading recipies...")
        MEL.ApplyBackports()
        -- clear all inject stacks
        MEL.FunctionInjectStack = {}
        MEL.BaseRecipies = {}
        MEL.Recipes = {}
        MEL.DisabledRecipies = {}
        MEL.InjectStack = {}
        MEL.RecipeSpecific = {}
        MEL.EntTables = {}
        MEL.TrainClasses = {}
        MEL.RandomFields = {}
        MEL.MetrostroiClasses = {}
        discoverRecipies()
        getEntTables()
        inject()
        -- try to reload all spawned trains csents and buttonmaps
        for k, v in ipairs(ents.FindByClass("gmod_subway_*")) do
            v.ClientPropsInitialized = false
            v:RemoveCSEnts()
            v:ClearButtons()
        end
    end)
end

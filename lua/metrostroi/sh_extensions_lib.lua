-- Copyright (C) 2025 Anatoly Raev
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
if SERVER then
    AddCSLuaFile()
    AddCSLuaFile("metrostroi/extensions/constants/language_id.lua")
    AddCSLuaFile("metrostroi/extensions/constants/spawner.lua")
end
if not MetrostroiExtensionsLib then MetrostroiExtensionsLib = {} end
MEL = MetrostroiExtensionsLib -- alias. 23 symbols vs 3. and we name it MetrostroiExtensionLib because there is fly's old Metrostroi Extensions.
local MEL_DEBUG_CONVAR = CreateConVar("metrostroi_ext_debug", 0, {FCVAR_ARCHIVE, FCVAR_REPLICATED,}, "Metrostroi Extensions Debug mode status. See https://metrostroiextensions.github.io/MetrostroiExtensions/recipe_basics/#debug- for more info.", 0, 1)
MEL.IsDebug = function()
    return MEL_DEBUG_CONVAR:GetBool() -- helps with autoreload, but may introduce problems. Disable in production!
end

MEL.Debug = MEL.IsDebug() -- DEPRECATED: Please use MEL.IsDebug function
MEL.BaseRecipies = {}
MEL.Recipes = {}
MEL.InjectStack = {}
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
MEL.FirstTimeInject = true -- temp global variable
MEL.EntTables = {}
MEL.MetrostroiClasses = {}
MEL.TrainClasses = {}

local backportsNeeded = Metrostroi.Version <= 1537278077

local LOG_PREFIX = "[MetrostroiExtensionsLib] "
local WARNING_COLOR = Color(255, 255, 0)
local DEBUG_COLOR = Color(255, 0, 191)
local INFO_COLOR = Color(0, 4, 255)
-- logger methods
local function printPrefix()
    if SERVER then
        MsgC(Color(0, 0, 255), "[Metrostroi", Color(0, 255, 0), "ExtensionsLib] ")
    else
        MsgC(Color(72, 120, 164), "[Metrostroi", Color(44, 131, 61), "ExtensionsLib] ")
    end
end

local function logDebug(msg)
    if MEL.IsDebug() then
        printPrefix()
        MsgC(DEBUG_COLOR, "Debug: ", msg, "\n")
    end
end

function MEL._LogInfo(msg)
    printPrefix()
    MsgC(INFO_COLOR, "Info: ", color_white, msg, "\n")
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
        class_name = Format("%s_%s", table.concat(train_type, "-"), name)
    else
        class_name = Format("%s_%s", train_type, name)
    end

    if not MEL.BaseRecipies[class_name] then MEL.BaseRecipies[class_name] = {} end
    if not MEL.BaseRecipies[class_name][CURRENT_SCOPE] then MEL.BaseRecipies[class_name][CURRENT_SCOPE] = {} end
    RECIPE = MEL.BaseRecipies[class_name][CURRENT_SCOPE]
    RECIPE.TrainType = train_type
    RECIPE.Name = name
    RECIPE.ClassName = class_name
    RECIPE.Scope = CURRENT_SCOPE
end

local ignoreNames = {
    ["warning.lua"] = true,
    ["license.lua"] = true,
    ["WARNING.lua"] = true,
    ["LICENSE.lua"] = true,
}

local function findRecipeFiles(folder, recipe_files)
    local found_files, found_folders = file.Find(folder .. "/*", "LUA")
    for _, recipe_file in pairs(found_files) do
        if string.GetExtensionFromFilename(recipe_file) ~= "lua" or ignoreNames[recipe_file] or ignoreNames[string.lower(recipe_file)] then continue end
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

local scopes = {
    ["sh_"] = true,
    ["sv_"] = true,
    ["cl_"] = true,
}

local function loadRecipe(filename)
    local File = string.GetFileFromFilename(filename)
    CURRENT_SCOPE = string.sub(File, 1, 3)
    if File[3] == "_" then CURRENT_SCOPE = string.sub(File, 1, 2) end
    if CURRENT_SCOPE ~= "sv" and CURRENT_SCOPE ~= "sh" and CURRENT_SCOPE ~= "cl" then CURRENT_SCOPE = "sh" end
    -- load recipe
    -- send shared or client recipe to client
    if SERVER and (CURRENT_SCOPE == "sh" or CURRENT_SCOPE == "cl") then AddCSLuaFile(filename) end
    if SERVER and CURRENT_SCOPE == "cl" then return end
    include(filename)
    if CLIENT and CURRENT_SCOPE == "sv" and not game.SinglePlayer() then
        MEL._LogError("ACHTUNG!!! SERVER RECIPE ON CLIENT!!!")
        return
    end

    if not RECIPE then
        MEL._LogError("looks like RECIPE table for " .. filename .. " is nil. Ensure that DefineRecipe was called.")
        return
    end

    if not RECIPE.TrainType then
        MEL._LogError("looks like you forgot to specify train type for " .. filename .. ". Refusing to load it.")
        return
    end

    local recipe_file_name = string.sub(File, 1, string.find(File, "%.lua") - 1)
    if scopes[string.sub(File, 1, 3)] then recipe_file_name = string.sub(File, 4, string.find(File, "%.lua") - 1) end
    if RECIPE.Name ~= recipe_file_name then MEL._LogWarning(Format("recipe \"%s\" file name and name defined in DefineRecipe (%s) differs. Consider renaming your file.", recipe_file_name, RECIPE.Name)) end
    logDebug(Format("[%s] loading recipe %s from %s", RECIPE.Scope, RECIPE.ClassName, filename))
    RECIPE.Description = RECIPE.Description or "No description"
    RECIPE.Specific = {}
    RECIPE.Init = RECIPE.Init or function() end
    RECIPE.BeforeInject = RECIPE.BeforeInject or function() end
    RECIPE.InjectNeeded = RECIPE.InjectNeeded or function() return true end
    RECIPE.Inject = RECIPE.Inject or function() end
    RECIPE.InjectSystem = RECIPE.InjectSystem or function() end
    RECIPE.InjectSpawner = RECIPE.InjectSpawner or function() end
    if not MEL.Recipes[RECIPE.ClassName] then MEL.Recipes[RECIPE.ClassName] = {} end
    if MEL.Recipes[RECIPE.ClassName][RECIPE.Scope] then
        MEL._LogError(Format("recipe with name \"%s\" and scope %s already exists. Refusing to load recipe from %s.", RECIPE.ClassName, RECIPE.Scope, filename))
        return
    end

    MEL.Recipes[RECIPE.ClassName][RECIPE.Scope] = RECIPE
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

        loadRecipe(recipe_file, scope)
    end

    MEL._LogInfo(Format("loaded %d recipies", #table.GetKeys(MEL.Recipes)))
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
    if table.HasValue(MEL.TrainFamilies["717_714_mvm"], entclass) then custom = wagon.CustomSettings and true or false end
    for name, data in pairs(MEL.RandomFields[entclass]) do
        if data.type_ == "List" then
            local elements_length = data.elements_length
            local value = wagon:GetNW2Int(name, 1)
            if not custom or value == 1 then
                if data.distribution then
                    value = MEL.Helpers.getWeightedRandomValue(data.distribution) + 1 -- +1 cause first is random, and we dont include it in distribution table
                elseif data.callback then
                    value = data.callback(wagon, elements_length)
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
    if not MEL.RandomFields[entclass] then return end
    -- add helper inject to server TrainSpawnerUpdate in order to automaticly handle random value
    MEL.InjectIntoServerFunction(entclass, "TrainSpawnerUpdate", function(wagon, ...) randomFieldHelper(wagon, entclass) end, -1)
    -- and inject it to interim too
    if entTable.spawner and entTable.spawner.interim then MEL.InjectIntoServerFunction(entTable.spawner.interim, "TrainSpawnerUpdate", function(wagon, ...) randomFieldHelper(wagon, entclass) end, -1) end
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
            if MEL.IsDebug() or wagon[key] ~= value then
                for _, prop_name in pairs(props) do
                    wagon:RemoveCSEnt(prop_name)
                end

                wagon[key] = value
            end
        end
    end)
end

local function injectFunction(key, tbl)
    if not MEL.FunctionInjectStack[key] then return end
    local builedInjects = {}
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

        local targetFunction = MEL.FunctionDefaults[key][functionName]
        -- PERFORMANCE: before we used unpack and varargs, but they doesn't play nicely with JIT. So this hacky thing is best that i can think of to fix it.
        local buildedInject = function(wagon, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
            for i = #beforeStack, 1, -1 do
                local level = beforeStack[i]
                for j = 1, #level do
                    local fn = level[j]
                    local rets = {fn(wagon, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)}  -- unavoidable allocation :(
                    local n = #rets
                    if n > 0 and rets[n] == MEL.Return then
                        -- Return all but last
                        if n == 1 then
                            return
                        elseif n == 2 then
                            return rets[1]
                        elseif n == 3 then
                            return rets[1], rets[2]
                        elseif n == 4 then
                            return rets[1], rets[2], rets[3]
                        elseif n == 5 then
                            return rets[1], rets[2], rets[3], rets[4]
                        else
                            -- fallback for >5 returns (really rare)
                            return unpack(rets, 1, n - 1)
                        end
                    end
                    -- else: continue
                end
            end

            local returnValue = targetFunction(wagon, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)

            for i = 1, #afterStack do
                local level = afterStack[i]
                for j = 1, #level do
                    local fn = level[j]
                    local rets = {fn(wagon, returnValue, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)}
                    local n = #rets
                    if n > 0 and rets[n] == MEL.Return then
                        if n == 1 then
                            return
                        elseif n == 2 then
                            return rets[1]
                        elseif n == 3 then
                            return rets[1], rets[2]
                        elseif n == 4 then
                            return rets[1], rets[2], rets[3]
                        elseif n == 5 then
                            return rets[1], rets[2], rets[3], rets[4]
                        else
                            return unpack(rets, 1, n - 1)
                        end
                    end
                end
            end
            return returnValue
        end

        builedInjects[functionName] = buildedInject
        tbl[functionName] = buildedInject
    end

    if string.StartsWith(key, "sys_") then return end
    -- FIXME: can we actually reinject after injecting all functions? this would save a lot of iterations
    for ent, _ in pairs(Metrostroi.SpawnedTrains) do
        if ent:GetClass() ~= key then continue end
        -- reinject functions on already spawned wagons
        for functionName, buildedInject in pairs(builedInjects) do
            ent[functionName] = buildedInject
        end

        -- call all Initialize injects on client
        -- we need this cause Initialize would be called before MEL would build injects
        if CLIENT and MEL.FirstTimeInject then
            for _, functionName in pairs({"Initialize", "InitializeSystems", "InitializeSounds"}) do
                if not MEL.FunctionInjectStack[key][functionName] then continue end
                for priority, functionStack in SortedPairs(MEL.FunctionInjectStack[key][functionName]) do
                    for _, func in pairs(functionStack) do
                        func(ent)
                    end
                end
            end
        end
    end
end

local function inject(isBackports)
    local start_time = SysTime()
    MEL._LogInfo(Format("injecting recipies (isBackports: %s)...", isBackports and "yes" or "no"))
    MEL._LoadHelpers()
    MEL._OverrideAnimate(MEL.EntTables["gmod_subway_base"])
    MEL._OverrideSetLightPower(MEL.EntTables["gmod_subway_base"])
    MEL._OverrideHidePanel(MEL.EntTables["gmod_subway_base"])
    MEL._OverrideShowHide(MEL.EntTables["gmod_subway_base"])
    -- we do it on spawned trains too because if we will enter on server and spawn right with some wagon on PVS - this wagon would get old animate, hidepanel and showhide methods
    for ent, _ in pairs(Metrostroi.SpawnedTrains) do
        MEL._OverrideAnimate(ent)
        MEL._OverrideSetLightPower(ent)
        MEL._OverrideHidePanel(ent)
        MEL._OverrideShowHide(ent)
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

        logDebug(Format("[%s] injecting recipe %s", recipe.Scope, recipe.ClassName))
        -- call Inject method on every ent that recipe changes
        for _, entclass in pairs(MEL.GetEntsByTrainType(recipe.TrainType)) do
            if recipe:InjectNeeded(entclass) then
                recipe:InjectSpawner(entclass)
                recipe:Inject(MEL.EntTables[entclass], entclass)
                -- call Inject method on all alredy spawned ent that recipe changes (for example, if we are loaded on server where trains were already spawned)
                -- mark this call of inject as for entity (needed for InjectInto*Function)
                MEL.InjectIntoSpawnedEnt = true
                -- yup, this is slow
                for _, ent in ents.Iterator() do
                    if ent:GetClass() ~= entclass then continue end
                    recipe:Inject(ent, entclass)
                end

                MEL.InjectIntoSpawnedEnt = false
            end
        end

        recipe:InjectSystem()
    end

    if CLIENT then
        logDebug("Precaching models...")
        local model_count = 0
        for _, model in pairs(MEL.ModelPrecacheTable) do
            model_count = model_count + 1
            util.PrecacheModel(model)
        end

        logDebug(Format("Precached %d models", model_count))
    end

    -- inject into functions with some helpers first
    for entclass, entTable in pairs(MEL.EntTables) do
        if SERVER then injectRandomFieldHelper(entclass, entTable) end
        if CLIENT then
            injectFieldUpdateHelper(entclass)
            injectAnimationReloadHelper(entclass, entTable)
        end
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
    -- -- helper inject to reload all animations
    if CLIENT then Metrostroi.LoadLanguage(Metrostroi.ChoosedLang) end
    MEL.FirstTimeInject = false
    MEL._LogInfo(Format("injected recipies in %f seconds", SysTime() - start_time))
end

-- we want to do this as soon as possible, so we would save old element values from original Metrostroi
MEL._populateSpawnerFieldMappings()
MEL.ReplaceLoadLanguage()

discoverRecipies()
-- injection logic
hook.Add("InitPostEntity", "MetrostroiExtensionsLibInject", function()
    -- just for backports
    if backportsNeeded then
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
        if not MEL.IsDebug() then
            if IsValid(ply) then
                ply:PrintMessage(HUD_PRINTCONSOLE, "Can't use metrostroi_ext_reload with metrostroi_ext_debug 0")
            else
                MEL._LogWarning("Can't use metrostroi_ext_reload with metrostroi_ext_debug 0")
            end
            return
        end

        net.Start("MetrostroiExtDoReload")
        net.Broadcast()
        MEL.ApplyBackports()
        MEL._LogInfo(Format("(%s) reloading recipies...", string.FormattedTime(CurTime(), "%02i:%02i:%02i")))
        -- clear all inject stacks
        MEL.FunctionInjectStack = {}
        MEL.BaseRecipies = {}
        MEL.Recipes = {}
        MEL.InjectStack = {}
        MEL.RecipeSpecific = {}
        MEL.EntTables = {}
        MEL.TrainClasses = {}
        MEL.RandomFields = {}
        MEL.MetrostroiClasses = {}
        MEL.SyncTableHashed = {}
        discoverRecipies()
        getEntTables()
        inject()
    end)
end

if CLIENT then
    net.Receive("MetrostroiExtDoReload", function(len, ply)
        MEL._LogInfo(Format("(%s) reloading recipies...", string.FormattedTime(CurTime(), "%02i:%02i:%02i")))
        MEL.ApplyBackports()
        -- clear all inject stacks
        MEL.FunctionInjectStack = {}
        MEL.BaseRecipies = {}
        MEL.Recipes = {}
        MEL.InjectStack = {}
        MEL.RecipeSpecific = {}
        MEL.EntTables = {}
        MEL.TrainClasses = {}
        MEL.RandomFields = {}
        MEL.MetrostroiClasses = {}
        MEL.ShowHideOverrides = {}
        MEL.AnimateOverrides = {}
        MEL.AnimateValueOverrides = {}
        MEL.HidePanelOverrides = {}
        MEL.ClientPropsToReload = {}
        MEL.DecoratorCache = {}
        discoverRecipies()
        getEntTables()
        inject()
        -- try to reload all spawned trains csents and buttonmaps
        for ent, _ in pairs(Metrostroi.SpawnedTrains) do
            ent.ClientPropsInitialized = false
            ent:RemoveCSEnts()
            ent:ClearButtons()
        end
    end)
end

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
if not MEL.SpawnerFieldMappings then
    MEL.SpawnerFieldMappings = {} -- lookup table for accessing spawner fields by name and list elements by default, non-translated name
end

-- (key: train_class, value: (key: field_name, value: {index = index_of_field, list_elements = (key: name of list element, value: index)}))
if not MEL.ButtonmapButtonMappings then
    MEL.ButtonmapButtonMappings = {} -- lookup table for accessing button of buttonmap by its id
end

MEL.SyncTableHashed = {} -- lookup table checking if some value is in SyncTable
--  (key: train_class, value: (key: sync key, value: always true)
local ENTCLASS_714_PATTERN = "714"
local ENTCLASS_717_PATTERN = "717"
local ENTCLASS_LVZ_PATTERN = "lvz"
MEL.Helpers = {}
local function stringContains(str, pattern)
    local i, _, _ = string.find(str, pattern)
    return i and true or false
end

-- helpers for checking wagon families
function MEL.Helpers.Is717(entclass)
    return stringContains(entclass, ENTCLASS_717_PATTERN)
end

function MEL.Helpers.Is714(entclass)
    return stringContains(entclass, ENTCLASS_714_PATTERN)
end

function MEL.Helpers.IsSPB(entclass)
    -- we probably should call this function as "IsLVZ", but this causes confusion. fuck metrostroi
    return stringContains(entclass, ENTCLASS_LVZ_PATTERN)
end

local SpawnerC = include("metrostroi/extensions/constants/spawner.lua")
function MEL.Helpers.getListElementIndex(field_table, element_name)
    field_table = MEL.Helpers.SpawnerEnsureNamedFormat(field_table)
    if field_table.Type == SpawnerC.TYPE_LIST and istable(field_table.Elements) then
        for list_i, name in pairs(field_table.Elements) do
            if name == element_name then return list_i end
        end
    end
end

function MEL.Helpers.SpawnerEnsureNamedFormat(option)
    local convertedOption = {}
    -- TODO: why do we even get functions here sometimes?
    if isfunction(option) then return option end
    -- already in named format, no need to convert it
    if option.Name then
        convertedOption = option
    else
        convertedOption.Name = option[SpawnerC.NAME]
        convertedOption.Translation = option[SpawnerC.TRANSLATION]
        convertedOption.Type = option[SpawnerC.TYPE]
        if convertedOption.Type == SpawnerC.TYPE_LIST then
            convertedOption.Elements = option[SpawnerC.List.ELEMENTS]
            convertedOption.Default = option[SpawnerC.List.DEFAULT_VALUE]
            convertedOption.WagonCallback = option[SpawnerC.List.WAGON_CALLBACK]
            convertedOption.ChangeCallback = option[SpawnerC.List.CHANGE_CALLBACK]
        elseif convertedOption.Type == SpawnerC.TYPE_SLIDER then
            convertedOption.Decimals = option[SpawnerC.Slider.DECIMALS]
            convertedOption.Min = option[SpawnerC.Slider.MIN_VALUE]
            convertedOption.Max = option[SpawnerC.Slider.MAX_VALUE]
            convertedOption.Default = option[SpawnerC.Slider.DEFAULT]
            convertedOption.WagonCallback = option[SpawnerC.Slider.WAGON_CALLBACK]
        elseif convertedOption.Type == SpawnerC.TYPE_BOOLEAN then
            convertedOption.Default = option[SpawnerC.Boolean.DEFAULT]
            convertedOption.WagonCallback = option[SpawnerC.Boolean.WAGON_CALLBACK]
            convertedOption.ChangeCallback = option[SpawnerC.Boolean.CHANGE_CALLBACK]
        end
    end
    return convertedOption
end

function MEL.Helpers.getWeightedRandomValue(distribution)
    local total = 0
    for _, part in pairs(distribution) do
        total = total + part
    end

    local random = math.random(total)
    local cursor = 0
    for i = 1, #distribution do
        cursor = cursor + distribution[i]
        if cursor >= random then return i end
    end

    MEL._LogError("getWeightedRandomValue is broken lol. Please report this error")
end

function MEL.GetButtonmapButtonMapping(ent_or_entclass, buttonmap_name, button_name, ignore_error)
    local ent_class = MEL.GetEntclass(ent_or_entclass)
    if not MEL.getEntTable(ent_class).ButtonMap then return end
    local buttonmap = MEL.getEntTable(ent_class).ButtonMap[buttonmap_name]
    if not MEL.ButtonmapButtonMappings[ent_class] then MEL.ButtonmapButtonMappings[ent_class] = {} end
    if not MEL.ButtonmapButtonMappings[ent_class][buttonmap_name] then MEL.ButtonmapButtonMappings[ent_class][buttonmap_name] = {} end
    local button_index = MEL.ButtonmapButtonMappings[ent_class][buttonmap_name][button_name]
    if not button_index then
        for i, button in pairs(buttonmap.buttons) do
            if button.ID and button.ID == button_name then
                MEL.ButtonmapButtonMappings[ent_class][buttonmap_name][button_name] = i
                button_index = i
            end
        end
    end

    if not ignore_error and not button_index then
        MEL._LogError(Format("can't find button %s in buttonmap %s", button_name, buttonmap_name))
        return
    end
    return button_index
end

function MEL.BodygroupLookup(model)
    local entity = ents.Create("prop_dynamic")
    entity:SetModel(model)
    local transformed = {}
    local bodyGroups = entity:GetBodyGroups()
    for bodyGroupId, bodyGroup in pairs(bodyGroups) do
        transformed[bodyGroup.name] = {}
        local bodyGroupData = transformed[bodyGroup.name]
        -- we need -1 here cause SetBodygroup doesn't accomodate main model id
        bodyGroupData.id = bodyGroupId - 1
        for subModelId, subModel in pairs(bodyGroup.submodels) do
            bodyGroupData[subModel] = subModelId
        end
    end

    entity:Remove()
    return transformed
end

function MEL._populateSpawnerFieldMappings()
    for _, train_class in pairs(MEL.TrainClasses) do
        local ent_table = MEL.getEntTable(train_class)
        if not ent_table.Spawner then continue end
        if not MEL.SpawnerFieldMappings[train_class] then MEL.SpawnerFieldMappings[train_class] = {} end
        local updated_fields = {}
        for field_i, field in pairs(ent_table.Spawner) do
            field = MEL.Helpers.SpawnerEnsureNamedFormat(field)
            if istable(field) and isstring(field.Name) then
                local field_name = field.Name
                updated_fields[field_name] = true
                if MEL.SpawnerFieldMappings[train_class][field_name] then
                    MEL.SpawnerFieldMappings[train_class][field_name].index = field_i
                else
                    MEL.SpawnerFieldMappings[train_class][field_name] = {
                        index = field_i,
                        list_elements = {},
                        list_elements_indexed = {}
                    }
                end

                if field.Type == SpawnerC.TYPE_LIST and istable(field.Elements) then
                    for list_i, name in pairs(field.Elements) do
                        if not MEL.SpawnerFieldMappings[train_class][field_name].list_elements[name] then MEL.SpawnerFieldMappings[train_class][field_name].list_elements[name] = list_i end
                        if not MEL.SpawnerFieldMappings[train_class][field_name].list_elements_indexed[list_i] then MEL.SpawnerFieldMappings[train_class][field_name].list_elements_indexed[list_i] = name end
                    end
                end
            end
        end
        -- FIXME: hack to delete field from mapping that was deleted somewhere else... seems so wrong, but it works soooo :)
        -- REALLY FIXME: it broke something... lol
        -- for field_name, _ in pairs(MEL.SpawnerFieldMappings[train_class]) do
        --     if not updated_fields[field_name] then
        --         MEL.SpawnerFieldMappings[train_class] = nil
        --     end
        -- end
    end
end

local function populateButtonmapButtonMappings()
    if SERVER then return end
    for _, train_class in pairs(MEL.TrainClasses) do
        local ent_table = MEL.EntTables[train_class]
        if not ent_table.ButtonMap then continue end
        MEL.ButtonmapButtonMappings[train_class] = {}
        for buttonmap_name, buttonmap in pairs(ent_table.ButtonMap) do
            if not buttonmap.buttons then continue end
            for i, button in pairs(buttonmap.buttons) do
                if not istable(button) or not button.ID then continue end
                if not MEL.ButtonmapButtonMappings[train_class][buttonmap_name] then MEL.ButtonmapButtonMappings[train_class][buttonmap_name] = {} end
                MEL.ButtonmapButtonMappings[train_class][buttonmap_name][button.ID] = i
            end
        end
    end
end

local function populateSyncTableHashed()
    if CLIENT then return end
    for _, train_class in pairs(MEL.TrainClasses) do
        local ent_table = MEL.EntTables[train_class]
        if not ent_table.SyncTable then continue end
        MEL.SyncTableHashed[train_class] = {}
        for _, sync_key in pairs(ent_table.SyncTable) do
            MEL.SyncTableHashed[train_class][sync_key] = true
        end
    end
end

function MEL._LoadHelpers()
    MEL._populateSpawnerFieldMappings()
    populateButtonmapButtonMappings()
    populateSyncTableHashed()
end

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

local LanguageIDC = include("metrostroi/extensions/constants/language_id.lua")
local function handle_buttons(id_parts, id, phrase, ent_tables, ent_class)
    local name = id_parts[LanguageIDC.Buttons.NAME]
    -- check if buttonmap is existent in base SENT
    local buttonmap = ent_tables[1].ButtonMap[name]
    if not buttonmap then return end
    if not buttonmap.buttons then return end
    local buttonmap_index = MEL.GetButtonmapButtonMapping(ent_class, name, id_parts[LanguageIDC.Buttons.ID], true)
    for _, ent_table in pairs(ent_tables) do
        local buttonmap = ent_table.ButtonMap[name]
        local buttonmap_copy = (ent_table and ent_table.ButtonMapCopy) and ent_table.ButtonMapCopy[name] or {}
        if not buttonmap then return end
        if not buttonmap.buttons then return end
        if not buttonmap_index then return end
        local button = buttonmap.buttons[buttonmap_index]
        local button_copy = (buttonmap_copy and buttonmap_copy.buttons) and buttonmap_copy.buttons[buttonmap_index] or {}
        if button then button.tooltip = phrase end
        if button_copy then button_copy.tooltip = phrase end
    end
end

local SpawnerC = include("metrostroi/extensions/constants/spawner.lua")
local function handle_spawner(id_parts, id, phrase, ent_tables, ent_class)
    for _, ent_table in pairs(ent_tables) do
        if not ent_table.Spawner then return end
        local field_mapping = MEL.SpawnerFieldMappings[ent_class][id_parts[LanguageIDC.Spawner.NAME]]
        if not field_mapping then return end
        local field_index = field_mapping.index
        local field = ent_table.Spawner[field_index]
        local field_value = id_parts[LanguageIDC.Spawner.VALUE]
        -- TODO: retrofitting new named ext spawner format. but looks ugly...
        if field.Name then
            if field_value == LanguageIDC.Spawner.VALUE_NAME then
                field.Translation = phrase
            elseif field.Type == SpawnerC.TYPE_LIST and istable(field.Elements) then
                if field_mapping.list_elements[field_value] then
                    field.Elements[field_mapping.list_elements[field_value]] = phrase
                elseif isnumber(tonumber(field_value)) then
                    local number_value = tonumber(field_value)
                    local elements = field.Elements
                    if number_value > #elements or number_value < 1 then return end
                    field.Elements[tonumber(field_value)] = phrase
                end
            end
        else
            if field_value == LanguageIDC.Spawner.VALUE_NAME then
                field[SpawnerC.TRANSLATION] = phrase
            elseif field[SpawnerC.TYPE] == SpawnerC.TYPE_LIST and istable(field[SpawnerC.List.ELEMENTS]) then
                if field_mapping.list_elements[field_value] then
                    field[SpawnerC.List.ELEMENTS][field_mapping.list_elements[field_value]] = phrase
                elseif isnumber(tonumber(field_value)) then
                    local number_value = tonumber(field_value)
                    local elements = field[SpawnerC.List.ELEMENTS]
                    if number_value > #elements or number_value < 1 then return end
                    field[SpawnerC.List.ELEMENTS][tonumber(field_value)] = phrase
                end
            end
        end
    end
end

local ENTITY_HANDLERS = {
    ["Name"] = function(id_parts, id, phrase, ent_tables, ent_class, ent_list)
        for _, ent_table in pairs(ent_tables) do
            if not ent_list[ent_class] then
                if ent_table.Spawner then ent_table.Spawner.Name = phrase end
                continue
            end
            ent_list[ent_class].PrintName = phrase
        end
    end,
    ["Buttons"] = handle_buttons,
    ["Spawner"] = handle_spawner,
}

local WEAPON_HANDLERS = {
    ["Name"] = function(swep_table, swep_list, swep_class, phrase)
        swep_table.PrintName = phrase
        swep_list[swep_class].PrintName = phrase
    end,
    ["Purpose"] = function(swep_table, swep_list, swep_class, phrase) swep_table.Purpose = phrase end,
    ["Instructions"] = function(swep_table, swep_list, swep_class, phrase) swep_table.Instructions = phrase end,
}

local metrostroi_language_softreload = GetConVar("metrostroi_language_softreload")
function MEL.ReplaceLoadLanguage()
    if SERVER then return end
    -- zachem? (вхай?)
    -- в дефолт мс говнокод. вопросы остаются?
    -- а ещё это работает быстрее!! O(N) vs O((N+M)^2)
    -- TODO: сообщения об ошибках
    Metrostroi.LoadLanguage = function(lang, force)
        local choosed_lang = lang or Metrostroi.ChoosedLang
        if not Metrostroi.Languages or not Metrostroi.Languages[choosed_lang] then return end
        Metrostroi.CurrentLanguageTable = Metrostroi.Languages[lang] or {}
        local ent_list = list.GetForEdit("SpawnableEntities")
        local swep_list = list.GetForEdit("Weapon")
        for id, phrase in pairs(Metrostroi.CurrentLanguageTable) do
            if id == "lang" then continue end
            local id_parts = string.Explode(".", id)
            if string.StartsWith(id, LanguageIDC.Entity.PREFIX) then
                if id_parts[LanguageIDC.Entity.CLASS] == "Category" then continue end
                local ent_class = id_parts[LanguageIDC.Entity.CLASS]
                local ent_tables = {MEL.EntTables[ent_class]}
                if not ent_tables[1] then continue end
                -- add all already spawned wagons
                table.Add(ent_tables, ents.FindByClass(ent_class))
                local handler = ENTITY_HANDLERS[id_parts[LanguageIDC.Entity.TYPE]]
                if handler then handler(id_parts, id, phrase, ent_tables, ent_class, ent_list) end
            elseif string.StartsWith(id, LanguageIDC.Weapons.PREFIX) then
                local swep_class = id_parts[LanguageIDC.Weapons.CLASS]
                local swep_table = weapons.GetStored(swep_class)
                if not swep_table then continue end
                WEAPON_HANDLERS[id_parts[LanguageIDC.Weapons.TYPE]](swep_table, swep_list, swep_class, phrase)
            end
        end

        if force or metrostroi_language_softreload:GetInt() ~= 1 then
            RunConsoleCommand("spawnmenu_reload")
            hook.Run("GameContentChanged")
        end
    end
end

cvars.AddChangeCallback("metrostroi_language", function(cvar, old, value)
    if SERVER then return end
    Metrostroi.LoadLanguage(value, true)
end, "ext_language")

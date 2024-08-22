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
MEL.LanguageCustomFields = MEL.LanguageCustomFields or {}

local LanguageIDC = MEL.Constants.LanguageID
local function handle_buttons(id_parts, id, phrase, ent_tables, ent_class)
    local name = id_parts[LanguageIDC.Buttons.NAME]
    -- check if buttonmap is existent in base SENT
    local buttonmap = ent_tables[1].ButtonMap[name]
    if not buttonmap then return end
    if not buttonmap.buttons then return end
    local buttonmap_index = MEL.GetButtonmapButtonMapping(ent_class, name, id_parts[LanguageIDC.Buttons.ID], true)
    for _, ent_table in pairs(ent_tables) do
        local buttonmap = ent_table.ButtonMap[name]
        local buttonmap_copy = ent_table.ButtonMapCopy[name]
        if not buttonmap then return end
        if not buttonmap.buttons then return end
        if not buttonmap_index then return end
        local button = buttonmap.buttons[buttonmap_index]
        local button_copy = buttonmap_copy.buttons[buttonmap_index]
        if button then button.tooltip = phrase end
        if button_copy then button_copy.tooltip = phrase end
    end
end

local SpawnerC = MEL.Constants.Spawner
local function handle_spawner(id_parts, id, phrase, ent_tables, ent_class)
    for _, ent_table in pairs(ent_tables) do
        if not ent_table.Spawner then return end
        local field_mapping = MEL.SpawnerFieldMappings[ent_class][id_parts[LanguageIDC.Spawner.NAME]]
        if not field_mapping then return end
        local field_index = field_mapping.index
        local field = ent_table.Spawner[field_index]
        local field_value = id_parts[LanguageIDC.Spawner.VALUE]
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

local ENTITY_HANDLERS = {
    ["Name"] = function(id_parts, id, phrase, ent_table, ent_class, ent_list)
        if not ent_list[class] then
            if ent_table.Spawner then ent_table.Spawner.Name = phrase end
            return
        end

        ent_list[ent_class].PrintName = phrase
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

function MEL.AddSpawnerFieldPhrase(ent_or_entclass, lang, setting_name, field_name, phrase)
    if not MEL.LanguageCustomFields[lang] then MEL.LanguageCustomFields[lang] = {} end
    if not MEL.LanguageCustomFields[lang]["Spawner"] then MEL.LanguageCustomFields[lang]["Spawner"] = {} end

    local class = ent_or_entclass

    if isentity(class) then
        class = ent_or_entclass:GetClass()

        if ent_or_entclass:GetClass() == "gmod_subway_81-717_mvm" and ent_or_entclass.CustomSettings then
            class = "gmod_subway_81-717_mvm_custom"
        end
    end

    if istable(class) then
        class = class.entclass
        
        if class == "gmod_subway_81-717_mvm" then
            class = "gmod_subway_81-717_mvm_custom"
        end
    end

    if not MEL.LanguageCustomFields[lang]["Spawner"][class] then MEL.LanguageCustomFields[lang]["Spawner"][class] = {} end
    if not MEL.LanguageCustomFields[lang]["Spawner"][class][setting_name] then MEL.LanguageCustomFields[lang]["Spawner"][class][setting_name] = {} end

    MEL.LanguageCustomFields[lang]["Spawner"][class][setting_name][field_name] = phrase
end

function MEL.ResetCustomPhrases()
    MEL.LanguageCustomFields = {}
end

local SpawnerC = MEL.Constants.Spawner

function MEL.BuildCustomPhrases()
    local current_lang = MEL.LanguageCustomFields[Metrostroi.ChoosedLang]
    if current_lang then
        for type, classes in pairs(current_lang) do
            if type == "Spawner" then
                for class, settings in pairs(classes) do
                    local ent = MEL.getEntTable(class)
                    local spawner = ent.Spawner
    
                    for setting_name, fields in pairs(settings) do
                        if not MEL.SpawnerFieldMappings[class] then continue end
                        local field_mapping = MEL.SpawnerFieldMappings[class][setting_name]
                        if not field_mapping then continue end
    
                        local field_index = field_mapping.index
                        
                        local field_settings = spawner[field_index]
    
                        for field_name, phrase in pairs(fields) do
                            if field_name == "Name" then
                                field_settings[SpawnerC.TRANSLATION] = phrase
                            else
                                local field_type = field_settings[SpawnerC.TYPE]
                                if field_type == "List" then
                                    field_settings[SpawnerC.List.ELEMENTS][field_mapping.list_elements[field_name]] = phrase
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    for type, classes in pairs(MEL.LanguageCustomFields["all"] or {}) do
        if type == "Spawner" then
            for class, settings in pairs(classes) do
                local ent = MEL.getEntTable(class)
                local spawner = ent.Spawner

                for setting_name, fields in pairs(settings) do
                    if not MEL.SpawnerFieldMappings[class] then continue end
                    local field_mapping = MEL.SpawnerFieldMappings[class][setting_name]
                    if not field_mapping then continue end

                    local field_index = field_mapping.index
                    
                    local field_settings = spawner[field_index]

                    for field_name, phrase in pairs(fields) do
                        if field_name == "Name" then
                            field_settings[SpawnerC.TRANSLATION] = Metrostroi.GetPhrase(phrase)
                        else
                            local field_type = field_settings[SpawnerC.TYPE]
                            if field_type == "List" then
                                field_settings[SpawnerC.List.ELEMENTS][field_mapping.list_elements[field_name]] = Metrostroi.GetPhrase(phrase)
                            end
                        end
                    end
                end
            end
        end
    end
end

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

        MEL.BuildCustomPhrases()
    end
end

cvars.AddChangeCallback("metrostroi_language", function(cvar, old, value)
    if SERVER then return end
    Metrostroi.LoadLanguage(value, true)
end, "ext_language")

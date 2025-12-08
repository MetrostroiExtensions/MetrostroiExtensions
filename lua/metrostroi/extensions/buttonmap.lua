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

MEL.HidePanelOverrides = {} -- table with HidePanel value overrides
-- (key: ent_class, value: (key: panel name, value: function to get value))
function reloadButtonMapProps(ent, buttonmap)
    if not buttonmap.props then return end
    for i, prop in pairs(buttonmap.props) do
        if ent.ClientEnts and IsValid(ent.ClientEnts[prop]) then
            ent.ClientEnts[prop]:Remove()
            ent.ClientEnts[prop] = nil
        end
    end
end

function MEL.AddToSyncTable(ent, sync_key)
    if SERVER then
        local ent_class = MEL.GetEntclass(ent)
        if not MEL.SyncTableHashed[ent_class][sync_key] then
            table.insert(ent.SyncTable, sync_key)
        end
    end
end

function MEL.ModifyButtonMap(ent, buttonmap_name, buttonmap_callback, button_callback)
    if CLIENT then
        local buttonmap = ent.ButtonMap[buttonmap_name]
        if not buttonmap then
            MEL._LogError(Format("no such buttonmap: %s", buttonmap_name))
            return
        end

        if buttonmap_callback then buttonmap_callback(buttonmap) end
        if not buttonmap.buttons then return end
        for i, button in pairs(buttonmap.buttons) do
            if not ent.ButtonMapCopy[buttonmap_name].buttons[i] then continue end

            if ent.ButtonMapCopy[buttonmap_name].buttons[i].model then
                button.model = table.Copy(ent.ButtonMapCopy[buttonmap_name].buttons[i].model)
            end

            if button_callback then button_callback(button, table.Copy(ent.ButtonMapCopy[buttonmap_name].buttons[i])) end
        end

        Metrostroi.GenerateClientProps(ent)
        reloadButtonMapProps(ent, buttonmap)
    end
end

function MEL.MoveButtonMap(ent, buttonmap_name, new_pos, new_ang)
    MEL.ModifyButtonMap(ent, buttonmap_name, function(buttonmap)
        if new_pos then buttonmap.pos = new_pos end
        if new_ang then buttonmap.ang = new_ang end
    end)
end

function MEL.MoveButtonMapButton(ent, buttonmap_name, button_name, x, y)
    if CLIENT then
        local buttonmap = ent.ButtonMap[buttonmap_name]
        local buttonmap_copy = ent.ButtonMapCopy[buttonmap_name]
        if not buttonmap then
            MEL._LogError(Format("no such buttonmap: %s", buttonmap_name))
            return
        end

        local button_index = MEL.GetButtonmapButtonMapping(ent, buttonmap_name, button_name)
        if x then
            buttonmap.buttons[button_index]["x"] = x
            buttonmap_copy.buttons[button_index]["x"] = x
        end

        if y then
            buttonmap.buttons[button_index]["y"] = y
            buttonmap_copy.buttons[button_index]["y"] = y
        end

        buttonmap.buttons[button_index].model = table.Copy(ent.ButtonMapCopy[buttonmap_name].buttons[button_index].model)
        Metrostroi.GenerateClientProps(ent)
        reloadButtonMapProps(ent, buttonmap)
    end
end

function MEL.NewButtonMap(ent, buttonmap_name, buttonmap_data, do_not_override)
    if CLIENT then
        if do_not_override and ent.ButtonMap[buttonmap_name] then
            MEL._LogError(Format("there is already buttonmap with name %s! are you sure you want to override it?", buttonmap_name))
            return
        end

        ent.ButtonMap[buttonmap_name] = buttonmap_data
        ent.ButtonMapCopy[buttonmap_name] = table.Copy(buttonmap_data)
        Metrostroi.GenerateClientProps(ent)
        reloadButtonMapProps(ent, ent.ButtonMap[buttonmap_name])
    end
end

function MEL.NewButtonMapButton(ent, buttonmap_name, button_data)
    if CLIENT then
        if not ent.ButtonMap then
            -- хм?
            return
        end

        local buttonmap = ent.ButtonMap[buttonmap_name]
        local buttonmap_copy = ent.ButtonMapCopy[buttonmap_name]
        if not buttonmap then
            MEL._LogError(Format("no such buttonmap: %s", buttonmap_name))
            return
        end

        local button_index = MEL.GetButtonmapButtonMapping(ent, buttonmap_name, button_data.ID, true)
        if button_index then
            buttonmap.buttons[button_index] = button_data
            buttonmap_copy.buttons[button_index] = table.Copy(button_data)
        else
            table.insert(buttonmap.buttons, button_data)
            table.insert(buttonmap_copy.buttons, table.Copy(button_data))
        end

        Metrostroi.GenerateClientProps(ent)
        reloadButtonMapProps(ent, buttonmap)
    end
end

function MEL._OverrideHidePanel(ent)
    if SERVER then return end
    function ent.HidePanel(wagon, kp, hide)
        if MEL.HidePanelOverrides[MEL.GetEntclass(wagon)] and MEL.HidePanelOverrides[MEL.GetEntclass(wagon)][kp] then hide = MEL.HidePanelOverrides[MEL.GetEntclass(wagon)][kp](wagon) end
        if hide and not wagon.HiddenPanels[kp] then
            wagon.HiddenPanels[kp] = true
            if wagon.ButtonMap[kp].props then
                for _, v in pairs(wagon.ButtonMap[kp].props) do
                    wagon:ShowHide(v, false, true)
                    wagon.Hidden.override[v] = true
                end
            end
        end

        if not hide and wagon.HiddenPanels[kp] then
            wagon.HiddenPanels[kp] = nil
            if wagon.ButtonMap[kp].props then
                for _, v in pairs(wagon.ButtonMap[kp].props) do
                    wagon.Hidden.override[v] = false
                    wagon:ShowHide(v, true, true)
                end
            end
        end
    end
end

function MEL.OverrideHidePanel(ent, buttonmap_name, value_callback)
    local ent_class = MEL.GetEntclass(ent)
    if not MEL.HidePanelOverrides[ent_class] then MEL.HidePanelOverrides[ent_class] = {} end
    MEL.HidePanelOverrides[ent_class][buttonmap_name] = value_callback
end

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

MEL.DefineRecipe("717_ext_int_lighting_overrides", "717_714")
function RECIPE:Inject(ent)
    -- Move interior lights
    MEL.InjectIntoClientFunction(ent, "UpdateWagonNumber", function(wagon)
        local INT_LIGHTS_Z = 35
        local int_lights_x = {}
        local int_lights_indexes = {}

        if MEL.Helpers.IsSPB(wagon:GetClass()) then
            -- TODO int lighting not shown in lights table
            int_lights_indexes = {  }
            PrintTable(wagon.Lights)
        else
            int_lights_indexes = { 11, 12, 13 }
        end

        if MEL.Helpers.Is717(wagon:GetClass()) then
            int_lights_x = { 250, -50, -350 }
        else
            int_lights_x = { 350, 0, -350 }
        end

        for i, idx in pairs(int_lights_indexes) do
            local x = int_lights_x[i] 
            wagon.Lights[idx][2] = Vector(x, 0, INT_LIGHTS_Z)    
        end
    end, 100)
end

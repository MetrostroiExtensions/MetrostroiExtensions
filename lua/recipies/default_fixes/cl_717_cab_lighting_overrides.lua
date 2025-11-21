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

-- TODO: make it work for SPB
MEL.DefineRecipe("717_ext_cab_lighting_overrides", "gmod_subway_81-717_mvm")
function RECIPE:Inject(ent)
    MEL.InjectIntoClientFunction(ent, "UpdateWagonNumber", function(wagon)
        -- Update cabine dynamic light
        wagon.Lights[10]["brightness"] = 1.2
        wagon.Lights[10]["distance"] = 500
        wagon.Lights[10][2] = Vector(417, 7, 55) -- orig 425.000000 0.000000 30.000000
    end, 100)
end

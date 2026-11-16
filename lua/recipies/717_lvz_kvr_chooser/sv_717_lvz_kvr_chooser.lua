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

MEL.DefineRecipe("717_lvz_kvr_chooser", "717_714_lvz")

function RECIPE:Inject(ent)
    MEL.InjectIntoServerFunction(ent, "TrainSpawnerUpdate", function(wagon)
        local isKVR = wagon:GetNW2Int("WagonType") == 2
        wagon:SetNW2Bool("KVR", isKVR)
        wagon:SetNW2Bool("Dot5", isKVR)
        local type_ = wagon:GetNW2Int("Type")
        local seats = false
        if type_ == 1 then --PAKSDM
            if wagon.UPO then  -- why UPO is nil?
                if isKVR then
                    wagon.UPO.Buzz = math.random() > 0.7 and 2 or math.random() > 0.7 and 1
                else
                    wagon.UPO.Buzz = math.random() > 0.4 and 2 or math.random() > 0.4 and 1
                end
            end

            wagon:SetNW2Bool("NewUSS", isKVR or math.random() > 0.3)
        elseif type_ == 2 then
            seats = math.random() > 0.2
            wagon:SetNW2Bool("NewUSS", isKVR or math.random() > 0.3)
        end

        -- wagon:SetNW2Int("Crane", isKVR and 1 or 0)
        wagon:SetNW2Bool("NewSeats", isKVR or seats)
        wagon:SetNW2Bool("NewSeats", isKVR or seats)
        wagon:UpdateTextures()
        wagon:UpdateLampsColors()
    end, 1)
end

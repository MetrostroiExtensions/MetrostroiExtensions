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
-- TODO: add documentation
MEL.DefineRecipe("base_scroll_event", "gmod_subway_base")

function RECIPE:Init()
    util.AddNetworkString("metrostroi-cabin-button-scroll")
end

function RECIPE:Inject(ent, entclass)
    net.Receive("metrostroi-cabin-button-scroll", function(len, ply)
        local train = net.ReadEntity()
        local button = net.ReadString()
        local event_delta = net.ReadInt(6)
        local seat = ply:GetVehicle()
        local outside = net.ReadBool()
        if outside then
            if not IsValid(train) then return end
            if outside and (train.CPPICanPickup and not train:CPPICanPickup(ply)) then return end
            if not outside and ply ~= train.DriverSeat.lastDriver then return end
            if not outside and train.DriverSeat.lastDriverTime and CurTime() - train.DriverSeat.lastDriverTime > 1 then return end
        else
            if not IsValid(train) then return end
            if seat ~= train.DriverSeat and seat ~= train.InstructorsSeat and (train.CPPICanPhysgun and not train:CPPICanPhysgun(ply)) and not button:find("Door") then return end
        end

        train:OnButtonScroll(button, event_delta, ply)
    end)
end

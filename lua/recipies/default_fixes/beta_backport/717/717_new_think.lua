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
MEL.DefineRecipe("717_new_think", "gmod_subway_81-717_mvm")
RECIPE.BackportPriority = 9
local Cpos = {0, 0.2, 0.4, 0.5, 0.6, 0.8, 1}
function RECIPE:Inject(ent)
    if CLIENT then
        ent.Think = function(wagon)
            wagon.BaseClass.Think(wagon)
            if not wagon.RenderClientEnts or wagon.CreatingCSEnts then
                wagon.RKTimer = nil
                wagon.OldBPSNType = nil
                wagon.RingType = nil
                return
            end

            if wagon.Scheme ~= wagon:GetNW2Int("Scheme", 1) then
                wagon.PassSchemesDone = false
                wagon.Scheme = wagon:GetNW2Int("Scheme", 1)
            end

            if wagon.RelaysConfig ~= wagon:GetNW2String("RelaysConfig") then
                wagon.RelaysConfig = wagon:GetNW2String("RelaysConfig")
                wagon:SetRelays()
            end

            if not wagon.PassSchemesDone and IsValid(wagon.ClientEnts.schemes) then
                local scheme = Metrostroi.Skins["717_new_schemes"] and Metrostroi.Skins["717_new_schemes"][wagon.Scheme]
                wagon.ClientEnts.schemes:SetSubMaterial(1, scheme and scheme[1])
                wagon.PassSchemesDone = true
            end

            wagon:SetLightPower(40, wagon:GetPackedBool("PanelLights"))
            wagon:SetLightPower(41, wagon:GetPackedBool("PanelLights"))
            wagon:SetLightPower(42, wagon:GetPackedBool("PanelLights"))
            wagon:SetLightPower(44, wagon:GetPackedBool("PanelLights"))
            wagon:SetLightPower(45, wagon:GetPackedBool("PanelLights"))
            local mask = wagon:GetNW2Int("MaskType", 1) --wagon:GetNW2Bool("Mask")
            local HL1 = wagon:Animate("Headlights1", wagon:GetPackedBool("Headlights1") and 1 or 0, 0, 1, 6, false)
            local HL2 = wagon:Animate("Headlights2", wagon:GetPackedBool("Headlights2") and 1 or 0, 0, 1, 6, false)
            local RL = wagon:Animate("RedLights_a", wagon:GetPackedBool("RedLights") and 1 or 0, 0, 1, 6, false)
            wagon:ShowHideSmooth("RedLights", RL)
            wagon:SetLightPower(8, RL > 0, RL)
            wagon:SetLightPower(9, RL > 0, RL)
            local headlight = HL1 * 0.6 + HL2 * 0.4
            wagon:SetLightPower(1, headlight > 0, headlight)
            wagon:SetLightPower(2, wagon:GetPackedBool("RedLights"), RL)
            wagon:SetLightPower(30, headlight > 0, headlight)
            wagon:SetLightPower(31, headlight > 0, headlight)
            wagon:SetLightPower(32, headlight > 0 and mask > 4, headlight)
            local newBortlamps = wagon:GetNW2Bool("NewBortlamps")
            local Bortlamp_w = wagon:Animate("Bortlamp_w", wagon:GetPackedBool("DoorsW") and 1 or 0, 0, 1, 16, false)
            local Bortlamp_g = wagon:Animate("Bortlamp_g", wagon:GetPackedBool("GRP") and 1 or 0, 0, 1, 16, false)
            local Bortlamp_y = wagon:Animate("Bortlamp_y", wagon:GetPackedBool("BrW") and 1 or 0, 0, 1, 16, false)
            if newBortlamps then
                wagon:ShowHide("bortlamps1", true)
                wagon:ShowHide("bortlamps2", true)
                wagon:ShowHide("bortlamps3", false)
                wagon:ShowHide("bortlamps4", false)
                wagon:ShowHideSmooth("bortlamp1_w", Bortlamp_w)
                wagon:ShowHideSmooth("bortlamp1_g", Bortlamp_g)
                wagon:ShowHideSmooth("bortlamp1_y", Bortlamp_y)
                wagon:ShowHideSmooth("bortlamp2_w", Bortlamp_w)
                wagon:ShowHideSmooth("bortlamp2_g", Bortlamp_g)
                wagon:ShowHideSmooth("bortlamp2_y", Bortlamp_y)
                wagon:ShowHideSmooth("bortlamp3_w", 0)
                wagon:ShowHideSmooth("bortlamp3_g", 0)
                wagon:ShowHideSmooth("bortlamp3_y", 0)
                wagon:ShowHideSmooth("bortlamp4_w", 0)
                wagon:ShowHideSmooth("bortlamp4_g", 0)
                wagon:ShowHideSmooth("bortlamp4_y", 0)
            else
                wagon:ShowHide("bortlamps1", false)
                wagon:ShowHide("bortlamps2", false)
                wagon:ShowHide("bortlamps3", true)
                wagon:ShowHide("bortlamps4", true)
                wagon:ShowHideSmooth("bortlamp1_w", 0)
                wagon:ShowHideSmooth("bortlamp1_g", 0)
                wagon:ShowHideSmooth("bortlamp1_y", 0)
                wagon:ShowHideSmooth("bortlamp2_w", 0)
                wagon:ShowHideSmooth("bortlamp2_g", 0)
                wagon:ShowHideSmooth("bortlamp2_y", 0)
                wagon:ShowHideSmooth("bortlamp3_w", Bortlamp_w)
                wagon:ShowHideSmooth("bortlamp3_g", Bortlamp_g)
                wagon:ShowHideSmooth("bortlamp3_y", Bortlamp_y)
                wagon:ShowHideSmooth("bortlamp4_w", Bortlamp_w)
                wagon:ShowHideSmooth("bortlamp4_g", Bortlamp_g)
                wagon:ShowHideSmooth("bortlamp4_y", Bortlamp_y)
            end

            wagon:SetLightPower(15, newBortlamps and Bortlamp_w > 0, Bortlamp_w)
            wagon:SetLightPower(18, newBortlamps and Bortlamp_w > 0, Bortlamp_w)
            wagon:SetLightPower(16, newBortlamps and Bortlamp_g > 0, Bortlamp_g)
            wagon:SetLightPower(19, newBortlamps and Bortlamp_g > 0, Bortlamp_g)
            wagon:SetLightPower(17, newBortlamps and Bortlamp_y > 0, Bortlamp_y)
            wagon:SetLightPower(20, newBortlamps and Bortlamp_y > 0, Bortlamp_y)
            wagon:SetLightPower(21, not newBortlamps and Bortlamp_w > 0, Bortlamp_w)
            wagon:SetLightPower(24, not newBortlamps and Bortlamp_w > 0, Bortlamp_w)
            wagon:SetLightPower(22, not newBortlamps and Bortlamp_g > 0, Bortlamp_g)
            wagon:SetLightPower(25, not newBortlamps and Bortlamp_g > 0, Bortlamp_g)
            wagon:SetLightPower(23, not newBortlamps and Bortlamp_y > 0, Bortlamp_y)
            wagon:SetLightPower(26, not newBortlamps and Bortlamp_y > 0, Bortlamp_y)
            wagon:Animate("Controller", wagon:GetPackedRatio("ControllerPosition"), 0.3, 0.02, 2, false)
            wagon:Animate("reverser", wagon:GetNW2Int("ReverserPosition") / 2, 0, 0.27, 4, false)
            wagon:Animate("krureverser", wagon:GetNW2Int("KRUPosition") / 2, 0.53, 0.95, 4, false)
            wagon:ShowHide("reverser", wagon:GetNW2Int("WrenchMode", 0) == 1)
            wagon:ShowHide("krureverser", wagon:GetNW2Int("WrenchMode", 0) == 2)
            wagon:ShowHide("brake013", wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("brake_valve_013", wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("valve_disconnect", wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("EPV_disconnect", wagon:GetPackedBool("Crane013"))
            wagon:HidePanel("DriverValveDisconnect", not wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("brake334", not wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("brake_valve_334", not wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("brake_disconnect", not wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("EPK_disconnect", not wagon:GetPackedBool("Crane013"))
            wagon:ShowHide("train_disconnect", not wagon:GetPackedBool("Crane013"))
            wagon:HidePanel("DriverValveBLDisconnect", wagon:GetPackedBool("Crane013"))
            wagon:HidePanel("DriverValveTLDisconnect", wagon:GetPackedBool("Crane013"))
            wagon:Animate("brake334", wagon:GetPackedRatio("CranePosition") / 5, 0.35, 0.65, 256, 24)
            wagon:Animate("brake013", Cpos[wagon:GetPackedRatio("CranePosition")] or 0, 0.03, 0.458, 256, 24)
            wagon:Animate("speed", wagon:GetPackedRatio("Speed"), 0.881 + 0.004, 0.609 - 0.008, nil, nil, 256, 2, 0.01)
            local ARSType = wagon:GetNW2Int("ARSType", 1)
            if wagon.ARSType ~= ARSType then
                wagon:RemoveCSEnt("ars_mvm")
                wagon.ARSType = ARSType
            end

            if wagon.KVType ~= wagon:GetNW2Int("KVType", 1) then
                wagon:RemoveCSEnt("Controller")
                wagon.KVType = wagon:GetNW2Int("KVType", 1)
            end

            wagon:ShowHide("speed", ARSType == 4 or ARSType == 5)
            wagon:HidePanel("Block2_2", ARSType ~= 1)
            wagon:HidePanel("Block2_1", ARSType ~= 2 and ARSType ~= 3)
            wagon:HidePanel("Block2_3", ARSType ~= 4 and ARSType ~= 5)
            wagon:ShowHide("SSpeed1", wagon:GetPackedBool("LUDS"))
            wagon:ShowHide("SSpeed2", wagon:GetPackedBool("LUDS"))
            wagon:ShowHide("RSpeed1", wagon:GetPackedBool("LUDS"))
            wagon:ShowHide("RSpeed2", wagon:GetPackedBool("LUDS"))
            wagon:SetLightPower(43, (ARSType == 4 or ARSType == 5) and wagon:GetPackedBool("PanelLights"))
            local speed = wagon:GetPackedRatio("Speed") * 100.0
            if wagon:GetPackedBool("LUDS") then
                if ARSType == 1 and IsValid(wagon.ClientEnts["SSpeed1"]) then wagon.ClientEnts["SSpeed1"]:SetSkin(math.floor(speed) % 10) end
                if ARSType == 1 and IsValid(wagon.ClientEnts["SSpeed2"]) then wagon.ClientEnts["SSpeed2"]:SetSkin(math.floor(speed / 10) % 10) end
                if (ARSType == 2 or ARSType == 3) and IsValid(wagon.ClientEnts["RSpeed1"]) then wagon.ClientEnts["RSpeed1"]:SetSkin(math.floor(speed) % 10) end
                if (ARSType == 2 or ARSType == 3) and IsValid(wagon.ClientEnts["RSpeed2"]) then wagon.ClientEnts["RSpeed2"]:SetSkin(math.floor(speed / 10) % 10) end
            end

            local handrails = wagon:GetNW2Bool("HandRails")
            local dot5 = wagon:GetNW2Bool("Dot5")
            local lvz = wagon:GetNW2Bool("LVZ")
            wagon:ShowHide("cabine_mvm", not dot5)
            wagon:ShowHide("destination", not dot5)
            wagon:HidePanel("Battery_C", dot5)
            wagon:HidePanel("AV_C", dot5)
            wagon:HidePanel("VBD_C", dot5)
            wagon:HidePanel("IGLA_C", dot5)
            wagon:HidePanel("IGLAButtons_C", dot5)
            wagon:HidePanel("HelperPanel_C", dot5)
            wagon:HidePanel("BZOS_C", dot5)
            wagon:HidePanel("CabVent_C", dot5)
            wagon:ShowHide("cabine_lvz", dot5)
            wagon:ShowHide("destination1", dot5)
            wagon:HidePanel("Battery_R", not dot5)
            wagon:HidePanel("AV_R", not dot5)
            wagon:HidePanel("VBD_R", not dot5)
            wagon:HidePanel("IGLA_R", not dot5)
            wagon:HidePanel("IGLAButtons_R", not dot5)
            wagon:HidePanel("CabVent_R", not dot5)
            wagon:HidePanel("HelperPanel_R", not dot5)
            wagon:HidePanel("BZOS_R", not dot5)
            wagon:ShowHide("handrails_old", not dot5)
            wagon:ShowHide("handrails_new", dot5)
            wagon.LastStation.EntityName = dot5 and "destination1" or "destination"
            local lamps_cab2 = wagon:Animate("lamps_cab2", wagon:GetPackedBool("EqLights") and 1 or 0, 0, 1, 5, false)
            local lamps_cab1 = wagon:Animate("lamps_cab1", wagon:GetPackedBool("CabLights") and 1 or 0, 0, 1, 5, false)
            wagon:ShowHideSmooth("Lamps_cab2", dot5 and 0 or lamps_cab2)
            wagon:ShowHideSmooth("Lamps_cab1", dot5 and 0 or lamps_cab1)
            wagon:ShowHideSmooth("Lamps2_cab2", dot5 and lamps_cab2 or 0)
            wagon:ShowHideSmooth("Lamps2_cab1", dot5 and lamps_cab1 or 0)
            wagon:SetLightPower("Lamps_cab1", not dot5 and lamps_cab1 > 0, lamps_cab1)
            wagon:SetLightPower("Lamps_cab2", not dot5 and lamps_cab2 > 0, lamps_cab2)
            wagon:SetLightPower("Lamps2_cab1", dot5 and lamps_cab1 > 0, lamps_cab1)
            wagon:SetLightPower("Lamps2_cab2", dot5 and lamps_cab2 > 0, lamps_cab2)
            local cabStrength = (lamps_cab1 * 0.3 + lamps_cab2 * 0.7) ^ 1.5
            wagon:SetLightPower(10, cabStrength > 0, cabStrength)
            local lamps_rtm = wagon:Animate("lamps_rtm", wagon:GetPackedBool("VPR") and 1 or 0, 0, 1, 8, false)
            wagon:SetSoundState("vpr", lamps_rtm > 0 and 1 or 0, 1)
            wagon:ShowHideSmooth("Lamp_RTM1", not dot5 and lamps_rtm or 0)
            wagon:ShowHideSmooth("Lamp_RTM2", dot5 and lamps_rtm or 0)
            wagon:SetLightPower("Lamp_RTM1", not dot5 and lamps_rtm > 0, lamps_rtm)
            wagon:SetLightPower("Lamp_RTM2", dot5 and lamps_rtm > 0, lamps_rtm)
            wagon:ShowHide("mask22_mvm", mask == 1)
            wagon:ShowHide("mask222_lvz", mask == 2)
            wagon:ShowHide("mask222_mvm", mask == 3)
            wagon:ShowHide("mask141_mvm", mask == 4)

            -- впизду, все равно в эксте новые масочки
            -- if mask == 4 then
            --     wagon.LightsOverride[30][2] = Vector(465, -48, -23.5)
            --     wagon.LightsOverride[31][2] = Vector(465, 48, -23.5)
            --     wagon.LightsOverride[32][2] = Vector(465, 0, -23.5)
            -- elseif mask < 4 then
            --     wagon.LightsOverride[30][2] = Vector(465, -45, -23.5)
            --     wagon.LightsOverride[31][2] = Vector(465, 45, -23.5)
            --     wagon.LightsOverride[32][2] = Vector(465, 0, 52)
            -- end

            --wagon:ShowHide("mask141_lvz",mask and lvz)
            wagon:ShowHide("1:KVTSet", not lvz)
            wagon:ShowHide("1:KVTRSet", not lvz)
            wagon:ShowHide("2:KVTSet", lvz)
            wagon:ShowHide("2:KVTRSet", lvz)
            if mask == 1 then
                wagon:ShowHideSmooth("Headlights22_1", HL1)
                wagon:ShowHideSmooth("Headlights22_2", HL2)

                wagon:ShowHideSmooth("Headlights222_1", 0)
                wagon:ShowHideSmooth("Headlights222_2", 0)
                wagon:ShowHideSmooth("Headlights141_1", 0)
                wagon:ShowHideSmooth("Headlights141_2", 0)
            elseif mask <= 3 then
                wagon:ShowHideSmooth("Headlights222_1", HL1)
                wagon:ShowHideSmooth("Headlights222_2", HL2)

                wagon:ShowHideSmooth("Headlights141_1", 0)
                wagon:ShowHideSmooth("Headlights141_2", 0)
                wagon:ShowHideSmooth("Headlights22_1", 0)
                wagon:ShowHideSmooth("Headlights22_2", 0)
            elseif mask == 4 then
                wagon:ShowHideSmooth("Headlights141_1", HL1)
                wagon:ShowHideSmooth("Headlights141_2", HL2)

                wagon:ShowHideSmooth("Headlights222_1", 0)
                wagon:ShowHideSmooth("Headlights222_2", 0)
                wagon:ShowHideSmooth("Headlights22_1", 0)
                wagon:ShowHideSmooth("Headlights22_2", 0)
            end

            local seats = wagon:GetNW2Int("SeatType", 1)
            wagon:ShowHide("seats_old", seats == 1)
            wagon:ShowHide("seats_old_cap", seats == 1)
            wagon:ShowHide("seats_new", seats == 2)
            wagon:ShowHide("seats_new_cap", seats == 2)
            wagon:Animate("PB", wagon:GetPackedBool("PB") and 1 or 0, 0, 0.2, 12, false)
            wagon:Animate("UAVALever", wagon:GetPackedBool("UAVA") and 1 or 0, 0, 0.6, 128, 3, false)
            wagon:Animate("parking_brake", wagon:GetPackedBool("ParkingBrake") and 1 or 0, 0.25, 0, 4, false)
            wagon:Animate("EPK_disconnect", wagon:GetPackedBool("EPK") and 1 or 0, 0.25, 0, 4, false)
            wagon:Animate("EPV_disconnect", wagon:GetPackedBool("EPK") and 1 or 0, 0.25, 0, 4, false)
            wagon:Animate("brake_disconnect", wagon:GetPackedBool("DriverValveBLDisconnect") and 1 or 0, 0.25, 0, 4, false)
            wagon:Animate("train_disconnect", wagon:GetPackedBool("DriverValveTLDisconnect") and 1 or 0, 0.25, 0, 4, false)
            wagon:Animate("valve_disconnect", wagon:GetPackedBool("DriverValveDisconnect") and 1 or 0, 0.25, 0, 4, false)
            wagon:Animate("stopkran", wagon:GetPackedBool("EmergencyBrakeValve") and 0 or 1, 0.25, 0, 128, 3, false)
            local c013 = wagon:GetNW2Int("Crane", 1) == 2
            wagon:ShowHide("brake_valve_334", not c013)
            wagon:ShowHide("brake334", not c013)
            wagon:ShowHide("brake_disconnect", not c013)
            wagon:ShowHide("train_disconnect", not c013)
            wagon:HidePanel("DriverValveBLDisconnect", c013)
            wagon:HidePanel("DriverValveTLDisconnect", c013)
            wagon:HidePanel("EPKDisconnect", c013)
            wagon:ShowHide("EPK_disconnect", not c013)
            wagon:ShowHide("brake_valve_013", c013)
            wagon:ShowHide("brake013", c013)
            wagon:ShowHide("valve_disconnect", c013)
            wagon:ShowHide("EPV_disconnect", c013)
            wagon:HidePanel("EPVDisconnect", not c013)
            wagon:HidePanel("DriverValveDisconnect", not c013)
            wagon:Animate("brake_line", wagon:GetPackedRatio("BLPressure"), 0.143, 0.88, 256, 2) --,0.01)
            wagon:Animate("train_line", wagon:GetPackedRatio("TLPressure"), 0.143, 0.88, 256, 0) --,0.01)
            wagon:Animate("brake_cylinder", wagon:GetPackedRatio("BCPressure"), 0.134, 0.874, 256, 0) --,0.03)
            wagon:Animate("voltmeter", wagon:GetPackedRatio("EnginesVoltage"), 0.396, 0.658, 256, 0.2, false)
            wagon:Animate("volt1", wagon:GetPackedRatio("BatteryVoltage"), 0.625, 0.376, 256, 0.2, false)
            wagon:Animate("ampermeter", wagon:GetPackedRatio("EnginesCurrent"), 0.39, 0.655, 256, 0.2, false)
            local otsek1 = wagon:Animate("door_otsek1", wagon:GetPackedBool("OtsekDoor1") and 1 or 0, 0, 0.25, 4, 0.5)
            local otsek2 = wagon:Animate("door_otsek2", wagon:GetPackedBool("OtsekDoor2") and 1 or 0, 0, 0.25, 4, 0.5)
            wagon:HidePanel("AV_S", not dot5 or otsek2 <= 0)
            local door1 = wagon:Animate("door1", wagon:GetPackedBool("RearDoor") and 1 or 0, 0, 0.25, 4, 0.5)
            local door2 = wagon:Animate("door2", wagon:GetPackedBool("PassengerDoor") and 1 or 0, 1, 0.8, 4, 0.5)
            local door3 = wagon:Animate("door3", wagon:GetPackedBool("CabinDoor") and 1 or 0, 0, 0.25, 4, 0.5)
            if wagon.Door1 ~= (door1 > 0) then
                wagon.Door1 = door1 > 0
                wagon:PlayOnce("door1", "bass", wagon.Door1 and 1 or 0)
            end

            if wagon.Door2 ~= (door2 < 1) then
                wagon.Door2 = door2 < 1
                wagon:PlayOnce("door2", "bass", wagon.Door2 and 1 or 0)
            end

            if wagon.Door3 ~= (door3 > 0) then
                wagon.Door3 = door3 > 0
                wagon:PlayOnce("door3", "bass", wagon.Door3 and 1 or 0)
            end

            if wagon.Otsek1 ~= (otsek1 > 0) then
                wagon.Otsek1 = otsek1 > 0
                if not wagon.Otsek1 then wagon:PlayOnce("door_otsek1", "bass", 1) end
            end

            if wagon.Otsek2 ~= (otsek2 > 0) then
                wagon.Otsek2 = otsek2 > 0
                if not wagon.Otsek2 then wagon:PlayOnce("door_otsek2", "bass", 1) end
            end

            wagon:SetLightPower(3, wagon.Otsek1 and wagon:GetPackedBool("EqLights"))
            wagon:SetLightPower(4, wagon.Otsek2 and wagon:GetPackedBool("EqLights"))
            local typ = wagon:GetNW2Int("LampType", 1)
            if wagon.LampType ~= typ then
                wagon.LampType = typ
                for i = 1, 25 do
                    if i < 13 then wagon:ShowHide("lamp1_" .. i, typ == 1) end
                    wagon:ShowHide("lamp2_" .. i, typ == 2)
                end

                wagon:ShowHide("lamps1", typ == 1)
                wagon:ShowHide("lamps2", typ == 2)
            end

            local activeLights = 0
            local maxLights
            if typ == 1 then
                for i = 1, 12 do
                    local colV = wagon:GetNW2Vector("lamp" .. i)
                    local col = Color(colV.x, colV.y, colV.z)
                    local state = wagon:Animate("Lamp1_" .. i, wagon:GetPackedBool("lightsActive" .. i) and 1 or 0, 0, 1, 6, false)
                    wagon:ShowHideSmooth("lamp1_" .. i, state, col)
                    activeLights = activeLights + state
                end

                maxLights = 12
            else
                for i = 1, 25 do
                    local colV = wagon:GetNW2Vector("lamp" .. i)
                    local col = Color(colV.x, colV.y, colV.z)
                    local state = wagon:Animate("Lamp2_" .. i, wagon:GetPackedBool("lightsActive" .. i) and 1 or 0, 0, 1, 6, false)
                    wagon:ShowHideSmooth("lamp2_" .. i, state, col)
                    activeLights = activeLights + state
                end

                maxLights = 25
            end

            for i = 11, 13 do
                local col = wagon:GetNW2Vector("lampD" .. i)
                if wagon.LightsOverride and wagon.LightsOverride[i] and wagon.LightsOverride[i].vec ~= col then
                    wagon.LightsOverride[i].vec = col
                    wagon.LightsOverride[i][4] = Color(col.x, col.y, col.z)
                    wagon:SetLightPower(i, false)
                else
                    wagon:SetLightPower(i, activeLights > 0, activeLights / maxLights)
                end
            end

            wagon:Animate("FrontBrake", wagon:GetNW2Bool("FbI") and 0 or 1, 0, 1, 3, false)
            wagon:Animate("FrontTrain", wagon:GetNW2Bool("FtI") and 1 or 0, 0, 1, 3, false)
            wagon:Animate("RearBrake", wagon:GetNW2Bool("RbI") and 0 or 1, 0, 1, 3, false)
            wagon:Animate("RearTrain", wagon:GetNW2Bool("RtI") and 1 or 0, 0, 1, 3, false)
            -- Main switch
            if wagon.LastGVValue ~= wagon:GetPackedBool("GV") then
                wagon.ResetTime = CurTime() + 1.5
                wagon.LastGVValue = wagon:GetPackedBool("GV")
            end

            wagon:Animate("gv_wrench", wagon.LastGVValue and 1 or 0, 0.5, 0.9, 128, 1, false)
            wagon:ShowHideSmooth("gv_wrench", CurTime() < wagon.ResetTime and 1 or 0.1)
            --wagon:InitializeSounds()
            for i = 0, 3 do
                for k = 0, 1 do
                    local st = k == 1 and "DoorL" or "DoorR"
                    local doorstate = wagon:GetPackedBool(st)
                    local id, sid = st .. i + 1, "door" .. i .. "x" .. k
                    local state = wagon:GetPackedRatio(id)
                    if (state ~= 1 and state ~= 0) ~= wagon.DoorStates[id] then
                        if doorstate and state < 1 or not doorstate and state > 0 then
                        else
                            if state > 0 then
                                wagon:PlayOnce(sid .. "o", "", 1, math.Rand(0.8, 1.2))
                            else
                                wagon:PlayOnce(sid .. "c", "", 1, math.Rand(0.8, 1.2))
                            end
                        end

                        wagon.DoorStates[id] = state ~= 1 and state ~= 0
                    end

                    if state ~= 1 and state ~= 0 then
                        wagon.DoorLoopStates[id] = math.Clamp((wagon.DoorLoopStates[id] or 0) + 2 * wagon.DeltaTime, 0, 1)
                    else
                        wagon.DoorLoopStates[id] = math.Clamp((wagon.DoorLoopStates[id] or 0) - 6 * wagon.DeltaTime, 0, 1)
                    end

                    wagon:SetSoundState(sid .. "r", wagon.DoorLoopStates[id], 0.8 + wagon.DoorLoopStates[id] * 0.2)
                    local n_l = "door" .. i .. "x" .. k --.."a"
                    --local n_r = "door"..i.."x"..k.."b"
                    local dlo = 1
                    if wagon.Anims[n_l] then
                        dlo = math.abs(state - (wagon.Anims[n_l] and wagon.Anims[n_l].oldival or 0))
                        if dlo <= 0 and wagon.Anims[n_l].oldspeed then dlo = wagon.Anims[n_l].oldspeed / 14 end
                    end

                    wagon:Animate(n_l, state, 0, 0.95, dlo * 14, false) --0.8 + (-0.2+0.4*math.random()),0)
                    --wagon:Animate(n_r,state,0,1,dlo*14,false)--0.8 + (-0.2+0.4*math.random()),0)
                end
            end

            local dT = wagon.DeltaTime
            local rollingi = math.min(1, wagon.TunnelCoeff + math.Clamp((wagon.StreetCoeff - 0.82) / 0.3, 0, 1))
            local rollings = math.max(wagon.TunnelCoeff * 0.6, wagon.StreetCoeff)
            local speed = wagon:GetPackedRatio("Speed") * 100.0
            local rol5 = math.Clamp(speed / 1, 0, 1) * (1 - math.Clamp((speed - 3) / 8, 0, 1))
            local rol10 = math.Clamp(speed / 12, 0, 1) * (1 - math.Clamp((speed - 25) / 8, 0, 1))
            local rol40p = Lerp((speed - 25) / 12, 0.6, 1)
            local rol40 = math.Clamp((speed - 23) / 8, 0, 1) * (1 - math.Clamp((speed - 55) / 8, 0, 1))
            local rol40p = Lerp((speed - 23) / 50, 0.6, 1)
            local rol70 = math.Clamp((speed - 40) / 8, 0, 1) * (1 - math.Clamp((speed - 62) / 5, 0, 1))
            local rol70p = Lerp(0.8 + (speed - 55) / 25 * 0.2, 0.8, 1.2)
            local rol80 = math.Clamp((speed - 70) / 5, 0, 1)
            local rol80p = Lerp(0.8 + (speed - 72) / 15 * 0.2, 0.8, 1.2)
            wagon:SetSoundState("rolling_5", math.min(1, rollingi * (1 - rollings) + rollings * 0.8) * rol5, 1)
            wagon:SetSoundState("rolling_10", rollingi * rol10, 1)
            wagon:SetSoundState("rolling_40", 0 * rollingi * rol40, rol40p)
            wagon:SetSoundState("rolling_70", 0 * rollingi * rol70, rol70p)
            wagon:SetSoundState("rolling_80", 0 * rollingi * rol80, rol80p)
            local rol32 = math.Clamp((speed - 25) / 13, 0, 1) * (1 - math.Clamp((speed - 40) / 10, 0, 1))
            local rol32p = Lerp((speed - 20) / 50, 0.8, 1.2)
            local rol68 = math.Clamp((speed - 40) / 10, 0, 1) * (1 - math.Clamp((speed - 50) / 20, 0, 1))
            local rol68p = Lerp(0.6 + (speed - 68) / 26 * 0.2, 0.6, 1.4)
            local rol75 = math.Clamp((speed - 55) / 20, 0, 1)
            local rol75p = Lerp(0.8 + (speed - 75) / 15 * 0.2, 0.6, 1.2)
            wagon:SetSoundState("rolling_32", rollingi * rol32, rol32p)
            wagon:SetSoundState("rolling_68", rollingi * rol68, rol68p)
            wagon:SetSoundState("rolling_75", rollingi * rol75, rol75p)
            local rol10 = math.Clamp(speed / 15, 0, 1) * (1 - math.Clamp((speed - 18) / 35, 0, 1))
            local rol10p = Lerp((speed - 15) / 14, 0.6, 0.78)
            local rol40 = math.Clamp((speed - 18) / 35, 0, 1) * (1 - math.Clamp((speed - 55) / 40, 0, 1))
            local rol40p = Lerp((speed - 15) / 66, 0.6, 1.3)
            local rol70 = math.Clamp((speed - 55) / 20, 0, 1) --*(1-math.Clamp((speed-72)/5,0,1))
            local rol70p = Lerp((speed - 55) / 27, 0.78, 1.15)
            --local rol80 = math.Clamp((speed-70)/5,0,1)
            --local rol80p = Lerp(0.8+(speed-72)/15*0.2,0.8,1.2)
            wagon:SetSoundState("rolling_low", rol10 * rollings, rol10p) --15
            wagon:SetSoundState("rolling_medium2", rol40 * rollings, rol40p) --57
            --wagon:SetSoundState("rolling_medium1",0 or rol40*rollings,rol40p) --57
            wagon:SetSoundState("rolling_high2", rol70 * rollings, rol70p) --70
            wagon.ReleasedPdT = math.Clamp(wagon.ReleasedPdT + 2 * (-wagon:GetPackedRatio("BrakeCylinderPressure_dPdT", 0) - 0.8 * wagon.ReleasedPdT) * dT, 0, 1)
            local release1 = math.Clamp((1.1 * wagon.ReleasedPdT - 0.1) / 0.48, 0, 8) ^ 2
            wagon:SetSoundState("release1", release1, 1)
            wagon:SetSoundState("release2", (math.Clamp(0.3 - release1, 0, 0.3) / 0.3) * (release1 / 0.3), 1.0)
            local parking_brake = wagon:GetPackedRatio("ParkingBrakePressure_dPdT", 0)
            local parking_brake_abs = math.Clamp(math.abs(parking_brake) - 0.3, 0, 1)
            if wagon.ParkingBrake1 ~= (parking_brake < 1) then
                wagon.ParkingBrake1 = parking_brake < 1
                if wagon.ParkingBrake1 then wagon:PlayOnce("parking_brake_en", "bass", 1, 1) end
            end

            if wagon.ParkingBrake2 ~= (parking_brake > -0.8) then
                wagon.ParkingBrake2 = parking_brake > -0.8
                if wagon.ParkingBrake2 then wagon:PlayOnce("parking_brake_rel", "bass", 0.6, 1) end
            end

            wagon:SetSoundState("parking_brake", parking_brake_abs, 1)
            wagon.FrontLeak = math.Clamp(wagon.FrontLeak + 10 * (-wagon:GetPackedRatio("FrontLeak") - wagon.FrontLeak) * dT, 0, 1)
            wagon.RearLeak = math.Clamp(wagon.RearLeak + 10 * (-wagon:GetPackedRatio("RearLeak") - wagon.RearLeak) * dT, 0, 1)
            wagon:SetSoundState("front_isolation", wagon.FrontLeak, 0.9 + 0.2 * wagon.FrontLeak)
            wagon:SetSoundState("rear_isolation", wagon.RearLeak, 0.9 + 0.2 * wagon.RearLeak)
            local ramp = wagon:GetPackedRatio("Crane_dPdT", 0)
            if c013 then
                if ramp > 0 then
                    wagon.CraneRamp = wagon.CraneRamp + (0.2 * ramp - wagon.CraneRamp) * dT
                else
                    wagon.CraneRamp = wagon.CraneRamp + (0.9 * ramp - wagon.CraneRamp) * dT
                end

                wagon.CraneRRamp = math.Clamp(wagon.CraneRRamp + 1.0 * (1 * ramp - wagon.CraneRRamp) * dT, 0, 1)
                wagon:SetSoundState("crane334_brake", 0, 1.0)
                wagon:SetSoundState("crane334_brake_reflection", 0, 1.0)
                wagon:SetSoundState("crane334_brake_slow", 0, 1.0)
                wagon:SetSoundState("crane334_release", 0, 1.0)
                wagon:SetSoundState("crane013_release", wagon.CraneRRamp ^ 1.5, 1.0)
                wagon:SetSoundState("crane013_brake", math.Clamp(-wagon.CraneRamp * 1.5 - 0.1, 0, 1) ^ 1.3, 1.0)
                local loudV = wagon:GetNW2Float("Crane013Loud", 0)
                if loudV > 0 then
                    if ramp > 0 then
                        wagon.CraneLRamp = wagon.CraneLRamp + (math.min(ramp, 0) - wagon.CraneLRamp) * dT * 0.5
                    else
                        wagon.CraneLRamp = wagon.CraneLRamp + (math.min(ramp, 0) - wagon.CraneLRamp) * dT * 1
                    end

                    wagon:SetSoundState("crane013_brake_l", math.Clamp(-wagon.CraneRamp * 2.5 - 0.1, 0, 1) ^ 1.3 * (1 - math.Clamp((-wagon.CraneLRamp - loudV) * 3, 0, 1)), 1.12 - math.Clamp((-wagon.CraneLRamp - 0.15) * 2, 0, 1) * 0.12)
                else
                    wagon:SetSoundState("crane013_brake_l", 0, 1)
                end

                wagon:SetSoundState("crane013_brake2", math.Clamp(-wagon.CraneRamp * 1.5 - 0.95, 0, 1.5) ^ 2, 1.0)
            else
                wagon:SetSoundState("crane013_brake", 0, 1.0)
                wagon:SetSoundState("crane013_release", 0, 1.0)
                --wagon:SetSoundState("crane013_brake2",0,1.0)
                wagon.CraneRamp = math.Clamp(wagon.CraneRamp + 8.0 * (1 * wagon:GetPackedRatio("Crane_dPdT", 0) - wagon.CraneRamp) * dT, -1, 1)
                wagon:SetSoundState("crane334_brake_low", math.Clamp(-wagon.CraneRamp * 2, 0, 1) ^ 2, 1)
                local high = math.Clamp((-wagon.CraneRamp - 0.5) / 0.5, 0, 1) ^ 1
                wagon:SetSoundState("crane334_brake_high", high, 1.0)
                wagon:SetSoundState("crane013_brake2", high * 2, 1.0)
                wagon:SetSoundState("crane334_brake_eq_high", --[[ math.Clamp(-wagon.CraneRamp*0,0,1)---]]
                    math.Clamp(-wagon:GetPackedRatio("ReservoirPressure_dPdT") - 0.2, 0, 1) ^ 0.8 * 1, 1)

                wagon:SetSoundState("crane334_brake_eq_low", --[[ math.Clamp(-wagon.CraneRamp*0,0,1)---]]
                    math.Clamp(-wagon:GetPackedRatio("ReservoirPressure_dPdT") - 0.4, 0, 1) ^ 0.8 * 1.3, 1)

                wagon:SetSoundState("crane334_release", math.Clamp(wagon.CraneRamp, 0, 1) ^ 2, 1.0)
            end

            local emergencyValveEPK = wagon:GetPackedRatio("EmergencyValveEPK_dPdT", 0)
            wagon.EmergencyValveEPKRamp = math.Clamp(wagon.EmergencyValveEPKRamp + 1.0 * (0.5 * emergencyValveEPK - wagon.EmergencyValveEPKRamp) * 12 * dT, 0, 1)
            if wagon.EmergencyValveEPKRamp < 0.01 then wagon.EmergencyValveEPKRamp = 0 end
            wagon:SetSoundState("epk_brake", wagon.EmergencyValveEPKRamp, 2.8)
            --[[
            local emergencyBrakeValve = wagon:GetPackedRatio("EmergencyBrakeValve_dPdT", 0)
            wagon.EmergencyBrakeValveRamp = math.Clamp(wagon.EmergencyBrakeValveRamp + (emergencyBrakeValve-wagon.EmergencyBrakeValveRamp)*dT*8,0,1)
            --wagon:SetSoundState("valve_brake",wagon.EmergencyBrakeValveRamp,0.8+math.min(0.4,wagon.EmergencyBrakeValveRamp*0.8))
            local emerBrakeValve = wagon.EmergencyBrakeValveRamp
            wagon:SetSoundState("valve_brake_l",math.Clamp(emerBrakeValve/0.2,0,1),1)
            wagon:SetSoundState("valve_brake_m",math.Clamp((emerBrakeValve-0.2)/0.3,0,1),1)
            wagon:SetSoundState("valve_brake_h",math.Clamp((emerBrakeValve-0.5)/0.5,0,1),1)
        --]]
            local emergencyBrakeValve = wagon:GetPackedRatio("EmergencyBrakeValve_dPdT", 0)
            wagon.EmergencyBrakeValveRamp = math.Clamp(wagon.EmergencyBrakeValveRamp + (emergencyBrakeValve - wagon.EmergencyBrakeValveRamp) * dT * 8, 0, 1)
            wagon:SetSoundState("valve_brake", wagon.EmergencyBrakeValveRamp, 0.8 + math.min(0.4, wagon.EmergencyBrakeValveRamp * 0.8))
            local emergencyValve = wagon:GetPackedRatio("EmergencyValve_dPdT", 0) ^ 0.4 * 1.2
            wagon.EmergencyValveRamp = math.Clamp(wagon.EmergencyValveRamp + (emergencyValve - wagon.EmergencyValveRamp) * dT * 16, 0, 1)
            local emer_brake = math.Clamp((wagon.EmergencyValveRamp - 0.9) / 0.05, 0, 1)
            local emer_brake2 = math.Clamp((wagon.EmergencyValveRamp - 0.2) / 0.4, 0, 1) * (1 - math.Clamp((wagon.EmergencyValveRamp - 0.9) / 0.1, 0, 1))
            wagon:SetSoundState("emer_brake", emer_brake, 1)
            wagon:SetSoundState("emer_brake2", emer_brake2, math.min(1, 0.8 + 0.2 * emer_brake2))
            --wagon:SetSoundState("emer_brake",wagon.EmergencyValveRamp*0.8,1)
            --wagon:SetSoundState("emer_brake",wagon.EmergencyValveRamp*0.8,1)
            -- Compressor
            wagon:SetSoundState("compressor", wagon:GetPackedBool("Compressor") and 0.6 or 0, 1)
            wagon:SetSoundState("compressor2", wagon:GetPackedBool("Compressor") and 0.8 or 0, 1)
            local v1state = wagon:GetPackedBool("M1_3") and 1 or 0
            local v2state = wagon:GetPackedBool("M4_7") and 1 or 0
            local vCstate = wagon:GetPackedRatio("M8") / 2
            if wagon.VentCab < vCstate then
                wagon.VentCab = math.min(1, wagon.VentCab + dT / 2.7)
            elseif wagon.VentCab > vCstate then
                wagon.VentCab = math.max(0, wagon.VentCab - dT / 2.7)
            end

            wagon.VentG1 = math.Clamp(wagon.VentG1 + dT / 2.7 * (v1state * 2 - 1), 0, 1)
            wagon.VentG2 = math.Clamp(wagon.VentG2 + dT / 2.7 * (v2state * 2 - 1), 0, 1)
            wagon:SetSoundState("vent_cabl", math.Clamp(wagon.VentCab * 2, 0, 1), 1)
            wagon:SetSoundState("vent_cabh", math.Clamp((wagon.VentCab - 0.5) * 2, 0, 1), 1)
            for i = 1, 7 do
                if i < 4 then
                    wagon:SetSoundState("vent" .. i, wagon.VentG1, 1)
                else
                    wagon:SetSoundState("vent" .. i, wagon.VentG2, 1)
                end
            end

            wagon:SetSoundState("IST", wagon:GetPackedBool("IST") and 1 or 0, 0.95)
            if wagon.RingType ~= wagon:GetNW2Int("RingType", 1) then
                wagon.RingType = wagon:GetNW2Int("RingType", 1)
                wagon:SetSoundState(wagon.RingName, 0, 0)
                wagon.RingPitch = 1
                wagon.RingVolume = 1
                if wagon.RingType == 1 then
                    wagon.RingName = "ring2"
                elseif wagon.RingType == 2 then
                    wagon.RingName = "ring3"
                    wagon.RingVolume = 1.4
                    wagon.RingPitch = 0.6
                elseif wagon.RingType == 3 then
                    wagon.RingName = "ring3"
                    wagon.RingVolume = 1.2
                    wagon.RingPitch = 0.8
                elseif wagon.RingType == 4 then
                    wagon.RingName = "ring3"
                    wagon.RingPitch = 0.95
                elseif wagon.RingType == 5 then
                    wagon.RingName = "ring"
                    wagon.RingPitch = 0.8
                elseif wagon.RingType == 6 then
                    wagon.RingName = "ring"
                elseif wagon.RingType == 7 then
                    wagon.RingName = "ring4"
                elseif wagon.RingType == 8 then
                    wagon.RingName = "ring5"
                elseif wagon.RingType == 9 then
                    wagon.RingName = "ring6"
                end

                wagon.RingFade = 0
            end

            -- ARS/ringer alert
            local bzos = wagon.RingName == "ring" or wagon.RingName == "ring6" or wagon.RingName == "ring3" and RealTime() % 0.8 < 0.35 or wagon.RingName ~= "ring3" and RealTime() % 0.5 > 0.25
            local ringstate = (wagon:GetPackedBool("Buzzer") or wagon:GetPackedBool("BuzzerBZOS") and bzos) and 1 or 0
            if 6 < wagon.RingType and wagon.RingType < 9 then
                wagon.RingFade = math.Clamp(wagon.RingFade + (ringstate - wagon.RingFade) * dT * (wagon:GetPackedBool("BuzzerBZOS") and 50 or 25), 0, 1)
                wagon:SetSoundState(wagon.RingName, wagon.RingFade * wagon.RingVolume, wagon.RingPitch)
            else
                wagon:SetSoundState(wagon.RingName, ringstate * wagon.RingVolume, wagon.RingPitch)
            end

            if wagon:GetPackedBool("RK") then wagon.RKTimer = CurTime() end
            wagon:SetSoundState("rk", (wagon.RKTimer and CurTime() - wagon.RKTimer < 0.2) and 0.7 or 0, 1)
            -- BPSN sound
            wagon.BPSNType = wagon:GetNW2Int("BPSNType", 13)
            if not wagon.OldBPSNType then wagon.OldBPSNType = wagon.BPSNType end
            if wagon.BPSNType ~= wagon.OldBPSNType then
                for i = 1, 12 do
                    wagon:SetSoundState("bpsn" .. i, 0, 1.0)
                end
            end

            wagon.OldBPSNType = wagon.BPSNType
            if wagon.BPSNType < 13 then
                wagon:SetSoundState("bpsn" .. wagon.BPSNType, wagon:GetPackedBool("BPSN") and 1 or 0, 1) --FIXME громкость по другому
            end

            local cabspeaker = wagon:GetPackedBool("AnnCab")
            local work = wagon:GetPackedBool("AnnPlay")
            local buzz = wagon:GetPackedBool("AnnBuzz") and wagon:GetNW2Int("AnnouncerBuzz", -1) > 0
            local buzz_old = wagon:GetNW2Int("AnnouncerBuzz", -1) == 2
            for k in ipairs(wagon.AnnouncerPositions) do
                wagon:SetSoundState("announcer_buzz" .. k, (buzz and not buzz_old and (k ~= 1 and work or k == 1 and cabspeaker)) and 1 or 0, 1)
                wagon:SetSoundState("announcer_buzz_o" .. k, (buzz and buzz_old and (k ~= 1 and work or k == 1 and cabspeaker)) and 1 or 0, 1)
            end

            for k, v in ipairs(wagon.AnnouncerPositions) do
                if IsValid(wagon.Sounds["announcer" .. k]) then wagon.Sounds["announcer" .. k]:SetVolume((k ~= 1 and work or k == 1 and cabspeaker) and (v[3] or 1) or 0) end
            end
        end
    end

    if SERVER then
        ent.Think = function(wagon)
            wagon.RetVal = wagon.BaseClass.Think(wagon)
            local Panel = wagon.Panel
            local Pneumatic = wagon.Pneumatic
            local power = Panel.V1 > -1.5
            local brightness = math.min(1, Panel.Headlights1) * 0.60 + math.min(1, Panel.Headlights2) * 0.40
            --local T = {}
            wagon:SetPackedBool("Headlights1", Panel.Headlights1 > 0)
            wagon:SetPackedBool("Headlights2", Panel.Headlights2 > 0)
            wagon:SetPackedBool("RedLights", Panel.RedLight2 > 0)
            wagon:SetPackedBool("CabLights", Panel.CabLights > 0)
            wagon:SetPackedBool("EqLights", Panel.EqLights > 0)
            wagon:SetPackedBool("PanelLights", Panel.PanelLights > 0.5)
            local lightsActive1 = Panel.EmergencyLights > 0
            local lightsActive2 = Panel.MainLights > 0.0
            local LampCount = wagon.LampType == 2 and 25 or 12
            local Ip = wagon.LampType == 2 and 7 or 3.6
            local Im = 0
            for i = 1, LampCount do
                if lightsActive2 or lightsActive1 and math.ceil((i + Ip - Im) % Ip) == 1 then
                    if not wagon.Lamps[i] and not wagon.Lamps.broken[i] then wagon.Lamps[i] = CurTime() + math.Rand(0.1, math.Rand(0.5, 2)) end
                else
                    wagon.Lamps[i] = nil
                end

                if wagon.Lamps[i] and CurTime() - wagon.Lamps[i] > 0 then
                    wagon:SetPackedBool("lightsActive" .. i, true)
                else
                    wagon:SetPackedBool("lightsActive" .. i, false)
                end
            end

            if wagon:ReadTrainWire(4) * wagon:ReadTrainWire(5) * wagon:ReadTrainWire(10) > 0 then wagon.A54:TriggerInput("Set", 0) end
            -- Door button lights
            wagon:SetPackedBool("DoorsLeftL", Panel.DoorsLeft > 0.5)
            wagon:SetPackedBool("DoorsRightL", Panel.DoorsRight > 0.5)
            wagon:SetPackedBool("DoorsW", Panel.DoorsW > 0)
            wagon:SetPackedBool("GRP", Panel.GreenRP > 0)
            wagon:SetPackedBool("BrW", Panel.BrW > 0)
            wagon:SetPackedBool("VH1", wagon.BZOS.VH1 > 0)
            wagon:SetPackedBool("VH2", wagon.BZOS.VH2 > 0)
            -- Switch and button states
            wagon:SetPackedBool("GreenRP", Panel.GreenRP > 0.5)
            wagon:SetPackedBool("AVU", Panel.AVU > 0.5)
            wagon:SetPackedBool("LKVP", Panel.LKVP > 0)
            wagon:SetPackedBool("RZP", Panel.RZP > 0)
            wagon:SetPackedBool("KUP", Panel.KUP > 0.5)
            wagon:SetPackedBool("PN", Panel.BrT > 0.5)
            wagon:SetPackedBool("VPR", Panel.VPR > 0)
            -- Signal if doors are open or no to platform simulation
            wagon.LeftDoorsOpen = Pneumatic.LeftDoorState[1] > 0.5 or Pneumatic.LeftDoorState[2] > 0.5 or Pneumatic.LeftDoorState[3] > 0.5 or Pneumatic.LeftDoorState[4] > 0.5
            wagon.RightDoorsOpen = Pneumatic.RightDoorState[1] > 0.5 or Pneumatic.RightDoorState[2] > 0.5 or Pneumatic.RightDoorState[3] > 0.5 or Pneumatic.RightDoorState[4] > 0.5
            -- DIP/power
            wagon:SetPackedBool("LUDS", Panel.LUDS > 0.5)
            -- Red RP
            local TW18 = 0
            if Panel.LSN > 0 then
                local wags = #wagon.WagonList
                for i, v in ipairs(wagon.WagonList) do
                    TW18 = TW18 + (v.Panel.TW18 or 0) / wags
                end
            end

            wagon:SetPackedBool("RP", TW18 > 0.5)
            wagon:SetPackedBool("SN", TW18 > 0)
            wagon:SetPackedRatio("RPR", math.Clamp(TW18 ^ 0.7, 0, 1))
            wagon:SetPackedBool("SD", Panel.SD > 0.5)
            wagon:SetPackedBool("AR04", Panel.AR04 > 0)
            wagon:SetPackedBool("AR0", Panel.AR0 > 0)
            wagon:SetPackedBool("AR40", Panel.AR40 > 0)
            wagon:SetPackedBool("AR60", Panel.AR60 > 0)
            wagon:SetPackedBool("AR70", Panel.AR70 > 0)
            wagon:SetPackedBool("AR80", Panel.AR80 > 0)
            --]]
            local drv = wagon:GetDriver()
            wagon:SetPackedBool("GLIB", power and IsValid(drv) and drv:SteamID() == "STEAM_0:1:31566374")
            -- wagon:SetPackedBool("LEKK", Panel.LEKK > 0)  -- TODO: FIX
            wagon:SetPackedBool("LN", Panel.LN > 0)
            wagon:SetPackedBool("ST", Panel.LST > 0)
            wagon:SetPackedBool("VD", Panel.LVD > 0)
            wagon:SetPackedBool("KVD", Panel.LKVD > 0)
            wagon:SetPackedBool("RS", Panel.RS > 0)
            wagon:SetPackedBool("OneFreq", Panel.OneFreq > 0)
            wagon:SetPackedBool("HRK", Panel.LhRK > 0)
            wagon:SetPackedBool("KVC", Panel.KVC > 0)
            wagon:SetPackedBool("KT", Panel.KT > 0)
            wagon:SetPackedRatio("PVK", wagon.PVK.Value / 2)
            wagon:SetPackedBool("L1", Panel.L1 > 0)
            wagon:SetPackedBool("M1_3", Panel.M1_3 > 0)
            wagon:SetPackedBool("M4_7", Panel.M4_7 > 0)
            wagon:SetPackedRatio("M8", Panel.M8)
            wagon:SetPackedBool("IST", Panel.IST > 0)
            wagon:SetPackedBool("ISTLamp", Panel.IST > 0 and CurTime() % 0.333 > 0.166)
            wagon:SetNW2Int("WrenchMode", wagon.KVWrenchMode)
            wagon:SetPackedBool("ReverserPresent", wagon.KVWrenchMode and wagon.KVWrenchMode > 0)
            wagon:SetPackedRatio("CranePosition", Pneumatic.RealDriverValvePosition)
            wagon:SetPackedRatio("ControllerPosition", (wagon.KV.ControllerPosition + 3) / 7)
            wagon:SetNW2Int("ReverserPosition", wagon.KV.ReverserPosition + 1)
            wagon:SetNW2Int("KRUPosition", wagon.KRU.Position)
            if Pneumatic.ValveType == 1 then
                wagon:SetPackedRatio("BLPressure", Pneumatic.ReservoirPressure / 16.0)
            else
                wagon:SetPackedRatio("BLPressure", Pneumatic.BrakeLinePressure / 16.0)
            end

            wagon:SetPackedRatio("TLPressure", Pneumatic.TrainLinePressure / 16.0)
            wagon:SetPackedRatio("BCPressure", Pneumatic.BrakeCylinderPressure / 6.0)
            wagon:SetPackedRatio("EnginesVoltage", wagon.Electric.Aux750V / 1000.0)
            wagon:SetPackedRatio("EnginesCurrent2", 0.5 + 0.5 * (wagon.Electric.I13 / 500.0))
            wagon:SetPackedRatio("EnginesCurrent", 0.5 + 0.5 * (wagon.Electric.I24 / 500.0))
            ----------------------------------*****************************--------------------------------
            --10th wire voltage readout imitation depending on the BPSNs and EKK state, not on the wagon battery switch state
            -- PC  power converter; CC  control circuits
            local hvcounter = 0
            local hvcar = nil
            local vdrop = 1.125 * #wagon.WagonList
            for k, v in ipairs(wagon.WagonList) do
                if v.PowerSupply.X2_2 > 0 and v.A24.Value > 0 then
                    hvcounter = hvcounter + 1
                    hvcar = hvcar or v
                    vdrop = vdrop - 1.125
                else
                    vdrop = vdrop - ((v.A56.Value == 0 and 0.4 or (v.VB.Value == 0 and 0.4 or 0)) + (v.LK4.Value == 0 and 0.725 or 0))
                end
            end

            local PCV_o = hvcounter > 0 and math.Clamp(76 + (hvcar.Electric.Aux750V - 600) * 8 / 375, 76, 84) - vdrop or wagon.WagonList[1].Battery.Voltage
            --imitating converter overload protection only when control circuits are energized and at least one PC on the train is off; pretty useless btw (but fun)
            local pcloadratio = #wagon.WagonList / (hvcounter > 0 and hvcounter or 0.5)
            local _A = 25 * (6 - 6 / 5.01) --assuming one PC on 6 cars can work for 25 secs while the cars' CCs are energized
            if pcloadratio > 1 and pcloadratio <= #wagon.WagonList and wagon.LK4.Value > 0 and wagon.PowerSupply.X2_2 > 0 and not wagon.pcrlxtimer then
                wagon.pcprotimer = wagon.pcprotimer or CurTime()
                --hyperbolic function of PC operating time depending on load coeff
                if CurTime() - wagon.pcprotimer > _A / (pcloadratio - 6 / 5.01) then wagon.pcrlxtimer = CurTime() end
            else
                if wagon.pcrlxtimer then
                    if CurTime() - wagon.pcrlxtimer < 30 then --30 seconds relaxation time before PC overload protecion can be reset
                        wagon.RZP:TriggerInput("Close", 1)
                    else
                        wagon.pcrlxtimer = nil
                    end
                else
                    wagon.pcprotimer = nil
                end
            end

            wagon.PowerSupply:TriggerInput("3x2", wagon.pcrlxtimer and 1 or 0) --BPSN overheat protection in case of RZP button is being pressed constantly
            ----------------------------------*****************************--------------------------------
            wagon:SetPackedRatio("BatteryVoltage", Panel["V1"] * PCV_o / 150.0)
            wagon:SetPackedBool("Compressor", Pneumatic.Compressor > 0)
            wagon:SetPackedBool("Buzzer", Panel.Ring >= 1)
            wagon:SetPackedBool("BuzzerBZOS", Panel.Ring > 0 and Panel.Ring < 1)
            wagon:SetPackedBool("RK", wagon.RheostatController.Velocity ~= 0.0)
            wagon:SetPackedBool("BPSN", wagon.PowerSupply.X2_2 > 0)
            wagon:SetPackedBool("RearDoor", wagon.RearDoor)
            wagon:SetPackedBool("PassengerDoor", wagon.PassengerDoor)
            wagon:SetPackedBool("CabinDoor", wagon.CabinDoor)
            wagon:SetPackedBool("OtsekDoor1", wagon.OtsekDoor1)
            wagon:SetPackedBool("OtsekDoor2", wagon.OtsekDoor2)
            wagon:SetPackedBool("AnnBuzz", Panel.AnnouncerBuzz > 0)
            wagon:SetPackedBool("AnnPlay", Panel.AnnouncerPlaying > 0)
            wagon:SetPackedBool("AnnCab", wagon.ASNP_VV.CabinSpeakerPower > 0)
            -- Exchange some parameters between engines, pneumatic system, and real world
            wagon.Engines:TriggerInput("Speed", wagon.Speed)
            wagon:SetPackedRatio("Speed", wagon.Speed / 100 or 0.5 or 0.85 - ((CurTime() % 36 / 36) ^ 0.8 * 8.5) / 10 or wagon.Speed / 100)
            if IsValid(wagon.FrontBogey) and IsValid(wagon.RearBogey) and not wagon.IgnoreEngine then
                local A = 2 * wagon.Engines.BogeyMoment
                --wagon.FrontBogey.MotorForce = 27000+1000*(A < 0 and 1 or 0)
                --wagon.RearBogey.MotorForce  = 27000+1000*(A < 0 and 1 or 0)
                wagon.FrontBogey.MotorForce = 22500 + 5500 * (A < 0 and 1 or 0)
                wagon.RearBogey.MotorForce = 22500 + 5500 * (A < 0 and 1 or 0)
                wagon.FrontBogey.Reversed = wagon.Reverser.NZ > 0.5
                wagon.RearBogey.Reversed = wagon.Reverser.VP > 0.5
                -- These corrections are required to beat source engine friction at very low values of motor power
                local P = math.max(0, 0.04449 + 1.06879 * math.abs(A) - 0.465729 * A ^ 2)
                if math.abs(A) > 0.4 then P = math.abs(A) end
                if math.abs(A) < 0.05 then P = 0 end
                if wagon.Speed < 10 then P = P * (1.0 + 0.5 * (10.0 - wagon.Speed) / 10.0) end
                wagon.RearBogey.MotorPower = P * 0.5 * (A > 0 and 1 or -1)
                wagon.FrontBogey.MotorPower = P * 0.5 * (A > 0 and 1 or -1)
                --wagon.RearBogey.MotorPower  = P*0.5
                --wagon.FrontBogey.MotorPower = P*0.5
                --wagon.Acc = (wagon.Acc or 0)*0.95 + wagon.Acceleration*0.05
                -- Apply brakes
                wagon.FrontBogey.PneumaticBrakeForce = 50000.0 - 2000
                wagon.FrontBogey.BrakeCylinderPressure = Pneumatic.BrakeCylinderPressure
                wagon.FrontBogey.ParkingBrakePressure = math.max(0, (2.6 - Pneumatic.ParkingBrakePressure) / 2.6) / 2
                wagon.FrontBogey.BrakeCylinderPressure_dPdT = -Pneumatic.BrakeCylinderPressure_dPdT
                wagon.RearBogey.PneumaticBrakeForce = 50000.0 - 2000
                wagon.RearBogey.BrakeCylinderPressure = Pneumatic.BrakeCylinderPressure
                wagon.RearBogey.BrakeCylinderPressure_dPdT = -Pneumatic.BrakeCylinderPressure_dPdT
                wagon.RearBogey.ParkingBrakePressure = math.max(0, (2.6 - Pneumatic.ParkingBrakePressure) / 2.6) / 2
            end

            wagon:GenerateJerks()
            return wagon.RetVal
        end
    end
end

function RECIPE:InjectNeeded()
    if Metrostroi.Version > 1537278077 then return false end
    return true
end

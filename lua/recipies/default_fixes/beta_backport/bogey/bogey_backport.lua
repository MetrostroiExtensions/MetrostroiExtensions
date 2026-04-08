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
MEL.DefineRecipe("bogey_backport", {"gmod_train_bogey"})
RECIPE.BackportPriority = 3
local C_Require3rdRail = GetConVar("metrostroi_train_requirethirdrail")
function RECIPE:Inject(ent)
    if CLIENT then
        ent.SoundNames = {}
        ent.SoundNames["ted1_703"] = "subway_trains/bogey/engines/703/speed_8.wav"
        ent.SoundNames["ted2_703"] = "subway_trains/bogey/engines/703/speed_16.wav"
        ent.SoundNames["ted3_703"] = "subway_trains/bogey/engines/703/speed_24.wav"
        ent.SoundNames["ted4_703"] = "subway_trains/bogey/engines/703/speed_32.wav"
        ent.SoundNames["ted5_703"] = "subway_trains/bogey/engines/703/speed_40.wav"
        ent.SoundNames["ted6_703"] = "subway_trains/bogey/engines/703/speed_48.wav"
        ent.SoundNames["ted7_703"] = "subway_trains/bogey/engines/703/speed_56.wav"
        ent.SoundNames["ted8_703"] = "subway_trains/bogey/engines/703/speed_64.wav"
        ent.SoundNames["ted9_703"] = "subway_trains/bogey/engines/703/speed_72.wav"
        ent.SoundNames["ted10_703"] = "subway_trains/bogey/engines/703/speed_80.wav"
        ent.SoundNames["ted11_703"] = "subway_trains/bogey/engines/703/speed_88.wav"
        ent.SoundNames["ted1_717"] = "subway_trains/bogey/engines/717/engines_8.wav"
        ent.SoundNames["ted2_717"] = "subway_trains/bogey/engines/717/engines_16.wav"
        ent.SoundNames["ted3_717"] = "subway_trains/bogey/engines/717/engines_24.wav"
        ent.SoundNames["ted4_717"] = "subway_trains/bogey/engines/717/engines_32.wav"
        ent.SoundNames["ted5_717"] = "subway_trains/bogey/engines/717/engines_40.wav"
        ent.SoundNames["ted6_717"] = "subway_trains/bogey/engines/717/engines_48.wav"
        ent.SoundNames["ted7_717"] = "subway_trains/bogey/engines/717/engines_56.wav"
        ent.SoundNames["ted8_717"] = "subway_trains/bogey/engines/717/engines_64.wav"
        ent.SoundNames["ted9_717"] = "subway_trains/bogey/engines/717/engines_72.wav"
        ent.SoundNames["ted10_717"] = "subway_trains/bogey/engines/717/engines_80.wav"
        ent.SoundNames["ted11_720"] = "subway_trains/bogey/engines/720/speed_88.wav"
        ent.SoundNames["ted1_720"] = "subway_trains/bogey/engines/720/speed_8.wav"
        ent.SoundNames["ted2_720"] = "subway_trains/bogey/engines/720/speed_16.wav"
        ent.SoundNames["ted3_720"] = "subway_trains/bogey/engines/720/speed_24.wav"
        ent.SoundNames["ted4_720"] = "subway_trains/bogey/engines/720/speed_32.wav"
        ent.SoundNames["ted5_720"] = "subway_trains/bogey/engines/720/speed_40.wav"
        ent.SoundNames["ted6_720"] = "subway_trains/bogey/engines/720/speed_48.wav"
        ent.SoundNames["ted7_720"] = "subway_trains/bogey/engines/720/speed_56.wav"
        ent.SoundNames["ted8_720"] = "subway_trains/bogey/engines/720/speed_64.wav"
        ent.SoundNames["ted9_720"] = "subway_trains/bogey/engines/720/speed_72.wav"
        ent.SoundNames["ted10_720"] = "subway_trains/bogey/engines/720/speed_80.wav"
        ent.SoundNames["flangea"] = "subway_trains/bogey/skrip1.wav"
        ent.SoundNames["flangeb"] = "subway_trains/bogey/skrip2.wav"
        ent.SoundNames["flange1"] = "subway_trains/bogey/flange_9.wav"
        ent.SoundNames["flange2"] = "subway_trains/bogey/flange_10.wav"
        ent.SoundNames["brakea_loop1"] = "subway_trains/bogey/braking_async1.wav"
        ent.SoundNames["brakea_loop2"] = "subway_trains/bogey/braking_async2.wav"
        ent.SoundNames["brake_loop1"] = "subway_trains/bogey/brake_rattle3.wav"
        ent.SoundNames["brake_loop2"] = "subway_trains/bogey/brake_rattle4.wav"
        ent.SoundNames["brake_loop3"] = "subway_trains/bogey/brake_rattle5.wav"
        ent.SoundNames["brake_loop4"] = "subway_trains/bogey/brake_rattle6.wav"
        ent.SoundNames["brake_loopb"] = "subway_trains/common/junk/junk_background_braking1.wav"
        ent.SoundNames["brake2_loop1"] = "subway_trains/bogey/brake_rattle2.wav"
        ent.SoundNames["brake2_loop2"] = "subway_trains/bogey/brake_rattle_h.wav"
        ent.SoundNames["brake_squeal1"] = "subway_trains/bogey/brake_squeal1.wav"
        ent.SoundNames["brake_squeal2"] = "subway_trains/bogey/brake_squeal2.wav"
        ent.EngineSNDConfig = {{{"ted1_703", 08, 00, 16, 1}, {"ted2_703", 16, 08 - 4, 24, 1}, {"ted3_703", 24, 16 - 4, 32, 1}, {"ted4_703", 32, 24 - 4, 40, 1}, {"ted5_703", 40, 32 - 4, 48, 1}, {"ted6_703", 48, 40 - 4, 56, 1}, {"ted7_703", 56, 48 - 4, 64, 1}, {"ted8_703", 64, 56 - 4, 72, 1}, {"ted9_703", 72, 64 - 4, 80, 1}, {"ted10_703", 80, 72 - 4, 88, 1}, {"ted11_703", 88, 80 - 4, 1},}, {{"ted1_717", 08, 00, 16, 1}, {"ted2_717", 16, 08 - 4, 24, 1}, {"ted3_717", 24, 16 - 4, 32, 1}, {"ted4_717", 32, 24 - 4, 40, 1}, {"ted5_717", 40, 32 - 4, 48, 1}, {"ted6_717", 48, 40 - 4, 56, 1}, {"ted7_717", 56, 48 - 4, 64, 1}, {"ted8_717", 64, 56 - 4, 72, 1}, {"ted9_717", 72, 64 - 4, 80, 1}, {"ted10_717", 80, 72 - 4, 1},}, {{"ted1_720", 08, 00, 16, 1 * 0.4}, {"ted2_720", 16, 08 - 4, 24, 1 * 0.43}, {"ted3_720", 24, 16 - 4, 32, 1 * 0.46}, {"ted4_720", 32, 24 - 4, 40, 1 * 0.49}, {"ted5_720", 40, 32 - 4, 48, 1 * 0.52}, {"ted6_720", 48, 40 - 4, 56, 1 * 0.55}, {"ted7_720", 56, 48 - 4, 64, 1 * 0.58}, {"ted8_720", 64, 56 - 4, 72, 1 * 0.61}, {"ted9_720", 72, 64 - 4, 80, 1 * 0.64}, {"ted10_720", 80, 72 - 4, 88, 1 * 0.67}, {"ted11_720", 88, 80 - 4, 1 * 0.7},},}
        function ent.ReinitializeSounds(wagon)
            -- Remove old sounds
            if wagon.Sounds then
                for k, v in pairs(wagon.Sounds) do
                    v:Stop()
                end
            end

            -- Create sounds
            wagon.Sounds = {}
            for k, v in pairs(wagon.SoundNames) do
                --[[local e = wagon

        if (k == "brake3a") and IsValid(wagon:GetNW2Entity("TrainWheels")) then

            e = wagon:GetNW2Entity("TrainWheels")

        end]]
                wagon.Sounds[k] = CreateSound(wagon, Sound(v))
            end

            wagon.MotorSoundType = nil
        end

        function ent.Initialize(wagon)
            wagon.MotorPowerSound = 0
            wagon.PlayTime = {0, 0}
            wagon.SmoothAngleDelta = 0
            wagon.CurrentBrakeSqueal = 0
            wagon:ReinitializeSounds()
        end

        function ent.OnRemove(wagon)
            if wagon.Sounds then
                for k, v in pairs(wagon.Sounds) do
                    v:Stop()
                end

                wagon.Sounds = {nil}
            end
        end

        function ent.Think(wagon)
            wagon.PrevTime = wagon.PrevTime or RealTime() - 0.33
            wagon.DeltaTime = RealTime() - wagon.PrevTime
            wagon.PrevTime = RealTime()
            -- Get interesting parameters
            local train = wagon:GetNW2Entity("TrainEntity")
            local soundsmul = 1
            local streetC, tunnelC = 0, 1
            if IsValid(train) then
                streetC, tunnelC = train.StreetCoeff or 0, train.TunnelCoeff or 1
                soundsmul = math.Clamp(tunnelC ^ 1.5 + streetC ^ 0.5 * 0.2, 0, 1)
            end

            local speed = wagon:GetSpeed()
            -- Engine sound
            local motorPower = wagon:GetMotorPower() * (1 + math.max(0, (speed - 55) / 35) * 0.4)
            if wagon.MotorSoundType ~= wagon:GetNWInt("MotorSoundType", 1) or wagon.DisableEngines ~= wagon:GetNWBool("DisableEngines") then
                if wagon.MotorSoundType then
                    for _, snd in ipairs(wagon.EngineSNDConfig[wagon.MotorSoundType + 1]) do
                        wagon:SetSoundState(snd[1], 0, 0)
                    end
                end

                wagon.MotorSoundType = wagon:GetNWInt("MotorSoundType", 1)
                wagon.DisableEngines = wagon:GetNWBool("DisableEngines")
                wagon.MotorSoundArr = wagon.EngineSNDConfig[wagon.MotorSoundType + 1]
            end

            if not wagon.DisableEngines and wagon.MotorSoundArr then
                wagon.MotorPowerSound = math.Clamp(wagon.MotorPowerSound + (motorPower - wagon.MotorPowerSound) * wagon.DeltaTime * 3, -1.5, 1.5)
                local t = RealTime() * 2.5
                local modulation = math.max(0, (speed - 60) / 30) * 0.7 + (0.2 + 1.0 * math.max(0, 0.2 + math.sin(t) * math.sin(t * 3.12) * math.sin(t * 0.24) * math.sin(t * 4.0))) * math.Clamp((speed - 15) / 60, 0, 1)
                local mod2 = 1.0 - math.min(1.0, math.abs(wagon.MotorPowerSound) / 0.1)
                if speed > -1.0 and math.abs(wagon.MotorPowerSound) + modulation >= 0.0 then
                    --local startVolRamp = 0.2 + 0.8*math.max(0.0,math.min(1.0,(speed - 1.0)*0.5))
                    local powerVolRamp
                    if wagon.MotorSoundType == 2 then
                        powerVolRamp = 0.2 * modulation * mod2 + 6 * math.abs(wagon.MotorPowerSound) --2.0*(math.abs(motorPower)^2)
                    else
                        powerVolRamp = 0.3 * modulation * mod2 + 2 * math.abs(wagon.MotorPowerSound) --2.0*(math.abs(motorPower)^2)
                    end

                    --local k,x = 1.0,math.max(0,math.min(1.1,(speed-1.0)/80))
                    --local motorPchRamp = (k*x^3 - k*x^2 + x)
                    --local motorPitch = 0.03+1.85*motorPchRamp
                    local volumemul = math.min(1, (speed / 4) ^ 3)
                    local motorsnd = math.min(1.0, math.max(0.0, 1.25 * math.abs(wagon.MotorPowerSound)))
                    local motorvol = soundsmul ^ 0.3 * math.Clamp(motorsnd + powerVolRamp, 0, 1) * volumemul
                    for i, snd in ipairs(wagon.MotorSoundArr) do
                        local prev = wagon.MotorSoundArr[i - 1]
                        local next = wagon.MotorSoundArr[i + 1]
                        local volume = 1
                        if prev and speed <= prev[4] then
                            volume = math.max(0, 1 - (prev[4] - speed) / (prev[4] - snd[3]))
                        elseif next and speed > next[3] then
                            volume = math.max(0, (snd[4] - speed) / (snd[4] - next[3]))
                        end

                        local pitch = math.max(0, speed / snd[2]) + 0.06 * streetC
                        wagon:SetSoundState(snd[1], motorvol * volume * (snd[5] or 1), math.Clamp(pitch, 0, 2))
                    end
                end
            end

            --Stop old sounds when we changind brake squeal type
            if wagon.Async ~= wagon:GetNWBool("Async") then
                wagon:SetSoundState("brake_loop1", 0, 0)
                wagon:SetSoundState("brake_loop2", 0, 0)
                wagon:SetSoundState("brake_loop3", 0, 0)
                wagon:SetSoundState("brake_loop4", 0, 0)
                wagon:SetSoundState("brake_loopb", 0, 0)
                wagon:SetSoundState("brake2_loop1", 0, 0)
                wagon:SetSoundState("brake2_loop2", 0, 0)
                wagon:SetSoundState("brakea_loop1", 0, 0)
                wagon:SetSoundState("brakea_loop2", 0, 0)
                wagon.Async = wagon:GetNWBool("Async")
            end

            if wagon.Async then
                local brakeSqueal = wagon:GetNW2Float("BrakeSqueal", 0)
                if brakeSqueal > 0.0 then
                    local nominalSqueal = wagon:GetNWFloat("SqualPitch", 1)
                    local secondSqueal = math.Clamp(1 - (speed - 2) / 5, 0, 1)
                    local squealPitch = nominalSqueal + secondSqueal * 0.05
                    local squealVolume = math.Clamp(speed / 2, 0, 1)
                    local volume = brakeSqueal * squealVolume * math.Clamp(1 - (speed - 2) / 3, 0, 1)
                    wagon:SetSoundState("brakea_loop1", volume * (1 - secondSqueal * 0.5) * 0.4, squealPitch, false, 75)
                    wagon:SetSoundState("brakea_loop2", volume * secondSqueal * 0.4, squealPitch, false, 75)
                elseif wagon.CurrentBrakeSqueal > 0 then
                    wagon:SetSoundState("brakea_loop1", 0, 0)
                    wagon:SetSoundState("brakea_loop2", 0, 0)
                end

                wagon.CurrentBrakeSqueal = brakeSqueal
            else
                local brakeSqueal1 = math.max(0.0, math.min(2, wagon:GetNW2Float("BrakeSqueal1")))
                if not wagon.SquealVolume or brakeSqueal1 <= 0 and wagon.CurrentBrakeSqueal > 0 or wagon.SquealType ~= wagon:GetNW2Int("SquealType", 1) then
                    wagon.SquealType = wagon:GetNW2Int("SquealType", 1)
                    wagon.SquealSound1 = "brake_loop" .. wagon.SquealType
                    wagon.SquealVolume = wagon.SquealType == 1 and 0.2 or 1
                    wagon:SetSoundState("brake_loop1", 0, 0)
                    wagon:SetSoundState("brake_loop2", 0, 0)
                    wagon:SetSoundState("brake_loop3", 0, 0)
                    wagon:SetSoundState("brake_loop4", 0, 0)
                    wagon:SetSoundState("brake_loopb", 0, 0)
                    wagon:SetSoundState("brake2_loop1", 0, 0)
                    wagon:SetSoundState("brake2_loop2", 0, 0)
                elseif brakeSqueal1 > 0 then
                    --local brakeRamp1 = math.min(1.0,math.max(0.0,(speed-10)/50.0))^1.5
                    local brakeRamp2 = math.min(1.0, math.max(0.0, speed / 3.0))
                    local ramp = 0.3 + math.Clamp((40 - speed) / 40, 0, 1) * 0.7
                    if wagon.SquealType <= 4 then
                        wagon:SetSoundState(wagon.SquealSound1, soundsmul * brakeSqueal1 * ramp * wagon.SquealVolume, 1 + 0.05 * (1.0 - brakeRamp2))
                        --[[wagon:SetSoundState("brake_loop1",typ==1 and soundsmul*brakeSqueal1*ramp*0.2 or 0,1+0.05*(1.0-brakeRamp2))

                    wagon:SetSoundState("brake_loop2",typ==2 and soundsmul*brakeSqueal1*ramp or 0,1+0.05*(1.0-brakeRamp2))

                    wagon:SetSoundState("brake_loop3",typ==3 and soundsmul*brakeSqueal1*ramp or 0,1+0.05*(1.0-brakeRamp2))

                    wagon:SetSoundState("brake_loop4",typ==4 and soundsmul*brakeSqueal1*ramp or 0,1+0.05*(1.0-brakeRamp2))

                    wagon:SetSoundState("brake_loopb",typ<=4 and 0*soundsmul*brakeSqueal1*ramp*0.4 or 0,1+0.05*(1.0-brakeRamp2))]]
                    elseif wagon.SquealType <= 7 then
                        local loop_h = soundsmul * brakeSqueal1 * ramp * 0.5
                        if loop_h > 0.1 and speed > 1.5 then
                            if not wagon.HighLoop then wagon.HighLoop = math.random() > 0.5 and "brake_squeal2" or "brake_squeal1" end
                            wagon:SetSoundState(wagon.HighLoop, loop_h * 1.5, 1)
                        elseif loop_h < 0.02 and wagon.HighLoop then
                            wagon:SetSoundState(wagon.HighLoop, 0, 0)
                            wagon.HighLoop = false
                        end

                        wagon.StartLoopStrength = loop_h
                        if wagon.SquealType <= 6 then wagon:SetSoundState("brake2_loop1", math.Clamp(loop_h * 0.5, 0, 0.5), 1 + 0.06 * (1.0 - brakeRamp2)) end
                        if wagon.SquealType >= 6 then wagon:SetSoundState("brake2_loop2", loop_h * 0.3, 1 + 0.06 * (1.0 - brakeRamp2)) end
                    end
                end

                wagon.CurrentBrakeSqueal = brakeSqueal1
            end

            -- Generate procedural landscape thingy
            local a = wagon:GetPos().x
            local b = wagon:GetPos().y
            local c = wagon:GetPos().z
            local f = math.sin(c / 200 + a * c / 3e7 + b * c / 3e7) --math.sin(a/3000)*math.sin(b/3000)
            -- Calculate flange squeal
            wagon.PreviousAngles = wagon.PreviousAngles or wagon:GetAngles()
            local deltaAngleYaw = math.abs(wagon:GetAngles().yaw - wagon.PreviousAngles.yaw)
            deltaAngleYaw = deltaAngleYaw % 360
            if deltaAngleYaw >= 180 then deltaAngleYaw = deltaAngleYaw - 360 end
            local speedAdd = math.max(1, math.min(2, 1 - (speed - 60) / 40))
            local deltaAngle = deltaAngleYaw / math.max(0.1, wagon.DeltaTime) * speedAdd
            deltaAngle = math.max(math.min(1.0, f * 10) * math.abs(deltaAngle), 0)
            wagon.PreviousAngles = wagon:GetAngles()
            -- Smooth it out
            wagon.SmoothAngleDelta = math.min(7, wagon.SmoothAngleDelta + (deltaAngle - wagon.SmoothAngleDelta) * 2 * wagon.DeltaTime)
            -- Create sound
            local speed_mod = math.min(1.0, math.max(0.0, speed / 5))
            local flangea = math.Clamp((speed - 18) / 25, 0, 1)
            local x = wagon.SmoothAngleDelta
            local f1 = math.max(0, x - 0.5) * 0.1
            local f2 = math.max(0, x - 3 - flangea * 1) * 0.6
            local f3 = math.max(0, x - 4.0 - flangea * 1.5) * 0.6
            local t = RealTime()
            local modulation = 1.5 * math.max(0, 0.2 + math.sin(t) * math.sin(t * 3.12) * math.sin(t * 0.24) * math.sin(t * 4.0))
            local pitch40 = math.max(0.9, 1.0 + (speed - 40.0) / 160.0)
            --local pitch60 = math.max(0.9,1.0+(speed-60.0)/160.0)
            -- Play it
            wagon:SetSoundState("flangea", (0.3 + soundsmul * 0.7) * speed_mod * math.Clamp(f2, 0, 1), pitch40)
            wagon:SetSoundState("flangeb", (0.3 + soundsmul * 0.7) * speed_mod * math.Clamp(f3 * modulation, 0, 1), pitch40)
            wagon:SetSoundState("flange1", (0.3 + soundsmul * 0.7) * speed_mod * f1 * modulation, pitch40)
            wagon:SetSoundState("flange2", (0.3 + soundsmul * 0.7) * speed_mod * f1, pitch40)
        end

        net.Receive("metrostroi_bogey_contact", function()
            local wagon = net.ReadEntity()
            if not IsValid(wagon) or not wagon.PlayTime then return end
            local PantNum = net.ReadUInt(1) + 1
            local PantPos = net.ReadVector()
            local Spark = net.ReadUInt(1) > 0
            local dt = CurTime() - wagon.PlayTime[PantNum]
            wagon.PlayTime[PantNum] = CurTime()
            local volume = 0.53
            if dt < 1.0 then volume = 0.43 end
            sound.Play("subway_trains/bogey/tr_" .. math.random(1, 5) .. ".wav", wagon:LocalToWorld(PantPos), 65, math.random(90, 120), volume)
            if not Spark then return end
            local effectdata = EffectData()
            effectdata:SetOrigin(wagon:LocalToWorld(PantPos))
            effectdata:SetNormal(Vector(0, 0, -1))
            util.Effect("stunstickimpact", effectdata, true, true)
            local light = ents.CreateClientside("gmod_train_dlight")
            light:SetPos(effectdata:GetOrigin())
            light:SetDColor(Color(100, 220, 255))
            light:SetSize(256)
            light:SetBrightness(5)
            light:Spawn()
            SafeRemoveEntityDelayed(light, 0.1)
            sound.Play("subway_trains/bogey/spark.mp3", effectdata:GetOrigin(), 75, math.random(100, 150), volume)
        end)
    end

    if SERVER then
        util.AddNetworkString("metrostroi_bogey_contact")
        function ent.InitializeWheels(wagon)
            -- Create missing wheels
            if IsValid(wagon.Wheels) then SafeRemoveEntity(wagon.Wheels) end
            local wheels = ents.Create("gmod_train_wheels")
            local typ = wagon.Types[wagon.BogeyType or "717"]
            wheels.Model = typ[4]
            if typ and typ[3] then wheels:SetAngles(wagon:LocalToWorldAngles(typ[3])) end
            if typ and typ[2] then wheels:SetPos(wagon:LocalToWorld(typ[2])) end
            wheels.WheelType = wagon.BogeyType
            wheels.NoPhysics = wagon.NoPhysics
            wheels:Spawn()
            if wagon.NoPhysics then
                wheels:SetParent(wagon)
            else
                constraint.Weld(wagon, wheels, 0, 0, 0, 1, 0)
            end

            if CPPI then wheels:CPPISetOwner(wagon:CPPIGetOwner() or wagon:GetNW2Entity("TrainEntity"):GetOwner()) end
            wheels:SetNW2Entity("TrainBogey", wagon)
            wagon.Wheels = wheels
        end

        function ent.CheckContact(wagon, pos, dir, id, cpos)
            local result = util.TraceHull({
                start = wagon:LocalToWorld(pos),
                endpos = wagon:LocalToWorld(pos + dir * 10),
                mask = -1,
                filter = {wagon:GetNW2Entity("TrainEntity"), wagon},
                mins = Vector(-2, -2, -2),
                maxs = Vector(2, 2, 2)
            })

            if not result.Hit then return end
            if result.HitWorld then return true end
            local traceEnt = result.Entity
            if not wagon.Connectors[id] and traceEnt:GetClass() == "gmod_track_udochka" then
                if not traceEnt.Timer and traceEnt.CoupledWith ~= wagon then
                    traceEnt:SetPos(wagon:LocalToWorld(cpos))
                    traceEnt:SetAngles(wagon:GetAngles())
                    if IsValid(constraint.Weld(wagon, traceEnt, 0, 0, 33000, true, false)) then
                        traceEnt:SetPos(wagon:LocalToWorld(cpos))
                        traceEnt:SetAngles(wagon:GetAngles())
                        traceEnt.Coupled = wagon
                        sound.Play("udochka_connect.wav", traceEnt:GetPos())
                        wagon.Connectors[id] = traceEnt
                        DropEntityIfHeld(traceEnt)
                    end
                end
                return false
            elseif wagon.Connectors[id] == traceEnt then
                if traceEnt.Coupled == nil then wagon.Connectors[id] = nil end
                return false
            elseif traceEnt:GetClass() == "player" and wagon.Voltage > 40 then
                local pPos = traceEnt:GetPos()
                wagon.VoltageDropByTouch = (wagon.VoltageDropByTouch or 0) + 1
                util.BlastDamage(traceEnt, traceEnt, pPos, 64, 3.0 * wagon.Voltage)
                local effectdata = EffectData()
                effectdata:SetOrigin(pPos + Vector(0, 0, -16 + math.random() * (40 + 0)))
                util.Effect("cball_explode", effectdata, true, true)
                sound.Play("ambient/energy/zap" .. math.random(1, 3) .. ".wav", pPos, 75, math.random(100, 150), 1.0)
                return
            end
            return result.Hit
        end

        function ent.CheckVoltage(wagon, dT)
            -- Check contact states
            if CurTime() - wagon.CheckTimeout <= 0.25 then return end
            wagon.CheckTimeout = CurTime()
            local supported = C_Require3rdRail:GetInt() > 0 and Metrostroi.MapHasFullSupport()
            local feeder = wagon.Feeder and Metrostroi.Voltages[wagon.Feeder]
            local contacts = not wagon.DisableContacts and not wagon.DisableContactsManual
            local volt = contacts and (feeder or Metrostroi.Voltage or 750) or 0
            -- Non-metrostroi maps
            if not supported then
                wagon.Voltage = volt
                wagon.NextStates[1] = contacts
                wagon.NextStates[2] = contacts
                wagon.ContactStates = wagon.NextStates
                return
            end

            wagon.VoltageDropByTouch = 0
            wagon.NextStates[1] = contacts and wagon:CheckContact(wagon.PantLPos, Vector(0, -1, 0), 1, wagon.PantLCPos)
            wagon.NextStates[2] = contacts and wagon:CheckContact(wagon.PantRPos, Vector(0, 1, 0), 2, wagon.PantRCPos)
            -- Detect changes in contact states
            for i = 1, 2 do
                local state = wagon.NextStates[i]
                if state ~= wagon.ContactStates[i] then
                    wagon.ContactStates[i] = state
                    if not state then continue end
                    net.Start("metrostroi_bogey_contact")
                    net.WriteEntity(wagon) -- Bogey
                    net.WriteUInt(i - 1, 1) -- PantNum
                    net.WriteVector(i == 1 and wagon.PantLPos or wagon.PantRPos) -- PantPos
                    net.WriteUInt(math.random() > math.Clamp(1 - wagon.MotorPower / 2, 0, 1) and 1 or 0, 1) -- Sparking probability
                    net.Broadcast()
                end
            end

            -- Voltage spikes
            wagon.VoltageDrop = math.max(-30, math.min(30, wagon.VoltageDrop + (0 - wagon.VoltageDrop) * 10 * dT))
            -- Detect voltage
            wagon.Voltage = 0
            wagon.DropByPeople = 0
            for i = 1, 2 do
                if wagon.ContactStates[i] then
                    wagon.Voltage = volt + wagon.VoltageDrop
                elseif IsValid(wagon.Connectors[i]) and wagon.Connectors[i].Coupled == wagon then
                    wagon.Voltage = wagon.Connectors[i].Power and Metrostroi.Voltage or 0
                end
            end

            if wagon.VoltageDropByTouch > 0 then
                local Rperson = 0.613
                local Iperson = Metrostroi.Voltage / (Rperson / (wagon.VoltageDropByTouch + 1e-9))
                wagon.DropByPeople = Iperson
            end
        end

        function ent.Think(wagon)
            -- Re-initialize wheels
            if not IsValid(wagon.Wheels) or wagon.Wheels:GetNW2Entity("TrainBogey") ~= wagon then
                wagon:InitializeWheels()
                constraint.NoCollide(wagon.Wheels, wagon, 0, 0)
                if IsValid(wagon:GetNW2Entity("TrainEntity")) then constraint.NoCollide(wagon.Wheels, wagon:GetNW2Entity("TrainEntity"), 0, 0) end
            end

            -- Update timing
            wagon.PrevTime = wagon.PrevTime or CurTime()
            wagon.DeltaTime = CurTime() - wagon.PrevTime
            wagon.PrevTime = CurTime()
            wagon:SetNW2Entity("TrainWheels", wagon.Wheels)
            wagon:CheckVoltage(wagon.DeltaTime)
            -- Skip physics related stuff
            if wagon.NoPhysics or not wagon.Wheels:GetPhysicsObject():IsValid() then
                wagon:SetMotorPower(wagon.MotorPower or 0)
                wagon:SetSpeed(wagon.Speed or 0)
                wagon:NextThink(CurTime())
                return true
            end

            -- Get speed of bogey in km/h
            local localSpeed = -wagon:GetVelocity():Dot(wagon:GetAngles():Forward()) * 0.06858
            local absSpeed = math.abs(localSpeed)
            if wagon.Reversed then localSpeed = -localSpeed end
            local sign = 1
            if localSpeed < 0 then sign = -1 end
            wagon.Speed = absSpeed
            wagon.SpeedSign = wagon.Reversed and -sign or sign
            -- Calculate acceleration in m/s
            wagon.Acceleration = 0.277778 * (wagon.Speed - (wagon.PrevSpeed or 0)) / wagon.DeltaTime
            wagon.PrevSpeed = wagon.Speed
            -- Add variables to debugger
            wagon.Variables["Speed"] = wagon.Speed
            wagon.Variables["Acceleration"] = wagon.Acceleration
            -- Calculate motor power
            local motorPower = 0.0
            if wagon.MotorPower > 0.0 then
                motorPower = math.Clamp(wagon.MotorPower, -1, 1)
            else
                motorPower = math.Clamp(wagon.MotorPower * sign, -1, 1)
            end

            -- Increace forces on slopes
            local slopemul = 1
            local pitch = wagon:GetAngles().pitch * sign
            if motorPower < 0 and pitch > 3 then
                slopemul = slopemul + math.Clamp((math.abs(pitch) - 3) / 3, 0, 1)
            else
                slopemul = slopemul + math.Clamp((pitch - 3) / 3, 0, 1) * 1.5
            end

            -- Final brake cylinder pressure
            local pneumaticPow = wagon.PneumaticPow or 1
            local pB = not wagon.DisableParking and wagon.ParkingBrakePressure or 0
            local BrakeCP = ((wagon.BrakeCylinderPressure / 2.7 + pB / 1.6) ^ pneumaticPow * 2.7) / 4.5 -- + (wagon.ParkingBrake and 1 or 0)
            if BrakeCP * 4.5 > 1.5 - math.Clamp(math.abs(pitch) / 1, 0, 1) and absSpeed < 1 then
                wagon.Wheels:GetPhysicsObject():SetMaterial("gmod_silent")
            else
                wagon.Wheels:GetPhysicsObject():SetMaterial("gmod_ice")
            end

            -- Calculate forces
            local motorForce = wagon.MotorForce * motorPower * slopemul
            local pneumaticFactor = math.Clamp(0.5 * wagon.Speed, 0, 1) * (1 + math.Clamp((2 - wagon.Speed) / 2, 0, 1) * 0.5)
            local pneumaticForce = 0
            if BrakeCP >= 0.05 then
                local slopemulBr = 1
                if -3 > pitch or pitch > 3 then slopemulBr = 1 + math.Clamp((math.abs(pitch) - 3) / 3, 0, 1) * 0.7 end
                pneumaticForce = -sign * pneumaticFactor * wagon.PneumaticBrakeForce * BrakeCP * slopemulBr
            end

            -- Compensate forward friction
            local compensateA = wagon.Speed / 86
            local compensateF = sign * wagon:GetPhysicsObject():GetMass() * compensateA
            -- Apply sideways friction
            local sideSpeed = -wagon:GetVelocity():Dot(wagon:GetAngles():Right()) * 0.06858
            if sideSpeed < 0.5 then sideSpeed = 0 end
            local sideForce = sideSpeed * 0.5 * wagon:GetPhysicsObject():GetMass()
            -- Apply force
            local dt_scale = 66.6 / (1 / wagon.DeltaTime)
            --print(pneumaticForce)
            local force = dt_scale * (motorForce + pneumaticForce + compensateF)
            local side_force = dt_scale * sideForce
            if wagon.Reversed then
                wagon:GetPhysicsObject():ApplyForceCenter(wagon:GetAngles():Forward() * force + wagon:GetAngles():Right() * side_force)
            else
                wagon:GetPhysicsObject():ApplyForceCenter(-wagon:GetAngles():Forward() * force + wagon:GetAngles():Right() * side_force)
            end

            -- Apply Z axis damping
            local avel = wagon:GetPhysicsObject():GetAngleVelocity()
            local avelz = math.min(20, math.max(-20, avel.z))
            local damping = Vector(0, 0, -avelz) * 0.75 * dt_scale
            wagon:GetPhysicsObject():AddAngleVelocity(damping)
            -- Calculate brake squeal
            wagon.SquealSensitivity = 1
            local BCPress = math.abs(wagon.BrakeCylinderPressure)
            wagon.RattleRandom = wagon.RattleRandom or 0.5 + math.random() * 0.2
            local PnF1 = math.Clamp((BCPress - 0.6) / 0.6, 0, 2)
            local PnF2 = math.Clamp((BCPress - wagon.RattleRandom) / 0.6, 0, 2)
            local brakeSqueal1 = PnF1 * PnF2 * pneumaticFactor
            --local brakeSqueal2 = (PnF1*PnF3)*pneumaticFactor
            -- Send parameters to client
            if wagon.DisableSound < 1 then wagon:SetMotorPower(motorPower) end
            if wagon.DisableSound < 2 then
                if wagon:GetNWBool("Async") then
                    wagon:SetNW2Float("BrakeSqueal", (wagon.BrakeCylinderPressure - 0.9) / 1.7)
                else
                    wagon:SetNW2Float("BrakeSqueal1", brakeSqueal1)
                end
            end

            if wagon.DisableSound < 3 then wagon:SetSpeed(absSpeed) end
            wagon:NextThink(CurTime())
            -- Trigger outputs
            if Wire_TriggerOutput then
                Wire_TriggerOutput(wagon, "Speed", absSpeed)
                Wire_TriggerOutput(wagon, "Voltage", wagon.Voltage)
                Wire_TriggerOutput(wagon, "BrakeCylinderPressure", wagon.BrakeCylinderPressure)
            end
            return true
        end
    end
end

function RECIPE:InjectNeeded()
    if Metrostroi.Version > 1537278077 then return false end
    return true
end

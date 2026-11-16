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

MEL.DefineRecipe("bogey_fix_breaking_changes", "gmod_train_bogey")
function RECIPE:Inject(ent, entclass)
    -- да.
    ent.Think = function(wagon)
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
        if wagon.MotorSoundType ~= wagon:GetNWInt("MotorSoundType", 1) or wagon.DisableEngines ~= wagon:GetNWBool("DisableEngines") or not wagon:GetNWBool("DisableEngines") and not wagon.MotorSoundArr then
            if wagon.MotorSoundType then
                -- берем говнокод у лучших
                wagon.MotorSoundArr = wagon.EngineSNDConfig and wagon.EngineSNDConfig[wagon.MotorSoundType + 1]
                if wagon.MotorSoundArr and not istable(wagon.MotorSoundArr[1]) then
                    -- then it have old format
                    wagon.MotorSoundArr = wagon.EngineSNDConfig
                end
                for _, snd in ipairs(wagon.MotorSoundArr or {}) do
                    local soundname = snd
                    if istable(snd) then soundname = snd[1] end
                    wagon:SetSoundState(soundname, 0, 0)
                end
            end

            wagon.MotorSoundType = wagon:GetNWInt("MotorSoundType", 1)
            wagon.DisableEngines = wagon:GetNWBool("DisableEngines")
            wagon.MotorSoundArr = not wagon.DisableEngines and wagon.EngineSNDConfig and wagon.EngineSNDConfig[wagon.MotorSoundType + 1]
            if wagon.MotorSoundArr and not istable(wagon.MotorSoundArr[1]) then
                -- then it have old format
                wagon.MotorSoundArr = wagon.EngineSNDConfig
            end
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
end

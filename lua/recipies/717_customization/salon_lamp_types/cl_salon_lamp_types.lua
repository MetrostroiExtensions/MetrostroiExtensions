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

MEL.DefineRecipe("salon_lamp_types", "717_714")
local MODELS_ROOT = "models/metrostroi_train/81-717/"
local MAX_GLOW_COUNT = 48
local COLOR_WHITE = Vector(255, 255, 255)
local logError = MEL.LogErrorFactory()
local function getLampData(wagon)
    local lamp_data = MEL.RecipeSpecific.SalonLampList[wagon:GetNW2Int("SalonLampType", 1)]
    if MEL.Helpers.Is717(wagon:GetClass()) then
        return lamp_data.head
    else
        return lamp_data.int
    end
end

local function getGlowData(wagon)
    return getLampData(wagon).glow
end

function RECIPE:Inject(ent, entclass)
    -- remove default lamps
    MEL.DeleteClientProp(ent, "lamps1")
    MEL.DeleteClientProp(ent, "lamps2")
    MEL.DeleteClientProp(ent, "lamps")
    for i = 0, 26 do
        MEL.DeleteClientProp(ent, "lamp1_" .. i + 1)
        MEL.DeleteClientProp(ent, "lamp2_" .. i + 1)
    end

    -- add new clientprops
    MEL.NewClientProp(ent, "salon_lamps_base", {
        model = MODELS_ROOT .. "lamps_type1.mdl",
        pos = vector_origin,
        ang = angle_zero,
        hide = 1.5,
        modelcallback = function(wagon) return getLampData(wagon).model end,
        callback = function(wagon, cent)
            local lamp_data = getLampData(wagon)
            if lamp_data.callback then lamp_data.callback(wagon, cent) end
        end
    }, "SalonLampType")

    for i = 1, MAX_GLOW_COUNT do
        -- first two glows always used (first one is emergency lighting, second one is main lighting)
        MEL.NewClientProp(ent, "salon_lamps_glow" .. i, {
            model = MODELS_ROOT .. "lamps/lamp_typ1.mdl",
            pos = vector_origin,
            ang = angle_zero,
            hideseat = 1.1,
            modelcallback = function(wagon)
                local glow_data = getGlowData(wagon)
                if glow_data.count == 1 and i == 1 then return glow_data.model_emergency end
                return glow_data.model
            end,
            callback = function(wagon, cent)
                local glow_data = getGlowData(wagon)
                if i > 2 and i > glow_data.count then
                    cent:SetNoDraw(true)
                    return
                end

                if glow_data.callback then glow_data.callback(wagon, cent, i) end
            end
        }, "SalonLampType")
    end

    ent.UpdateLampsColors = function(wagon)
        local lamp_data = MEL.RecipeSpecific.SalonLampList[wagon:GetNW2Int("SalonLampType", 1)]
        local lamp_amount = lamp_data.int.glow.count
        if string.find(wagon:GetClass(), "717") then lamp_amount = lamp_data.head.glow.count end
        if not wagon.SalonLamps then
            wagon.SalonLamps = {
                broken = {}
            }
        end

        local rand = math.random() > 0.8 and 1 or math.random(0.95, 0.99)
        local colors = {COLOR_WHITE}
        if lamp_data.random_color then colors = lamp_data.random_color(lamp_amount) end
        local mean_color_sum, mean_count, mean_current_lamp_id = Vector(), 0, 11
        for i = 1, lamp_amount do
            local color = colors[i] or COLOR_WHITE
            wagon:SetNW2Vector("SalonLampColor" .. i, color)
            wagon.SalonLamps.broken[i] = math.random() > rand and math.random() > 0.7
            if not lamp_data.light_color then
                mean_color_sum = mean_color_sum + color
                mean_count = mean_count + 1
                if i % (lamp_amount / 3) < 1 then
                    if mean_current_lamp_id > 13 then
                        logError("mean_current_lamp_id is more, than available lamps. Please report this error. Lamp name: " .. lamp_data.name .. ", lamp model id: " .. i)
                        return
                    end

                    local mean_color = (mean_color_sum / mean_count) / 255
                    wagon:SetNW2Vector("lampD" .. mean_current_lamp_id, Vector(mean_color.r, mean_color.g ^ 3, mean_color.b ^ 3) * 255)
                    mean_color_sum, mean_count = Vector(), 0
                    mean_current_lamp_id = mean_current_lamp_id + 1
                end
            end
        end

        if lamp_data.light_color then
            local light_color = lamp_data.light_color
            for i = 11, 13 do
                wagon:SetNW2Vector("lampD" .. i, Vector(light_color.r, light_color.g, light_color.b))
            end
            return
        end

        -- 13 + 1 cause we do +1 in last iteration while counting mean color, if everything goes normally
        if mean_current_lamp_id ~= 13 + 1 then
            -- if we didn't changed colors on all lights, than just do it manually (but get a mean from ALL colors)
            mean_color_sum = Vector()
            for _, color in pairs(colors) do
                mean_color_sum = mean_color_sum + (color or COLOR_WHITE)
            end

            local mean_color = (mean_color_sum / #colors) / 255
            for i = 11, 13 do
                wagon:SetNW2Vector("lampD" .. i, Vector(mean_color.r, mean_color.g ^ 3, mean_color.b ^ 3) * 255)
            end
        end
    end

    MEL.InjectIntoClientFunction(ent, "Think", function(wagon)
        local lamp_data = getLampData(wagon)
        local glow_data = lamp_data.glow
        if glow_data.count == 1 then
            local emergencyLights = wagon:GetPackedBool("EmergencyLights")
            local mainLights = wagon:GetPackedBool("MainLights")
            wagon:ShowHide("salon_lamps_glow1", emergencyLights and not mainLights)
            wagon:ShowHide("salon_lamps_glow2", mainLights)
        else
            for i = 1, glow_data.count do
                local color_vector = wagon:GetNW2Vector("SalonLampColor" .. i)
                local color = Color(color_vector.x, color_vector.y, color_vector.z)
                local state = wagon:Animate("SalonLamp" .. i, wagon:GetPackedBool("SalonLampEnabled" .. i) and 1 or 0, 0, 1, 6, false)
                wagon:ShowHideSmooth("salon_lamps_glow" .. i, state, color)
            end
        end
    end, 1)
end

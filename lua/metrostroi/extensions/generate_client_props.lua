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

-- да, за это на меня выльется тонна говна.
-- уважаемые, не нравится - не пользуйтесь экстом))))))))))))
-- и моделями тоже, пожалуйста
local function addAutoAnim(wagon, name, func)
    if wagon.AutoAnimIndexes[name] then
        wagon.AutoAnims[wagon.AutoAnimIndexes[name]] = func
    else
        wagon.AutoAnimIndexes[name] = table.insert(wagon.AutoAnims, func)
    end
    return wagon.AutoAnimIndexes[name]
end

local function newGenerateClientProps()
    function Metrostroi.GenerateClientProps(ent)
        local wagon = ent or ENT
        if not wagon.ButtonMapCopy then wagon.ButtonMapCopy = {} end
        if not wagon.AutoAnimNames then wagon.AutoAnimNames = {} end
        if not wagon.AutoAnimIndexes then wagon.AutoAnimIndexes = {} end
        if not wagon.ButtonMap then
            MEL._LogWarning(Format("weird, but ButtonMap for wagon with class %s is nil. lol", MEL.GetEntclass(wagon)))
            return
        end

        for id, panel in pairs(wagon.ButtonMap) do
            if not wagon.ButtonMapCopy[id] then wagon.ButtonMapCopy[id] = table.Copy(panel) end
            if not panel.buttons then continue end
            if not panel.props then panel.props = {} end
            if not panel.props_kv then panel.props_kv = {} end
            for name, buttons in pairs(panel.buttons or {}) do
                --if reti > 8 then reti=0; ret=ret.."\n" end
                if buttons.tooltipFunc then
                    local func = buttons.tooltipFunc
                    buttons.tooltipState = function(wag)
                        local str = func(wag)
                        if not str then return "" end
                        return "\n[" .. str:gsub("\n", "]\n[") .. "]"
                    end
                elseif buttons.varTooltip then
                    local states = buttons.states or {"Train.Buttons.Off", "Train.Buttons.On"}
                    local count = #states - 1
                    buttons.tooltipState = function(wag) return Format("\n[%s]", Metrostroi.GetPhrase(states[math.floor(buttons.varTooltip(wag) * count + 0.5) + 1]):gsub("\n", "]\n[")) end
                elseif buttons.var then
                    local var = buttons.var
                    local st1, st2 = "Train.Buttons.Off", "Train.Buttons.On"
                    if buttons.states then
                        st1 = buttons.states[1]
                        st2 = buttons.states[2]
                    end

                    buttons.tooltipState = function(wag) return Format("\n[%s]", Metrostroi.GetPhrase(wag:GetPackedBool(var) and st2 or st1):gsub("\n", "]\n[")) end
                end

                if buttons.model then
                    local config = buttons.model
                    local name = config.name or buttons.ID
                    if config.tooltipFunc then
                        local func = config.tooltipFunc
                        buttons.tooltipState = function(wag)
                            local str = func(wag)
                            if not str then return "" end
                            return "\n[" .. str:gsub("\n", "]\n[") .. "]"
                        end
                    elseif config.varTooltip then
                        local states = config.states or {"Train.Buttons.Off", "Train.Buttons.On"}
                        local count = #states - 1
                        local func = config.getfunc
                        if config.varTooltip == true and func then
                            buttons.tooltipState = function(wag) return Format("\n[%s]", Metrostroi.GetPhrase(states[math.floor(config.func(wag) * count + 0.5) + 1]):gsub("\n", "]\n[")) end
                        elseif config.varTooltip ~= true then
                            buttons.tooltipState = function(wag) return Format("\n[%s]", Metrostroi.GetPhrase(states[math.floor(config.varTooltip(wag) * count + 0.5) + 1]):gsub("\n", "]\n[")) end
                        end
                    elseif config.var and (not config.noTooltip and not buttons.ID:find("Set") or config.noTooltip == false) then
                        local var = config.var
                        local st1, st2 = "Train.Buttons.Off", "Train.Buttons.On"
                        if config.states then
                            st1 = config.states[1]
                            st2 = config.states[2]
                        end

                        buttons.tooltipState = function(wag) return Format("\n[%s]", Metrostroi.GetPhrase(wag:GetPackedBool(var) and st2 or st1)) end
                    end

                    if config.model then
                        if not panel.props_kv[name] then panel.props_kv[name] = table.insert(panel.props, name) end
                        wagon.ClientProps[name] = {
                            model = config.model or "models/metrostroi/81-717/button07.mdl",
                            pos = Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, config.z or 0.2, config.x or 0, config.y or 0, ent),
                            ang = Metrostroi.AngleFromPanel(id, config.ang, ent),
                            color = config.color,
                            colora = config.colora,
                            skin = config.skin or 0,
                            config = config,
                            bodygroup = config.bodygroup,
                            callback = config.callback,
                            modelcallback = config.modelcallback,
                            cabin = config.cabin,
                            hide = panel.hide or config.hide,
                            hideseat = panel.hideseat or config.hideseat,
                            bscale = config.bscale,
                            scale = config.scale,
                        }

                        --[[if config.varTooltip then
                            local states = config.states or {"Train.Buttons.On","Train.Buttons.Off"}
                            local count = (#states-1)
                            buttons.tooltipState = function(ent)
                                local text = "\n["
                                for i,t in ipairs(states) do
                                    if i == #states then
                                        text = text..Metrostroi.GetPhrase(t)
                                    else
                                        text = text..Metrostroi.GetPhrase(t).."|"
                                    end
                                end
                                text = text.."]"
                                return text,states[math.floor(config.varTooltip(ent)+0.5)*count+1]
                            end
                        elseif (config.var and not config.noTooltip) then
                            local var = config.var
                            local st1,st2 = "Train.Buttons.On","Train.Buttons.Off"
                            if config.states then
                                st1 = config.states[1]
                                st2 = config.states[2]
                            end
                            buttons.tooltipState = function(ent)
                                return Format("\n[%s|%s]",Metrostroi.GetPhrase(st1),Metrostroi.GetPhrase(st2)),ent:GetPackedBool(var) and st1 or st2
                            end
                        end]]
                        if config.var then
                            local var = config.var
                            local vmin, vmax = config.vmin or 0, config.vmax or 1
                            local min, max = config.min or 0, config.max or 1
                            local speed, damping, stickyness = config.speed or 16, config.damping or false, config.stickyness or nil
                            local func = config.getfunc
                            local i
                            if func then
                                if config.disable then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:Animate(name, func(ent, vmin, vmax, var), min, max, speed, damping, stickyness)
                                        ent:HideButton(config.disable, ent:GetPackedBool(var))
                                    end)
                                elseif config.disableinv then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:Animate(name, func(ent, vmin, vmax, var), min, max, speed, damping, stickyness)
                                        ent:HideButton(config.disableinv, not ent:GetPackedBool(var))
                                    end)
                                elseif config.disableoff and config.disableon then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:Animate(name, func(ent, vmin, vmax, var), min, max, speed, damping, stickyness)
                                        ent:HideButton(config.disableoff, ent:GetPackedBool(var))
                                        ent:HideButton(config.disableon, not ent:GetPackedBool(var))
                                    end)
                                elseif config.disablevar then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:HideButton(name, ent:GetPackedBool(config.disablevar))
                                        ent:Animate(name, func(ent, vmin, vmax, var), min, max, speed, damping, stickyness)
                                    end)
                                else
                                    i = addAutoAnim(wagon, name, function(ent) ent:Animate(name, func(ent, vmin, vmax), min, max, speed, damping, stickyness) end)
                                end
                            else
                                if config.disable then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:Animate(name, ent:GetPackedBool(var) and vmax or vmin, min, max, speed, damping, stickyness)
                                        ent:HideButton(config.disable, ent:GetPackedBool(var))
                                    end)
                                elseif config.disableinv then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:Animate(name, ent:GetPackedBool(var) and vmax or vmin, min, max, speed, damping, stickyness)
                                        ent:HideButton(config.disableinv, not ent:GetPackedBool(var))
                                    end)
                                elseif config.disableoff and config.disableon then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:Animate(name, ent:GetPackedBool(var) and vmax or vmin, min, max, speed, damping, stickyness)
                                        ent:HideButton(config.disableoff, ent:GetPackedBool(var))
                                        ent:HideButton(config.disableon, not ent:GetPackedBool(var))
                                    end)
                                elseif config.disablevar then
                                    i = addAutoAnim(wagon, name, function(ent)
                                        ent:HideButton(name, ent:GetPackedBool(config.disablevar))
                                        ent:Animate(name, ent:GetPackedBool(var) and vmax or vmin, min, max, speed, damping, stickyness)
                                    end)
                                else
                                    i = addAutoAnim(wagon, name, function(ent) ent:Animate(name, ent:GetPackedBool(var) and vmax or vmin, min, max, speed, damping, stickyness) end)
                                end
                            end

                            wagon.AutoAnimNames[i] = name
                        end
                    end

                    if config.sound or config.sndvol and config.var then
                        local id = config.sound or config.var
                        local sndid = config.sndid or buttons.ID
                        local vol, pitch, min, max = config.sndvol, config.sndpitch, config.sndmin, config.sndmax
                        local func, snd = config.getfunc, config.snd
                        local vmin, vmax = config.vmin or 0, config.vmax or 1
                        local var = config.var
                        local ang = config.sndang
                        --if func then
                        --wagon.ClientSounds[id] = {sndid,function(ent,var) return snd(func(ent,vmin,vmax),var) end,vol or 1,pitch or 1,min or 100,max or 1000,ang or Angle(0,0,0)}
                        --else
                        if not wagon.ClientSounds[id] then wagon.ClientSounds[id] = {} end
                        -- wagon.ClientSounds[id] = {}  -- TEST
                        local already_inserted = false
                        for i, snd in pairs(wagon.ClientSounds[id]) do
                            if snd[1] == sndid then already_inserted = true end
                        end

                        if not already_inserted then table.insert(wagon.ClientSounds[id], {sndid, function(ent, var) return snd(var > 0, var) end, vol or 1, pitch or 1, min or 100, max or 1000, ang or angle_zero}) end
                    end

                    if config.plomb then
                        local pconfig = config.plomb
                        local pname = name .. "_pl"
                        if pconfig.model then
                            if not panel.props_kv[pname] then panel.props_kv[pname] = table.insert(panel.props, pname) end
                            wagon.ClientProps[pname] = {
                                model = pconfig.model,
                                pos = Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, (config.z or 0.2) + (pconfig.z or 0.2), (config.x or 0) + (pconfig.x or 0), (config.y or 0) + (pconfig.y or 0), ent),
                                ang = Metrostroi.AngleFromPanel(id, pconfig.ang or config.ang, ent),
                                color = pconfig.color or pconfig.color,
                                skin = pconfig.skin or config.skin or 0,
                                config = pconfig,
                                cabin = pconfig.cabin,
                                hide = panel.hide or config.hide,
                                hideseat = panel.hideseat or config.hideseat,
                                bscale = pconfig.bscale or config.bscale,
                                scale = pconfig.scale or config.scale,
                            }
                        end

                        if pconfig.var then
                            local var = pconfig.var
                            if pconfig.model then
                                local i = addAutoAnim(wagon, pname, function(ent) ent:SetCSBodygroup(pname, 1, ent:GetPackedBool(var) and 0 or 1) end)
                                wagon.AutoAnimNames[i] = pname
                            end

                            local id, tooltip = buttons.ID, buttons.tooltip
                            local pid, ptooltip = pconfig.ID, pconfig.tooltip
                            buttons.plombed = function(ent)
                                if ent:GetPackedBool(var) then
                                    return Format("%s\n%s", buttons.tooltip, Metrostroi.GetPhrase("Train.Buttons.Sealed") or "Plombed"), pid, Color(255, 150, 150), true
                                else
                                    return buttons.tooltip, id, false
                                end
                            end
                        end
                    end

                    if config.lamp then
                        local lconfig = config.lamp
                        local lname = name .. "_lamp"
                        if not panel.props_kv[lname] then panel.props_kv[lname] = table.insert(panel.props, lname) end
                        wagon.ClientProps[lname] = {
                            model = lconfig.model or "models/metrostroi/81-717/button07.mdl",
                            pos = Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, (config.z or 0.2) + (lconfig.z or 0.2), (config.x or 0) + (lconfig.x or 0), (config.y or 0) + (lconfig.y or 0), ent),
                            ang = Metrostroi.AngleFromPanel(id, lconfig.ang or config.ang, ent),
                            color = lconfig.color or config.color,
                            skin = lconfig.skin or config.skin or 0,
                            config = lconfig,
                            cabin = lconfig.cabin,
                            igrorepanel = true,
                            hide = panel.hide or config.hide,
                            hideseat = panel.hideseat or config.hideseat,
                            bscale = lconfig.bscale or config.bscale,
                            scale = lconfig.scale or config.scale,
                        }

                        if lconfig.anim then
                            -- Keep lamp movement separate from the sprite callback below.
                            -- Both callbacks use lname as their visible/client-prop name,
                            -- but they must not share an AutoAnimIndexes key.
                            local i = addAutoAnim(wagon, "__lamp_move:" .. lname, function(ent) ent:AnimateFrom(lname, name) end)
                            wagon.AutoAnimNames[i] = lname
                        end

                        if lconfig.lcolor then
                            wagon.Lights[lname] = {
                                "headlight",
                                Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, (config.z or 0.2) + (lconfig.z or 0.2) + (lconfig.lz or 0.2), (config.x or 0) + (lconfig.x or 0) + (lconfig.lx or 0), (config.y or 0) + (lconfig.y or 0) + (lconfig.ly or 0), ent),
                                Metrostroi.AngleFromPanel(id, lconfig.lang or lconfig.ang or config.ang, ent) + Angle(90, 0, 0),
                                lconfig.lcolor,
                                farz = lconfig.lfar or 8,
                                nearz = lconfig.lnear or 1,
                                shadows = lconfig.lshadows or 1,
                                brightness = lconfig.lbright or 1,
                                fov = lconfig.lfov,
                                texture = lconfig.ltex or "effects/flashlight/soft",
                                panellight = true,
                                hidden = lname,
                            }
                            --[[wagon.ClientProps[lname.."TEST"] = {
                                model = "models/metrostroi_train/81-703/cabin_cran_334.mdl",
                                pos = Metrostroi.PositionFromPanel(id,config.pos or buttons.ID,(config.z or 0.2)+(lconfig.z or 0.2)+(lconfig.lz or 0.2),(config.x or 0)+(lconfig.x or 0)+(lconfig.lx or 0),(config.y or 0)+(lconfig.y or 0)+(lconfig.ly or 0)),
                                ang = Metrostroi.AngleFromPanel(id,lconfig.lang or lconfig.ang or config.ang)+Angle(-180,180,0),
                                scale=0.1,
                            }]]
                            --[[table.insert(wagon.AutoAnims, function(ent)
                                ent:AnimateFrom(lname,name)
                            end)]]
                        end

                        if lconfig.var then
                            --ret=ret.."\""..lconfig.var.."\","
                            --reti = reti + 1
                            local var, animvar = lconfig.var, lname .. "_anim"
                            local min, max = lconfig.min or 0, lconfig.max or 1
                            local speed = lconfig.speed or 10
                            local func = lconfig.getfunc
                            local light = lconfig.lcolor
                            if func then
                                local i = addAutoAnim(wagon, animvar, function(ent)
                                    local val = ent:Animate(animvar, func(ent, min, max, var), 0, 1, speed, false)
                                    ent:ShowHideSmooth(lname, val)
                                    if light then ent:SetLightPower(lname, val > 0, val) end
                                end)
                                wagon.AutoAnimNames[i] = animvar

                            else
                                local i = addAutoAnim(wagon, animvar, function(ent)
                                    --print(lname,ent.SmoothHide[lname])
                                    local val = ent:Animate(animvar, ent:GetPackedBool(var) and max or min, 0, 1, speed, false)
                                    ent:ShowHideSmooth(lname, val)
                                    if light then ent:SetLightPower(lname, val > 0, val) end
                                end)
                                wagon.AutoAnimNames[i] = animvar

                            end
                        end
                    end

                    if config.lamps then
                        for k, lconfig in ipairs(config.lamps) do
                            local lname = name .. "_lamp" .. k
                            if not panel.props_kv[lname] then panel.props_kv[lname] = table.insert(panel.props, lname) end
                            wagon.ClientProps[lname] = {
                                model = lconfig.model or "models/metrostroi/81-717/button07.mdl",
                                pos = Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, (config.z or 0.2) + (lconfig.z or 0.2), (config.x or 0) + (lconfig.x or 0), (config.y or 0) + (lconfig.y or 0), ent),
                                ang = Metrostroi.AngleFromPanel(id, lconfig.ang or config.ang, ent),
                                color = lconfig.color or config.color,
                                skin = lconfig.skin or config.skin or 0,
                                config = lconfig,
                                cabin = lconfig.cabin,
                                igrorepanel = true,
                                hide = panel.hide or config.hide,
                                hideseat = panel.hideseat or config.hideseat,
                                bscale = lconfig.bscale or config.bscale,
                                scale = lconfig.scale or config.scale,
                            }

                            if lconfig.var then
                                --ret=ret.."\""..lconfig.var.."\","
                                --reti = reti + 1
                                local var, animvar = lconfig.var, lname .. "_anim"
                                local min, max = lconfig.min or 0, lconfig.max or 1
                                local speed = lconfig.speed or 10
                                local func = lconfig.getfunc
                                local light = lconfig.lcolor
                                if func then
                                    local i = addAutoAnim(wagon, lname, function(ent)
                                        local val = ent:Animate(animvar, func(ent, min, max, var), 0, 1, speed, false)
                                        ent:ShowHideSmooth(lname, val)
                                        if light then ent:SetLightPower(lname, val > 0, val) end
                                    end)
                                    wagon.AutoAnimNames[i] = animvar

                                else
                                    local i = addAutoAnim(wagon, lname, function(ent)
                                        --print(lname,ent.SmoothHide[lname])
                                        local val = ent:Animate(animvar, ent:GetPackedBool(var) and max or min, 0, 1, speed, false)
                                        ent:ShowHideSmooth(lname, val)
                                        if light then ent:SetLightPower(lname, val > 0, val) end
                                    end)
                                    wagon.AutoAnimNames[i] = animvar

                                end
                            end
                        end
                    end

                    if config.sprite then
                        local sconfig = config.sprite
                        local hideName = sconfig.hidden or config.lamp and name .. "_lamp" or name
                        local sname = name .. "_sprite"
                        wagon.Lights[sconfig.lamp or name] = {
                            sconfig.glow and "glow" or "light",
                            Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, (config.z or 0.5) + (sconfig.z or 0.2), (config.x or 0) + (sconfig.x or 0), (config.y or 0) + (sconfig.y or 0), ent),
                            Metrostroi.AngleFromPanel(id, sconfig.ang or config.ang, ent) + Angle(90, 0, 0),
                            sconfig.color or sconfig.color,
                            brightness = sconfig.bright,
                            texture = sconfig.texture or "sprites/light_glow02",
                            scale = sconfig.scale or 0.02,
                            vscale = sconfig.vscale,
                            size = sconfig.size,
                            hidden = hideName,
                            aa = sconfig.aa,
                            panel = sconfig.panel ~= false,
                        }

                        local i
                        if sconfig.getfunc then
                            local func = sconfig.getfunc
                            i = addAutoAnim(wagon, "__sprite:" .. sname, function(ent)
                                local val = func(ent)
                                ent:SetLightPower(name, not ent.Hidden[hideName] and val > 0, val)
                            end)
                        elseif sconfig.var then
                            --ret=ret.."\""..lconfig.var.."\","
                            --reti = reti + 1
                            local var, animvar = sconfig.var, name .. "_sanim"
                            local speed = sconfig.speed or 10
                            i = addAutoAnim(wagon, "__sprite:" .. sname, function(ent)
                                local val = ent:Animate(animvar, ent:GetPackedBool(var) and 1 or 0, 0, 1, speed, false)
                                ent:SetLightPower(name, val > 0, val)
                            end)
                        elseif sconfig.lamp then
                            local lightName = sconfig.lamp
                            i = addAutoAnim(wagon, "__sprite:" .. sname, function(ent)
                                local val = ent.Anims[lightName] and ent.Anims[lightName].value or 0
                                ent:SetLightPower(lightName, val > 0, val)
                            end)
                        elseif config.lamp and config.lamp.var then
                            local lname = name .. "_lamp"
                            local lightName = lname .. "_anim"
                            i = addAutoAnim(wagon, "__sprite:" .. sname, function(ent)
                                local val = ent.Anims[lightName] and ent.Anims[lightName].value or 0
                                ent:SetLightPower(name, val > 0, val)
                            end)
                        end

                        if not i then
                            ErrorNoHalt("Bad sprite " .. name .. "/" .. hideName .. ", no controlable function...\n")
                        else
                            wagon.AutoAnimNames[i] = hideName
                        end
                    end

                    if config.labels then
                        for k, aconfig in ipairs(config.labels) do
                            local aname = name .. "_label" .. k
                            if not panel.props_kv[aname] then panel.props_kv[aname] = table.insert(panel.props, aname) end
                            wagon.ClientProps[aname] = {
                                model = aconfig.model or "models/metrostroi/81-717/button07.mdl",
                                pos = Metrostroi.PositionFromPanel(id, config.pos or buttons.ID, (config.z or 0.2) + (aconfig.z or 0.2), (config.x or 0) + (aconfig.x or 0), (config.y or 0) + (aconfig.y or 0), ent),
                                ang = Metrostroi.AngleFromPanel(id, aconfig.ang or config.ang, ent),
                                color = aconfig.color or config.color,
                                colora = aconfig.colora or config.colora,
                                skin = aconfig.skin or config.skin or 0,
                                config = aconfig,
                                cabin = aconfig.cabin,
                                igrorepanel = true,
                                hide = panel.hide or config.hide,
                                hideseat = panel.hideseat or config.hideseat,
                                bscale = aconfig.bscale or config.bscale,
                                scale = aconfig.scale or config.scale,
                                callback = aconfig.callback
                            }
                        end
                    end

                    buttons.model = nil
                end
            end
        end

        for k, v in pairs(wagon.ClientProps) do
            if not v.model then continue end
            -- Metrostroi.PrecacheModels[v.model] = true
        end

        for k, v in pairs(wagon.Lights or {}) do
            if not v.hidden then continue end
            local cP = wagon.ClientProps[v.hidden]
            if not cP then
                -- ErrorNoHalt("No clientProp " .. v.hidden .. " in entity " .. wagon.Folder .. "\n")
                continue
            end

            if not cP.lamps then cP.lamps = {} end
            table.insert(cP.lamps, k)
        end
        --ret = ret.."\n}"
        --SetClipboardText(ret)
    end
end

hook.Add("MetrostroiLoaded", "MetrostroiExtApplyNewGenerateClientProps", function() newGenerateClientProps() end)

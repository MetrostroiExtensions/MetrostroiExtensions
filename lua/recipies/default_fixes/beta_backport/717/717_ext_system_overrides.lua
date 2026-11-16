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

MEL.DefineRecipe("717_ext_system_overrides", "gmod_subway_81-717_mvm")
function RECIPE:Inject(ent)
    ent.InitializeSystems = function(wagon)
        -- Электросистема 81-710
        wagon:LoadSystem("Electric", "81_717_Electric_EXT")
        -- Токоприёмник
        wagon:LoadSystem("TR", "TR_3B")
        -- Электротяговые двигатели
        wagon:LoadSystem("Engines", "DK_117DM")
        -- Резисторы для реостата/пусковых сопротивлений
        wagon:LoadSystem("KF_47A", "KF_47A1")
        -- Резисторы для ослабления возбуждения
        wagon:LoadSystem("KF_50A")
        -- Ящик с предохранителями
        wagon:LoadSystem("YAP_57")
        -- Резисторы для цепей управления
        --wagon:LoadSystem("YAS_44V")
        wagon:LoadSystem("Reverser", "PR_722D")
        -- Реостатный контроллер для управления пусковыми сопротивления
        wagon:LoadSystem("RheostatController", "EKG_17B")
        -- Групповой переключатель положений
        wagon:LoadSystem("PositionSwitch", "PKG_761")
        -- Кулачковый контроллер
        wagon:LoadSystem("KV", "KV_70")
        -- Контроллер резервного управления
        wagon:LoadSystem("KRU")
        -- Ящики с реле и контакторами
        wagon:LoadSystem("BV", "BV_630")
        wagon:LoadSystem("LK_755A")
        wagon:LoadSystem("YAR_13B", "YAR_13B_EXT")
        wagon:LoadSystem("YAR_27", "YAR_27_EXT", "MSK")
        wagon:LoadSystem("YAK_36")
        wagon:LoadSystem("YAK_37E")
        wagon:LoadSystem("YAS_44V")
        wagon:LoadSystem("YARD_2")
        wagon:LoadSystem("PR_14X_Panels")
        -- Пневмосистема 81-717
        wagon:LoadSystem("Pneumatic", "81_717_Pneumatic_EXT")
        -- Панель управления 81-717
        wagon:LoadSystem("Panel", "81_717_Panel_EXT")
        -- Everything else
        wagon:LoadSystem("Battery")
        wagon:LoadSystem("PowerSupply", "BPSN_EXT")
        wagon:LoadSystem("ALS_ARS", "ALS_ARS_D")
        wagon:LoadSystem("Horn")
        wagon:LoadSystem("IGLA_CBKI", "IGLA_CBKI1_EXT")
        wagon:LoadSystem("IGLA_PCBK")
        wagon:LoadSystem("UPPS")
        wagon:LoadSystem("BZOS", "81_718_BZOS")
        wagon:LoadSystem("Announcer", "81_71_Announcer", "AnnouncementsASNP")
        wagon:LoadSystem("ASNP", "81_71_ASNP_EXT")
        wagon:LoadSystem("ASNP_VV", "81_71_ASNP_VV")
        wagon:LoadSystem("RouteNumber", "81_71_RouteNumber", 2)
        wagon:LoadSystem("LastStation", "81_71_LastStation", "717", "destination")
    end
end

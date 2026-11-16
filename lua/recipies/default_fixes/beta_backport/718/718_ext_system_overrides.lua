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

MEL.DefineRecipe("718_ext_system_overrides", "gmod_subway_81-718")
function RECIPE:Inject(ent)
    function ent.InitializeSystems(wagon)
        wagon:LoadSystem("Electric", "81_718_Electric")
        -- Токоприёмник
        wagon:LoadSystem("TR", "TR_3B")
        -- Электротяговые двигатели
        wagon:LoadSystem("Engines", "DK_117DM")
        wagon:LoadSystem("BBE", "81_718_BBE")
        wagon:LoadSystem("BKVA", "81_718_BKVA")
        wagon:LoadSystem("BSKA", "81_718_BSKA")
        wagon:LoadSystem("BUVS", "81_718_BUVS")
        wagon:LoadSystem("PTTI", "81_718_PTTI")
        wagon:LoadSystem("Panel", "81_718_Panel")
        wagon:LoadSystem("KR", "81_718_KR")
        wagon:LoadSystem("KRU", "81_718_KRU")
        wagon:LoadSystem("BKCU", "81_718_BKCU")
        wagon:LoadSystem("BUP", "81_718_BUP")
        wagon:LoadSystem("BUV", "81_718_BUV")
        wagon:LoadSystem("BVA", "81_718_BVA")
        wagon:LoadSystem("BKBD", "81_718_BKBD")
        wagon:LoadSystem("BZOS", "81_718_BZOS")
        --wagon:LoadSystem("IGLA_CBKI","IGLA_CBKI1")
        --wagon:LoadSystem("IGLA_PCBK")
        wagon:LoadSystem("Announcer", "81_71_Announcer", "AnnouncementsASNP")
        wagon:LoadSystem("RRI", "81_71_RRI_EXT", Metrostroi.ASNPSetup)
        wagon:LoadSystem("RRI_VV", "81_71_RRI_VV")
        --wagon:LoadSystem("ASNP","81_71_ASNP")
        -- Пневмосистема 81-710
        wagon:LoadSystem("Pneumatic", "81_718_Pneumatic")
        wagon:LoadSystem("Battery", "81_718_Battery")
        wagon:LoadSystem("Horn", "81_722_Horn")
        wagon:LoadSystem("RouteNumber", "81_718_RouteNumber_EXT")
        wagon:LoadSystem("LastStation", "81_71_LastStation", "717", "destination")
    end
end

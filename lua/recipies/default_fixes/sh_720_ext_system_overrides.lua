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

MEL.DefineRecipe("720_ext_system_overrides", "gmod_subway_81-720")
function RECIPE:Inject(ent)
    function ent.InitializeSystems(wagon)
        wagon:LoadSystem("TR","TR_3B")
        wagon:LoadSystem("Engines","DK_120AM")
        wagon:LoadSystem("Electric","81_720_Electric_EXT")
        wagon:LoadSystem("BPTI","81_720_BPTI")
        wagon:LoadSystem("RV","81_720_RV")


        wagon:LoadSystem("BUKP","81_720_BUKP")
        wagon:LoadSystem("BUV","81_720_BUV")

        wagon:LoadSystem("BARS","81_720_BARS")

        wagon:LoadSystem("Pneumatic","81_720_Pneumatic")
        wagon:LoadSystem("Horn","81_720_Horn")


        wagon:LoadSystem("Panel","81_720_Panel")

        wagon:LoadSystem("Announcer","81_71_Announcer", "AnnouncementsASNP")
        wagon:LoadSystem("ASNP","81_71_ASNP")
        wagon:LoadSystem("ASNP_VV","81_71_ASNP_VV")

        wagon:LoadSystem("Tickers","81_720_Ticker")
        wagon:LoadSystem("PassSchemes","81_720_PassScheme")


        wagon:LoadSystem("IGLA_CBKI","81_720_IGLA_CBKI2")
        wagon:LoadSystem("IGLA_PCBK","81_720_IGLA_PCBK")


        wagon:LoadSystem("RouteNumber","81_71_RouteNumber",2)
        wagon:LoadSystem("LastStation","81_71_LastStation","720","route")
    end
end

MEL.DefineRecipe("hello_world", "717")
RECIPE.Description = "This recipe adds new prop into interior and simple example button"
function RECIPE:InjectSpawner(entclass)
    MEL.AddSpawnerField(entclass, {
        [1] = "HelloWorldPropType",
        [2] = "Spawner.717.HelloWorldPropType",
        [3] = "List",
        [4] = {"Random", "Watermelon", "TrafficCone", "Barrel"}
    }, true)
end

function RECIPE:Inject(ent, entclass)
    MEL.NewClientProp(ent, "hello_world_prop", {
        model = "models/props_junk/watermelon01.mdl",
        modelcallback = function(wagon, cent)
            local models = {"models/props_junk/watermelon01.mdl", "models/props_junk/TrafficCone001a.mdl", "models/props_borealis/bluebarrel001.mdl"}
            return models[wagon:GetNW2Int("HelloWorldPropType")]
        end,
        pos = Vector(0, 0, 0),
        ang = Angle(0, 0, 0),
    }, "HelloWorldPropType")

    MEL.InjectIntoSharedFunction(ent, "InitializeSystems", function(wagon) wagon:LoadSystem("GreetWorld", "Relay", "Switch", {bass = true}) end)
    MEL.AddToSyncTable(ent, "GreetWorld")
    MEL.NewButtonMap(ent, "HelloWorld", {
        pos = Vector(0, 0, 0),
        ang = Angle(0, 90, 90),
        width = 100,
        height = 100,
        scale = 0.0625, -- на самом деле это 1/16
        buttons = {
            {
                ID = "GreetWorldSet",
                x = 0,
                y = 0,
                w = 100,
                h = 100,
                tooltip = "Hello world!",
                model = {
                    model = "models/metrostroi_train/81-710/ezh3_button_black.mdl",
                    var = "GreetWorld",
                    speed = 16,
                    vmin = 1,
                    vmax = 0,
                    sndvol = 0.07,
                    snd = function(val) return val and "button3_on" or "button3_off" end,
                    sndmin = 60,
                    sndmax = 1e3 / 3,
                    sndang = Angle(-90, 0, 0),
                },
            },
        }
    })
    MEL.InjectIntoClientFunction(ent, "Think", function(wagon)
        if wagon.OldGreetWorld ~= wagon:GetNW2Bool("GreetWorld") then
            wagon.OldGreetWorld = wagon:GetNW2Bool("GreetWorld")

            local hello_world_prop = wagon.ClientEnts["hello_world_prop"]
            -- wagon.OldGreetWorld == true нужен только для того, чтобы менять цвет только при нажатии кнопки, не менять его второй раз при отпускании
            if wagon.OldGreetWorld == true and IsValid(hello_world_prop) then
                hello_world_prop:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
            end
        end
    end)
    MEL.InjectIntoServerFunction(ent, "OnButtonPress", function(wagon, button, ply) if button == "GreetWorldSet" then ply:ChatPrint("Hello World!") end end)
end

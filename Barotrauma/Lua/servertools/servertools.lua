ST.Utils = dofile(ST.Path .. "/Lua/servertools/utils.lua")
ST.Commands = dofile(ST.Path .. "/Lua/servertools/commandhandler.lua")
ST.Modules = dofile(ST.Path .. "/Lua/servertools/modules.lua")

ST.Modules.SetConfigPath(ST.Path .. "/config/")

local timer = 0
Hook.Add("think", "ServerTools.Think", function ()
    if timer > Timer.GetTime() then
        return
    end

    Hook.Call("st.slowthink")

    timer = Timer.GetTime() + 1
end)


if SERVER then
    dofile(ST.Path .. "/Lua/servertools/defaultmodules.lua")
    dofile(ST.Path .. "/Lua/servertools/server/main.lua")
    dofile(ST.Path .. "/Lua/servertools/server/commands.lua")

    Networking.Receive("st.heartbeat", function (message, client)
        ST.Utils.Log("Received heartbeat from %s", client.Name)
        local message = Networking.Start("st.heartbeat")
        Networking.Send(message, client.Connection)
    end)
else
    local message = Networking.Start("st.heartbeat")
    Networking.Send(message)

    Networking.Receive("st.heartbeat", function ()
        ST.Utils.Log("This server has ServerTools installed. Initializing...")
        dofile(ST.Path .. "/Lua/servertools/defaultmodules.lua")
        dofile(ST.Path .. "/Lua/servertools/client/main.lua")

    end)
end
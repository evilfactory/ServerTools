ST.Utils = dofile(ST.Path .. "/Lua/servertools/utils.lua")
ST.Commands = dofile(ST.Path .. "/Lua/servertools/commandhandler.lua")
ST.Modules = dofile(ST.Path .. "/Lua/servertools/modules.lua")

if SERVER then
    dofile(ST.Path .. "/Lua/servertools/server/commands.lua")
else

end

local timer = 0
Hook.Add("think", "ServerTools.Think", function ()
    if timer > Timer.GetTime() then
        return
    end

    Hook.Call("st.slowthink")

    timer = Timer.GetTime() + 1
end)

ST.Modules.Register("servertools.modules.adminpm")
ST.Modules.Register("servertools.modules.jobbans")
ST.Modules.Register("servertools.modules.discordlogalerts")
ST.Modules.Register("servertools.modules.chatfilter")
ST.Modules.Register("servertools.modules.brokenhandcuffs")
ST.Modules.Register("servertools.modules.networkscanner")
ST.Modules.Register("servertools.modules.donatorsystem")

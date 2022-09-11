ST.Utils = dofile(ST.Path .. "/Lua/servertools/utils.lua")
ST.Commands = dofile(ST.Path .. "/Lua/servertools/commandhandler.lua")
ST.Modules = dofile(ST.Path .. "/Lua/servertools/modules.lua")

if SERVER then
    dofile(ST.Path .. "/Lua/servertools/server/commands.lua")
else

end

ST.Modules.Register("servertools.modules.adminpm")
ST.Modules.Register("servertools.modules.jobbans")
ST.Modules.Register("servertools.modules.discordlogalerts")
ST.Modules.Register("servertools.modules.networkscanner")

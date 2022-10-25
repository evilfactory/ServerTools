if Game.IsSingleplayer then return end
if CLIENT then return end

ST = {}
ST.Path = ...

dofile(ST.Path .. "/Lua/ServerTools/servertools.lua")
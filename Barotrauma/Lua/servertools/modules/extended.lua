local module = {}

module.Name = "Extended"

module.Config = {
    Enabled = true,
}

AccountId = LuaUserData.CreateStatic("Barotrauma.Networking.AccountId")

module.OnEnabled = function ()
    if CLIENT then return end

    ST.Commands.Add("!ban", function (args, cmd)
        if #args < 2 then
            cmd:Reply("Usage: !ban \"SteamID\" \"Reason\"", Color.Red)
            return true
        end

        local steamid = args[1]
        local reason = args[2]

        local account = AccountId.Parse(steamid)

        if account == none then
            cmd:Reply("Invalid SteamID.", Color.Red)
            return true
        end

        local isBanned = Game.ServerSettings.BanList.IsBanned(account)

        if not isBanned then
            Game.ServerSettings.BanList.BanPlayer("Unnamed", account, reason)
            cmd:Reply(string.format("Banned SteamID \"%s\" for \"%s\".", steamid, reason))
        else
            cmd:Reply(string.format("SteamID \"%s\" is already banned.", steamid), Color.Red)
        end
        return true
    end, ClientPermissions.ConsoleCommands, true)

    ST.Commands.Add("!isbanned", function (args, cmd)
        if #args < 1 then
            cmd:Reply("Usage: !isbanned \"SteamID\"", Color.Red)
            return true
        end

        local steamid = args[1]

        local account = AccountId.Parse(steamid)

        if account == none then
            cmd:Reply("Invalid SteamID.", Color.Red)
            return true
        end

        local isBanned = Game.ServerSettings.BanList.IsBanned(account)

        if isBanned then
            cmd:Reply(string.format("SteamID \"%s\" is banned.", steamid))
        else
            cmd:Reply(string.format("SteamID \"%s\" is not banned.", steamid))
        end

        return true
    end, ClientPermissions.ConsoleCommands, true)

    ST.Commands.Add("!unban", function (args, cmd)
        if #args < 1 then
            cmd:Reply("Usage: !unban \"SteamID\"", Color.Red)
            return true
        end

        local steamid = args[1]

        local account = AccountId.Parse(steamid)

        if account == none then
            cmd:Reply("Invalid SteamID.", Color.Red)
            return true
        end

        local isBanned = Game.ServerSettings.BanList.IsBanned(account)

        if isBanned then
            Game.ServerSettings.BanList.UnbanPlayer(account)
            cmd:Reply(string.format("Unbanned SteamID \"%s\".", steamid))
        else
            cmd:Reply(string.format("SteamID \"%s\" is not banned.", steamid), Color.Red)
        end

        return true
    end, ClientPermissions.ConsoleCommands, true)
end

module.OnDisabled = function ()
    if CLIENT then return end

    ST.Commands.Remove("!ban")
    ST.Commands.Remove("!isbanned")
    ST.Commands.Remove("!unban")
end

return module
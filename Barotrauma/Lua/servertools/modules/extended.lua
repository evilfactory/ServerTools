local module = {}

module.Name = "Extended"

module.Config = {
    Enabled = true,
}

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Networking.ServerSettings"], "set_ClientPermissions")

module.OnEnabled = function ()
    if CLIENT then return end

    ST.Commands.Add("!givepermission", function (args, cmd)
        if #args < 2 then
            cmd:Reply("Usage: !givepermission \"SteamID\" \"Permission\"", Color.Red)
            return true
        end

        local steamid = args[1]
        local permission = ClientPermissions[args[2]]

        if permission == nil then
            cmd:Reply("Invalid Permission.", Color.Red)
            return true
        end

        local account = AccountId.Parse(steamid)

        if account == nil then
            cmd:Reply("Invalid SteamID.", Color.Red)
            return true
        end

        local oldPermission

        local permissions = Game.ServerSettings.ClientPermissions
        for key, value in pairs(permissions) do
            if value.AddressOrAccountId == account then
                table.remove(permissions, key)
                oldPermission = value
                break
            end
        end

        if oldPermission then
            local permittedCommands = {}
            for command in oldPermission.PermittedCommands do
                table.insert(permittedCommands, command)
            end

            local newPermission = bit32.bor(oldPermission.Permissions, permission)
            table.insert(permissions, Game.ServerSettings.SavedClientPermission.__new(oldPermission.Name, oldPermission.AddressOrAccountId, newPermission, permittedCommands))
        else
            table.insert(permissions, Game.ServerSettings.SavedClientPermission.__new("Unknown", account, permission, {}))
        end

        Game.ServerSettings.set_ClientPermissions(permissions)

        cmd:Reply(string.format("Assigned \"%s\" the permission %s.", steamid, args[2]))

        return true
    end, ClientPermissions.All, true)

    ST.Commands.Add("!revokepermission", function (args, cmd)
        if #args < 2 then
            cmd:Reply("Usage: !revokepermission \"SteamID\" \"Permission\"", Color.Red)
            return true
        end

        local steamid = args[1]
        local permission = ClientPermissions[args[2]]

        if permission == nil then
            cmd:Reply("Invalid Permission.", Color.Red)
            return true
        end

        local account = AccountId.Parse(steamid)

        if account == nil then
            cmd:Reply("Invalid SteamID.", Color.Red)
            return true
        end

        local permissions = Game.ServerSettings.ClientPermissions
        for key, value in pairs(permissions) do
            if value.AddressOrAccountId == account then
                if bit32.band(value.Permissions, permission) ~= permission then
                    break
                end

                table.remove(permissions, key)

                local permittedCommands = {}
                for command in value.PermittedCommands do
                    table.insert(permittedCommands, command)
                end

                local newPermission = bit32.band(value.Permissions, bit32.bnot(permission))
                table.insert(permissions, Game.ServerSettings.SavedClientPermission.__new(value.Name, value.AddressOrAccountId, newPermission, permittedCommands))

                Game.ServerSettings.set_ClientPermissions(permissions)

                cmd:Reply(string.format("Revoked \"%s\" the permission %s.", steamid, args[2]))

                return true
            end
        end

        cmd:Reply(string.format("\"%s\" already doesn't have the permission %s.", steamid, args[2]))

        return true
    end, ClientPermissions.All, true)

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
    ST.Commands.Remove("!givepermission")
    ST.Commands.Remove("!revokepermission")
end

return module
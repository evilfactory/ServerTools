local module = {}

module.Name = "MasterServer"

module.Config = {
    Enabled = false,
    EndPoint = "http://127.0.0.1",
    UniqueId = "barotrauma-server-1234567890",
    SharedBanList = true,
    SendStatusUpdates = true,
    SendLogs = true,
}

if SERVER then
    loadfile(ST.Path .. "/Lua/servertools/modules/masterserver/banlist.lua")(module)
    loadfile(ST.Path .. "/Lua/servertools/modules/masterserver/statusupdate.lua")(module)
    loadfile(ST.Path .. "/Lua/servertools/modules/masterserver/sendlogs.lua")(module)
end

local lastSend = 0

module.OnEnabled = function ()
    if CLIENT then return end

    if module.Config.SharedBanList then
        Hook.Add("think", "MasterServer.Think", function ()
            module.UpdateLog()
            if lastSend > Timer.GetTime() then return end

            lastSend = Timer.GetTime() + 60
            module.GetBanList()
            Timer.Wait(module.SendStatusUpdate, 100)
        end)

        Hook.Add("banList.ban", "MasterServer.Ban", function (account, reason)
            module.SendBan(account, reason)
        end)

        Hook.Add("banList.unban", "MasterServer.Unban", function (account)
            module.BanList[account.StringRepresentation] = nil
            module.SendUnban(account)
        end)

        Hook.Patch("MasterServer.IsBanned", "Barotrauma.Networking.BanList", "IsBanned", {"Barotrauma.Networking.AccountId", "out System.String"}, function (self, ptable)
            local account = ptable["accountId"]

            if module.BanList[account.StringRepresentation] then
                ptable["reason"] = module.BanList[account.StringRepresentation].Reason or ""
                ptable.PreventExecution = true
                return true
            end
        end, Hook.HookMethodType.Before)

        Hook.Add("client.connected", "MasterServer.Connected", function ()
            Timer.Wait(module.SendStatusUpdate, 100)
        end)
        Hook.Add("client.disconnected", "MasterServer.Disconnected", function ()
            Timer.Wait(module.SendStatusUpdate, 100)
        end)
        Hook.Add("roundStart", "MasterServer.RoundStart", function ()
            Timer.Wait(module.SendStatusUpdate, 100)
            Timer.Wait(module.NewRound, 100)
        end)
        Hook.Add("roundEnd", "MasterServer.RoundEnd", function ()
            Timer.Wait(module.SendStatusUpdate, 100)
        end)
        
        Hook.Add("serverLog", "MasterServer.SendLogs", function (message, type)
            module.SendLog(message, type)
        end)

        module.SendStatusUpdate()
    end
end

module.OnDisabled = function ()
    if CLIENT then return end

    Hook.Remove("think", "MasterServer.Think")
    Hook.Remove("banList.ban", "MasterServer.Ban")
    Hook.Remove("banList.unban", "MasterServer.Unban")
    Hook.RemovePatch("MasterServer.IsBanned", "Barotrauma.Networking.BanList", "IsBanned", {"Barotrauma.Networking.AccountId", "out System.String"}, Hook.HookMethodType.Before)
end

return module
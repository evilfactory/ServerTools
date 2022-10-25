local module = {}

module.Name = "MasterServer"

module.Config = {
    Enabled = false,
    EndPoint = "http://127.0.0.1",
    UniqueId = "barotrauma-server-1234567890",
}

local json = require("servertools.json")
local lastSend = 0

module.BanList = {}

module.SendBan = function(account, reason)
    local data = {
        UniqueId = module.Config.UniqueId,
        Account = account.StringRepresentation,
        Reason = reason,
    }

    Networking.HttpPost(module.Config.EndPoint .. "/api/v1/ban", function (res) end, json.encode(data))
end

module.SendUnban = function (account)
    local data = {
        UniqueId = module.Config.UniqueId,
        Account = account.StringRepresentation,
    }
    Networking.HttpPost(module.Config.EndPoint .. "/api/v1/unban", function (res) end, json.encode(data))
end

module.GetBanList = function()
    Networking.HttpPost(module.Config.EndPoint .. "/api/v1/banlist", function (res)
        local success, result = pcall(json.decode, res)
        if not success then
            ST.Utils.Log("Failed to retrieve ban list from master server: " .. res)
            return
        end

        module.BanList = result.BanList
    end)
end

if SERVER then
    Hook.Patch("Barotrauma.Networking.BanList", "BanPlayer", 
    {
        "System.String", 
        "Barotrauma.Either`2[[Barotrauma.Networking.Address], [Barotrauma.Networking.AccountId]]", 
        "System.String",
        "System.TimeSpan"
    },
    function (self, ptable)
        Hook.Call("banList.ban", ptable["addressOrAccountId"], ptable["reason"])
    end, Hook.HookMethodType.After)

    Hook.Patch("Barotrauma.Networking.BanList", "RemoveBan", function (self, ptable)
        Hook.Call("banList.unban", ptable["banned"].AddressOrAccountId)
    end, Hook.HookMethodType.Before)

    Hook.Patch("Barotrauma.Networking.BanList", "UnbanPlayer", {"Barotrauma.Either`2[[Barotrauma.Networking.Address], [Barotrauma.Networking.AccountId]]"}, function (self, ptable)
        print("a")
        Hook.Call("banList.unban", ptable["addressOrAccountId"])
    end, Hook.HookMethodType.Before)
end

module.OnEnabled = function ()
    if CLIENT then return end

    Hook.Add("think", "MasterServer.Think", function ()
        if lastSend > Timer.GetTime() then return end

        lastSend = Timer.GetTime() + 60
        module.GetBanList()
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
end

module.OnDisabled = function ()
    if CLIENT then return end

    Hook.Remove("think", "MasterServer.Think")
    Hook.Remove("banList.ban", "MasterServer.Ban")
    Hook.Remove("banList.unban", "MasterServer.Unban")
    Hook.RemovePatch("MasterServer.IsBanned", "Barotrauma.Networking.BanList", "IsBanned", {"Barotrauma.Networking.AccountId", "out System.String"}, Hook.HookMethodType.Before)
end

return module
local module = ...
local json = require("servertools.json")

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
    Hook.Call("banList.unban", ptable["addressOrAccountId"])
end, Hook.HookMethodType.Before)

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
    end, json.encode({ UniqueId = module.Config.UniqueId }))
end
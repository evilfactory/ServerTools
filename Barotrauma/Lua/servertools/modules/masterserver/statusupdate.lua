local module = ...
local json = require("servertools.json")

module.SendStatusUpdate = function()
    local submarine = nil
    if Submarine.MainSub then
        submarine = Submarine.MainSub.Info.Name
    end

    local clients = {}
    for key, value in pairs(Client.ClientList) do
        table.insert(clients,
        {
            Name = value.Name,
            AccountId = tostring(value.AccountId),
            Ping = value.Ping,
        })
    end

    local data = {
        UniqueId = module.Config.UniqueId,
        AmountPlayers = #Client.ClientList,
        MaxPlayers = Game.ServerSettings.MaxPlayers,
        Submarine = submarine,
        Clients = clients
    }

    Networking.HttpPost(module.Config.EndPoint .. "/api/v1/update-status", function (res) print(res) end, json.encode(data))
end
local module = {}

module.Name = "Statistics"

module.Config = {
    Enabled = false,
    EndPoint = "example.com"
}

local function SendData(data)
    Networking.HttpPost(module.Config.EndPoint, function ()
    end, string.format('{"data": %s}', tostring(data)))
end

module.OnEnabled = function ()
    if CLIENT then return end

    Hook.Add("client.connected", "Statistics.ClientConnected", function (client)
        Timer.Wait(function() SendData(#Client.ClientList) end, 1000)
    end)

    Hook.Add("client.disconnected", "Statistics.ClientDisconnected", function (client)
        Timer.Wait(function() SendData(#Client.ClientList) end, 1000)
    end)
end

module.OnDisable = function ()
    if CLIENT then return end

end

return module
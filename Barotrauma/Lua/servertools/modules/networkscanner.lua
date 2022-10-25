-- this is a simple network package debug tool, do not use this if you dont know what you are doing.

local module = {}

module.Name = "NetworkScanner"

module.Config = {Enabled = true}

local scanned = {}

local function StartNetworkScan()
    scanned = {}
    Hook.Add("netMessageReceived", "ServerTools.NetworkScan", function (message, header, client)
        table.insert(scanned, {header, client, message.Buffer})
    end)
end

local function EndNetworkScan()
    Hook.Remove("netMessageReceived", "ServerTools.NetworkScan")

    local text = ""
    for _, v in pairs(scanned) do
        local bytes = ""

        for key, value in pairs(v[3]) do
            bytes = bytes .. string.char(value)
        end

        text = text .. "[S]" .. tostring(v[2].SteamID) .. " [ID] " .. tostring(v[1]) .. " [B] " .. bytes .. "[E]\n\n"
    end

    File.Write(ST.Path .. "/networkscan.txt", text)

    scanned = {}
end

module.OnEnabled = function ()
    if CLIENT then return end

    ST.Commands.Add("!startnetworkscan", function(args, cmd)
        StartNetworkScan()
        local time = tonumber(args[1])
        if time ~= nil then
            cmd:Reply("Network scan started and its going to end in " .. time .. " seconds.")
            Timer.Wait(EndNetworkScan, time * 1000)
        else
            cmd:Reply("Network scan started")
        end
    end, ClientPermissions.ConsoleCommands, true)

    ST.Commands.Add("!endnetworkscan", function (args, cmd)
        cmd:Reply("Network scan ended")

        EndNetworkScan()
    end, ClientPermissions.ConsoleCommands, true)
end

module.OnDisabled = function ()
    if CLIENT then return end

    ST.Commands.Remove("!startnetworkscan")
    ST.Commands.Remove("!endnetworkscan")

    Hook.Remove("netMessageReceived", "ServerTools.NetworkScan")
end

return module
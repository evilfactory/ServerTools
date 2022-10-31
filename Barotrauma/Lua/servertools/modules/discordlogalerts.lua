local module = {}

module.Name = "DiscordLogAlerts"

module.Config = {
    Enabled = false,
    AlertWebhook = "",
    AllWebhook = "",
    LogKeyWords = {"Nuclear Shell", "Velonaceps Calyx Eggs", "Morbusine", "Sufforin", "Cyanide", "Radiotoxin", "Frag Grenade", "Incendium Grenade"}
}


local json = require("servertools.json")

local serverLogMessageTypeLookup = {}

for key, value in pairs(ServerLogMessageType) do
    serverLogMessageTypeLookup[value] = key
end

local allLogQueue = {}
local sendDelay = 0

local function EscapeQuotes(str)
    return str:gsub("\"", "\\\"")
end

local function SendMessage(message, alert)
    local webhook = nil

    if alert then
        webhook = module.Config.AlertWebhook
        if module.Config.AlertWebhook == "" then return end
    else
        webhook = module.Config.AllWebhook
        if module.Config.AllWebhook == "" then return end
    end

    message = EscapeQuotes(message)
    Networking.HttpPost(webhook, function(result) end, json.encode({content = message}))
end

local causeOfDeathLookup = {}
for key, value in pairs(CauseOfDeathType) do
    causeOfDeathLookup[value] = key
end

module.OnEnabled = function ()
    Hook.Add("characterDeath", "ServerTools.DiscordLogAlerts.Deaths", function (character)
        if not character.IsHuman or character.IsBot then return end

        local name = character.Name

        local client = ST.Utils.FindClientByCharacter(character)
        if client ~= nil then
            name = "`" .. tostring(client.AccountId) .. "` ***" .. name .. "***"
        end

        local killer = "Unknown"
        local type = "Unknown"
        local affliction = "Unknown"
        local damageSource = "Unknown"

        if character.CauseOfDeath then
            if character.CauseOfDeath.Killer then
                killer = character.CauseOfDeath.Killer.Name

                local client = ST.Utils.FindClientByCharacter(character.CauseOfDeath.Killer)
                if client ~= nil then
                    killer = "`" .. tostring(client.AccountId) .. "` ***" .. killer .. "***"
                end
            end

            if character.CauseOfDeath.Type then
                type = causeOfDeathLookup[character.CauseOfDeath.Type]
            end

            if character.CauseOfDeath.Affliction then
                affliction = character.CauseOfDeath.Affliction.Name.Value
            end

            if character.CauseOfDeath.DamageSource then
                damageSource = tostring(character.CauseOfDeath.DamageSource)
                if damageSource == "Human" then
                    damageSource = character.CauseOfDeath.DamageSource.Name
                end
            end
        end

        SendMessage(string.format("%s has died, killer = %s, death type = `%s`, affliction = `%s`, last damage source = `%s`", name, killer, type, affliction, damageSource), true)
    end)

    Hook.Add("roundStart", "ServerTools.DiscordLogAlerts.RoundStart", function ()
        SendMessage("```Round has started```", true)
    end)

    Hook.Add("roundEnd", "ServerTools.DiscordLogAlerts.RoundEnd", function ()
        local traitors = ""
        if Traitormod ~= nil and Traitormod.SelectedGamemode ~= nil and Traitormod.SelectedGamemode.Traitors ~= nil then
            for character, traitor in pairs(Traitormod.SelectedGamemode.Traitors) do
                local client = ST.Utils.FindClientByCharacter(character)
                if client == nil then
                    traitors = traitors .. "(?) '" .. character.Name .. "' "
                else
                    traitors = traitors .. "(" .. tostring(client.AccountId) .. ") '" .. character.Name .. "' "
                end
            end
        else
            for key, value in pairs(Character.CharacterList) do
                if value.IsTraitor then
                    local client = ST.Utils.FindClientByCharacter(value)
                    if client == nil then
                        traitors = traitors .. "(?) '" .. value.Name .. "' "
                    else
                        traitors = traitors .. "(" .. tostring(client.AccountId) .. ") '" .. value.Name .. "' "
                    end
                end
            end
        end
        SendMessage(string.format("```Round has ended Traitors: %s```", traitors), true)
    end)

    Hook.Add("serverLog", "ServerTools.DiscordLogAlerts.ServerLog", function (message, type)
        -- throwing an error here would be quite catastrophic
        pcall(function ()
            for _, keyword in pairs(module.Config.LogKeyWords) do
                if string.find(message, keyword) then
                    message = message:gsub("‖metadata:", "`")
                    message = message:gsub("‖end‖", "***")
                    message = message:gsub("‖", "`***")
                    Timer.Wait(SendMessage(message), 1000)
                    break
                end
            end

            if module.Config.AllWebhook ~= "" then
                local time = "<t:" .. tostring(math.floor(os.time())) .. ":T>"
                table.insert(allLogQueue, time .. " **[" .. serverLogMessageTypeLookup[type] .. "]** " .. message)
            end
        end)
    end)

    Hook.Add("think", "ServerTools.DiscordLogAlerts.Think", function ()
        if sendDelay > Timer.GetTime() then return end
        
        local amount = 0
        local toSend = ""
        for key, value in pairs(allLogQueue) do
            if amount > 25 then
                break
            end

            toSend = toSend .. value .. "\n"
            allLogQueue[key] = nil

            amount = amount + 1
        end

        if toSend ~= "" then
            SendMessage(toSend, false)
        end

        sendDelay = Timer.GetTime() + 5
    end)

    SendMessage("Hello World!", true)
end

module.OnDisabled = function ()
    Hook.Remove("characterDeath", "ServerTools.DiscordLogAlerts.Deaths")
    Hook.Remove("roundStart", "ServerTools.DiscordLogAlerts.RoundStart")
    Hook.Remove("roundEnd", "ServerTools.DiscordLogAlerts.RoundEnd")
    Hook.Remove("serverLog", "ServerTools.DiscordLogAlerts.ServerLog")
end

return module
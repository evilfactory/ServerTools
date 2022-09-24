local module = {}

module.Name = "DiscordLogAlerts"

module.Config = {
    Enabled = false,
    Webhook = "Enter Here Your Discord Web Hook URL",
    LogKeyWords = {"Nuclear Shell", "Velonaceps Calyx Eggs", "Morbusine", "Sufforin", "Cyanide", "Radiotoxin", "Frag Grenade", "Incendium Grenade"}
}

local function EscapeQuotes(str)
    return str:gsub("\"", "\\\"")
end

local function SendMessage(message)
    message = EscapeQuotes(message)
    Networking.HttpPost(module.Config.Webhook, function(result) end, '{\"content\": \"'..message..'\"}')
end

local causeOfDeathLookup = {}
for key, value in pairs(CauseOfDeathType) do
    causeOfDeathLookup[value] = key
end

module.OnEnable = function ()
    Hook.Add("characterDeath", "ServerTools.DiscordLogAlerts.Deaths", function (character)
        if not character.IsHuman or character.IsBot then return end

        local name = character.Name

        local client = ST.Utils.FindClientByCharacter(character)
        if client ~= nil then
            name = "`" .. tostring(client.SteamID) .. "` ***" .. name .. "***"
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
                    killer = "`" .. tostring(client.SteamID) .. "` ***" .. killer .. "***"
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

        SendMessage(string.format("%s has died, killer = %s, death type = `%s`, affliction = `%s`, last damage source = `%s`", name, killer, type, affliction, damageSource))
    end)

    Hook.Add("roundStart", "ServerTools.DiscordLogAlerts.RoundStart", function ()
        SendMessage("```Round has started```")
    end)

    Hook.Add("roundEnd", "ServerTools.DiscordLogAlerts.RoundEnd", function ()
        local traitors = ""
        for key, value in pairs(Character.CharacterList) do
            if value.IsTraitor then
                local client = ST.Utils.FindClientByCharacter(value)
                if client == nil then
                    traitors = traitors .. "(?) '" .. value.Name .. "' "
                else
                    traitors = traitors .. "(" .. client.SteamID .. ") '" .. value.Name .. "' "
                end
            end
        end
        SendMessage(string.format("```Round has ended Traitors: %s```", traitors))
    end)

    Hook.Add("serverLog", "ServerTools.DiscordLogAlerts.ServerLog", function (message)
        -- throwing an error here would be quite catastrophic
        pcall(function ()
            for _, keyword in pairs(module.Config.LogKeyWords) do
                if string.find(message, keyword) then
                    message = message:gsub("‖metadata:", "`")
                    message = message:gsub("‖end‖", "***")
                    message = message:gsub("‖", "`***")
                    SendMessage(message)
                    break
                end
            end
        end)
    end)

    SendMessage("Hello World!")
end

module.OnDisable = function ()
    Hook.Remove("characterDeath", "ServerTools.DiscordLogAlerts.Deaths")
    Hook.Remove("roundStart", "ServerTools.DiscordLogAlerts.RoundStart")
    Hook.Remove("roundEnd", "ServerTools.DiscordLogAlerts.RoundEnd")
end

return module
local module = {}

module.Name = "ChatFilter"

module.Config = {
    Enabled = false,

    -- the message will simply be hidden
    BlockWords = {},

    -- the person will be kicked from the server
    KickWords = {},
    KickReason = "[Chat Filter] Bad word: [word].",

    -- the person will be banned from the server
    BanWords = {},
    BanReason = "[Chat Filter] Bad word: [word].",
    BanTime = 9999999,
}

module.OnEnabled = function ()
    if CLIENT then return end

    Hook.Add("chatMessage", "ChatFilter", function (message, client)
        message = string.lower(message)

        for _, word in pairs(module.Config.BanWords) do
            if string.find(message, string.lower(word)) then
                local reason = string.gsub(module.Config.KickReason, "%[word%]", word)
                client.Ban(reason, true, module.Config.BanTime)
                return true
            end
        end

        for _, word in pairs(module.Config.KickWords) do
            if string.find(message, string.lower(word)) then
                local reason = string.gsub(module.Config.KickReason, "%[word%]", word)
                client.Kick(reason)
                return true
            end
        end

        for _, word in pairs(module.Config.BlockWords) do
            if string.find(message, string.lower(word)) then
                return true
            end
        end
    end)
end

module.OnDisable = function ()
    if CLIENT then return end

    Hook.Remove("chatMessage", "ChatFilter")
end

return module
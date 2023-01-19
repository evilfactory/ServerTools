local module = {}

module.Name = "ChatFilter"

module.Config = {
    Enabled = false,

    -- the message will simply be hidden
    BlockWords = {},
    BlockReason = "[Chat Filter] Bad word: [word].",

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
                local reason = string.gsub(module.Config.BanReason, "%[word%]", word)
                client.Ban(reason, module.Config.BanTime)
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
                local chatMessage = ChatMessage.Create("", string.gsub(module.Config.BlockReason, "%[word%]", word), ChatMessageType.Default, nil, nil)
                chatMessage.Color = Color(255, 0, 0, 255)
                Game.SendDirectChatMessage(chatMessage, client)

                Game.Log("ChatFilter: " .. client.Name .. " tried to say: " .. message, ServerLogMessageType.ServerMessage)

                return true
            end
        end
    end)
end

module.OnDisabled = function ()
    if CLIENT then return end

    Hook.Remove("chatMessage", "ChatFilter")
end

return module
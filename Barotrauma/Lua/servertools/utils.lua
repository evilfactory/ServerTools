local utils = {}


utils.SendChat = function (text, client, color, senderName)
    if color == nil then color = Color.Cyan end
    if senderName == nil then senderName = "" end

    if client == nil then
        for key, value in pairs(Client.ClientList) do
            local chatMessage = ChatMessage.Create(senderName, text, ChatMessageType.Default, nil, nil)
            chatMessage.Color = color
            Game.SendDirectChatMessage(chatMessage, value)
        end
    else
        local chatMessage = ChatMessage.Create(senderName, text, ChatMessageType.Default, nil, nil)
        chatMessage.Color = color
        Game.SendDirectChatMessage(chatMessage, client)
    end
end

utils.SendMissionText = function (text, client, icon)
    if icon == nil then icon = "" end

    if client == nil then
        for key, value in pairs(Client.ClientList) do
            local chatMessage = ChatMessage.Create(senderName, text, ChatMessageType.ServerMessageBoxInGame, nil, nil)
            chatMessage.IconStyle = icon
            Game.SendDirectChatMessage(chatMessage, value)
        end
    else
        local chatMessage = ChatMessage.Create(senderName, text, ChatMessageType.ServerMessageBoxInGame, nil, nil)
        chatMessage.IconStyle = icon
        Game.SendDirectChatMessage(chatMessage, client)
    end
end

utils.SendPopup = function (text, client, color)
    if client == nil then
        for key, value in pairs(Client.ClientList) do
            local chatMessage = ChatMessage.Create(senderName, text, ChatMessageType.MessageBox, nil, nil)
            if color then chatMessage.Color = color end
            Game.SendDirectChatMessage(chatMessage, value)
        end
    else
        local chatMessage = ChatMessage.Create(senderName, text, ChatMessageType.MessageBox, nil, nil)
        if color then chatMessage.Color = color end
        Game.SendDirectChatMessage(chatMessage, client)
    end
end

utils.FindClientByName = function(name)
    for key, value in pairs(Client.ClientList) do
        if value.Name == name then return value end
    end
end

utils.FindClientByCharacter = function(character)
    for key, value in pairs(Client.ClientList) do
        if value.Character == character then return value end
    end
end

utils.ClientLogName = function (client, name)
    if name == nil then name = client.Name end

    name = string.gsub(name, "%‖", "")

    local log = "‖metadata:" .. client.SteamID .. "‖" .. name .. "‖end‖"
    return log
end

utils.Log = function (text, ...)
    print(string.format(text, ...))
end

utils.LogError = function (text, ...)
    printerror(string.format(text, ...))
end

return utils
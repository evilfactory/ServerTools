Hook.Add("chatMessage", "ServerTools.ChatMessage", function (text, client)
    local result, message = ST.Commands.Execute(text, client)

    if result == true then
        Game.Log(string.format("[ServerTools] %s used command \"%s\".", ST.Utils.ClientLogName(client), text), ServerLogMessageType.ConsoleUsage)

        return true
    elseif result == false then

        Game.Log(string.format("[ServerTools] %s attempted to use command \"%s\" but failed with reason \"%s\"", ST.Utils.ClientLogName(client), text, message), ServerLogMessageType.ConsoleUsage)

        ST.Utils.SendChat(message, client, Color.Red)
        return true
    end
end)

ST.Commands.Add("!reloadmodules", function (args, client)
    ST.Modules.ReloadAll()

    ST.Utils.SendChat("Reloaded modules.", client)
end, ClientPermissions.ConsoleCommands)

ST.Commands.Add("!savemodules", function (args, client)
    ST.Modules.SaveAll()

    ST.Utils.SendChat("Saved modules.", client)
end, ClientPermissions.ConsoleCommands)
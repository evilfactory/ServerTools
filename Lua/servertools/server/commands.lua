local ClientCommandReply = {
    Client = nil,

    Reply = function (self, message, color)
        ST.Utils.SendChat(message, self.Client, color)
    end
}

local ServerCommandReply = {
    Reply = function (self, message, color)
        print(message)
    end
}

Hook.Add("chatMessage", "ServerTools.ChatMessage", function (text, client)
    if client == nil then return end

    local command, args = ST.Commands.Prepare(text)

    if command == nil then
        return
    end

    local success, message = ST.Commands.CanExecute(command, client)

    if success then
        Game.Log(string.format("[ServerTools] %s used command \"%s\".", ST.Utils.ClientLogName(client), text), ServerLogMessageType.ConsoleUsage)

        ClientCommandReply.Client = client
        ST.Commands.Execute(command, args, ClientCommandReply, client)

        return true
    else
        Game.Log(string.format("[ServerTools] %s attempted to use command \"%s\" but failed with reason \"%s\"", ST.Utils.ClientLogName(client), text, message), ServerLogMessageType.ConsoleUsage)

        ST.Utils.SendChat(message, client, Color.Red)
        return true
    end
end)

Game.AddCommand("st_cli", "", function (args)
    local command, args = ST.Commands.Prepare(args)

    if command == nil then
        ServerCommandReply:Reply("Command not found.", Color.Red)
        return
    end

    local success, message = ST.Commands.CanExecute(command)

    if success then
        ST.Commands.Execute(command, args, ServerCommandReply)
    else
        ServerCommandReply:Reply(message, Color.Red)
    end
end)

ST.Commands.Add("!reloadmodules", function (args, cmd)
    ST.Modules.ReloadAll()

    cmd:Reply("Reloaded modules.")
end, ClientPermissions.ConsoleCommands, true)

ST.Commands.Add("!savemodules", function (args, cmd)
    ST.Modules.SaveAll()

    cmd:Reply("Saved modules.")
end, ClientPermissions.ConsoleCommands, true)
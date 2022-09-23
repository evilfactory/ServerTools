local module = {}

module.Name = "AdminPM"

module.Config = {
    Enabled = true,
}

local function SendMessageAdmins(text)
    for key, value in pairs(Client.ClientList) do
        if value.HasPermission(ClientPermissions.ConsoleCommands) then
            ST.Utils.SendChat(text, value, Color.Red, "[ADMIN PM]")
        end
    end
end

module.OnEnable = function ()
    if CLIENT then return end

    ST.Commands.Add("!adminpm", function (args, cmd, client)
        if client.HasPermission(ClientPermissions.ConsoleCommands) then
            local target = ST.Utils.FindClientByName(args[1])
            if target == nil then
                cmd:Reply("Client not found.", Color.Red)
                return true
            end

            if args[2] == nil then
                cmd:Reply("Please specify a message to send.", Color.Red)
                return true
            end

            local text = table.concat(args, " ", 2)

            ST.Utils.SendPopup(string.format("[ADMIN PM] %s\n\n(Use !adminpm text to respond)", text), target)
            SendMessageAdmins(string.format("%s sent \"%s\" to %s", ST.Utils.ClientLogName(client), text, ST.Utils.ClientLogName(target)))

            return true
        else
            if args[1] == nil then
                cmd:Reply("Please specify a message to send.", Color.Red)
                return true
            end

            local text = table.concat(args, " ", 1)

            SendMessageAdmins(string.format("%s: %s", ST.Utils.ClientLogName(client), text))
            ST.Utils.SendChat(string.format("sent \"%s\" to admins.", text), client, Color.Red)

            return true
        end
    end)
end

module.OnDisable = function ()
    if CLIENT then return end

    ST.Commands.Remove("!adminpm")
end


return module
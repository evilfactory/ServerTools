local module = {}

module.Name = "DonatorSystem"

module.Config = {
    Enabled = false,

    Styles = {
        Default = {},
        Meefus = {
            Default = {255, 71, 111},
            Dead = {255, 46, 46},
            Radio = {149, 227, 187},
        },
    },

    ClientStyle = {}
}

if SERVER then
    Hook.Patch("Barotrauma.Networking.GameServer", "SendDirectChatMessage", {"Barotrauma.Networking.ChatMessage", "Barotrauma.Networking.Client"}, function (self, ptable)
        Hook.Call("DonatorSystem.ChatMessage", ptable["msg"])
    end)
end

LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Item"], "set_InventoryIconColor")

module.OnEnabled = function ()
    if CLIENT then return end

    ST.Commands.Add("!clothcolor", function (args, cmd, client)
        if not client.Character or not client.Character.IsHuman or client.Character.IsDead then
            cmd:Reply("You must be alive to use this command.")
        end

        if #args < 3 then
            cmd:Reply("Usage: !clothcolor \"R\" \"G\" \"B\"")
            return true
        end

        local r = tonumber(args[1])
        local g = tonumber(args[2])
        local b = tonumber(args[3])

        if r == nil or g == nil or b == nil then
            cmd:Reply("Usage: !clothcolor \"R\" \"G\" \"B\"")
            return true
        end

        local item = client.Character.Inventory.GetItemInLimbSlot(InvSlotType.InnerClothes)

        if item == nil then
            cmd:Reply("You must be wearing clothes to use this command.")
            return true
        end

        item.set_InventoryIconColor(Color(r, g, b))
        item.SpriteColor = Color(r, g, b)

        local color = item.SerializableProperties[Identifier("SpriteColor")]
        Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(color, item))

        local invColor = item.SerializableProperties[Identifier("InventoryIconColor")]
        Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(invColor, item))

        cmd:Reply(string.format("Set your clothes color to %s, %s, %s", r, g, b))
    end, ClientPermissions.KarmaImmunity)

    ST.Commands.Add("!chatstyle", function (args, cmd, client)
        if #args < 1 then
            local availableStyles = ""

            for key, value in pairs(module.Config.Styles) do
                availableStyles = availableStyles .. key .. "\n"
            end

            cmd:Reply("Usage: !chatstyle \"StyleName\"\n\nAvailable Styles:\n" .. availableStyles)
            return true
        end

        if args[1] == nil or module.Config.Styles[args[1]] == nil then
            local availableStyles = ""

            for key, value in pairs(module.Config.Styles) do
                availableStyles = availableStyles .. key .. "\n"
            end

            cmd:Reply("Usage: !chatstyle \"StyleName\"\n\nAvailable Styles:\n" .. availableStyles)
            return
        end

        module.Config.ClientStyle[tostring(client.SteamID)] = args[1]

        cmd:Reply(string.format("Set chat style to \"%s\"", args[1]))
        ST.Modules.Save(module)
    end, ClientPermissions.KarmaImmunity)

    Hook.Add("DonatorSystem.ChatMessage", "DonatorSystem.ChatMessage", function (msg)
        if msg.Type ~= ChatMessageType.Radio and msg.Type ~= ChatMessageType.Dead and msg.Type ~= ChatMessageType.Default then
            return
        end

        local client = msg.SenderClient

        if client == nil then return end
        if not client.HasPermission(ClientPermissions.KarmaImmunity) then return end

        local style = module.Config.ClientStyle[tostring(client.SteamID)]

        if style == nil then
            return
        end

        style = module.Config.Styles[style]
        if style == nil then return end

        if msg.Type == ChatMessageType.Radio then
            if style.Radio then
                msg.Color = Color(style.Radio[1], style.Radio[2], style.Radio[3])
            end
        elseif msg.Type == ChatMessageType.Dead then
            if style.Dead then
                msg.Color = Color(style.Dead[1], style.Dead[2], style.Dead[3])
            end
        else
            if style.Default then
                msg.Color = Color(style.Default[1], style.Default[2], style.Default[3])
            end
        end
    end)
end

module.OnDisabled = function ()
    if CLIENT then return end

    ST.Commands.Remove("!chatstyle")
    ST.Commands.Remove("!clothcolor")
    Hook.Remove("DonatorSystem.ChatMessage", "DonatorSystem.ChatMessage")
end


return module
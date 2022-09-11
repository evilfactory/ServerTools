local commands = {}

commands.RegisteredCommands = {}

commands.Parse = function (text)
    local result = {}

    if text == nil then return result end

    local spat, epat, buf, quoted = [=[^(["])]=], [=[(["])$]=]
    for str in text:gmatch("%S+") do
        local squoted = str:match(spat)
        local equoted = str:match(epat)
        local escaped = str:match([=[(\*)["]$]=])
        if squoted and not quoted and not equoted then
            buf, quoted = str, squoted
        elseif buf and equoted == quoted and #escaped % 2 == 0 then
            str, buf, quoted = buf .. ' ' .. str, nil, nil
        elseif buf then
            buf = buf .. ' ' .. str
        end
        if not buf then result[#result + 1] = str:gsub(spat,""):gsub(epat,"") end
    end

    return result
end

commands.Add = function (names, onExecute, permissionRequired)
    if type(names) == "string" then names = {names} end

    local command = {}
    command.Names = names
    command.OnExecute = onExecute
    command.PermissionRequired = permissionRequired

    table.insert(commands.RegisteredCommands, command)
end

commands.Remove = function (name)
    for key, value in pairs(commands.RegisteredCommands) do
        for key2, value2 in pairs(value.Names) do
            if value2 == name then
                commands.RegisteredCommands[key] = nil
                return true
            end
        end
    end
    return false
end

commands.CanExecute = function (command, client)
    if client == nil then return true end
    
    if command.PermissionRequired ~= nil and not client.HasPermission(command.PermissionRequired) then
        return false, "You do not have permission to execute this command."
    end

    return true
end

commands.Execute = function (text, client)
    local args

    if type(text) == "table" then
        args = text
    else
        args = commands.Parse(text)
    end

    local command = table.remove(args, 1)

    for key, value in pairs(commands.RegisteredCommands) do
        for key2, value2 in pairs(value.Names) do
            if value2 == command then
                local success, message = commands.CanExecute(value, client)
                if not success then
                    return false, message
                end

                value.OnExecute(args, client)
                return true
            end
        end
    end

    return nil
end

return commands
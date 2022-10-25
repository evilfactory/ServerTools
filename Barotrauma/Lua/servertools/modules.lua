local modules = {}

local json = require("servertools.json")

modules.SetConfigPath = function (path)
    modules.ConfigPath = path
end

modules.RegisteredModules = {}
modules.Register = function (module)
    if module.Name == nil then
        error("Tried to register a module that doesnt have a Name defined.", 2)
    end

    module.Config = module.Config or {}

    module.Load = function() return modules.Load(module) end
    module.LoadFile = function(path) return modules.LoadFile(module, path) end
    module.LoadJson = function(data) return modules.LoadJson(module, data) end

    module.Save = function() return modules.Save(module) end
    module.SaveFile = function(path) return modules.SaveFile(module, path) end
    module.SaveJson = function() return modules.SaveJson(module) end

    module.Reload = function() return modules.Reload(module) end

    modules.RegisteredModules[module.Name] = module

    ST.Utils.Log("Registered module %s", module.Name)
end

modules.Load = function (module)
    modules.LoadFile(module, modules.ConfigPath .. module.Name .. ".json")
end

modules.LoadJson = function (module, data)
    local config = json.decode(data)

    for key, value in pairs(config) do
        module.Config[key] = value
    end
end

modules.LoadFile = function (module, path)
    local config

    if File.Exists(path) then
        local file = File.Read(path)
        config = json.decode(file)
    else
        modules.SaveFile(module, path)

        local file = File.Read(path)
        config = json.decode(file)
    end

    for key, value in pairs(config) do
        module.Config[key] = value
    end
end

modules.Save = function (module)
    modules.SaveFile(module, modules.ConfigPath .. module.Name .. ".json")
end

modules.SaveJson = function (module)
    return json.encode(module.Config)
end

modules.SaveFile = function (module, path)
    File.Write(path, modules.SaveJson(module))
end

modules.Reload = function (module)
    if module.OnDisabled then
        module.OnDisabled()
    end

    if module.Config.Enabled and module.OnEnabled then
        module.OnEnabled()
    end
end

modules.All = function ()
    local nextIndex
    local value
    return function ()
        nextIndex, value = next(modules.RegisteredModules, nextIndex)
        return value
    end
end

modules.FindByName = function (name)
    return modules.RegisteredModules[name]
end


return modules
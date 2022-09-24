local modules = {}

local json = require("servertools.json")

modules.RegisteredModules = {}
modules.Register = function (module)
    if type(module) == "string" then
        module = require(module)
    end

    if module.Name == nil then
        error("Tried to register a module that doesnt have a Name defined.", 2)
    end

    modules.RegisteredModules[module.Name] = module

    modules.Load(module)

    ST.Utils.Log("Registered and loaded module %s", module.Name)

    if module.Config.Enabled and module.OnEnable then
        module.OnEnable()
    end
end

modules.Load = function (module)
    if type(module) == "string" then
        module = require(module)
    end

    if CLIENT then
        return module
    end

    local configPath = ST.Path .. "/config/" .. module.Name .. ".json"
    local config

    if File.Exists(configPath) then
        local file = File.Read(configPath)
        config = json.decode(file)
    else
        modules.Save(module)

        local file = File.Read(configPath)
        config = json.decode(file)
    end

    for key, value in pairs(config) do
        module.Config[key] = value
    end

    return module
end

modules.Save = function (module)
    if type(module) == "string" then
        module = require(module)
    end

    local configPath = ST.Path .. "/config/" .. module.Name .. ".json"
    local config = json.encode(module.Config)

    File.Write(configPath, config)
end

modules.ReloadAll = function ()
    for key, module in pairs(modules.RegisteredModules) do
        if module.OnDisable then module.OnDisable() end

        modules.Load(module)

        if module.Config.Enabled and module.OnEnable then
            module.OnEnable()
        end
    end
end

modules.SaveAll = function ()
    for key, module in pairs(modules.RegisteredModules) do
        modules.Save(module)
    end
end


return modules
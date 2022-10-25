ST.ConfigPath = ST.Path .. "/config/"

for module in ST.Modules.All() do
    module.Load()
end

for module in ST.Modules.All() do
    module.Reload()
end

Networking.Receive("st.reqmodulecfg", function (message, client)
    local moduleName = message.ReadString()
    local module = ST.Modules.FindByName(moduleName)

    if module == nil then
        ST.Utils.Log("Received module config for unknown module %s from client", moduleName)
        return
    end

    local message = Networking.Start("st.modulecfg")
    message.WriteString(module.Name)
    message.WriteString(module.SaveJson())
    Networking.Send(message, client.Connection)
end)
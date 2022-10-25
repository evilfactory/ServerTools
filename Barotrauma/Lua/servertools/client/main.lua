for module in ST.Modules.All() do
    local message = Networking.Start("st.reqmodulecfg")
    message.WriteString(module.Name)
    Networking.Send(message)
end

Networking.Receive("st.modulecfg", function (message)
    local module = ST.Modules.FindByName(message.ReadString())

    if module == nil then return end

    local json = message.ReadString()
    module.LoadJson(json)

    module.Reload()

    ST.Utils.Log("Received module config %s from server", module.Name)
end)
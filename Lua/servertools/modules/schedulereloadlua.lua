local module = {}

module.Name = "ScheduleReloadLua"

module.Config = {
    Enabled = true,
}

module.OnEnable = function ()
    if CLIENT then return end

    module.IsScheduled = false

    ST.Commands.Add("!schedulereloadlua", function (args, cmd)
        module.IsScheduled = true

        cmd:Reply("Reload lua has been scheduled, its going to be reloaded next round.")
    end, ClientPermissions.ConsoleCommands, true)

    Hook.Add("roundEnd", "ScheduleReloadLua", function ()
        if module.IsScheduled then
            module.IsScheduled = false

            Timer.Wait(function ()
                -- lets let other scripts do their own thing before we ruin it
                Game.ExecuteCommand("reloadlua")
            end, 100)
        end
    end)
end

module.OnDisable = function ()
    if CLIENT then return end

    ST.Commands.Remove("!schedulereloadlua")
    Hook.Remove("roundEnd", "ScheduleReloadLua")
end


return module
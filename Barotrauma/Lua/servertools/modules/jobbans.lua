local module = {}

module.Name = "JobBans"

module.Config = {
    Enabled = true,

    JobBanned = {}
}

module.OnEnabled = function ()
    if CLIENT then return end

    Hook.Add("jobsAssigned", "ServerTools.JobBans", function ()
        for key, value in pairs(Client.ClientList) do
            if value.AssignedJob then
                local job = value.AssignedJob.Prefab.Identifier.Value
                local banned = module.Config.JobBanned[value.SteamID]
                if banned ~= nil then
                    if banned[job] then
                        value.AssignedJob = JobVariant(JobPrefab.Get("assistant"), 0)
                    end
                end
            end
        end
    end)

    ST.Commands.Add({"!banjob", "!jobban"}, function (args, cmd, client)
        if #args < 2 then
            cmd:Reply("Usage: !banjob \"Name\" \"Job\"", Color.Red)
            return true
        end

        local target = ST.Utils.FindClientByName(args[1])
        if target == nil then
            cmd:Reply("Client not found.", Color.Red)
            return
        end

        local job = JobPrefab.Get(args[2])
        if job == nil then
            cmd:Reply("Job not found.", Color.Red)
            return
        end

        if module.Config.JobBanned[target.SteamID] then
            if module.Config.JobBanned[target.SteamID][args[2]] then
                cmd:Reply("This client is already banned from this job.", Color.Red)
                return
            end

            module.Config.JobBanned[target.SteamID][args[2]] = true
        else
            module.Config.JobBanned[target.SteamID] = {[args[2]] = true}
        end

        cmd:Reply(string.format("\"%s\" has been banned from using the job \"%s\"", target.Name, args[2]), Color.Green)

        ST.Modules.Save(module)
    end, ClientPermissions.ConsoleCommands)

    ST.Commands.Add({"!unbanjob", "!jobunban", "!unjobban"}, function (args, cmd, client)
        if #args < 2 then
            cmd:Reply("Usage: !unbanjob \"Name\" \"Job\"", Color.Red)
            return true
        end

        local target = ST.Utils.FindClientByName(args[1])
        if target == nil then
            cmd:Reply("Client not found.", Color.Red)
            return
        end

        local jobBanned = module.Config.JobBanned[client.SteamID]

        if jobBanned == nil or jobBanned[args[2]] == nil then
            cmd.Reply("This client is not banned from this job.", Color.Red)
            return
        else
            jobBanned[args[2]] = nil

            if next(jobBanned) == nil then
                module.Config.JobBanned[client.SteamID] = nil
            end

            cmd:Reply(string.format("\"%s\" has been unbanned from using the job %s", target.Name, args[2]), Color.Green)

            ST.Modules.Save(module)
        end
    end, ClientPermissions.ConsoleCommands)

    ST.Commands.Add({"!jobbans"}, function (args, cmd, client)
        if #args < 1 then
            cmd:Reply("Usage: !jobbans \"Name\"", Color.Red)
            return true
        end

        local target = ST.Utils.FindClientByName(args[1])
        if target == nil then
            cmd:Reply("Client not found.", Color.Red)
            return
        end

        local jobBanned = module.Config.JobBanned[client.SteamID]

        local text = target.Name .. " has the following job bans: \n"

        if jobBanned == nil or next(jobBanned) == nil then
            text = text .. " - No job bans."
        else
            for key, value in pairs(jobBanned) do
                text = text .. " - " .. key .. "\n"
            end
        end

        cmd:Reply(text, Color.Green)
    end)
end

module.OnDisabled = function ()
    if CLIENT then return end

    ST.Commands.Remove("!banjob")
    ST.Commands.Remove("!unbanjob")
    ST.Commands.Remove("!jobbans")

    Hook.Remove("jobsAssigned", "ServerTools.JobBans")
end

return module
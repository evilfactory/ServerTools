local module = {}

module.Name = "JobBans"

module.Config = {
    Enabled = true,

    JobBanned = {}
}

module.OnEnable = function ()
    if CLIENT then return end

    Hook.Add("jobsAssigned", "ServerTools.JobBans", function ()
        for key, value in pairs(Client.ClientList) do
            local job = value.AssignedJob.Prefab.Identifier.Value
            local banned = module.Config.JobBanned[value.SteamID]
            if banned ~= nil then
                if banned[job] then
                    value.AssignedJob = JobVariant(JobPrefab.Get("assistant"), 0)
                end
            end
        end
    end)

    ST.Commands.Add({"!banjob", "!jobban"}, function (args, client)
        if #args < 2 then
            ST.Utils.SendChat("Usage: !banjob \"Name\" \"Job\"", client, Color.Red)
            return true
        end

        local target = ST.Utils.FindClientByName(args[1])
        if target == nil then
            ST.Utils.SendChat("Client not found.", client, Color.Red)
            return
        end

        local job = JobPrefab.Get(args[2])
        if job == nil then
            ST.Utils.SendChat("Job not found.", client, Color.Red)
            return
        end

        if module.Config.JobBanned[target.SteamID] then
            if module.Config.JobBanned[target.SteamID][args[2]] then
                ST.Utils.SendChat("This client is already banned from this job.", client, Color.Red)
                return
            end

            module.Config.JobBanned[target.SteamID][args[2]] = true
        else
            module.Config.JobBanned[target.SteamID] = {[args[2]] = true}
        end

        ST.Utils.SendChat(string.format("\"%s\" has been banned from using the job \"%s\"", target.Name, args[2]), client, Color.Green)
    end, ClientPermissions.ConsoleCommands)

    ST.Commands.Add({"!unbanjob", "!jobunban", "!unjobban"}, function (args, client)
        if #args < 2 then
            ST.Utils.SendChat("Usage: !unbanjob \"Name\" \"Job\"", client, Color.Red)
            return true
        end

        local target = ST.Utils.FindClientByName(args[1])
        if target == nil then
            ST.Utils.SendChat("Client not found.", client, Color.Red)
            return
        end

        local jobBanned = module.Config.JobBanned[client.SteamID]

        if jobBanned == nil or jobBanned[args[2]] == nil then
            ST.Utils.SendChat("This client is not banned from this job.", client, Color.Red)
            return
        else
            jobBanned[args[2]] = nil

            if next(jobBanned) == nil then
                module.Config.JobBanned[client.SteamID] = nil
            end

            ST.Utils.SendChat(string.format("\"%s\" has been unbanned from using the job %s", target.Name, args[2]), client, Color.Green)
        end
    end, ClientPermissions.ConsoleCommands)

    ST.Commands.Add({"!jobbans"}, function (args, client)
        if #args < 1 then
            ST.Utils.SendChat("Usage: !jobbans \"Name\"", client, Color.Red)
            return true
        end

        local target = ST.Utils.FindClientByName(args[1])
        if target == nil then
            ST.Utils.SendChat("Client not found.", client, Color.Red)
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

        ST.Utils.SendChat(text, client, Color.Green)
        ST.Utils.SendPopup(text, client)
    end)
end

module.OnDisable = function ()
    if CLIENT then return end

    ST.Commands.Remove("!banjob")
    ST.Commands.Remove("!unbanjob")
    ST.Commands.Remove("!jobbans")

    Hook.Remove("jobsAssigned", "ServerTools.JobBans")
end

return module
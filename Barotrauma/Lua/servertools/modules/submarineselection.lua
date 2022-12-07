local module = {}

module.Name = "SubmarineSelection"

module.Config = {
    Enabled = false,
    MaxPickAmount = 2,
}

module.OnEnabled = function ()
    if CLIENT then return end

    module.LastPickedSubmarine = nil
    module.PickedTimes = 0

    Hook.Patch("Barotrauma.Networking.GameServer", "InitiateStartGame", function (self, ptable)
        if module.LastPickedSubmarine == ptable["selectedSub"] then
            PickedTimes = PickedTimes + 1
        else
            PickedTimes = 0
        end

        if PickedTimes > module.Config.MaxPickAmount then
            local submarines = Game.NetLobbyScreen.subs
            ptable["selectedSub"] = submarines[math.random(#submarines)]
            PickedTimes = 0
        end

        module.LastPickedSubmarine = ptable["selectedSub"]
    end)
end

module.OnDisabled = function ()
    if CLIENT then return end

end


return module
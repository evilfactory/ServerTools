local module = {}

module.Name = "SubmarineSelection"

module.Config = {
    Enabled = false,
    MaxPickAmount = 1,
    RandomPicks = {"Azimuth"}
}

local function GetRandomSub()
    local randomPick = module.Config.RandomPicks[math.random(#module.Config.RandomPicks)]

    for key, value in pairs(Game.NetLobbyScreen.subs) do
        if value.Name == randomPick then
            return value
        end
    end
end

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
            local submarine = GetRandomSub()

            if submarine then
                ptable["selectedSub"] = submarine
            end

            PickedTimes = 0
        end

        module.LastPickedSubmarine = ptable["selectedSub"]
    end)
end

module.OnDisabled = function ()
    if CLIENT then return end

end


return module
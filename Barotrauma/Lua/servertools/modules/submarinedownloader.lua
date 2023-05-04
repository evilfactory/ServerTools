local module = {}

module.Name = "SubmarineDownloader"

module.Config = {
    Enabled = false,
    WorkshopCollections = {2854772695},
    Path = "LocalMods/TempSubmarines/",
}

local itemsBeingDownloaded = 0
local itemsDownloaded = 0

local function UpdateItem(id)
    Steam.GetWorkshopItem(UInt64(id), function (item)
        if item == nil then
            print(string.format("Couldn't find workshop item with id %s.", id))
            return
        end

        if item.Title == "" then return end

        itemsBeingDownloaded = itemsBeingDownloaded + 1

        print(string.format("Downloading latest version of '%s'...", item.Title))

        Steam.DownloadWorkshopItem(item, module.Config.Path .. id, function (downloadedItem)
            itemsDownloaded = itemsDownloaded + 1
            print(string.format("(%s/%s) '%s' was successfully downloaded and placed in %s", itemsDownloaded, itemsBeingDownloaded, downloadedItem.Title, module.Config.Path .. id))

            if itemsDownloaded == itemsBeingDownloaded then
                print("Updating submarine lobby.")
                Timer.Wait(function()
                    module.UpdateLobby()
                end, 1000)
            end
        end)
    end)
end

module.UpdateLobby = function()
    SubmarineInfo.RefreshSavedSubs()
    local toReplace = {}

    for _, sub in pairs(SubmarineInfo.SavedSubmarines) do
        if sub.Type == 0 and not sub.HasTag(2) then
            table.insert(toReplace, sub)
        end
    end

    local files = File.DirSearch(module.Config.Path)

    local extension = ".sub"

    for key, value in pairs(files) do
        if value:sub(-#extension) == extension then
            local submarineInfo = SubmarineInfo(value)
            if not submarineInfo.HasTag(2) then
                table.insert(toReplace, submarineInfo)
                SubmarineInfo.AddToSavedSubs(submarineInfo)
            end
        end
    end

    Game.NetLobbyScreen.subs = toReplace

    for _, client in pairs(Client.ClientList) do
        client.LastRecvLobbyUpdate = 0
        Networking.ClientWriteLobby(client)
    end
end

module.UpdateSubmarines = function ()
    if File.DirectoryExists(module.Config.Path) then
        File.DeleteDirectory(module.Config.Path)
    end

    itemsBeingDownloaded = 0
    itemsDownloaded = 0

    for key, collection in pairs(module.Config.WorkshopCollections) do
        Steam.GetWorkshopItem(collection, function (item)
            Steam.GetWorkshopCollection(collection, function (items)
                print(string.format("Retrieved %s items from collection '%s'", #items, item.Title))
                for key, value in pairs(items) do
                    UpdateItem(value)
                end
            end)
        end)
    end

end

module.OnEnabled = function ()
    if CLIENT then return end

    ST.Commands.Add("!updatesubmarines", function (args, cmd)
        if Game.RoundStarted then
            cmd:Reply("You can't update submarines while the round is running.", Color.Red)
            return true
        end

        if Game.ServerSettings.StartWhenClientsReady then
            cmd:Reply("Please disable Start When Clients Ready to prevent accidental starts.", Color.Red)
            return true
        end

        if not Game.IsDedicated then
            cmd:Reply("Submarine downloading can only be used in dedicated servers.", Color.Red)
            return true
        end

        module.UpdateSubmarines()

        cmd:Reply("Submarines are being updated, this may take a while, check console for more details. Do not start the game while this is in progress.", Color.Yellow)
    end, ClientPermissions.ConsoleCommands, true)

    if Game.IsDedicated and ExecutionNumber == 0 then -- prevents reloadlua from re-executing this code
        Timer.Wait(function ()
            module.UpdateSubmarines()
        end, 5000)
    end
end

module.OnDisabled = function ()
    if CLIENT then return end

    ST.Commands.Remove("!updatesubmarines")
end

return module
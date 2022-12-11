local module = ...
local json = require("servertools.json")

local serverLogMessageTypeLookup = {}

for key, value in pairs(ServerLogMessageType) do
    serverLogMessageTypeLookup[value] = key
end

module.NewRound = function ()
    local data = {
        UniqueId = module.Config.UniqueId,
    }

    Networking.HttpPost(module.Config.EndPoint .. "/api/v1/new-round", function (res) end, json.encode(data))
end

local logQueue = {}
local timer = 0

module.SendLog = function(message, type)
    if not module.Config.SendLogs then return end

    message = message:gsub("‖metadata:", "(")
    message = message:gsub("‖end‖", "")
    message = message:gsub("‖", ")")

    if message == "[LuaCs] Test" then return end

    type = serverLogMessageTypeLookup[type]

    table.insert(logQueue, "[" .. type .. "] " .. message)
end

module.UpdateLog = function ()
    if not module.Config.SendLogs then return end

    if Timer.GetTime() < timer then return end

    timer = Timer.GetTime() + 5

    local amount = 0
    local toSend = ""
    for key, value in pairs(logQueue) do
        if amount > 25 then
            break
        end

        toSend = toSend .. value .. "\n"
        logQueue[key] = nil

        amount = amount + 1
    end

    if toSend ~= "" then
        local data = {
            UniqueId = module.Config.UniqueId,
            Message = toSend,
        }

        Networking.HttpPost(module.Config.EndPoint .. "/api/v1/send-logs", function (res) end, json.encode(data))
    end
end
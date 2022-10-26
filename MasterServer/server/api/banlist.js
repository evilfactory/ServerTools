baroMS.banList = {}

const fs = require("fs")
const path = require("path")

function loadData() {
    if (fs.existsSync(path.join(__dirname, "/data/banlist.json"))) {
        const data = fs.readFileSync(path.join(__dirname, "/data/banlist.json"))
        baroMS.banList = JSON.parse(data)
    }
}

function saveData() {
    fs.writeFileSync(path.join(__dirname, "/data/banlist.json"), JSON.stringify(baroMS.banList))
}


loadData()

baroMS.app.post("/api/v1/ban", function (req, res) {
    const data = req.body

    if (baroMS.config.barotraumaServers[data.UniqueId] == null) {
        res.end()
        return
    }

    baroMS.banList[data.Account] = {Reason: data.Reason}

    console.log("[" + data.UniqueId + "] Adding " + data.Account + " to ban list.")

    saveData()

    res.end()
})

baroMS.app.post("/api/v1/unban", function (req, res) {
    const data = req.body

    if (baroMS.config.barotraumaServers[data.UniqueId] == null) {
        res.end()
        return
    }

    delete baroMS.banList[data.Account]

    console.log("[" + data.UniqueId + "] Removing " + data.Account + " from ban list.")

    saveData()

    res.end()
})

baroMS.app.post("/api/v1/banlist", function (req, res) {
    const data = req.body

    if (baroMS.config.barotraumaServers[data.UniqueId] == null) {
        res.end()
        return
    }

    res.json({ "BanList": baroMS.banList }).end()
})
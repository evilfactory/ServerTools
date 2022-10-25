website.banList = {}

const fs = require("fs")
const path = require("path")

function loadData() {
    if (fs.existsSync(path.join(__dirname, "/data/banlist.json"))) {
        const data = fs.readFileSync(path.join(__dirname, "/data/banlist.json"))
        website.banList = JSON.parse(data)
    }
}

function saveData() {
    fs.writeFileSync(path.join(__dirname, "/data/banlist.json"), JSON.stringify(website.banList))
}


loadData()

website.app.post("/api/v1/ban", function (req, res) {
    const data = req.body

    if (website.config.barotraumaServers[data.UniqueId] = null) {
        return
    }

    website.banList[data.Account] = {Reason: data.Reason}

    console.log("[" + data.UniqueId + "] Adding " + data.Account + " to ban list.")

    saveData()

    res.end()
})

website.app.post("/api/v1/unban", function (req, res) {
    const data = req.body

    if (website.config.barotraumaServers[data.UniqueId] = null) {
        return
    }

    delete website.banList[data.Account]

    console.log("[" + data.UniqueId + "] Removing " + data.Account + " from ban list.")

    saveData()

    res.end()
})

website.app.post("/api/v1/banlist", function (req, res) {
    const data = req.body

    if (website.config.barotraumaServers[data.UniqueId] = null) {
        return
    }

    res.json({ "BanList": website.banList })
})
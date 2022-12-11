const fs = require("fs")
const path = require("path")

baroMS.serverData = {}

function loadData() {
    if (fs.existsSync("./data/server.json")) {
        const data = fs.readFileSync("./data/server.json")
        baroMS.serverData = JSON.parse(data)
    }
}

function saveData() {
    fs.writeFileSync("./data/server.json", JSON.stringify(baroMS.serverData))
}

loadData()

baroMS.app.post("/api/v1/send-logs", function (req, res) {
    const data = req.body

    if (!baroMS.config.barotraumaServers[data.UniqueId]) {
        res.end()
        return
    }

    if (!baroMS.serverData[data.UniqueId]) {
        baroMS.serverData[data.UniqueId] = {}
        baroMS.serverData[data.UniqueId].roundNumber = 1

        saveData()
    }

    let dir = "./data/serverlogs/" + data.UniqueId + "/"
    let path = dir + "round " + baroMS.serverData[data.UniqueId].roundNumber + ".txt"

    if (!fs.existsSync(dir)) { fs.mkdirSync(dir, {recursive: true}) }

    fs.appendFileSync(path, data.Message)

    res.end()
})

baroMS.app.post("/api/v1/new-round", function (req, res) {
    const data = req.body

    if (!baroMS.config.barotraumaServers[data.UniqueId]) {
        res.end()
        return
    }

    if (!baroMS.serverData[data.UniqueId]) {
        baroMS.serverData[data.UniqueId] = {}
        baroMS.serverData[data.UniqueId].roundNumber = 0
    }

    baroMS.serverData[data.UniqueId].roundNumber++

    saveData()

    res.end()
})
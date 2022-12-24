baroMS.traitormodData = {}

const fs = require("fs")
const path = require("path")

function loadData() {
    if (fs.existsSync("./data/traitormod_data.json")) {
        const data = fs.readFileSync("./data/traitormod_data.json")
        baroMS.traitormodData = JSON.parse(data)
    }
}

function saveData() {
    fs.writeFileSync("./data/traitormod_data.json", JSON.stringify(baroMS.traitormodData))
}

loadData()

baroMS.app.post("/api/v1/traitormod", function (req, res) {
    const data = req.body

    if (baroMS.config.barotraumaServers[data.UniqueId] == null) {
        res.end()
        return
    }

    if (data.Points) {
        let accData = baroMS.traitormodData[data.Account]

        if (accData) {
            console.log("[" + data.UniqueId + "] " + data.Account + " Set points from " + data.Points + " to " + data.Points + "")
            accData.Points = data.Points
        }
        else {
            baroMS.traitormodData[data.Account] = { Points: data.Points }
        }

        saveData()

    } else {
        let accData = baroMS.traitormodData[data.Account]

        if (accData) {
            console.log("[" + data.UniqueId + "] " + data.Account + " Get points " + accData.Points)

            res.json({ "Points": accData.Points }).end()
        } else {
            res.json().end()
        }
    }

    res.end()
})
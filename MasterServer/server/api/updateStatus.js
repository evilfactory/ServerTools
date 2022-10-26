baroMS.app.post("/api/v1/update-status", function (req, res) {
    const data = req.body

    if (baroMS.config.barotraumaServers[data.UniqueId] == null) {
        res.end()
        return
    }

    baroMS.updateStatus(data.UniqueId, data.AmountPlayers, data.MaxPlayers, data.Submarine)
    baroMS.config.barotraumaServers[data.UniqueId].clients = data.Clients

    res.end()
})
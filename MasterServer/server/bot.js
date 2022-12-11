const { Client, GatewayIntentBits, ActivityType, Partials } = require("discord.js")

const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.DirectMessages,
    ],
    partials: [Partials.Channel]
})

client.once("ready", () => {
    console.log("Successfully started discord bot!")
})

client.on("messageCreate", message => {
    if (message.author.bot) return

    if (message.content == "!players") {
        Object.values(baroMS.config.barotraumaServers).forEach(value => {
            if (value.clients) {
                let response = "#:  SteamID            | Name    | Ping"
                let count = 1
                let space = "  "
                for (var i in value.clients) {
                    if (count > 9) space = " "
                    let client = value.clients[i]
                    response = `${response}\n${count}:${space}${client.AccountId} | ${client.Name} | ${client.Ping}ms`
                    count++
                }
                message.channel.send("```" + response + "```")
            }
        })
    }
})

Object.entries(baroMS.config.barotraumaServers).forEach(entry => {
    const [key, value] = entry

    if (value.botToken == baroMS.config.botToken) {
        value.client = client
    } else {
        value.client = new Client({
            intents: []
        })

        value.client.login(value.botToken)
    }

    value.client.once("ready", () => {
        console.log(`Discord bot from ${key} is ready.`)
        value.client.user.setPresence({
            activities: [{ name: `Pending status update...`, type: ActivityType.Playing }],
        })
    })
})

baroMS.updateStatus = function (server, amountPlayers, maxPlayers, submarine) {
    server = baroMS.config.barotraumaServers[server]

    server.AmountPlayers = amountPlayers
    server.MaxPlayers = maxPlayers
    server.Submarine = submarine

    let serverClient = server.client
    if (!serverClient) { return }
    if (!serverClient.user) { return }

    if (submarine == null) {
        serverClient.user.setPresence({
            activities: [{ name: `${amountPlayers}/${maxPlayers} in lobby`, type: ActivityType.Watching }],
        })
    } else {
        serverClient.user.setPresence({
            activities: [{ name: `${amountPlayers}/${maxPlayers} on ${submarine}`, type: ActivityType.Playing }],
        })
    }
}

if (baroMS.config.botToken) {
    client.login(baroMS.config.botToken)
}
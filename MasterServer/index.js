baroMS = {}

const config = require("./config.js")

baroMS.config = config

require("./server/listenServer.js")
require("./server/bot.js")
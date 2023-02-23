const path = require("path")
const express = require("express")
const session = require('express-session')
const app = express()
const fs = require("fs")

baroMS.app = app

app.set("views", "./public")
app.set("view engine", "ejs")
app.use(express.urlencoded({ extended: true }))
app.use(express.json());

function makeid(length) {
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

app.use(session({
    secret: makeid(64),
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false }
}))

app.use("/css", express.static('./public/css'))

app.get("/", function (req, res) {
    if (req.session.authenticated == true) {
        res.render("index.ejs")
    } else {
        res.redirect("/login")
    }
})

Object.entries(baroMS.config.barotraumaServers).forEach(entry => {
    const [key, value] = entry

    app.get(`/servers/${key}/home`, function (req, res) {
        if (req.session.authenticated == true) {
            res.render("server.ejs", { server: key })
        } else {
            res.redirect("/login")
        }
    })

    app.use(`/servers/${key}/logs`, express.static("./data/serverlogs/" + key + "/"))
    
    app.use(`/servers/${key}/logs`, function (req, res, next) {
        if (req.session.authenticated == true) {

            let fileNames = fs.readdirSync(`./data/serverlogs/${key}`)
            
            let files = []

            fileNames.forEach(fileName => {
                let stats = fs.statSync(`./data/serverlogs/${key}/${fileName}`)

                files.push({
                    Name: fileName, 
                    Start: stats.birthtime.toLocaleString("en-US", {timeZone: req.session.timezone}), 
                    End: stats.mtime.toLocaleString("en-US", {timeZone: req.session.timezone}),
                    StartTimeSort: stats.birthtime.getTime(),
                })
            })

            files.sort(function (a, b) {
                return a.StartTimeSort > b.StartTimeSort ? -1 : 1
            })

            res.render("serverlogs.ejs", { server: key, files: files })
        } else {
            res.redirect("/login")
        }
    })
})

app.get("/login", function (req, res) {
    res.render("login.ejs")
})

app.post("/login", function (req, res) {
    const pin = req.body.pin

    if (pin == baroMS.config.pin) {
        req.session.authenticated = true
        req.session.timezone = req.body.timezone
        res.redirect("/")
    } else {
        res.redirect("/login")
    }
})

require("./api/banlist.js")
require("./api/updateStatus.js")
require("./api/sendLogs.js")
require("./api/traitormod.js")

app.listen(baroMS.config.port, function () {
    console.log(`Server listening at port ${baroMS.config.port}`)
})
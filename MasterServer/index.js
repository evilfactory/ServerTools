website = {}

const config = require("./config.js")
const fs = require("fs")

const path = require("path")

const express = require("express")
const session = require('express-session')
const app = express()

website.app = app

app.set('views', path.join(__dirname, '/public'))
app.set("view engine", "ejs")
app.use(express.urlencoded({ extended: true }))

app.use(session({
    secret: 'IGJRIjgirJGIPrjripjHOPRjgipwjgpwrijgwripjGIPRJNIRWPJ',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false }
}))

app.use("/css", express.static('public/css'))

app.get("/", function (req, res) {
    if (req.session.authenticated == true) {
        res.render("index.ejs")
    } else {
        res.redirect("/login")
    }
})

app.get("/login", function (req, res) {
    res.render("login.ejs")
})

app.post("/login", function (req, res) {
    const pin = req.body.pin

    if (pin == config.pin) {
        req.session.authenticated = true
        res.redirect("/")
    } else {
        res.redirect("/login")
    }
})

app.listen(config.port, function () {
    console.log(`Server listening at port ${config.port}`)
})
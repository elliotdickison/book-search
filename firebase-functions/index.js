const functions = require("firebase-functions")
const admin = require("firebase-admin")
const express = require("express")
const api = require("amazon-product-api")
const cors = require("cors")

const config = functions.config()

admin.initializeApp(config.firebase)

const app = express()

const client = api.createClient({
  awsId: config.amazon.id,
  awsSecret: config.amazon.key,
  awsTag: config.amazon.tag,
})

app.use(cors())

app.get("/books", (req, res) =>
  client
    .itemSearch({
      keywords: req.query.q,
      searchIndex: "Books",
      responseGroup: "ItemAttributes, Images",
    })
    .then(data => res.json(data))
    .catch(err => res.status(520).json(err))
)

exports.app = functions.https.onRequest(app)

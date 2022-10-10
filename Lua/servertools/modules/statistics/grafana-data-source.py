from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import dateutil.parser
import time
import json

app = Flask(__name__)
cors = CORS(app)

data = []

if os.path.exists("data.json"):
    jsonFile = open("data.json")
    data = json.load(jsonFile)
    jsonFile.close()

addedDataCount = 0

def save_json_data():
    f = open("data.json", "w")
    f.write(json.dumps(data))
    f.close()


@app.route("/", methods=["GET", "POST"])
def main():
    return ""

@app.route("/search", methods=["GET", "POST"])
def r_search():

    return jsonify(["PlayerCount"])

@app.route("/add", methods=["POST"])
def r_add():
    global addedDataCount
    addedDataCount = addedDataCount + 1

    if addedDataCount % 10 == 0:
        save_json_data()
    
    req = request.json
    data.append([req["data"], time.time() * 1000])
    return jsonify({"status": "ok"})

@app.route("/query", methods=["GET", "POST"])
def r_querey():
    req = request.json

    from_ms = dateutil.parser.parse(req["range"]["from"]).timestamp()*1000
    to_ms = dateutil.parser.parse(req["range"]["to"]).timestamp()*1000

    dataToSend = []

    for d in data:
        if d[1] >= from_ms and d[1] <= to_ms:
            dataToSend.append([d[0], d[1]])

    response = [
        {
            "datapoints": dataToSend
        }
    ]

    return jsonify(response)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8758, debug=False)
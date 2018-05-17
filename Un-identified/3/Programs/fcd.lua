--Discord Webhook Trigger

--The JSON Library
local JSON = require("Libraries.JSON")

--Usage
if not (...) or (...) == "-?" then
  printUsage("discord <msg>","Sends a discord message using a webhook")
end

--The webhook url
local webhook = "https://discordapp.com/api/webhooks/357967074913419264/Jvy_9ttIVz6aIPXxa0eR8id5OI4dPtjAA2BOrfaDGBl97QKuQDCM9rmWCG4OpnVkne3z"

--The message content
local msg = table.concat({...}," ")

color(9) print("Sending...")

--The webhook trigger params
local Params = {}

Params.content = msg

--Send the request
local success, err = http.request(webhook, JSON:encode(Params))

--Explains itself.
if success then
  color(11) print("Sent successfully")
else
  color(7) print("Failed: "..tostring(err))
end
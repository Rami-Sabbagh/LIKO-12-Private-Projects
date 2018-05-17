local term = require("terminal")

term.reload()

local discord = require("Libraries.Discord")

color(6)

discord.oauth.requestAutorization()

print("Please authorize and copy the token, then press enter to continue.")

local code

for event,a in pullEvent do
  if event == "keypressed" then
    if a == "escape" then
      color(8) print("Aborted.")
      return
    elseif a == "return" then
      local c, err = discord.oauth.readAuthorizationCode(clipboard():gsub(" ",""))
      if c then
        code = c
        break
      else
        color(8) print("Invalid token, please make sure that you copied it correctly without any spaces.")
        color(6) print("Press enter to return again")
      end
    end
  end
end

print("Generating access token...")

discord.oauth.exchangeToken(code)

print("Requesting user information...")

local user = discord.user.getCurrentUser()

color(7)

for k,v in pairs(user) do
  print(tostring(k)..": "..tostring(v))
end

color(6)

print("Requesting user guilds list...")

local guilds = discord.user.getCurrentUserGuilds()

color(7)

for k,guild in pairs(guilds) do
  print(guild.name)
end

color(6)

print("Revoking access token...")

discord.oauth.revokeToken()
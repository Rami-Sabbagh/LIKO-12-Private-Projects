--LIKO-12 Discord Library Config

local conf = {}

--OAuth
conf.clientID = "411788153490505729" --Client: "411262083599171585"
conf.clientSecret = "C4NTb9TdpLeCqoYLPVylipeTdVlElnjO" --Client: "Rr_DuP2MAU_93ozQkKxf76yktBQXMrEu"
conf.oAuth_redirect_uri = "https://ramilego4game.github.io/LIKO-12-Discord/index.html"
conf.oAuth_scopes = {
  "identify", "guilds", "messages.read"
}

--Bot
conf.bot_token = "NDExNzg4MTUzNDkwNTA1NzI5.DWAzXg.2_O_xk2Rj6DM-zOQEKm3PlAldN8"

--Other
conf.agent = "DiscordBot (https://github.com/RamiLego4Game/LIKO-12, 1)"

return conf
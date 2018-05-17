local frame = require'Libraries.Websocket.frame'

return {
  client = require'Libraries.Websocket.client',
  CONTINUATION = frame.CONTINUATION,
  TEXT = frame.TEXT,
  BINARY = frame.BINARY,
  CLOSE = frame.CLOSE,
  PING = frame.PING,
  PONG = frame.PONG
}

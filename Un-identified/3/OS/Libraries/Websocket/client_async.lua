local socket = WEB.luasocket("socket")
local async = require'Libraries.Websocket.async'
local tools = require'Libraries.Websocket.tools'

local new = function(ws)
  ws =  ws or {}
  local self = {}
  
  self.sock_connect = function(self,host,port)
    self.sock = socket.tcp()
    if not ws.timeout then
      self.sock:settimeout(ws.timeout)
    end
    local _,err = self.sock:connect(host,port)
    if err then
      self.sock:close()
      return nil,err
    end
  end
  
  self.sock_send = function(self,...)
    return self.sock:send(...)
  end
  
  self.sock_receive = function(self,...)
    return self.sock:receive(...)
  end
  
  self.sock_close = function(self)
    --self.sock:shutdown() Causes errors?
    self.sock:close()
  end
  
  self = async.extend(self)
  return self
end

return new
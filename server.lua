local socket = require("socket")
local inspect = require("inspect")

function table.del(table, key)
  local element = table[key]
  table[key] = nil
  return element
end

Server = {}
function Server:new(host,port)
  setmetatable({},Server)
  self.host = host
  self.port = port
  self.connected = {} --{{ip,port,accumilator}}
  return self
end

function Server:setup(timeout)
  self.udp = socket.udp()
  if not self.udp then print("Failed to create socket") end
  if not self.udp:setsockname(self.host, self.port) then print("Failed to bind.") end
  if not self.udp:settimeout(timeout) then print("Setting timeout failed") end

  ip, port = self.udp:getsockname()
  if not ip or not port then print("Failed to get socketname") end
end

function Server:pinghandle()
  --[[
  server sends client a ping if client fails to respond 10 times
  assumes as disconnected.
  ]]--
  for k,client in ipairs(self.connected) do
    self.udp:sendto("ping", client.ip, client.port)
    msg, ip, port = self.udp:receivefrom()

    if msg ~= "pong" or not msg then
      client.acc = client.acc + 1
      if client.acc > 10 then
        print(string.format("%s:%d disconnected", client.ip, client.port))
        table.del(self.connected,k)
      end
    else
      client.acc = 0 -- reset if it gets pong back
    end

  end
end

function Server:broadcast(msg,rip,rport)
  print(string.format("Msg: %s From: %s:%d",msg,rip,rport))
  for k,client in ipairs(self.connected) do
    if client.ip ~= rip and client.port ~= rport then
      self.udp:sendto(msg, client.ip, client.port)
    end
  end
end

function Server:start()
  while 1 do
    msg, ip, port = self.udp:receivefrom()
    if msg then
      if msg == "join" then
        print(string.format("%s:%d connected", ip, port))
        table.insert(self.connected, {ip=ip,port=port,acc=0})
      else
        self:broadcast(msg,ip,port)
      end
    end
    self:pinghandle()
  end
end

local m_server = Server:new("127.0.0.1",8080)
m_server:setup(0)
m_server:start()

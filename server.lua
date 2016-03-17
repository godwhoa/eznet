local socket = require("socket")

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
  if self.connected.acc ~= nil then
    for k,client in ipairs(self.connected) do
      self.udp:sendto("ping", client.ip, client.port)
      msg, ip, port = self.udp:receivefrom()
      if msg ~= "pong" or not msg then
        self.connected.acc = self.connected.acc + 1
      end
      if self.connected.acc == 10 then
        print(string.format("%s:%d disconnected", client.ip, client.port))
        table.del(self.connected,k)
      end
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
    self:pinghandle()
    msg, ip, port = self.udp:receivefrom()
    if msg then
      if msg == "join" then
        print(string.format("%s:%d connected", ip, port))
        table.insert(self.connected, {ip=ip,port=port,acc=0})
      else
        self:broadcast(msg,ip,port)
      end
    end
  end
end

local m_server = Server:new("127.0.0.1",8080)
m_server:setup(0)
m_server:start()

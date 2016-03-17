local socket = require("socket")

Client = {}

function Client:new(host,port)
  setmetatable({},Client)
  self.host = socket.dns.toip(host)
  self.port = port
  self.udp = socket.udp()
  if not self.udp then 
  	print("Failed to create socket")
  	return false
  elseif not self.udp:setpeername(self.host, self.port) then
  	print("Failed to set peername")
  	return false
  else
  	self.udp:send("join")
  	print("Connected")
  	return self
  end
end

function Client:ponghandle()

end

local client = Client:new("localhost",8080)

while 1 do
  msg = client.udp:receive()
  if msg == "ping" then
    client.udp:send("pong")
  end
  line = io.read()
  if not line or line == "" then os.exit() end
  client.udp:send(line)
  
  print(msg)
end
PubSub = {}

function PubSub:new()
  setmetatable({},PubSub)
  self.hub = {} --hub{ch={cb,cb2}} channel and callbacks
  return self
end

function PubSub:pub(ch, msg)
  if ch ~= nil and self.hub[ch] ~= nil then
    for i,cb in ipairs(self.hub[ch]) do
      cb(msg)
    end
  else
    print("Either channel or subcribers are missing.")
  end
end

function PubSub:sub(ch, cb)
  if self.hub[ch] == nil then
    self.hub[ch] = {cb}
  else
    table.insert(self.hub[ch],cb)
  end
end


local hub = PubSub:new()
hub:sub("cat",function (msg)
    print(msg)
  end)

hub:sub("dog",function (msg)
    print(msg)
  end)
for i=1,3 do
	hub:pub("cat","cat: "..tostring(i))
	hub:pub("dog","dog: "..tostring(i))
	print()
end
z = false
if not z then 
	print("lala")
end
--[[
Output:
cat: 1
dog: 1

cat: 2
dog: 2

cat: 3
dog: 3

]]--
-- Monitor to Web - Kirim data ke endpoint gratis
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local ENDPOINT = "https://api.jsonbin.io/v3/b/[BIN_ID]?meta=false"  -- Nanti ganti
local SECRET_KEY = "$2b$10$[HASH]"  -- Nanti

local function getFishData()
    local data = {executor = Players.LocalPlayer.Name, timestamp = os.time(), players = {}}
    for _, p in Players:GetPlayers() do
        data.players[p.Name] = {
            Common = math.random(10,50), -- Ganti real inventory
            Uncommon = math.random(5,20),
            Rare = math.random(0,10),
            Epic = math.random(0,5),
            Legendary = math.random(0,2)
        }
    end
    return HttpService:JSONEncode(data)
end

spawn(function()
    while true do
        HttpService:RequestAsync({
            Url = ENDPOINT,
            Method = "PUT",
            Headers = {["Content-Type"] = "application/json", ["X-Master-Key"] = SECRET_KEY},
            Body = getFishData()
        })
        wait(15)
    end
end)
print("Data sent to web monitor!")

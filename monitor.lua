local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- PASTE URL webhook.site KAMU DISINI
local url = "https://webhook.site/56cec7a6-3a50-45b8-8438-275d94b9be2b"

spawn(function()
    while wait(15) do
        local data = {
            executor = Players.LocalPlayer.Name,
            players = {}
        }
        for _,p in Players:GetPlayers() do
            data.players[p.Name] = {
                Common=math.random(10,50),
                Uncommon=math.random(5,25),
                Rare=math.random(1,10),
                Epic=math.random(0,5),
                Legendary=math.random(0,2)
            }
        end
        HttpService:PostAsync(url, HttpService:JSONEncode(data))
    end
end)
print("Live to webhook.site!")

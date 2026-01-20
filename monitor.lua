-- Fish Monitor Script for Delta Executor
-- Buat repo GitHub, upload file ini sebagai monitor.lua
-- Execute: loadstring(game:HttpGet("https://raw.githubusercontent.com/YOURUSER/fish-monitor/main/monitor.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Path inventory (adaptasi ke game, cek via explorer di executor)
local inventoryPath = playerGui:WaitForChild("InventoryFrame") -- Ganti sesuai game, misal ScreenGui.Inventory
local fishDataPath = inventoryPath:WaitForChild("FishData") -- Asumsi Folder/Value berisi ikan

-- Definisikan rarity dan gambar dari screenshot (asset ID Roblox images, upload gambar ikan ke Roblox)
local rarities = {
    {name = "Common", color = Color3.fromRGB(255,0,0), imageId = "rbxassetid://1234567890"}, -- Merah, ganti ID
    {name = "Uncommon", color = Color3.fromRGB(0,255,0), imageId = "rbxassetid://1234567891"}, -- Hijau
    {name = "Rare", color = Color3.fromRGB(0,0,255), imageId = "rbxassetid://1234567892"}, -- Biru
    {name = "Epic", color = Color3.fromRGB(255,0,255), imageId = "rbxassetid://1234567893"}, -- Ungu
    {name = "Legendary", color = Color3.fromRGB(255,255,0), imageId = "rbxassetid://1234567894"} -- Kuning
}

-- Buat GUI monitor
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishMonitor"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Text = "Fish Monitor - Executor: " .. player.Name
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0,5,0,35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 8
scrollFrame.Parent = mainFrame

-- Fungsi hitung inventory per player
local function getFishInventory(targetPlayer)
    local inv = {}
    for _, rarity in ipairs(rarities) do
        inv[rarity.name] = 0
    end
    
    -- Adaptasi: loop data ikan dari targetPlayer.PlayerGui atau RemoteEvent
    -- Contoh asumsi: fireserver("GetInventory") -> tapi client-side simulasikan
    local success, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://api.roblox.com/...")) -- Ganti ke actual API jika ada, atau loop GUI
    end)
    
    if success then
        for fishName, count in pairs(data) do
            local rarity = "Common" -- Detect rarity dari nama/data
            inv[rarity] = inv[rarity] + count
        end
    end
    return inv
end

-- Update monitor untuk semua players
local function updateMonitor()
    for _, child in ipairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scrollFrame
    
    -- Executor info
    local execFrame = Instance.new("Frame")
    execFrame.Size = UDim2.new(1,0,0,50)
    execFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    execFrame.Parent = scrollFrame
    
    local execLabel = Instance.new("TextLabel")
    execLabel.Size = UDim2.new(1,0,1,0)
    execLabel.BackgroundTransparency = 1
    execLabel.Text = "Executor: " .. player.Name
    execLabel.TextColor3 = Color3.new(1,1,1)
    execLabel.TextScaled = true
    execLabel.Parent = execFrame
    
    -- Players terdaftar (semua di server)
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            local playerFrame = Instance.new("Frame")
            playerFrame.Size = UDim2.new(1,0,0,100)
            playerFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
            playerFrame.Parent = scrollFrame
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1,0,0,20)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = "Player: " .. targetPlayer.Name
            nameLabel.TextColor3 = Color3.new(1,1,1)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.Gotham
            nameLabel.Parent = playerFrame
            
            local fishLayout = Instance.new("UIListLayout")
            fishLayout.FillDirection = Enum.FillDirection.Horizontal
            fishLayout.Parent = playerFrame
            
            local inv = getFishInventory(targetPlayer)
            for _, rarity in ipairs(rarities) do
                local fishItem = Instance.new("Frame")
                fishItem.Size = UDim2.new(0.18,0,1,0)
                fishItem.BackgroundColor3 = rarity.color
                fishItem.Parent = playerFrame
                
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.new(0.6,0,0.6,0)
                img.Position = UDim2.new(0.2,0,0.1,0)
                img.Image = rarity.imageId
                img.BackgroundTransparency = 1
                img.Parent = fishItem
                
                local countLabel = Instance.new("TextLabel")
                countLabel.Size = UDim2.new(1,0,0.3,0)
                countLabel.Position = UDim2.new(0,0,0.7,0)
                countLabel.BackgroundTransparency = 1
                countLabel.Text = rarity.name .. ": " .. inv[rarity.name]
                countLabel.TextColor3 = Color3.new(1,1,1)
                countLabel.TextScaled = true
                countLabel.Parent = fishItem
            end
        end
    end
    
    scrollFrame.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y)
end

-- Update setiap 10 detik
spawn(function()
    while screenGui.Parent do
        updateMonitor()
        wait(10)
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,30,0,30)
closeBtn.Position = UDim2.new(1,-35,0,0)
closeBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Drag GUI
local dragging = false
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
game:GetService("RunService").RenderStepped:Connect(function()
    if dragging then
        mainFrame.Position = UDim2.new(0, game:GetService("UserInputService"):GetMouseLocation().X + mainFrame.Size.X.Offset/2 * -1, 0, game:GetService("UserInputService"):GetMouseLocation().Y + mainFrame.Size.Y.Offset/2 * -1)
    end
end)

print("Fish Monitor loaded! Check PlayerGui.FishMonitor")


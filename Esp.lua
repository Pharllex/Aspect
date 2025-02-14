local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Length = 50
local MaxDistance = 500
local TeamCheckEnabled = true

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false 

local playerBeacons = {}

local function createBeacon(targetPlayer)
    if targetPlayer == player then return end 

    if TeamCheckEnabled and targetPlayer.Team == player.Team then
        return
    end

    local beacon = Instance.new("Frame")
    beacon.Size = UDim2.new(0, 5, 0, Length)
    beacon.BackgroundColor3 = Color3.new(1, 0, 0) 
    beacon.BorderSizePixel = 0
    beacon.AnchorPoint = Vector2.new(0.5, 1)
    beacon.Visible = false
    beacon.Parent = screenGui

    playerBeacons[targetPlayer] = beacon
end

local function updateBeacons()
    local camera = workspace.CurrentCamera
    if not camera then return end

    for targetPlayer, beacon in pairs(playerBeacons) do
        local character = targetPlayer.Character
        if not character then
            beacon.Visible = false
            continue
        end

        local head = character:FindFirstChild("Head")
        if not head then
            beacon.Visible = false
            continue
        end

        if TeamCheckEnabled and targetPlayer.Team == player.Team then
            beacon.Visible = false
            continue
        end

        local distance = (player.Character and player.Character:FindFirstChild("Head") and player.Character.Head.Position - head.Position).Magnitude or math.huge
        
        if distance > MaxDistance then
            beacon.Visible = false
            continue
        end

        local screenPosition, onScreen = camera:WorldToScreenPoint(head.Position)

        if onScreen then
            local clampedY = math.clamp(screenPosition.Y - Length, 0, camera.ViewportSize.Y - Length)
           
            beacon.Position = UDim2.new(0, screenPosition.X, 0, clampedY)
            beacon.Visible = true
        else
            beacon.Visible = false
        end
    end
end

local function onPlayerAdded(targetPlayer)
    createBeacon(targetPlayer)
end

local function onPlayerRemoved(targetPlayer)
    local beacon = playerBeacons[targetPlayer]
    if beacon then
        beacon:Destroy()
        playerBeacons[targetPlayer] = nil
    end
end

for _, targetPlayer in ipairs(game.Players:GetPlayers()) do
    onPlayerAdded(targetPlayer)
end

game.Players.PlayerAdded:Connect(onPlayerAdded)
game.Players.PlayerRemoving:Connect(onPlayerRemoved)

game:GetService("RunService").RenderStepped:Connect(updateBeacons)

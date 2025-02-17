local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- 🔹 Replace with your script's raw URL
local ScriptURL = ""

local function Notify(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 5
    })
end

LocalPlayer.Idled:Connect(function()
    Notify("AFK Detected", "Preventing kick...", 3)
    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

local function ServerHop()
    Notify("Low Players", "Server hopping...", 5)

    local servers
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and result and result.data then
        servers = result.data
    else
        Notify("Error", "Failed to fetch servers", 3)
        return
    end

    for _, server in ipairs(servers) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:QueueOnTeleport(function()
                loadstring(game:HttpGet(ScriptURL, true))()
            end)
            TeleportService:TeleportToPlaceInstance(PlaceId, server.id, LocalPlayer)
            return
        end
    end
    Notify("Server Hop Failed", "No better server found!", 3)
end

local cooldown = 30 -- Seconds between hop attempts
local lastHop = 0
task.spawn(function()
    while true do
        task.wait(10)
        if os.time() - lastHop >= cooldown and #Players:GetPlayers() < 5 then
            lastHop = os.time()
            ServerHop()
        end
    end
end)

Notify("Script Loaded", "Anti-AFK & Auto Server Hop activated!", 5)

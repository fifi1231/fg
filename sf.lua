--  services

local Players   = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService    = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--  variables

local InGame    = false
local Player    = Players.LocalPlayer
local Things    = Workspace:WaitForChild("__THINGS")
local Active    = Things:WaitForChild("__INSTANCE_CONTAINER"):WaitForChild("Active")
local Debris    = Workspace:WaitForChild("__DEBRIS")
local Network   = ReplicatedStorage:WaitForChild("Network")
local OldHooks  = {}
local FishingGame    = Player:WaitForChild("PlayerGui"):WaitForChild("_INSTANCES").FishingGame.GameBar
local CurrentFishingModule = require(Things.__INSTANCE_CONTAINER.Active:WaitForChild("AdvancedFishing").ClientModule.FishingGame)

--  functions

for i,v in CurrentFishingModule do
    OldHooks[i] = v
end

CurrentFishingModule.IsFishInBar    = function()
    return math.random(1, 6) ~= 1
end

CurrentFishingModule.StartGame  = function(...) 
    InGame  = true

    return OldHooks.StartGame(...) 
end

CurrentFishingModule.StopGame   = function(...)
    InGame  = false

    return OldHooks.StopGame(...)
end

local function waitForGameState(state: boolean)
    repeat RunService.RenderStepped:Wait() until InGame == state
end

local function getRod()
    return Player.Character and Player.Character:FindFirstChild("Rod", true)
end

local function getBubbles(anchor: BasePart)
    local myBobber  = nil
    local myBubbles = false
    local closestBobber = math.huge

    for _,v in Active.Fishing.Bobbers:GetChildren() do
        local distance  = (v.Bobber.CFrame.Position-anchor.CFrame.Position).Magnitude

       if distance <= closestBobber then
            myBobber    = v.Bobber
            closestBobber   = distance
        end
    end
end
    if myBobber then
        for _,v in Debris:GetChildren() do
            if v.Name == "host" and v:FindFirstChild("Attachment") and (v.Attachment:FindFirstChild("Bubbles")) or (v.Attachment:FindFirstChild("Rare Bubbles")) and (v.CFrame.Position-myBobber.CFrame.Position.Magnitude) <= 1 then
                myBubbles   = true
                break
            end
        end
    end
end
    return myBubbles
end

while task.wait(1) do
    pcall(function()
        if Things.__INSTANCE_CONTAINER.Active:FindFirstChild("Fishing") and not InGame then
            Network.Instancing_FireCustomFromClient:FireServer("Fishing", "RequestCast", Vector3.new(1158+math.random(-10, 10), 75, -3454+math.random(-10, 10)))

            local myAnchor  = getRod():WaitForChild("FishingLine").Attachment0
            repeat RunService.RenderStepped:Wait() until not Active:FindFirstChild("Fishing") or myAnchor and getBubbles(myAnchor) or InGame
            
            if Active:FindFirstChild("Fishing") then
                Network.Instancing_FireCustomFromClient:FireServer("Fishing", "RequestReel")
                waitForGameState(true)
                waitForGameState(false)
            end

            repeat RunService.RenderStepped:Wait() until not Active:FindFirstChild("Fishing") or getRod() and getRod().Parent.Bobber.Transparency <= 0
        end
    end)
end

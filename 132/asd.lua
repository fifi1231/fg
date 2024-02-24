
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   wait(1)
   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)


game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-180.852783203125, 117.92350006103516, 5175.45703125)

wait(5)
local Part = Instance.new("Part")
Part.Anchored = true
Part.BottomSurface = Enum.SurfaceType.Smooth
Part.TopSurface = Enum.SurfaceType.Smooth
Part.Size = Vector3.new(5, 1, 5)
Part.CFrame = CFrame.new(1127, 64, -4049)
Part.Parent = workspace


game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1127, 70, -4049)

game:GetService("RunService"):Set3dRenderingEnabled(false)

setfpscap(10)

_G.WebhookURL = "https://discord.com/api/webhooks/1202348766540341258/5WBqJvTm2leLsXfHszvyjaOUgd3frPIWIrM-NnSag5RW8CldAx-mIIcFBF3mWFjlGSO3"
_G.DiscUserID = "531416084956315649"

wait(60)
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/6672724acd01b8aff52f4dd6c276a425.lua"))()

while task.wait() do  
        local argsCast = {
        [1] = "AdvancedFishing",
        [2] = "RequestCast",
        [3] = Vector3.new(1127, 61.6249885559082, -4049)
        }
    
        game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(argsCast))
        task.wait(3.5)
    
        local argsReel = {
        [1] = "AdvancedFishing",
        [2] = "RequestReel"
        }
    
        game:GetService("ReplicatedStorage").Network.Instancing_FireCustomFromClient:FireServer(unpack(argsReel))
        repeat
        task.wait()
    
        local hasFishingLine = false
        for _, descendant in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                if descendant.Name == "FishingLine" then
                hasFishingLine = true
                break
                end
        end
    
        if not hasFishingLine then
                break
        end
    
        local argsClicked = {
                [1] = "AdvancedFishing",
                [2] = "Clicked"
        }
    
        game:GetService("ReplicatedStorage").Network.Instancing_InvokeCustomFromClient:InvokeServer(
                unpack(argsClicked)
        )
        until not hasFishingLine
        task.wait()
end


while wait(0) and getgenv().present do
loadstring(game:HttpGet("https://raw.githubusercontent.com/fifi1231/fg/main/132/test.lua"))()
end


while wait(0) and getgenv().secu do
    plrs = game:GetService("Players")
plrs.PlayerAdded:Connect(function(player)
    if player:IsInGroup(5060810) then
        hop()
    end
end)

local function hop()
    local TeleportService = game:GetService("TeleportService")
    TeleportService:Teleport(8737899170)
end  
end

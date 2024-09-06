    local LocalPlayer = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
    LocalPlayer.Anchored = true
    LocalPlayer.CFrame = LocalPlayer.CFrame + Vector3.new(Random.new():NextInteger(-1000, 1000), -30, Random.new():NextInteger(-1000, 1000))

    local platform = Instance.new("Part")
    platform.Parent = game:GetService("Workspace")
    platform.Anchored = true
    platform.CFrame = LocalPlayer.CFrame + Vector3.new(0, -5, 0)
    platform.Size = Vector3.new(5, 1, 5)
    platform.Transparency = 1

    LocalPlayer.Anchored = false

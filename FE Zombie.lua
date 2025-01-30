-- Animation and Sound Setup
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://179629775"
local idleTrack = animator:LoadAnimation(idleAnim)

local attackAnim = Instance.new("Animation")
attackAnim.AnimationId = "rbxassetid://188854557"
local attackTrack = animator:LoadAnimation(attackAnim)

idleTrack:Play()

local biteSound = Instance.new("Sound", character:WaitForChild("Torso"))
biteSound.SoundId = "rbxassetid://3043029786"
biteSound.Pitch = 0.95
biteSound.Volume = 1

-- Tool Setup
local backpack = player:WaitForChild("Backpack")
local tool = Instance.new("Tool", backpack)
tool.Name = "Bite"
tool.RequiresHandle = false

local canAttack = true

tool.Activated:Connect(function()
    if canAttack then
        idleTrack:Stop()
        attackTrack:Play(0, 5, 1.5)
        biteSound:Play()
        canAttack = false

        -- Cooldown and Timer Updates
        tool.Name = "2 Secs.."
        wait(0.5)
        idleTrack:Play()
        attackTrack:Stop()
        tool.Name = "1.5 Secs.."
        wait(0.5)
        tool.Name = "1 Secs.."
        wait(0.5)
        tool.Name = "0.5 Secs.."
        wait(0.5)

        canAttack = true
        tool.Name = "Bite"
    end
end)

-- Arm Mesh Setup
local function createArmMesh(name, color)
    local arm = Instance.new("Part", workspace)
    arm.Anchored = true
    arm.CanCollide = false
    arm.Size = Vector3.new(1, 2, 1)

    local mesh = Instance.new("SpecialMesh", arm)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "http://www.roblox.com/asset/?id=3036366188" -- Replace with actual MeshId
    mesh.Scale = Vector3.new(1, 1, 1)

    arm.Name = name
    arm.Color = color
    return arm
end

local leftArmVisual = createArmMesh("LeftArmVisual", Color3.new(1, 1, 1))
local rightArmVisual = createArmMesh("RightArmVisual", Color3.new(1, 1, 1))

-- First-Person Arm Update
local camera = workspace.CurrentCamera

local function updateArms()
    local leftArm = character:FindFirstChild("Left Arm")
    local rightArm = character:FindFirstChild("Right Arm")
    if not leftArm or not rightArm then return end

    local isFirstPerson = (camera.Focus.Position - camera.CFrame.Position).Magnitude < 1

    if isFirstPerson then
        leftArmVisual.Transparency = 0
        leftArmVisual.Color = leftArm.Color
        leftArmVisual.Position = leftArm.Position
        leftArmVisual.Rotation = leftArm.Rotation
        leftArm.Transparency = 1

        rightArmVisual.Transparency = 0
        rightArmVisual.Color = rightArm.Color
        rightArmVisual.Position = rightArm.Position
        rightArmVisual.Rotation = rightArm.Rotation
        rightArm.Transparency = 1
    else
        leftArmVisual.Transparency = 1
        rightArmVisual.Transparency = 1
        leftArm.Transparency = 0
        rightArm.Transparency = 0
    end
end

game:GetService("RunService").RenderStepped:Connect(updateArms)

-- Speed Manipulation
local runService = game:GetService("RunService")
local heartbeat = runService.Heartbeat

local function getPart(parent, name, className)
    for _, v in pairs(parent:GetChildren()) do
        if v.Name == name and v:IsA(className) then
            return v
        end
    end
    return nil
end

while task.wait() do
    heartbeat:Wait()

    local humanoidRootPart = getPart(character, "HumanoidRootPart", "BasePart")
    if humanoidRootPart then
        local velocity = humanoidRootPart.Velocity
        humanoidRootPart.Velocity = velocity.Unit * Vector3.new(20000, 0, 20000) + Vector3.new(0, 5000, 0)
        runService.RenderStepped:Wait()
        humanoidRootPart.Velocity = velocity
    end
end
game.Players.LocalPlayer.Character.Animate:Destroy()

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local idleAnimationId = "rbxassetid://183696478"
local walkAnimationId = "rbxassetid://179629775"

humanoid.WalkSpeed = 30

local idleAnimation = Instance.new("Animation")
idleAnimation.AnimationId = idleAnimationId
local idleTrack = humanoid:LoadAnimation(idleAnimation)

local walkAnimation = Instance.new("Animation")
walkAnimation.AnimationId = walkAnimationId
local walkTrack = humanoid:LoadAnimation(walkAnimation)

idleTrack:Play()

local isChoppyWalking = false
humanoid.Running:Connect(function(speed)
    if speed > 0 then
        if not walkTrack.IsPlaying and not isChoppyWalking then
            idleTrack:Stop()
            walkTrack:Play()
            isChoppyWalking = true

            task.spawn(function()
                while humanoid.MoveDirection.Magnitude > 0 do
                    rootPart.Anchored = true
                    task.wait(0.05)
                    rootPart.Anchored = false
                    task.wait(0.05)
                end
                rootPart.Anchored = false
                walkTrack:Stop()
                idleTrack:Play()
                isChoppyWalking = false
            end)
        end
    else
        if not idleTrack.IsPlaying then
            walkTrack:Stop()
            idleTrack:Play()
        end
    end
end)

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local rs = game:GetService("RunService")
local stepped = rs.Stepped
local renderstepped = rs.RenderStepped
local heartbeat = rs.Heartbeat
local v3 = Vector3.new

local function gp(parent, name, className)
	local ret = nil
	pcall(function()
		for i, v in pairs(parent:GetChildren()) do
			if (v.Name == name) and v:IsA(className) then
				ret = v
				break
			end
		end
	end)
	return ret
end

while true do
	task.wait()
	heartbeat:Wait()
	c = lp.Character
	hrp = gp(c, "HumanoidRootPart", "BasePart")
	vel = hrp.Velocity
	hrp.Velocity = hrp.Velocity.Unit * v3(20000, 0, 20000) + v3(0, 5000, 0)
	renderstepped:Wait()
	hrp.Velocity = vel
end
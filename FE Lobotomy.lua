while task.wait(math.random(1,5)) do
	local CC = Instance.new("ColorCorrectionEffect", game.Lighting)
	CC.Saturation = math.random(-2, 1)
	CC.Contrast = math.random(0, 5)
	local chime = Instance.new("Sound", game.Players.LocalPlayer.Character.Torso)
	chime.SoundId = "rbxassetid://1085317309"
	chime.Volume = 1
	chime:Play()
	game.Players.LocalPlayer.Character.Humanoid.Sit = true
	game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
	game.Players.LocalPlayer.Character.Humanoid.JumpPower = 0
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = math.random(0,10)
	workspace.Camera.FieldOfView = math.random(30,300)
	wait(5)
	game.Players.LocalPlayer.Character.Humanoid.HipHeight = 0
	game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
	workspace.Camera.FieldOfView = 70
	game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
	chime:Destroy()
	CC:Destroy()
end
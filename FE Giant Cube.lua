game:GetService('TextChatService').TextChannels.RBXGeneral:SendAsync("-gh 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741, 123122136464741")

local accs = game.Players.LocalPlayer.Character:GetChildren()

for _, acc in ipairs(accs) do
    if acc.Name == "Accessory (Crystal Fedora :D)" then
        acc.Handle.Mesh:Destroy()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(math.random(-1024,1024), 1024, math.random(-1024,1024))
		wait()
        acc.Handle.AccessoryWeld:Destroy()
        acc.Parent = workspace
        task.wait(0.05)
    end
end
local lp = game:FindService("Players").LocalPlayer

local function gplr(String)
	local Found = {}
	local strl = String:lower()
	if strl == "all" then
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			table.insert(Found,v)
		end
	elseif strl == "others" then
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			if v.Name ~= lp.Name then
				table.insert(Found,v)
			end
		end 
	elseif strl == "me" then
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			if v.Name == lp.Name then
				table.insert(Found,v)
			end
		end 
	else
		for i,v in pairs(game:FindService("Players"):GetPlayers()) do
			if v.Name:lower():sub(1, #String) == String:lower() then
				table.insert(Found,v)
			end
		end 
	end
	return Found 
end

-- Instances

local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local gradient = Instance.new("ImageLabel")
local UICorner_2 = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local ImageLabel = Instance.new("ImageLabel")
local CloseButton = Instance.new("TextButton")
local TextBox = Instance.new("TextBox")
local UICorner_3 = Instance.new("UICorner")
local TextButton = Instance.new("TextButton")
local UICorner_4 = Instance.new("UICorner")

-- Properties

ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.new(0.117647, 0.117647, 0.117647)
Frame.BorderColor3 = Color3.new(0, 0, 0)
Frame.BorderSizePixel = 0
Frame.Position = UDim2.new(0.42924872, 0, 0.416113555, 0)
Frame.Size = UDim2.new(0, 194, 0, 150)

UICorner.Parent = Frame
UICorner.CornerRadius = UDim.new(0, 10)

gradient.Name = "gradient"
gradient.Parent = Frame
gradient.BackgroundColor3 = Color3.new(1, 1, 1)
gradient.BackgroundTransparency = 1
gradient.BorderColor3 = Color3.new(0, 0, 0)
gradient.BorderSizePixel = 0
gradient.Position = UDim2.new(0, 0, 6.10351549e-07, 0)
gradient.Size = UDim2.new(0, 194, 0, 150)
gradient.Image = "http://www.roblox.com/asset/?id=11385696724"
gradient.ImageColor3 = Color3.new(0.0392157, 0.0392157, 0.0392157)

UICorner_2.Parent = gradient
UICorner_2.CornerRadius = UDim.new(0, 10)

TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
TextLabel.BackgroundTransparency = 1
TextLabel.BorderColor3 = Color3.new(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.198845297, 0, 0.106999919, 0)
TextLabel.Size = UDim2.new(0, 76, 0, 24)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.Text = "FE Fling GUI"
TextLabel.TextColor3 = Color3.new(1, 0.8, 0)
TextLabel.TextSize = 14

ImageLabel.Parent = Frame
ImageLabel.BackgroundColor3 = Color3.new(1, 1, 1)
ImageLabel.BackgroundTransparency = 1
ImageLabel.BorderColor3 = Color3.new(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0.0299999993, 0, 0.0666666701, 0)
ImageLabel.Size = UDim2.new(0, 25, 0, 25)
ImageLabel.Image = "http://www.roblox.com/asset/?id=9809572211"

CloseButton.Name = "CloseButton"
CloseButton.Parent = Frame
CloseButton.BackgroundColor3 = Color3.new(1, 1, 1)
CloseButton.BackgroundTransparency = 1
CloseButton.BorderColor3 = Color3.new(0, 0, 0)
CloseButton.BorderSizePixel = 0
CloseButton.Position = UDim2.new(0.835089624, 0, 0.106666669, 0)
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 0, 0.0156863)
CloseButton.TextScaled = true
CloseButton.TextSize = 14
CloseButton.TextStrokeTransparency = 0
CloseButton.TextWrapped = true

TextBox.Parent = Frame
TextBox.BackgroundColor3 = Color3.new(0, 0, 0)
TextBox.BackgroundTransparency = 0.5
TextBox.BorderColor3 = Color3.new(0, 0, 0)
TextBox.BorderSizePixel = 0
TextBox.Position = UDim2.new(0.0979390889, 0, 0.333333343, 0)
TextBox.Size = UDim2.new(0, 155, 0, 50)
TextBox.Font = Enum.Font.GothamMedium
TextBox.PlaceholderColor3 = Color3.new(1, 1, 1)
TextBox.PlaceholderText = "Target Name"
TextBox.Text = ""
TextBox.TextColor3 = Color3.new(1, 1, 1)
TextBox.TextSize = 15
TextBox.TextWrapped = true

UICorner_3.Parent = TextBox

TextButton.Parent = Frame
TextButton.BackgroundColor3 = Color3.new(0, 0, 0)
TextButton.BackgroundTransparency = 0.25
TextButton.BorderColor3 = Color3.new(0, 0, 0)
TextButton.BorderSizePixel = 0
TextButton.Position = UDim2.new(0.0979999974, 0, 0.720000029, 0)
TextButton.Size = UDim2.new(0, 154, 0, 31)
TextButton.Font = Enum.Font.FredokaOne
TextButton.Text = "Cheese That Dude!"
TextButton.TextColor3 = Color3.new(1, 0.8, 0)
TextButton.TextSize = 15
TextButton.TextWrapped = true

UICorner_4.Parent = TextButton

-- Scripts

local function CLAJN_fake_script() -- Frame.UIDrag 
	local script = Instance.new('LocalScript', Frame)

	-- Simple UI dragger (PC Only/Any device that has a mouse) --
	
	local UIS = game:GetService('UserInputService')
	local frame = script.Parent
	local dragToggle = nil
	local dragSpeed = 0.25
	local dragStart = nil
	local startPos = nil
	
	local function updateInput(input)
		local delta = input.Position - dragStart
		local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		game:GetService('TweenService'):Create(frame, TweenInfo.new(dragSpeed), {Position = position}):Play()
	end
	
	frame.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then 
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if dragToggle then
				updateInput(input)
			end
		end
	end)
end
coroutine.wrap(CLAJN_fake_script)()
local function SJUSWJN_fake_script() -- CloseButton.LocalScript 
	local script = Instance.new('LocalScript', CloseButton)

	script.Parent.MouseButton1Click:Connect(function()
		script.Parent.Parent.Parent:Destroy()
	end)
end
coroutine.wrap(SJUSWJN_fake_script)()

TextButton.MouseButton1Click:Connect(function()
	local Target = gplr(TextBox.Text)
	if Target[1] then
		Target = Target[1]

		local Thrust = Instance.new('BodyThrust', lp.Character.HumanoidRootPart)
		Thrust.Force = Vector3.new(9999,9999,9999)
		Thrust.Name = "YeetForce"
		repeat
			lp.Character.HumanoidRootPart.CFrame = Target.Character.HumanoidRootPart.CFrame
			Thrust.Location = Target.Character.HumanoidRootPart.Position
			game:FindService("RunService").Heartbeat:wait()
		until not Target.Character:FindFirstChild("Head")
	else
		print("Invalid player my boy ??")		
	end
end)
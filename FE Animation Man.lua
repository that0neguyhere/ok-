--reanimate by MyWorld#4430 discord.gg/pYVHtSJmEY
--the code that looks trash and works great
local healthHide = false --moves your head away every 3 seconds so players dont see your health bar (alignmode 4 only)
local reclaim = true --if you lost control over a part this will move your primary part to the part so you get it back (alignmode 4)
local novoid = true --prevents parts from going under workspace.FallenPartsDestroyHeight if you control them (alignmode 4 only)
local physp = nil --PhysicalProperties.new(0.01, 0, 1, 0, 0) --sets .CustomPhysicalProperties to this for each part
local noclipAllParts = false --set it to true if you want noclip
local antiragdoll = true --removes hingeConstraints and ballSocketConstraints from your character
local newanimate = true --disables the animate script and enables after reanimation
local discharscripts = true --disables all localScripts parented to your character before reanimation
local R15toR6 = true --tries to convert your character to r6 if its r15
local hatcollide = true --makes hats cancollide (credit to ShownApe) (works only with reanimate method 0)
local humState16 = true --enables collisions for limbs before the humanoid dies (using hum:ChangeState)
local addtools = false --puts all tools from backpack to character and lets you hold them after reanimation
local hedafterneck = true --disable aligns for head and enable after neck or torso is removed
local simrad = 1000 --simulation radius with sethiddenproperty (nil to disable)
local loadtime = game:GetService("Players").RespawnTime + 0.5 --anti respawn delay
local method = 3 --reanimation method
--methods:
--0 - breakJoints (takes [loadtime] seconds to load)
--1 - limbs
--2 - limbs + anti respawn
--3 - limbs + breakJoints after [loadtime] seconds
--4 - remove humanoid + breakJoints
--5 - remove humanoid + limbs
local alignmode = 1 --AlignPosition mode
--modes:
--1 - AlignPosition rigidity enabled true
--2 - 2 AlignPositions rigidity enabled both true and false
--3 - AlignPosition rigidity enabled false
--4 - no AlignPosition, CFrame only
local flingpart = "HumanoidRootPart" --name of the part or the hat used for flinging
--the fling function
--usage: fling(target, duration, velocity)
--target can be set to: basePart, CFrame, Vector3, character model or humanoid (flings at mouse.Hit if argument not provided)
--duration (fling time in seconds) can be set to a number or a string convertable to a number (0.5s if not provided)
--velocity (fling part rotation velocity) can be set to a vector3 value (Vector3.new(20000, 20000, 20000) if not provided)

local lp = game:GetService("Players").LocalPlayer
local rs, ws, sg = game:GetService("RunService"), game:GetService("Workspace"), game:GetService("StarterGui")
local stepped, heartbeat, renderstepped = rs.Stepped, rs.Heartbeat, rs.RenderStepped
local twait, tdelay, rad, inf, abs, mclamp = task.wait, task.delay, math.rad, math.huge, math.abs, math.clamp
local cf, v3, angles = CFrame.new, Vector3.new, CFrame.Angles
local v3_0, cf_0 = v3(0, 0, 0), cf(0, 0, 0)

local c = lp.Character
if not (c and c.Parent) then
    return
end

c:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (c and c.Parent) then
        c = nil
    end
end)

local destroy = c.Destroy

local function gp(parent, name, className)
    if typeof(parent) == "Instance" then
        for i, v in pairs(parent:GetChildren()) do
            if (v.Name == name) and v:IsA(className) then
                return v
            end
        end
    end
    return nil
end

local v3_xz, v3_net = v3(8, 0, 8), v3(0.1, 25.1, 0.1)
local function getNetlessVelocity(realPartVelocity) --edit this if you have a better netless method
    if realPartVelocity.Magnitude < 0.1 then return v3_net end
    return realPartVelocity * v3_xz + v3_net
end

if type(simrad) == "number" then
    local shp = getfenv().sethiddenproperty
    if shp then
        local con = nil
        con = heartbeat:Connect(function()
            if not c then return con:Disconnect() end
            shp(lp, "SimulationRadius", simrad)
        end)
    end
end

healthHide = healthHide and ((method == 0) or (method == 2) or (method == 3)) and gp(c, "Head", "BasePart")

local reclaim, lostpart = reclaim and c.PrimaryPart, nil

local v3_hide = v3(0, 3000, 0)
local function align(Part0, Part1)
    
    local att0 = Instance.new("Attachment")
    att0.Position, att0.Orientation, att0.Name = v3_0, v3_0, "att0_" .. Part0.Name
    local att1 = Instance.new("Attachment")
    att1.Position, att1.Orientation, att1.Name = v3_0, v3_0, "att1_" .. Part1.Name

    if alignmode == 4 then
    
        local hide = false
        if Part0 == healthHide then
            healthHide = false
            tdelay(0, function()
                while twait(2.9) and Part0 and c do
                    hide = #Part0:GetConnectedParts() == 1
                    twait(0.1)
                    hide = false
                end
            end)
        end
        
        local rot = rad(0.05)
        local con0, con1 = nil, nil
        con0 = stepped:Connect(function()
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            Part0.RotVelocity = Part1.RotVelocity
        end)
        local lastpos, vel = Part0.Position, Part0.Velocity
        con1 = heartbeat:Connect(function(delta)
            if not (Part0 and Part1 and att1) then return con0:Disconnect() and con1:Disconnect() end
            if (not Part0.Anchored) and (Part0.ReceiveAge == 0) then
                if lostpart == Part0 then
                    lostpart = nil
                end
                local newcf = Part1.CFrame * att1.CFrame
                local vel = (newcf.Position - lastpos) / delta
                Part0.Velocity = getNetlessVelocity(vel)
                if vel.Magnitude < 1 then
                    rot = -rot
                    newcf *= angles(0, 0, rot)
                end
                lastpos = newcf.Position
                if lostpart and (Part0 == reclaim) then
                    newcf = lostpart.CFrame
                elseif hide then
                    newcf += v3_hide
                end
                if novoid and (newcf.Y < ws.FallenPartsDestroyHeight + 0.1) then
                    newcf += v3(0, ws.FallenPartsDestroyHeight + 0.1 - newcf.Y, 0)
                end
                Part0.CFrame = newcf
            elseif (not Part0.Anchored) and (abs(Part0.Velocity.X) < 45) and (abs(Part0.Velocity.Y) < 25) and (abs(Part0.Velocity.Z) < 45) then
                lostpart = Part0
            end
        end)
    
    else
        
        Part0.CustomPhysicalProperties = physp
        if (alignmode == 1) or (alignmode == 2) then
            local ape = Instance.new("AlignPosition")
            ape.MaxForce, ape.MaxVelocity, ape.Responsiveness = inf, inf, inf
            ape.ReactionForceEnabled, ape.RigidityEnabled, ape.ApplyAtCenterOfMass = false, true, false
            ape.Attachment0, ape.Attachment1, ape.Name = att0, att1, "AlignPositionRtrue"
            ape.Parent = att0
        end
        
        if (alignmode == 2) or (alignmode == 3) then
            local apd = Instance.new("AlignPosition")
            apd.MaxForce, apd.MaxVelocity, apd.Responsiveness = inf, inf, inf
            apd.ReactionForceEnabled, apd.RigidityEnabled, apd.ApplyAtCenterOfMass = false, false, false
            apd.Attachment0, apd.Attachment1, apd.Name = att0, att1, "AlignPositionRfalse"
            apd.Parent = att0
        end
        
        local ao = Instance.new("AlignOrientation")
        ao.MaxAngularVelocity, ao.MaxTorque, ao.Responsiveness = inf, inf, inf
        ao.PrimaryAxisOnly, ao.ReactionTorqueEnabled, ao.RigidityEnabled = false, false, false
        ao.Attachment0, ao.Attachment1 = att0, att1
        ao.Parent = att0
        
        local con0, con1 = nil, nil
        local vel = Part0.Velocity
        con0 = renderstepped:Connect(function()
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
--            Part0.Velocity = framevel
        end)
        local lastpos = Part0.Position
        con1 = heartbeat:Connect(function(delta)
            if not (Part0 and Part1) then return con0:Disconnect() and con1:Disconnect() end
            vel = Part0.Velocity
            Part0.Velocity = getNetlessVelocity((Part1.Position - lastpos) / delta)
            lastpos = Part1.Position
        end)
    
    end

    att0:GetPropertyChangedSignal("Parent"):Connect(function()
        Part0 = att0.Parent
        if not Part0:IsA("BasePart") then
            att0 = nil
            if lostpart == Part0 then
                lostpart = nil
            end
            Part0 = nil
        end
    end)
    att0.Parent = Part0
    
    att1:GetPropertyChangedSignal("Parent"):Connect(function()
        Part1 = att1.Parent
        if not Part1:IsA("BasePart") then
            att1 = nil
            Part1 = nil
        end
    end)
    att1.Parent = Part1
end

local function respawnrequest()
    local ccfr, c = ws.CurrentCamera.CFrame, lp.Character
    lp.Character = nil
    lp.Character = c
    local con = nil
    con = ws.CurrentCamera.Changed:Connect(function(prop)
        if (prop ~= "Parent") and (prop ~= "CFrame") then
            return
        end
        ws.CurrentCamera.CFrame = ccfr
        con:Disconnect()
    end)
end

local destroyhum = (method == 4) or (method == 5)
local breakjoints = (method == 0) or (method == 4)
local antirespawn = (method == 0) or (method == 2) or (method == 3)

hatcollide = hatcollide and (method == 0)

addtools = addtools and lp:FindFirstChildOfClass("Backpack")

if antiragdoll then
    antiragdoll = function(v)
        if v:IsA("HingeConstraint") or v:IsA("BallSocketConstraint") then
            v.Parent = nil
        end
    end
    for i, v in pairs(c:GetDescendants()) do
        antiragdoll(v)
    end
    c.DescendantAdded:Connect(antiragdoll)
end

if antirespawn then
    respawnrequest()
end

if method == 0 then
    twait(loadtime)
    if not c then
        return
    end
end

if discharscripts then
    for i, v in pairs(c:GetDescendants()) do
        if v:IsA("LocalScript") then
            v.Disabled = true
        end
    end
elseif newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate and (not animate.Disabled) then
        animate.Disabled = true
    else
        newanimate = false
    end
end

if addtools then
    for i, v in pairs(addtools:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = c
        end
    end
end

pcall(function()
    settings().Physics.AllowSleep = false
    settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
end)

local OLDscripts = {}

for i, v in pairs(c:GetDescendants()) do
    if v.ClassName == "Script" then
        OLDscripts[v.Name] = true
    end
end

local scriptNames = {}

for i, v in pairs(c:GetDescendants()) do
    if v:IsA("BasePart") then
        local newName, exists = tostring(i), true
        while exists do
            exists = OLDscripts[newName]
            if exists then
                newName = newName .. "_"    
            end
        end
        table.insert(scriptNames, newName)
        Instance.new("Script", v).Name = newName
    end
end

local hum = c:FindFirstChildOfClass("Humanoid")
if hum then
    for i, v in pairs(hum:GetPlayingAnimationTracks()) do
        v:Stop()
    end
end
c.Archivable = true
local cl = c:Clone()
if hum and humState16 then
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    if destroyhum then
        twait(1.6)
    end
end
if destroyhum then
    pcall(destroy, hum)
end

if not c then
    return
end

local head, torso, root = gp(c, "Head", "BasePart"), gp(c, "Torso", "BasePart") or gp(c, "UpperTorso", "BasePart"), gp(c, "HumanoidRootPart", "BasePart")
if hatcollide then
    pcall(destroy, torso)
    pcall(destroy, root)
    pcall(destroy, c:FindFirstChildOfClass("BodyColors") or gp(c, "Health", "Script"))
end

local model = Instance.new("Model", c)
model:GetPropertyChangedSignal("Parent"):Connect(function()
    if not (model and model.Parent) then
        model = nil
    end
end)

for i, v in pairs(c:GetChildren()) do
    if v ~= model then
        if addtools and v:IsA("Tool") then
            for i1, v1 in pairs(v:GetDescendants()) do
                if v1 and v1.Parent and v1:IsA("BasePart") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity, bv.MaxForce, bv.P, bv.Name = v3_0, v3(1000, 1000, 1000), 1250, "bv_" .. v.Name
                    bv.Parent = v1
                end
            end
        end
        v.Parent = model
    end
end

if breakjoints then
    model:BreakJoints()
else
    if head and torso then
        for i, v in pairs(model:GetDescendants()) do
            if v:IsA("JointInstance") then
                local save = false
                if (v.Part0 == torso) and (v.Part1 == head) then
                    save = true
                end
                if (v.Part0 == head) and (v.Part1 == torso) then
                    save = true
                end
                if save then
                    if hedafterneck then
                        hedafterneck = v
                    end
                else
                    pcall(destroy, v)
                end
            end
        end
    end
    if method == 3 then
        task.delay(loadtime, pcall, model.BreakJoints, model)
    end
end

cl.Parent = ws
for i, v in pairs(cl:GetChildren()) do
    v.Parent = c
end
pcall(destroy, cl)

local uncollide, noclipcon = nil, nil
if noclipAllParts then
    uncollide = function()
        if c then
            for i, v in pairs(c:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            noclipcon:Disconnect()
        end
    end
else
    uncollide = function()
        if model then
            for i, v in pairs(model:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        else
            noclipcon:Disconnect()
        end
    end
end
noclipcon = stepped:Connect(uncollide)
uncollide()

for i, scr in pairs(model:GetDescendants()) do
    if (scr.ClassName == "Script") and table.find(scriptNames, scr.Name) then
        local Part0 = scr.Parent
        if Part0:IsA("BasePart") then
            for i1, scr1 in pairs(c:GetDescendants()) do
                if (scr1.ClassName == "Script") and (scr1.Name == scr.Name) and (not scr1:IsDescendantOf(model)) then
                    local Part1 = scr1.Parent
                    if (Part1.ClassName == Part0.ClassName) and (Part1.Name == Part0.Name) then
                        align(Part0, Part1)
                        pcall(destroy, scr)
                        pcall(destroy, scr1)
                        break
                    end
                end
            end
        end
    end
end

for i, v in pairs(c:GetDescendants()) do
    if v and v.Parent and (not v:IsDescendantOf(model)) then
        if v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("BasePart") then
            v.Transparency = 1
            v.Anchored = false
        elseif v:IsA("ForceField") then
            v.Visible = false
        elseif v:IsA("Sound") then
            v.Playing = false
        elseif v:IsA("BillboardGui") or v:IsA("SurfaceGui") or v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        end
    end
end

if newanimate then
    local animate = gp(c, "Animate", "LocalScript")
    if animate then
        animate.Disabled = false
    end
end

if addtools then
    for i, v in pairs(c:GetChildren()) do
        if v:IsA("Tool") then
            v.Parent = addtools
        end
    end
end

local hum0, hum1 = model:FindFirstChildOfClass("Humanoid"), c:FindFirstChildOfClass("Humanoid")
if hum0 then
    hum0:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (hum0 and hum0.Parent) then
            hum0 = nil
        end
    end)
end
if hum1 then
    hum1:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (hum1 and hum1.Parent) then
            hum1 = nil
        end
    end)

    ws.CurrentCamera.CameraSubject = hum1
    local camSubCon = nil
    local function camSubFunc()
        camSubCon:Disconnect()
        if c and hum1 then
            ws.CurrentCamera.CameraSubject = hum1
        end
    end
    camSubCon = renderstepped:Connect(camSubFunc)
    if hum0 then
        hum0:GetPropertyChangedSignal("Jump"):Connect(function()
            if hum1 then
                hum1.Jump = hum0.Jump
            end
        end)
    else
        respawnrequest()
    end
end

local rb = Instance.new("BindableEvent", c)
rb.Event:Connect(function()
    pcall(destroy, rb)
    sg:SetCore("ResetButtonCallback", true)
    if destroyhum then
        if c then c:BreakJoints() end
        return
    end
    if model and hum0 and (hum0.Health > 0) then
        model:BreakJoints()
        hum0.Health = 0
    end
    if antirespawn then
        respawnrequest()
    end
end)
sg:SetCore("ResetButtonCallback", rb)

tdelay(0, function()
    while c do
        if hum0 and hum1 then
            hum1.Jump = hum0.Jump
        end
        wait()
    end
    sg:SetCore("ResetButtonCallback", true)
end)

R15toR6 = R15toR6 and hum1 and (hum1.RigType == Enum.HumanoidRigType.R15)
if R15toR6 then
    local part = gp(c, "HumanoidRootPart", "BasePart") or gp(c, "UpperTorso", "BasePart") or gp(c, "LowerTorso", "BasePart") or gp(c, "Head", "BasePart") or c:FindFirstChildWhichIsA("BasePart")
    if part then
        local cfr = part.CFrame
        local R6parts = { 
            head = {
                Name = "Head",
                Size = v3(2, 1, 1),
                R15 = {
                    Head = 0
                }
            },
            torso = {
                Name = "Torso",
                Size = v3(2, 2, 1),
                R15 = {
                    UpperTorso = 0.2,
                    LowerTorso = -0.8
                }
            },
            root = {
                Name = "HumanoidRootPart",
                Size = v3(2, 2, 1),
                R15 = {
                    HumanoidRootPart = 0
                }
            },
            leftArm = {
                Name = "Left Arm",
                Size = v3(1, 2, 1),
                R15 = {
                    LeftHand = -0.849,
                    LeftLowerArm = -0.174,
                    LeftUpperArm = 0.415
                }
            },
            rightArm = {
                Name = "Right Arm",
                Size = v3(1, 2, 1),
                R15 = {
                    RightHand = -0.849,
                    RightLowerArm = -0.174,
                    RightUpperArm = 0.415
                }
            },
            leftLeg = {
                Name = "Left Leg",
                Size = v3(1, 2, 1),
                R15 = {
                    LeftFoot = -0.85,
                    LeftLowerLeg = -0.29,
                    LeftUpperLeg = 0.49
                }
            },
            rightLeg = {
                Name = "Right Leg",
                Size = v3(1, 2, 1),
                R15 = {
                    RightFoot = -0.85,
                    RightLowerLeg = -0.29,
                    RightUpperLeg = 0.49
                }
            }
        }
        for i, v in pairs(c:GetChildren()) do
            if v:IsA("BasePart") then
                for i1, v1 in pairs(c:GetChildren()) do
                    if v1:IsA("Motor6D") then
                        v1.Part0 = nil
                    end
                end
            end
        end
        part.Archivable = true
        for i, v in pairs(R6parts) do
            local part = part:Clone()
            part:ClearAllChildren()
            part.Name, part.Size, part.CFrame, part.Anchored, part.Transparency, part.CanCollide = v.Name, v.Size, cfr, false, 1, false
            for i1, v1 in pairs(v.R15) do
                local R15part = gp(c, i1, "BasePart")
                local att = gp(R15part, "att1_" .. i1, "Attachment")
                if R15part then
                    local weld = Instance.new("Weld")
                    weld.Part0, weld.Part1, weld.C0, weld.C1, weld.Name = part, R15part, cf(0, v1, 0), cf_0, "Weld_" .. i1
                    weld.Parent = R15part
                    R15part.Massless, R15part.Name = true, "R15_" .. i1
                    R15part.Parent = part
                    if att then
                        att.Position = v3(0, v1, 0)
                        att.Parent = part
                    end
                end
            end
            part.Parent = c
            R6parts[i] = part
        end
        local R6joints = {
            neck = {
                Parent = R6parts.torso,
                Name = "Neck",
                Part0 = R6parts.torso,
                Part1 = R6parts.head,
                C0 = cf(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
                C1 = cf(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            },
            rootJoint = {
                Parent = R6parts.root,
                Name = "RootJoint" ,
                Part0 = R6parts.root,
                Part1 = R6parts.torso,
                C0 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0),
                C1 = cf(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, -0)
            },
            rightShoulder = {
                Parent = R6parts.torso,
                Name = "Right Shoulder",
                Part0 = R6parts.torso,
                Part1 = R6parts.rightArm,
                C0 = cf(1, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
                C1 = cf(-0.5, 0.5, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            },
            leftShoulder = {
                Parent = R6parts.torso,
                Name = "Left Shoulder",
                Part0 = R6parts.torso,
                Part1 = R6parts.leftArm,
                C0 = cf(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
                C1 = cf(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            },
            rightHip = {
                Parent = R6parts.torso,
                Name = "Right Hip",
                Part0 = R6parts.torso,
                Part1 = R6parts.rightLeg,
                C0 = cf(1, -1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0),
                C1 = cf(0.5, 1, 0, 0, 0, 1, 0, 1, -0, -1, 0, 0)
            },
            leftHip = {
                Parent = R6parts.torso,
                Name = "Left Hip" ,
                Part0 = R6parts.torso,
                Part1 = R6parts.leftLeg,
                C0 = cf(-1, -1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0),
                C1 = cf(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
            }
        }
        for i, v in pairs(R6joints) do
            local joint = Instance.new("Motor6D")
            for prop, val in pairs(v) do
                joint[prop] = val
            end
            R6joints[i] = joint
        end
        if hum1 then
            hum1.RigType, hum1.HipHeight = Enum.HumanoidRigType.R6, 0
        end
    end
end

local torso1 = torso
torso = gp(c, "Torso", "BasePart") or ((not R15toR6) and gp(c, torso.Name, "BasePart"))
if (typeof(hedafterneck) == "Instance") and head and torso and torso1 then
    local conNeck, conTorso, conTorso1 = nil, nil, nil
    local aligns = {}
    local function enableAligns()
        conNeck:Disconnect()
        conTorso:Disconnect()
        conTorso1:Disconnect()
        for i, v in pairs(aligns) do
            v.Enabled = true
        end
    end
    conNeck = hedafterneck.Changed:Connect(function(prop)
        if table.find({"Part0", "Part1", "Parent"}, prop) then
            enableAligns()
        end
    end)
    conTorso = torso:GetPropertyChangedSignal("Parent"):Connect(enableAligns)
    conTorso1 = torso1:GetPropertyChangedSignal("Parent"):Connect(enableAligns)
    for i, v in pairs(head:GetDescendants()) do
        if v:IsA("AlignPosition") or v:IsA("AlignOrientation") then
            i = tostring(i)
            aligns[i] = v
            v:GetPropertyChangedSignal("Parent"):Connect(function()
                aligns[i] = nil
            end)
            v.Enabled = false
        end
    end
end

local flingpart0 = gp(model, flingpart, "BasePart") or gp(gp(model, flingpart, "Accessory"), "Handle", "BasePart")
local flingpart1 = gp(c, flingpart, "BasePart") or gp(gp(c, flingpart, "Accessory"), "Handle", "BasePart")

local fling = function() end
if flingpart0 and flingpart1 then
    flingpart0:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (flingpart0 and flingpart0.Parent) then
            flingpart0 = nil
            fling = function() end
        end
    end)
    flingpart0.Archivable = true
    flingpart1:GetPropertyChangedSignal("Parent"):Connect(function()
        if not (flingpart1 and flingpart1.Parent) then
            flingpart1 = nil
            fling = function() end
        end
    end)
    local att0 = gp(flingpart0, "att0_" .. flingpart0.Name, "Attachment")
    local att1 = gp(flingpart1, "att1_" .. flingpart1.Name, "Attachment")
    if att0 and att1 then
        att0:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (att0 and att0.Parent) then
                att0 = nil
                fling = function() end
            end
        end)
        att1:GetPropertyChangedSignal("Parent"):Connect(function()
            if not (att1 and att1.Parent) then
                att1 = nil
                fling = function() end
            end
        end)
        local lastfling = nil
        local mouse = lp:GetMouse()
        fling = function(target, duration, rotVelocity)
            if typeof(target) == "Instance" then
                if target:IsA("BasePart") then
                    target = target.Position
                elseif target:IsA("Model") then
                    target = gp(target, "HumanoidRootPart", "BasePart") or gp(target, "Torso", "BasePart") or gp(target, "UpperTorso", "BasePart") or target:FindFirstChildWhichIsA("BasePart")
                    if target then
                        target = target.Position
                    else
                        return
                    end
                elseif target:IsA("Humanoid") then
                    target = target.Parent
                    if not (target and target:IsA("Model")) then
                        return
                    end
                    target = gp(target, "HumanoidRootPart", "BasePart") or gp(target, "Torso", "BasePart") or gp(target, "UpperTorso", "BasePart") or target:FindFirstChildWhichIsA("BasePart")
                    if target then
                        target = target.Position
                    else
                        return
                    end
                else
                    return
                end
            elseif typeof(target) == "CFrame" then
                target = target.Position
            elseif typeof(target) ~= "Vector3" then
                target = mouse.Hit
                if target then
                    target = target.Position
                else
                    return
                end
            end
            if target.Y < ws.FallenPartsDestroyHeight + 5 then
                target = v3(target.X, ws.FallenPartsDestroyHeight + 5, target.Z)
            end
            lastfling = target
            if type(duration) ~= "number" then
                duration = tonumber(duration) or 0.5
            end
            if typeof(rotVelocity) ~= "Vector3" then
                rotVelocity = v3(20000, 20000, 20000)
            end
            if not (target and flingpart0 and flingpart1 and att0 and att1) then
                return
            end
            flingpart0.Archivable = true
            local flingpart = flingpart0:Clone()
            flingpart.Transparency = 1
            flingpart.CanCollide = false
            flingpart.Name = "flingpart_" .. flingpart0.Name
            flingpart.Anchored = true
            flingpart.Velocity = v3_0
            flingpart.RotVelocity = v3_0
            flingpart.Position = target
            flingpart:GetPropertyChangedSignal("Parent"):Connect(function()
                if not (flingpart and flingpart.Parent) then
                    flingpart = nil
                end
            end)
            flingpart.Parent = flingpart1
            if flingpart0.Transparency > 1 then
                flingpart0.Transparency = 1
            end
            att1.Parent = flingpart
            local con = nil
            local rotchg = v3(0, rotVelocity.Unit.Y * -1000, 0)
            con = heartbeat:Connect(function(delta)
                if target and (lastfling == target) and flingpart and flingpart0 and flingpart1 and att0 and att1 then
                    flingpart.Orientation += rotchg * delta
                    flingpart0.RotVelocity = rotVelocity
                else
                    con:Disconnect()
                end
            end)
            if alignmode ~= 4 then
                local con = nil
                con = renderstepped:Connect(function()
                    if flingpart0 and target then
                        flingpart0.RotVelocity = v3_0
                    else
                        con:Disconnect()
                    end
                end)
            end
            twait(duration)
            if lastfling ~= target then
                if flingpart then
                    if att1 and (att1.Parent == flingpart) then
                        att1.Parent = flingpart1
                    end
                    pcall(destroy, flingpart)
                end
                return
            end
            target = nil
            if not (flingpart and flingpart0 and flingpart1 and att0 and att1) then
                return
            end
            flingpart0.RotVelocity = v3_0
            att1.Parent = flingpart1
            pcall(destroy, flingpart)
        end
    end
end

local cmt = {
	Angles = function(x,y,z,useRad)
		if not useRad then
			return CFrame.Angles(x,y,z)
		else
			return CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
		end
	end
}
local imt = {
	CreateWeld = function(p1,p2,c0,c1)
		c0,c1 = c0 or CFrame.new(0,0,0),c1 or CFrame.new(0,0,0)
		local weld = Instance.new("Motor6D",p1)
		weld.Part0,weld.Part1 = p1,p2
		weld.C0,weld.C1 = c0,c1
		return weld
	end,
	New = function(type,args)
		local instance = Instance.new(type)
		for i,v in pairs(args) do
			pcall(function()
				instance[i] = v
			end)
		end
		return instance
	end,
	Remove = function(instance,time)
		time = time or 0
		game:GetService("Debris"):AddItem(instance,time)
	end
}
local math     = setmetatable({random = function(minNum,maxNum,div) div = div or 1 return math.random(minNum * div,maxNum * div)/div end},{__index = math})
local CFrame   = setmetatable(cmt,{__index = CFrame})
local Instance = setmetatable(imt,{__index = Instance})

local stepped = game:GetService("RunService").Stepped

--BasicFunctions
local ins    = Instance.new
local v3     = Vector3.new
local cf     = CFrame.new
local angles = CFrame.Angles
local rad    = math.rad
local huge   = math.huge
local cos    = math.cos
local sin    = math.sin
local tan    = math.tan
local ray    = Ray.new
local random = math.random
local ud     = UDim.new
local ud2    = UDim2.new
local c3     = Color3.new
local rgb    = Color3.fromRGB
local bc     = BrickColor.new

--Variables
local plr	 = game.Players.LocalPlayer
local plrg   = plr.PlayerGui
local char   = plr.Character
local h      = char.Head
local t      = char.Torso
local ra     = char["Right Arm"]
local la     = char["Left Arm"]
local rl     = char["Right Leg"]
local ll     = char["Left Leg"]
local rut    = char.HumanoidRootPart
local hum    = char:FindFirstChildOfClass("Humanoid")
local necno  = t.Neck
local rutjno = rut.RootJoint
local rsno   = t["Right Shoulder"]
local lsno   = t["Left Shoulder"]
local rhno   = t["Right Hip"]
local lhno   = t["Left Hip"]
--
local change  = 1
local sine    = 0
local ws      = 8
local jp      = 35
local songPos = 1
local jok     = false
local sprint  = false
local sitting = false
local laying  = false
local crying  = false
local wsGrow  = false
local muted   = false
local anim    = "Idle"
local asset   = "rbxassetid://"
local songs = {
	2734040079,
	1179830130,
	152675132,
	1467405749,
	411386717,
	3517565766,
	509308446
}
--
necc0,necc1=cf(0,t.Size.Y/2,0),cf(0,-h.Size.Y/2,0)
rutjc0,rutjc1=cf(0,0,0),cf(0,0,0)
rsc0,rsc1=cf(t.Size.X/2,t.Size.Y/4,0),cf(-ra.Size.X/2,ra.Size.Y/4,0)
lsc0,lsc1=cf(-t.Size.X/2,t.Size.Y/4,0),cf(la.Size.X/2,la.Size.Y/4,0)
rhc0,rhc1=cf(t.Size.X/4,-t.Size.Y/2,0),cf(0,rl.Size.Y/2,0)
lhc0,lhc1=cf(-t.Size.X/4,-t.Size.Y/2,0),cf(0,ll.Size.Y/2,0)
if char:FindFirstChild("Animate") then
char.Animate:Destroy()
end
if hum:FindFirstChildOfClass("Animator") then
hum.Animator:Destroy()
end
--Creating new joints
local nec = ins("Motor6D",t) nec.Name = "Neck" nec.Part0 = t nec.Part1 = h
local rutj = ins("Motor6D",rut) rutj.Name = "RootJoint" rutj.Part0 = t rutj.Part1 = rut
local rs = ins("Motor6D",t) rs.Name = "Right Shoulder" rs.Part0 = t rs.Part1 = ra
local ls = ins("Motor6D",t) ls.Name = "Left Shoulder" ls.Part0 = t ls.Part1 = la
local rh = ins("Motor6D",t) rh.Name = "Right Hip" rh.Part0 = t rh.Part1 = rl
local lh = ins("Motor6D",t) lh.Name = "Left Hip" lh.Part0 = t lh.Part1 = ll
--Removing old joints
necno.Parent = nil
rutjno.Parent = nil
rsno.Parent = nil
lsno.Parent = nil
rhno.Parent = nil
lhno.Parent = nil
--Setting CFrames
nec.C1 = necc1
nec.C0 = necc0
rs.C1 = rsc1
rs.C0 = rsc0
ls.C1 = lsc1
ls.C0 = lsc0
rh.C1 = rhc1
rh.C0 = rhc0
lh.C1 = lhc1
lh.C0 = lhc0
rutj.C1 = rutjc1
rutj.C0 = rutjc0

local rem = Instance.New("RemoteEvent",{Name = "ARemote",Parent = char})
local mus = Instance.New("Sound",{Looped = true,Volume = .5,SoundId = asset..songs[songPos],Parent = t})
local vroOm = Instance.New("Sound",{Looped = true,Volume = 7.5,SoundId = asset..2658538628,Parent = t})
if jok then
	mus:Play()
end

function swait()
	stepped:Wait()
end
function rayc(spos,direc,ignore,dist)
    return workspace:FindPartOnRayWithIgnoreList(ray(spos,direc.Unit * dist),ignore,false,false)
end
function tween(instance,args,info,playOnCreate)
	if instance and args then
		playOnCreate = playOnCreate or true
		info = info or TweenInfo.new(
			1,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.In,
			0,
			false,
			0
		)
		if typeof(info) == "table" then
			info = TweenInfo.new(unpack(info))
		end
		local tween = game:GetService("TweenService"):Create(instance,info,args)
		if playOnCreate then
			tween:Play()
		end
		return tween
	end
end

local mouse = plr:GetMouse()
mouse.KeyDown:Connect(function(key)
	if key == "n" then
		jok = not jok
	end
	if key == "z" then
		sitting = not sitting
		laying = false
		crying = false
	end
	if key == "x" then
		sitting = false
		laying = not laying
		crying = false
	end
	if key == "c" then
		sitting = false
		laying = false
		crying = not crying
	end
	if key == "l" then
		songPos = songPos + 1
		if songPos > #songs then
			songPos = 1
		end
		mus.SoundId = asset..songs[songPos]
		mus:Play()
		mus.TimePosition = 0
	end
	if key == "m" then
		muted = not muted
	end
end)

stepped:Connect(function()
	sine = sine + change
	
	local dir = hum.MoveDirection
	if dir.Magnitude == 0 then dir = rut.Velocity/10 end
	
    local Ccf		  = rut.CFrame
    local Walktest1   = dir*Ccf.LookVector
    local Walktest2   = dir*Ccf.RightVector
    local rotfb		  = Walktest1.X+Walktest1.Z
    local rotrl		  = Walktest2.X+Walktest2.Z
	
	local hit,pos,rot = rayc(rut.Position,-rut.CFrame.UpVector,{char},4.5)
	
	local verVel	  = rut.Velocity.y
    local horVel	  = (rut.Velocity * v3(1,0,1)).Magnitude
	
	if mus.Parent ~= t then
		Instance.Remove(mus)
		mus = Instance.New("Sound",{Looped = true,Volume = .5,SoundId = asset..songs[songPos],Parent = t})
		mus:Play()
	end
	if vroOm.Parent ~= t then
		Instance.Remove(vroOm)
		vroOm = Instance.New("Sound",{Looped = true,Volume = 7.5,SoundId = asset..2658538628,Parent = t})
	end
	if rotfb > 1 then
		rotfb = 1
	elseif rotfb < -1 then
		rotfb = -1
	end
	if rotrl > 1 then
		rotrl = 1
	elseif rotrl < -1 then
		rotrl = -1
	end
	
	if jok then
		if not sprint then
			ws = 16
		else
			if not wsGrow then
				ws = 6
			end
		end
		jp = 65
		if not muted then
			mus:Resume()
		else
			mus:Stop()
		end
	else
		if not sprint then
			ws = 8
		else
			ws = 38
		end
		jp = 35
		mus:Stop()
	end
	
	hum.WalkSpeed = ws
	hum.JumpPower = jp
	
	local sn = 0 if plr.Name == "vlad20020" and random(0,1,50) == .6 then sn = random(5,10) end
	
	if anim == "walk" and hit then
		if not jok then
			nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(cos(sine/3) * 5,0,0,true) * angles(-rotfb/15,rotrl/2,0),.2)
			rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,.2 * cos(sine/3),0) * angles(sin(sine/3) * 2.5,sin(sine/6) * 2.5,0,true) * angles(-rotfb/12.5,0,-rotrl/8.5),.2)
			rs.C1 = rs.C1:Lerp(rsc1 * cf(.05 - .05 *  cos(sine/3),0,.1 * cos(sine/6) * rotfb) * angles(-10 - sin(sine/6) * 40 * rotfb,-sin(sine/6) * 25 * rotfb,0,true),.2)
			ls.C1 = ls.C1:Lerp(lsc1 * cf(-.05 + .05 *  cos(sine/3),0,-.1 * cos(sine/6) * rotfb) * angles(-10 + sin(sine/6) * 40 * rotfb,-sin(sine/6) * 25 * rotfb,0,true),.2)
			rh.C1 = rh.C1:Lerp(rhc1 * cf(0,.2 * cos(sine/6),.3 * -cos(sine/6)) * angles((7.5 * math.abs(rotfb)) + sin(sine/6) * 40 * rotfb,sin(sine/6) * 5,sin(sine/6) * 40 * rotrl,true),.2)
			lh.C1 = lh.C1:Lerp(lhc1 * cf(0,-.2 * cos(sine/6),.3 * cos(sine/6)) * angles((7.5 * math.abs(rotfb)) - sin(sine/6) * 40 * rotfb,sin(sine/6) * 5,-sin(sine/6) * 40 * rotrl,true),.2)
			wsGrow = false
			vroOm:Stop()
		else
			nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(sin(sine/5) * 15,sin(sine/10) * 20,0,true) * angles(-rotfb/10,rotrl/2,0),.2)
			rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,cos(sine/5) * 2.5,0) * angles(0,sin(sine/10) * 20,0,true) * angles(-rotfb/5,0,-rotrl/5),.2)
			rs.C1 = rs.C1:Lerp(rsc1 * cf(0,0,sin(sine/10) * 2.5 * rotfb) * angles(-15 + (sin(-sine/10) * 60 * rotfb),(-sin(sine/10) * 20) * rotfb,0,true),.2)
			ls.C1 = ls.C1:Lerp(lsc1 * cf(0,0,-sin(sine/10) * 2.5 * rotfb) * angles(-15 + (sin(sine/10) * 60 * rotfb),(-sin(sine/10) * 20) * rotfb,0,true),.2)
			rh.C1 = rh.C1:Lerp(rhc1 * cf((sin(sine/10) * 2.5) * rotrl,cos(sine/10) * 2.5,(-sin(sine/10) * 2.5) * rotfb) * angles(6.5 - (-sin(sine/10) * 35) * rotfb,sin(sine/10) * 10,(sin(sine/10) * 35) * rotrl,true),.2)
			lh.C1 = lh.C1:Lerp(lhc1 * cf((-sin(sine/10) * 2.5) * rotrl,-cos(sine/10) * 2.5,(sin(sine/10) * 2.5) * rotfb) * angles(6.5 - (sin(sine/10) * 35) * rotfb,sin(sine/10) * 10,(-sin(sine/10) * 35) * rotrl,true),.2)
			wsGrow = false
			vroOm:Stop()
		end
	elseif anim == "run" and hit then
		if not jok then
			nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(cos(sine/3) * 7.5,sin(sine/6) * 5,0,true) * angles(-rotfb/10,rotrl/2,0),.2)
			rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,.4 * cos(sine/3),0) * angles(sin(sine/3) * 4,sin(sine/6) * 7.5,0,true) * angles(-rotfb/5,0,-rotrl/5),.2)
			rs.C1 = rs.C1:Lerp(rsc1 * cf(.1 - .1 *  cos(sine/3),0,-.15 - .2 * cos(sine/6) * rotfb) * angles(-15 - sin(sine/6) * 110 * rotfb,-sin(sine/6) * 25 * rotfb,-10,true),.2)
			ls.C1 = ls.C1:Lerp(lsc1 * cf(-.1 + .1 *  cos(sine/3),0,-.15 +.2 * cos(sine/6) * rotfb) * angles(-15 + sin(sine/6) * 110 * rotfb,-sin(sine/6) * 25 * rotfb,10,true),.2)
			rh.C1 = rh.C1:Lerp(rhc1 * cf(0,.5 * cos(sine/6),.75 * -cos(sine/6)) * angles((7.5 * math.abs(rotfb)) + (sin(sine/6) * 80 * rotfb),sin(sine/6) * 15,sin(sine/6) * 60 * rotrl,true),.2)
			lh.C1 = lh.C1:Lerp(lhc1 * cf(0,.5 * -cos(sine/6),.75 * cos(sine/6)) * angles((7.5 * math.abs(rotfb)) + (-sin(sine/6) * 80 * rotfb),sin(sine/6) * 15,-sin(sine/6) * 60 * rotrl,true),.2)
			wsGrow = false
			vroOm:Stop()
		else
			nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(0,0,0,true) * angles(-rotfb * 1.5,0,0),.2)
			rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,-math.abs(rotfb * 1.5) + 1 * sin(sine),0) * angles(sin(sine) * 25,0,cos(sine) * 15,true) * angles(-rotfb * 1.5,0,-rotrl * 1.5),.2)
			rs.C1 = rs.C1:Lerp(rsc1 * cf(0,0,0) * angles(-sine * 50 * (ws/750) * rotfb,sin(sine) * 200,sine * 50 * (ws/750) * rotrl,true),.2)
			ls.C1 = ls.C1:Lerp(lsc1 * cf(0,0,0) * angles(-sine * 50 * (ws/750) * rotfb,sin(sine) * 200,sine * 50 * (ws/750) * rotrl,true),.2)
			rh.C1 = rh.C1:Lerp(rhc1 * cf(0,0,1 * sin(sine/5) * 5 * (ws/750)) * angles(sine * 50 * (ws/750) * rotfb,0,sine * 50 * (ws/750) * rotrl,true),.2)
			lh.C1 = lh.C1:Lerp(lhc1 * cf(0,0,-1 * sin(sine/5) * 5 * (ws/750)) * angles(sine * 50 * (ws/750) * rotfb,0,sine * 50 * (ws/750) * rotrl,true),.2)
			vroOm:Resume()
			if vroOm.TimePosition > vroOm.TimeLength -.1 then
				vroOm.TimePosition = 8.5
			end
			if vroOm.TimePosition < .1 then
				ws = 6
			end
			if vroOm.TimePosition < 8.5 then
				ws = ws + .01
			else
				ws = 750
				wsGrow = true
			end
		end
	elseif anim == "jump" and not hit then
		nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(0,0,0,true),.2)
		rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,0,0) * angles(0,0,0,true) * angles(-rotfb/5,0,-rotrl/5),.2)
		rs.C1 = rs.C1:Lerp(rsc1 * cf(0,0,0) * angles(0,0,0,true),.2)
		ls.C1 = ls.C1:Lerp(lsc1 * cf(0,0,0) * angles(0,0,0,true),.2)
		rh.C1 = rh.C1:Lerp(rhc1 * cf(0,0,0) * angles(0,0,0,true),.2)
		lh.C1 = lh.C1:Lerp(lhc1 * cf(0,0,0) * angles(0,0,0,true),.2)
	elseif anim == "fall" and not hit then
		nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(0,0,0,true),.2)
		rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,0,0) * angles(0,0,0,true) * angles(-rotfb/5,0,-rotrl/5),.2)
		rs.C1 = rs.C1:Lerp(rsc1 * cf(0,0,0) * angles(sin(sine/10) * 5,cos(sine/10) * 5,0,true),.2)
		ls.C1 = ls.C1:Lerp(lsc1 * cf(0,0,0) * angles(-sin(sine/10) * 5,-cos(sine/10) * 5,0,true),.2)
		rh.C1 = rh.C1:Lerp(rhc1 * cf(0,0,0) * angles(0,0,0,true),.2)
		lh.C1 = lh.C1:Lerp(lhc1 * cf(0,0,0) * angles(0,0,0,true),.2)
	elseif anim == "idle" and hit then
		if not jok or sitting or laying or crying then
			nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(cos(sine/20) * 4,sin(sine/80) * 10,0,true) * angles(random(-sn,sn),random(-sn,sn),random(-sn,sn),true),.2)
			rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(sin(sine/80)/20,sin(sine/20)/15,sin(sine/30)/17.5) * angles(sin(sine/20) * .9,sin(sine/60) * 2.25,sin(sine/80) * 2.25,true),.2)
			rs.C1 = rs.C1:Lerp(rsc1 * cf(0,sin(sine/20)/15,0) * angles((cos(sine/20) * 4),sin(sine/20) * 1.8,(sin(sine/80) * 2.25) + (cos(sine/20) * 2.25),true),.2)
			ls.C1 = ls.C1:Lerp(lsc1 * cf(0,sin(sine/20)/15,0) * angles((cos(sine/20) * 4),-sin(sine/20) * 1.8,(sin(sine/80) * 2.25) + (-cos(sine/20) * 2.25),true),.2)
			rh.C1 = rh.C1:Lerp(rhc1 * cf(0,(sin(sine/20)/15) + (sin(sine/80)/25),0) * angles((sin(sine/20) * 1.8) - (sin(sine/30) * 2.25) + (sin(sine/60) * 1.35),sin(sine/60) * 2.25,(sin(sine/80) * 3.25),true),.2)
			lh.C1 = lh.C1:Lerp(lhc1 * cf(0,(sin(sine/20)/15) - (sin(sine/80)/25),0) * angles((sin(sine/20) * 1.8) - (sin(sine/30) * 2.25) - (sin(sine/60) * 1.35),sin(sine/60) * 2.25,(sin(sine/80) * 3.25),true),.2)
			wsGrow = false
			vroOm:Stop()
		elseif jok and not sitting and not laying and not crying then
			nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(-cos(sine/10) * sin(sine/20) * 45,sin(sine/20) * cos(sine/40) * 30,sin(sine/30) * cos(sine/60) * 20,true),.2)
			rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(.25 * sin(sine/30) * cos(sine/60),-.65 + 1 * sin(sine/10) * cos(sine/20),0) * angles(sin(sine/10) * cos(sine/20) * 35,0,sin(sine/30) * cos(sine/60) * 10,true),.2)
			rs.C1 = rs.C1:Lerp(rsc1 * cf(0,.25 - .25 * sin(sine/20) * cos(sine/10),.25 * sin(sine/10) * cos(sine/20)) * angles(-105 + sin(sine/20) * cos(sine/10) * 65,sin(sine/20) * cos(sine/60) * 5,sin(sine/10) * cos(sine/20) * 70,true),.2)
			ls.C1 = ls.C1:Lerp(lsc1 * cf(0,.25 - .25 * sin(sine/20) * cos(sine/10),.25 * sin(sine/10) * cos(sine/20)) * angles(-105 + sin(sine/20) * cos(sine/10) * 65,sin(sine/20) * cos(sine/60) * 5,sin(sine/10) * cos(sine/20) * -70,true),.2)
			rh.C1 = rh.C1:Lerp(rhc1 * cf(0,-.625 + 1 * sin(sine/10) * cos(sine/20),.25 - .5 * sin(sine/10) * cos(sine/20)) * angles(10 + sin(sine/10) * cos(sine/20) * 40,0,sin(sine/30) * cos(sine/60) * 17.5,true),.2)
			lh.C1 = lh.C1:Lerp(lhc1 * cf(0,-.625 + 1 * sin(sine/10) * cos(sine/20),.25 - .5 * sin(sine/10) * cos(sine/20)) * angles(10 + sin(sine/10) * cos(sine/20) * 40,0,sin(sine/30) * cos(sine/60) * 17.5,true),.2)
			wsGrow = false
			vroOm:Stop()
		end
	end
	
	if verVel > 20 then
		anim = "jump"
		change = 1
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(5,0,0,true),.2)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(-5,0,0,true),.2)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,-.15,-.25) * angles(150,10,12.5,true),.2)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,-.15,-.25) * angles(155,-10,-12.5,true),.2)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,.5,-.35) * angles(-12.5,0,5,true),.2)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,.2,-.15) * angles(-2.5,0,-5,true),.2)
	elseif verVel < -20 then
		anim = "fall"
		change = 1
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(-7.5,0,0,true),.2)
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(5,0,0,true),.2)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(.25,-.25,0) * angles(0,10,110,true),.2)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(-.25,-.25,0) * angles(0,-10,-110,true),.2)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,.2,-.15) * angles(-2.5,0,5,true),.2)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,.5,-.35) * angles(-12.5,0,-5,true),.2)
	elseif horVel > 5 and verVel > -20 and verVel < 20 then
		if not sprint then
			anim = "walk"
			if not jok then
				change = .6
			else
				change = 1
			end
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(0,0,0,true),.2)
		else
			anim = "run"
			if not jok then
				change = .9
			else
				change = 1
			end
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(0,0,0,true),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(0,0,0,true),.2)
		end
	elseif horVel < 5 and verVel > -20 and verVel < 20 then
		anim = "idle"
		change = 1
		if not sitting and not laying and not crying then
			if not jok then
				nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(0,0,0,true),.2)
				rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(0,0,0,true),.2)
				rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,0) * angles(.5,0,-.5,true),.2)
				ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(.5,0,.5,true),.2)
				rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(0,-2.5,2,true),.2)
				lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(0,2.5,-2,true),.2)
			else
				nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(0,0,0,true),.2)
				rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(0,0,0,true),.2)
				rs.C0 = rs.C0:Lerp(rsc0 * cf(0,0,0) * angles(0,0,0,true),.2)
				ls.C0 = ls.C0:Lerp(lsc0 * cf(0,0,0) * angles(0,0,0,true),.2)
				rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(0,0,5,true),.2)
				lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(0,0,-5,true),.2)
			end
		elseif sitting and not laying and not crying then
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(-20,0,0,true),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,1.75,0) * angles(-15,0,0,true),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(-.1,-.5,.15) * angles(-20,-60,10,true),.2)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(0,-.25,-.2) * angles(70,-60,60,true) * angles(40,0,0,true),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(70,7.5,5,true),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,1.25,-.5) * angles(10,-10,-5,true),.2)
		elseif not sitting and laying and not crying then
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(-35,0,0,true),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,-2.4) * angles(-87.5,0,0,true),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(-.1,.75,-.25) * angles(195,0,-65,true) * angles(0,90,0,true),.2)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(.125,-.3,-.05) * angles(90,20,85,true) * angles(-30,20,0,true),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,.25,-1) * angles(-55,20,7.5,true),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(2,-7.5,5,true),.2)
		elseif not sitting and not laying and crying then
			nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(-80,0,0,true),.2)
			rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,1.9,0) * angles(10,0,0,true),.2)
			rs.C0 = rs.C0:Lerp(rsc0 * cf(-.25,-.475,-.8) * angles(85,0,-80,true) * angles(0,100,0,true),.2)
			ls.C0 = ls.C0:Lerp(lsc0 * cf(.25,-.4,-.75) * angles(80,0,85,true) * angles(0,-87.5,0,true),.2)
			rh.C0 = rh.C0:Lerp(rhc0 * cf(0,1.85,-.75) * angles(5,-5,-5,true),.2)
			lh.C0 = lh.C0:Lerp(lhc0 * cf(0,1.85,-.7) * angles(3.5,5,5,true),.2)
		end
	end
end)

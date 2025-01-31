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

lp:GetMouse().Button1Down:Connect(fling) --click fling

local Player, Character, Mouse  = game:service("Players").LocalPlayer, game:GetService("Players").LocalPlayer.Character, game:GetService("Players").LocalPlayer:GetMouse();
local Torso = Character:FindFirstChild("Torso")
local rootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")
local Head = Character:FindFirstChild("Head")
local Right_Arm = Character:FindFirstChild("Right Arm")
local Left_Arm = Character:FindFirstChild("Left Arm")
local Right_Leg = Character:FindFirstChild("Right Leg")
local Left_Leg = Character:FindFirstChild("Left Leg")
local Right_Shoulder = Torso:FindFirstChild("Right Shoulder")
local Left_Shoulder = Torso:FindFirstChild("Left Shoulder")
local Right_Hip = Torso:FindFirstChild("Right Hip")
local Left_Hip = Torso:FindFirstChild("Left Hip")
local Neck = Torso:FindFirstChild("Neck")
local rootPart = Character:FindFirstChild("HumanoidRootPart")
local rootJoint = rootPart:FindFirstChild("RootJoint")
local CurrentIdle = "Idling1"
local Degree = 0.0175438596491228
local Camera = workspace.CurrentCamera
local canremove = false
local debounce = false
local Size = 1
dabbing = false
_G.SongName = math.random(1,9025232)
sin = math.sin
Right_Leg.FormFactor                 = "Custom";
Left_Leg.FormFactor                        = "Custom";
rootPart.Archivable                 = true;
rootJoint.Archivable                 = true;
c_new                                                = CFrame.new;
c_angles                                        = CFrame.Angles;
i_new = Instance.new
Humanoid:ClearAllChildren();
local isAttacking = false
local isSprinting = false
local Animations = false
local Angle = 0
local Axis = 0
local angleSpeed = 1
local axisSpeed = angleSpeed
local currentAnim
local levetatingheight = 3
local WalkType = "Ground"
local holding = false 
isFalling = false
local val2 = 1
local val3 = 1
local Sitting = false
Jp = Humanoid.JumpPower*Size
ws = 16*Size/2
val = 1
local deb = false
drink = false
local deb2 = false
local deb3 = false
local deb5 = false
local deb6 = false
local Punch2 = false
local Raising = false
local Stomping = false
local Grabbing = false
 crawl = false
 local valz = false
 Character.Health:Destroy()
local Shielding = false
local Clap = false
local Punch1 = false
local combo = 1
local Charge2 = false
local Punch2 = false
Spin1 = false
local Charge3 = false
local Lunge1 = false
local Charge4 = false
local Uppercut1 = false
local Terra = false
local rage = false
local raged = 10
Mouse.KeyDown:connect(function(key)
        if key:byte() == 48 then
                isSprinting = true
        end
        
        Mouse.KeyUp:connect(function(key2)
                if key:byte() == 48 then
                        isSprinting = false
                end
        end)
end)
 
twist = 0

local deb = false
local activez = false

Mouse.KeyDown:connect(function(key)
if key == "z" and Humanoid.Health < Humanoid.MaxHealth/2 and Animations == false then
rage = true
Humanoid.WalkSpeed = 0
Humanoid.MaxHealth = Humanoid.MaxHealth*100000000000
Humanoid.Health = Humanoid.Health*100000000000
spawn(function()
for i = 0,1,0.03 do
 local x,y,z = Torso.CFrame:toEulerAnglesXYZ()
local ring = Instance.new("Part", Character)
ring.Anchored = true
ring.CFrame = rootPart.CFrame * CFrame.new(0,-2.5*Size,0)*CFrame.Angles(math.rad(-90),0,0)
ring.BrickColor  = BrickColor.new("Really red")
ring.CanCollide = false
local ringmesh = Instance.new("SpecialMesh", ring)
ringmesh.MeshId = "http://www.roblox.com/asset/?id=3270017"
local ring2 = Instance.new("Part", Character)
ring2.Anchored = true
ring2.Shape = "Cylinder"
ring2.CanCollide = false
ring2.CFrame = rootPart.CFrame*CFrame.Angles(0,0,math.rad(90))
ring2.BrickColor = BrickColor.new("Really red")
ring2.TopSurface = 0
ring2.BottomSurface = 0
game.Debris:AddItem(ring2, 0.8)
game.Debris:AddItem(ring, 0.8)
spawn(function()
for i = 0,1,0.01 do
ring2.Size = ring2.Size+Vector3.new(5 ,1.5,5)
ring2.Transparency = i*8
wait()
end
end)
spawn(function()
for i = 0,1,0.01 do
ringmesh.Scale = ringmesh.Scale+Vector3.new(19,19,10)
ring.Transparency = i*8
wait()
end
end)
wait(0.17)
end
end)
wait(2)
Humanoid.WalkSpeed = 16
rage = false
Humanoid.MaxHealth = 1500*raged
Humanoid.Health = Humanoid.MaxHealth/2
end
end)

Mouse.KeyDown:connect(function(key)
if key == "e" and Animations == false then
Animations = true
Terra = true
activez = true
wait(0.1)
local b  = Instance.new("Part", Character)
b.TopSurface = 0
b.BottomSurface = 0
b.Shape = "Ball"
b.CanCollide = false
b.BrickColor = BrickColor.new("Bright violet")
b.CFrame = rootPart.CFrame*CFrame.new(0,0,1)
b.Size = Vector3.new(60,60,60)
b.Transparency = 0.4
b.Material = "Neon"
local bodyv = Instance.new("BodyVelocity", b)
bodyv.maxForce = Vector3.new(math.huge,math.huge,math.huge)
bodyv.Velocity = rootPart.CFrame.lookVector*60

spawn(function()
while activez == true do
local ring = Instance.new("Part", Character)
ring.Anchored = true
ring.BrickColor  = BrickColor.new("Bright violet")
ring.CanCollide = false
game.Debris:AddItem(ring, 2)
local ringmesh = Instance.new("SpecialMesh", ring)
ringmesh.MeshId = "http://www.roblox.com/asset/?id=3270017"
spawn(function()
for i = 0,1,0.01 do
ringmesh.Scale = ringmesh.Scale+Vector3.new(6,6,6)
ring.Transparency = i*8
wait()
end
end)
ring.CFrame = b.CFrame*CFrame.Angles(math.random(1,360),math.random(1,360),math.random(1,360))
wait(0)
end
end)


function onDamage(Part)
        if Part.Parent:FindFirstChild("Torso") ~= nil and Part.Parent.Name ~= Character.Name and deb3 == false then
        deb3 = true
       activez = false
                   spawn(function()
                      for i = 1,10 do
                      local p = Instance.new("Part", Character)
                      p.TopSurface = 0
                      p.BottomSurface = 0
                      p.Size = Vector3.new(2,2,2)
                      p.CanCollide = false
                      p.Anchored = true
                      p.BrickColor = BrickColor.new("Bright violet")
                      game.Debris:AddItem(p, 2)
                      p.CFrame = b.CFrame*CFrame.Angles(math.random(1,360),math.random(1,360),math.random(1,360))
                      spawn(function()
                      for i = 0,1,0.01 do
                      p.Size = p.Size+Vector3.new(12,12,12)
                      p.Transparency = i*8
                      wait()
                    end
                   end)
                      end
                      end)
                      b:Destroy()
        end
        wait(0.13)
        deb3 = false
end

b.Touched:connect(onDamage)
          


  --[[
spawn(function()
wait(3)
if touched == false then
--asd
end
end)
--]]

Terra = false
Animations = false
end
end)

Mouse.Button1Down:connect(function()
if combo == 1 and Animations == false then
Charge = true
Animations = true
wait(0.13)
Charge = false
Punch1 = true


dmg = math.random(7,15)
        for i,v in pairs(game.Workspace:GetChildren()) do
        torso = v:FindFirstChild("Torso")
                if torso and (torso.Position - Right_Arm.Position).magnitude <= 3*Size and torso.Parent.Name ~= Character.Name then
                     --[[local p = Instance.new("Part", torso.Parent)
                      p.CanCollide = false
                      p.Anchored = true
                      p.CFrame = torso.CFrame*CFrame.new(math.random(-2,2),2,math.random(-2,2))
                      p.Transparency  = 1
                      local billb = Instance.new("BillboardGui", p)
                      billb.Adornee = p
                      billb.AlwaysOnTop = true
                      billb.Enabled = true
                      local textl = Instance.new("TextLabel", billb)
                      textl.Text = tostring(dmg)--]]
                else
                       --hi just some useless code here
                end
        end
  
  

wait(0.13) 
deb = false
Punch1 = false
Animations = false
combo = combo+1

elseif combo == 2 and Animations == false then
Charge2 = true
Animations = true
wait(0.13)
Charge2 = false
Punch2 = true

  for i,v in pairs(game.Workspace:GetChildren()) do
        torso = v:FindFirstChild("Torso")
                if torso and (torso.Position - Left_Arm.Position).magnitude <= 3*Size and torso.Parent.Name ~= Character.Name then
                else
                       --hi just some useless code here
                end
        end
  
  
wait(0.16) 
deb2 = false
Punch2 = false
Animations = false
combo = combo+1
elseif combo == 4 and Animations == false then

Charge3 = true
Animations = true
wait(0.13)


Charge3 = false
Lunge1 = true
local  phitboxz3 = Instance.new("Part", Character)
phitboxz3.CanCollide = false
phitboxz3.Transparency = 1
phitboxz3.Size = Vector3.new(4,4,4)
local pweldz3 = Instance.new("Weld", Character)
pweldz3.Part0 = phitboxz3
pweldz3.Part1 = Torso
pweldz3.C0 = CFrame.new(0,-1,3)

function onDamage(Part)
        if Part.Parent:FindFirstChild("Torso") ~= nil and Part.Parent.Name ~= Character.Name and deb3 == false then
        deb3 = true
        end
        wait(0.13)
        deb3 = false
end

phitboxz3.Touched:connect(onDamage)

wait(0.13)
phitboxz3:Destroy()
deb3 = false
Lunge1 = false
Animations = false
combo = combo+1

 elseif combo == 3 and Animations == false then
 Charge4 = true
 Animations = true
 wait(0.13)
 Charge4 = false
 Uppercut1 = true
 
   for i,v in pairs(game.Workspace:GetChildren()) do
        torso = v:FindFirstChild("Torso")
                if torso and (torso.Position - Right_Arm.Position).magnitude <= 3*Size and torso.Parent.Name ~= Character.Name then
                else
                       --hi just some useless code here
                end
        end
  
  
 wait(0.13)
 Uppercut1 = false
 Charge4 = false
 Animations = false
 
 combo = combo+1
elseif combo == 5 and Animations == false then
Spin1 = true
Animations = true

spawn(function()
while Spin1 == true do
   for i,v in pairs(game.Workspace:GetChildren()) do
        torso = v:FindFirstChild("Torso")
                if torso and (torso.Position - Torso.Position).magnitude <= 7*Size and torso.Parent.Name ~= Character.Name then
                else
                       --hi just some useless code here
                end
        end
wait(0.5)
end
end)

wait(2)
Spin1 = false
Animations = false
combo = 1
end
end)

spawn(function()
while game:service'RunService'.RenderStepped:wait() do
if twist < 360 then
for i = 0,360,40 do
twist = i
game:service'RunService'.RenderStepped:wait()
end
elseif twist == 360 then
twist = 0
end
end
end)

newWeld = function(wp0, wp1, wc0x, wc0y, wc0z)
        wld = Instance.new("Weld", wp1)
        wld.Part0 = wp0
        wld.Part1 = wp1
        wld.C0 = CFrame.new(wc0x, wc0y, wc0z)
        return wld
end
 
function noOutline(part)
        Part.TopSurface, part.BottomSurface, part.LeftSurface, part.RightSurface, part.FrontSurface, part.BackSurface = 10, 10, 10, 10, 10, 10
end
 
local function Part(Color, Material, Transparency,Shape, Size, CFrame,CanCollide,Anchored,parent)
        local partie = i_new("Part",parent)
        partie.BrickColor = BrickColor.new(Color)
        partie.Material = Material
        partie.Shape = Shape
        partie.Transparency = Transparency
        partie.Size = Size
        partie.CFrame = CFrame
        partie.CanCollide = CanCollide
        partie.Anchored = Anchored
        return partie
end
        
 
 
function swait(num)
        if num == 0 or num == nil then
                game:GetService("RunService").RenderStepped:wait()
        else
                for i = 0, num do
                        game:GetService("RunService").RenderStepped:wait()
                end
        end
end
 
Humanoid.FreeFalling:connect(function(falling)
if falling then
isFalling = true
elseif not falling then
isFalling = false
end
end)
 
function mesh(Mesh, part, meshtype, meshid, offset, scale)
        local mesh = i_new(Mesh)
        mesh.Parent = part
        if Mesh == "SpecialMesh" then
                mesh.MeshType = meshtype
                mesh.MeshId = meshid
        end
        mesh.Offset = offset
        mesh.Scale = scale
        return mesh
end


function rayCast(Pos, Dir, Max, Ignore) -- Origin Position, Direction, MaxDistance, IgnoreDescendants
        return game:GetService("Workspace"):FindPartOnRay(Ray.new(Pos, Dir.unit * (Max or 999.999)), Ignore) 
end
 
function QuaternionFromCFrame(cf) 
        local mx, my, mz, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:components() 
        local trace = m00 + m11 + m22 
        if trace > 0 then 
                local s = math.sqrt(1 + trace) 
                local recip = 0.5/s 
                return (m21-m12)*recip, (m02-m20)*recip, (m10-m01)*recip, s*0.5 
        else 
                local i = 0 
                if m11 > m00 then
                        i = 1
                end
                if m22 > (i == 0 and m00 or m11) then 
                        i = 2 
                end 
                if i == 0 then 
                        local s = math.sqrt(m00-m11-m22+1) 
                        local recip = 0.5/s 
                        return 0.5*s, (m10+m01)*recip, (m20+m02)*recip, (m21-m12)*recip 
                elseif i == 1 then 
                        local s = math.sqrt(m11-m22-m00+1) 
                        local recip = 0.5/s 
                        return (m01+m10)*recip, 0.5*s, (m21+m12)*recip, (m02-m20)*recip 
                elseif i == 2 then 
                        local s = math.sqrt(m22-m00-m11+1) 
                        local recip = 0.5/s return (m02+m20)*recip, (m12+m21)*recip, 0.5*s, (m10-m01)*recip 
                end 
        end 
end
 
function QuaternionToCFrame(px, py, pz, x, y, z, w) 
        local xs, ys, zs = x + x, y + y, z + z 
        local wx, wy, wz = w*xs, w*ys, w*zs 
        local xx = x*xs 
        local xy = x*ys 
        local xz = x*zs 
        local yy = y*ys 
        local yz = y*zs 
        local zz = z*zs 
        return CFrame.new(px, py, pz,1-(yy+zz), xy - wz, xz + wy,xy + wz, 1-(xx+zz), yz - wx, xz - wy, yz + wx, 1-(xx+yy)) 
end
 
function QuaternionSlerp(a, b, t) 
        local cosTheta = a[1]*b[1] + a[2]*b[2] + a[3]*b[3] + a[4]*b[4] 
        local startInterp, finishInterp; 
        if cosTheta >= 0.0001 then 
                if (1 - cosTheta) > 0.0001 then 
                        local theta = math.acos(cosTheta) 
                        local invSinTheta = 1/math.sin(theta) 
                        startInterp = math.sin((1-t)*theta)*invSinTheta 
                        finishInterp = math.sin(t*theta)*invSinTheta  
                else 
                        startInterp = 1-t 
                        finishInterp = t 
                end 
        else 
                if (1+cosTheta) > 0.0001 then 
                        local theta = math.acos(-cosTheta) 
                        local invSinTheta = 1/math.sin(theta) 
                        startInterp = math.sin((t-1)*theta)*invSinTheta 
                        finishInterp = math.sin(t*theta)*invSinTheta 
                else 
                        startInterp = t-1 
                        finishInterp = t 
                end 
        end 
        return a[1]*startInterp + b[1]*finishInterp, a[2]*startInterp + b[2]*finishInterp, a[3]*startInterp + b[3]*finishInterp, a[4]*startInterp + b[4]*finishInterp 
end

function clerp(a, b, t) 
        local qa = {QuaternionFromCFrame(a)}
        local qb = {QuaternionFromCFrame(b)} 
        local ax, ay, az = a.x, a.y, a.z 
        local bx, by, bz = b.x, b.y, b.z
        local _t = 1-t
        return QuaternionToCFrame(_t*ax + t*bx, _t*ay + t*by, _t*az + t*bz,QuaternionSlerp(qa, qb, t)) 
end
 

wait()
function bigger (char, S)
 tor = char.Torso
 larm = char["Left Arm"]
 rarm = char["Right Arm"]
 lleg = char["Left Leg"]
 rleg = char["Right Leg"]
 head = char.Head
 root = char.HumanoidRootPart
 hum = char.Humanoid
 
 tor.Size = tor.Size*S
 larm.Size = larm.Size*S
 rarm.Size = rarm.Size*S
 lleg.Size = lleg.Size*S
 rleg.Size = rleg.Size*S
 root.Size = root.Size*S
 hum.HipHeight = hum.HipHeight*S
 hum.JumpPower = hum.JumpPower*S/1.1
 head.Mesh.Scale = head.Mesh.Scale*S
  hum.MaxHealth = 500*S
  print(hum.MaxHealth)
 for i,v in pairs (char:children()) do
 if v:IsA("Hat") then
     v.Handle.Mesh.Scale = v.Handle.Mesh.Scale*S
     
local yInc = (S-1)*.5
                v.AttachmentPos = (v.AttachmentPos * S) - (v.AttachmentUp * Vector3.new(yInc,yInc,yInc))
 
 end
 end
LA_Weld = newWeld(Torso, Left_Arm, -1.5*S, 0.5*S, 0)
Left_Arm.Weld.C1 = CFrame.new(0, 0.5*S, 0)
RA_Weld = newWeld(Torso, Right_Arm, 1.5*S, 0.5*S, 0)
Right_Arm.Weld.C1 = CFrame.new(0, 0.5*S, 0)
LL_Weld = newWeld(Torso, Left_Leg, -0.5*S, -1*S, 0)
Left_Leg.Weld.C1 = CFrame.new(0, 1*S, 0) -- Left_Leg.Weld.C1 = CFrame.new(0, 1, 0.15)
RL_Weld = newWeld(Torso, Right_Leg, 0.5*S, -1*S, 0)
Right_Leg.Weld.C1 = CFrame.new(0, 1*S, 0) -- Right_Leg.Weld.C1 = CFrame.new(0, 1, 0.15)
Torso_Weld = newWeld(rootPart, Torso, 0, -1*S, 0)
Torso.Weld.C1 = CFrame.new(0, -1*S, 0)
Head_Weld = newWeld(Torso, Head, 0, 1.5*S, 0)
end
 
bigger(Character, Size)
 
sine = 0
change = 1

 spawn(function()
 
 while wait(.7) do
 spawn(function()
 while wait(5) do
 _G.currentHealth = Humanoid.Health
 end
 end)
 if Humanoid.Health >= _G.currentHealth then
 Humanoid.Health = Humanoid.Health+Humanoid.MaxHealth/20
 end
 end
 end)
 
 function stuff(limb)
 local mainpart = Instance.new("Part", Character)
 mainpart.CanCollide = false
 local mesh = Instance.new("SpecialMesh", mainpart)
 mainpart.BrickColor = BrickColor.new("Bright yellow")
 mesh.MeshId = "http://www.roblox.com/Asset/?id=9944765"
 mesh.Scale = Vector3.new(2,2,7)
 local w1 = Instance.new("Weld", limb)
 w1.Part0 = mainpart
 w1.Part1 = limb
 w1.C0 = CFrame.Angles(math.rad(90),math.rad(180),math.rad(180)) *  CFrame.new(0,1.5,0)
 local cap = Instance.new("Part", Character)
 cap.CanCollide = false
 cap.BrickColor = BrickColor.new("Bright yellow")
 local mesh2 = Instance.new("SpecialMesh", cap)
 mesh2.MeshId = "http://www.roblox.com/Asset/?id=9944765"
 mesh2.Scale = Vector3.new(2,2,1)
 local w2 = Instance.new("Weld", mainpart)
 w2.Part0 = cap
 w2.Part1 = mainpart
 w2.C0 = CFrame.new(0,0,-0.01) * CFrame.Angles(math.rad(180),math.rad(0),math.rad(180))
  local claw1 = Instance.new("Part", Character)
  claw1.CanCollide = false
 local mesh3 = Instance.new("SpecialMesh", claw1)
 mesh3.MeshId = "http://www.roblox.com/Asset/?id=9944765"
 mesh3.Scale = Vector3.new(0.5,1,3)
  local w3 = Instance.new("Weld", mainpart)
 w3.Part0 = claw1
 w3.Part1 = cap
 w3.C0 = CFrame.new(0,-0.25,0.2)
 
   local claw2 = Instance.new("Part", Character)
   claw2.CanCollide = false
 local mesh4 = Instance.new("SpecialMesh", claw2)
 mesh4.MeshId = "http://www.roblox.com/Asset/?id=9944765"
 mesh4.Scale = Vector3.new(0.5,1,3)
  local w4 = Instance.new("Weld", mainpart)
 w4.Part0 = claw2
 w4.Part1 = cap
 w4.C0 = CFrame.new(0.5,-0.25,0.2)
 
    local claw3 = Instance.new("Part", Character)
    claw3.CanCollide = false
 local mesh5 = Instance.new("SpecialMesh", claw3)
 mesh5.MeshId = "http://www.roblox.com/Asset/?id=9944765"
 mesh5.Scale = Vector3.new(0.5,1,3)
  local w5 = Instance.new("Weld", mainpart)
 w5.Part0 = claw3
 w5.Part1 = cap
 w5.C0 = CFrame.new(-0.5,-0.25,0.2)
 
     local clawc = Instance.new("Part", Character)
clawc.TopSurface = 0
clawc.BottomSurface = 0
clawc.Size = Vector3.new(1.1,0.8,1.1)
clawc.CanCollide = false
clawc.BrickColor = BrickColor.new("Bright yellow")
  local w6 = Instance.new("Weld", mainpart)
 w6.Part0 = clawc
 w6.Part1 = limb
 
  
     local clawc1 = Instance.new("Part", Character)
clawc1.TopSurface = 0
clawc1.BottomSurface = 0
clawc1.Size = Vector3.new(0.65,0.8,0.4)
clawc1.Shape = "Ball"
clawc1.CanCollide = false
clawc1.BrickColor = BrickColor.new("Bright yellow")
  local w7 = Instance.new("Weld", mainpart)
 w7.Part0 = clawc1
 w7.Part1 = claw1
 w7.C1 = CFrame.new(0,0.2,-0.1)
 
 local clawc2 = Instance.new("Part", Character)
clawc2.TopSurface = 0
clawc2.BottomSurface = 0
clawc2.Size = Vector3.new(0.65,0.8,0.4)
clawc2.Shape = "Ball"
clawc2.CanCollide = false
clawc2.BrickColor = BrickColor.new("Bright yellow")
  local w9 = Instance.new("Weld", mainpart)
 w9.Part0 = clawc2
 w9.Part1 = claw2
 w9.C1 = CFrame.new(0,0.2,-0.1)
 
  local clawc3 = Instance.new("Part", Character)
clawc3.TopSurface = 0
clawc3.BottomSurface = 0
clawc3.Size = Vector3.new(0.65,0.8,0.4)
clawc3.Shape = "Ball"
clawc3.CanCollide = false
clawc3.BrickColor = BrickColor.new("Bright yellow")
  local w10 = Instance.new("Weld", mainpart)
 w10.Part0 = clawc3
 w10.Part1 = claw3
 w10.C1 = CFrame.new(0,0.2,-0.1)
 
 end
 
  stuff(Right_Arm)
  stuff(Left_Arm)
 
 game.Lighting.Outlines = false
 

 game:GetService("RunService").Stepped:connect(function()
--Camera.CameraSubject = Torso
        Angle = (Angle % 100) + angleSpeed/10
        Axis = (Axis % 100) + axisSpeed/10
        walkingMagnitude = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z).magnitude
        jumpVel = Torso.Velocity.Y
        sine = change + sine
 
        if (Humanoid.Jump) and jumpVel > 1 then
                currentAnim = "Jumping"
        elseif walkingMagnitude < 2 then
                currentAnim = "Idling"
        elseif isSprinting == true then
                currentAnim = "Sprinting"
        elseif walkingMagnitude > 2 then
                isSprinting = false
                currentAnim = "Walking"
        elseif isAttacking == true then
                currentAnim = "Attacking"
        end
 
 
        if currentAnim == "Jumping" and Animations == false then
                angleSpeed = 2
                axisSpeed = 2
                change = 0.5
                RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(10)), 0.15)
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, 0.5*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(-10)), 0.15)
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(-5)), 0.15)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(5)), 0.15)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, 0) * c_angles(math.rad(9), math.rad(0), math.rad(0)), 0.15)  
  

       elseif isFalling == true and Animations == false then
                angleSpeed = 2
                axisSpeed = 2
                change = 0.5
                RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(50)), 0.15)
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, 0.5*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(-50)), 0.15)
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, -0.5*Size) * c_angles(math.rad(-20), math.rad(0), math.rad(-0)), 0.15)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, -0.5*Size) * c_angles(math.rad(-20), math.rad(0), math.rad(0)), 0.15)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, 0) * c_angles(math.rad(-15), math.rad(0), math.rad(0)), 0.15)    
 
        elseif currentAnim == "Idling" and Animations == false then
                angleSpeed = 1
                axisSpeed = 1
                change = 0.5

                        RA_Weld.C0            = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size+-0.02*math.sin(tick()),0) * c_angles(math.rad(20)+math.rad(5*math.sin(tick()*1.5)), math.rad(20), math.rad(20)), 0.15)
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, 0.5*Size+-0.05*math.sin(tick()/1.5),0) * c_angles(math.rad(20)+math.rad(-5*math.sin(tick()*1.5)), math.rad(-20), math.rad(-20)), 0.15)
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -0.9*Size-0.1*math.sin(tick()*4), 0) * c_angles(math.rad(0),math.rad(15),math.rad(-5)), 0.15)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -0.9*Size-0.1*math.sin(tick()*4), 0)* c_angles(math.rad(0),math.rad(-15),math.rad(5)), 0.15)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0*Size, -1.2*Size+0.1*math.sin(tick()*4), 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, 0) * c_angles(math.rad(0), math.rad(-10), math.rad(0)), 0.15)    
                


        elseif currentAnim == "Sprinting" and Animations == false then
                angleSpeed = 1        
                axisSpeed = 1
                Humanoid.WalkSpeed = 72*Size
                
                        RA_Weld.C0            = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size,0) * c_angles(math.rad(-20), math.rad(0), math.rad(10)), 0.15)
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, 0.5*Size,0) * c_angles(math.rad(-20), math.rad(0), math.rad(-15)), 0.15)
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0) * c_angles(math.rad(-10),math.rad(0),math.rad(0)), 0.15)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -.1*Size, -0.3*Size)* c_angles(math.rad(5),math.rad(0),math.rad(0)), 0.15)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0*Size, -1*Size, 0*Size) * c_angles(math.rad(-80), math.sin(rootPart.RotVelocity.y/10)/2, 0), 0.15)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.4*Size, 0.4*Size) * c_angles(math.rad(80), math.rad(0), math.rad(0)), 0.15)    

       elseif Charge == true  then
       
                                      RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.7*Size, -0.25*Size) * c_angles(math.rad(-30), math.rad(35), math.rad(40)), 0.5)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.2*Size, .3*Size, -.6*Size) * c_angles(math.rad(90), math.rad(0), math.rad(20)), 0.5)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(-10), math.rad(0), math.rad(-10)), 0.5)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(10), math.rad(0), math.rad(10)), 0.5)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-5), math.rad(20), math.rad(0)), 0.5)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(-20), math.rad(0)), 0.35)    
      
      elseif Charge4 == true then
      
                                            RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.7*Size, -0.25*Size) * c_angles(math.rad(-40), math.rad(35), math.rad(40)), 0.5)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.2*Size, .3*Size, -.6*Size) * c_angles(math.rad(30), math.rad(0), math.rad(20)), 0.5)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(-10), math.rad(0), math.rad(-10)), 0.5)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(10), math.rad(0), math.rad(10)), 0.5)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-5), math.rad(20), math.rad(0)), 0.5)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(-20), math.rad(0)), 0.35)    
       
       elseif Uppercut1 == true then
       
                              RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.7*Size, -0.25*Size) * c_angles(math.rad(150), math.rad(0), math.rad(0)), 0.65)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.2*Size, .3*Size, -.6*Size) * c_angles(math.rad(60), math.rad(0), math.rad(-50)), 0.65)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size+0.1*math.sin(tick()*2), 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(-10)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size+0.1*math.sin(tick()*2), 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(10)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-5), math.rad(90), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(-90), math.rad(0)), 0.55)    
       
        elseif Punch1 == true then
        


             -- First Punch (All C1, Lasts 3 Frames)
                       RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.7*Size, -0.25*Size) * c_angles(math.rad(-60), math.rad(45), math.rad(170)), 0.65)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.2*Size, .3*Size, -.6*Size) * c_angles(math.rad(90), math.rad(0), math.rad(50)), 0.65)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size+0.1*math.sin(tick()*2), 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(-10)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size+0.1*math.sin(tick()*2), 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(10)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-5), math.rad(90), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(-90), math.rad(0)), 0.55)    

       elseif Punch2 == true then
       
       RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.2*Size, .3*Size, -.6*Size) * c_angles(math.rad(90), math.rad(0), math.rad(-50)), 0.65)
                
                       LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, 0.7*Size, -0.25*Size) * c_angles(math.rad(0), math.rad(-5), math.rad(-110)), 0.65)
                       
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(-10)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(10)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-5), math.rad(-90), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(90), math.rad(0)), 0.55)   

     elseif Terra == true then
     
     
                                                 RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size, 0*Size) * c_angles(math.rad(90), math.rad(90), math.rad(20)), 0.65)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, .5*Size, 0*Size) * c_angles(math.rad(90), math.rad(-90), math.rad(-20)), 0.65)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.55)    

      elseif Charge3 == true then
      
                                            RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size, 0.5*Size) * c_angles(math.rad(90), math.rad(180), math.rad(0)), 0.65)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, .5*Size, 0.5*Size) * c_angles(math.rad(90), math.rad(180), math.rad(0)), 0.65)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(-40), math.rad(0), math.rad(-10)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(-40), math.rad(0), math.rad(10)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(40), math.rad(0), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(-20), math.rad(0)), 0.55)    
 
  elseif Lunge1 == true then
  
                                              RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size, -0.5*Size) * c_angles(math.rad(90), math.rad(180), math.rad(0)), 0.65)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, .5*Size, -0.5*Size) * c_angles(math.rad(90), math.rad(180), math.rad(0)), 0.65)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(40), math.rad(0), math.rad(-15)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(40), math.rad(0), math.rad(15)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-40), math.rad(0), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-25), math.rad(0), math.rad(0)), 0.55)    

        elseif Spin1 == true then
        
                                                      RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(90)), 0.15)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, .5*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(-90)), 0.15)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-15), math.rad(twist), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, 0*Size) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)    


        elseif Charge2 == true then
        
                                              RA_Weld.C0                = clerp(RA_Weld.C0, c_new(1.5*Size, 0.7*Size, -0.25*Size) * c_angles(math.rad(-30), math.rad(35), math.rad(40)), 0.65)
                       
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.2*Size, .3*Size, 0.5*Size) * c_angles(math.rad(90), math.rad(0), math.rad(20)), 0.65)
                
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(-10), math.rad(0), math.rad(-10)), 0.65)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size, 0*Size) * c_angles(math.rad(10), math.rad(0), math.rad(10)), 0.65)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0, -1*Size, 0) * c_angles(math.rad(-5), math.rad(-20), math.rad(0)), 0.65)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, -0.2*Size) * c_angles(math.rad(-20), math.rad(20), math.rad(0)), 0.55)    


        elseif currentAnim == "Walking" and Animations == false then
                angleSpeed = 1
                axisSpeed = 1
                Humanoid.WalkSpeed = 19*Size
                
                        RA_Weld.C0            = clerp(RA_Weld.C0, c_new(1.5*Size, 0.5*Size+-0.02*math.sin(tick()), 0) * c_angles(math.rad(25), math.rad(0), math.rad(25)), 0.15)
                LA_Weld.C0                = clerp(LA_Weld.C0, c_new(-1.5*Size, 0.5*Size+-0.05*math.sin(tick()/1.5), 0) * c_angles(math.rad(5), math.rad(0), math.rad(-25)), 0.15)
                LL_Weld.C0                = clerp(LL_Weld.C0, c_new(-0.5*Size, -1*Size+0.2*math.sin(sine/3)*1.2, math.sin(sine/5)/9) * c_angles(math.rad(60*math.sin(tick()*8))*1.5,math.rad(0),math.rad(-1)), 0.15)
                RL_Weld.C0                 = clerp(RL_Weld.C0, c_new(0.5*Size, -1*Size+0.2*math.sin(sine/3)*1.2, math.sin(sine/5)/9)* c_angles(math.rad(-60*math.sin(tick()*8)),math.rad(0),math.rad(1)), 0.15)
                Torso_Weld.C0         = clerp(Torso_Weld.C0, c_new(0*Size, -1*Size, 0*Size) * c_angles(math.rad(-5), math.rad(0), math.sin(rootPart.RotVelocity.y/20)/7), 0.15)
Head_Weld.C0 = clerp(Head_Weld.C0, c_new(0, 1.5*Size, 0) * c_angles(math.rad(0), math.rad(0), math.rad(0)), 0.15)     
                
                end
end)

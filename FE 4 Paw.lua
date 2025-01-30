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
            Part0.Velocity = framevel
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

--services
local debrs = game:GetService("Debris")

--BasicFunctions
local ins = Instance.new
local v3 = Vector3.new
local cf = CFrame.new
local angles = CFrame.Angles
local rad = math.rad
local huge = math.huge
local cos = math.cos
local sin = math.sin
local tan = math.tan
local ray = Ray.new
local random = math.random
local ud = UDim.new
local ud2 = UDim2.new
local c3 = Color3.new
local rgb = Color3.fromRGB
local bc = BrickColor.new

--Variables
local plr = game.Players.LocalPlayer
local plrg = plr.PlayerGui
local char = plr.Character
local h = char.Head
local t = char.Torso
local ra = char["Right Arm"]
local la = char["Left Arm"]
local rl = char["Right Leg"]
local ll = char["Left Leg"]
local rut = char.HumanoidRootPart
local hum = char:FindFirstChildOfClass("Humanoid")
local necno = t.Neck
local rutjno = rut.RootJoint
local rsno = t["Right Shoulder"]
local lsno = t["Left Shoulder"]
local rhno = t["Right Hip"]
local lhno = t["Left Hip"]
--
local change = 1
local sine = 0
local animspeed = .1
local walkanimspeed = .2
local idledevider = 15
local walkDivider = 7.5
local num = 1
local hugTime = 4
local using = false
local takingAStep = false
local sitting = false
local lying = false
local canHug = false
local hugging = false
local owowhat = false
local canOwo = false
local holdingItem = nil
local anim = "idle"
local asset = "rbxassetid://"
--
local stepsounds = {
Grass = asset.."1201103066",
Sand = asset.."1436385526",
Plastic = asset.."1569994049",
Stone = asset.."1201103555",
Wood = asset.."1201103959",
Pebble = asset.."1201103211",
Ice = asset.."265653271",
Glass = asset.."145180170",
Metal = asset.."379482691"
}
--
necc0,necc1=necno.C0,necno.C1
rutjc0,rutjc1=rutjno.C0,rutjno.C1
rsc0,rsc1=rsno.C0,rsno.C1
lsc0,lsc1=lsno.C0,lsno.C1
rhc0,rhc1=rhno.C0,rhno.C1
lhc0,lhc1=lhno.C0,lhno.C1


if char:FindFirstChild("Animate") then
char.Animate:Destroy()
end
if hum:FindFirstChildOfClass("Animator") then
char.Humanoid.Animator:Destroy()
end

--Creating new joints
h.Size = v3(1,1,1)
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

--Some creates
--Models
--Parts
--Welds
--Sounds
local footstepsound = ins("Sound",t)
footstepsound.Volume = 1
footstepsound.SoundId = stepsounds.Grass

--Connecting sprint
local rem = ins("RemoteEvent",char) rem.Name = "SprintEvent"
local bRem = ins("BindableEvent",char) bRem.Name = "-w-"
local huggingDeb = ins("BoolValue",bRem) huggingDeb.Name = "Deb"

bRem.Event:Connect(function(character)
	hug(character)
end)

function remove(instance,time)
	time = time or 0
    debrs:AddItem(instance,time)
end

function createWeld(p1,p2,c0,c1)
	local weld = ins("Motor6D",p1)
	weld.Part0 = p1
	weld.Part1 = p2
	weld.C0 = c0
	weld.C1 = c1
	return weld
end

function createBVel(part,direction,force,timeBeforeRemove)
	local vel = ins("BodyVelocity",part)
	vel.MaxForce = v3(huge,huge,huge)
	vel.Velocity = direction * force
	remove(vel,timeBeforeRemove)
end

function hug(whomst)
	if whomst then
		local tors = whomst:FindFirstChild("Torso") or whomst:FindFirstChild("UpperTorso")
		if tors then
			local hRem = whomst:FindFirstChild("-w-")
			if hRem and not hRem:FindFirstChild("Deb").Value then
				hRem:Fire(char)
			end
			huggingDeb.Value = true
			anim = "idle"
			canHug = false
			hugging = true
			local tWeld = createWeld(t,tors,cf(0,0,-tors.Size.z) * angles(rad(0),rad(180),rad(0)),cf(0,0,0))
			whomst:FindFirstChildOfClass("Humanoid").PlatformStand = true
			hum.PlatformStand = true
			createBVel(t,rut.CFrame.LookVector + v3(0,.65,0),40,.025)
			remove(tWeld,hugTime+.25)
			coroutine.wrap(function()
				wait(hugTime+.25)
				whomst:FindFirstChildOfClass("Humanoid").PlatformStand = false
				hum.PlatformStand = false
				rut.CFrame = cf(rut.CFrame.p,v3(nil,rut.CFrame.y,rut.CFrame.z)) * cf(0,2,0)
				huggingDeb.Value = false
				hugging = false
			end)()
			coroutine.wrap(function()
				for i = 0,1,.075 do
					rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(0),rad(0),rad(0)),walkanimspeed)
					nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(20),rad(0),rad(50)),walkanimspeed)
					rs.C0 = rs.C0:Lerp(rsc0 * cf(.65,0,-.2) * angles(rad(2.5),rad(79),rad(96)),walkanimspeed)
					ls.C0 = ls.C0:Lerp(lsc0 * cf(-.65,0,-.2) * angles(rad(-2.5),rad(-76),rad(-86)),walkanimspeed)
					rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(0),rad(-5),rad(-5)),walkanimspeed)
					lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(0),rad(5),rad(5)),walkanimspeed)
					rutj.C1 = rutj.C1:Lerp(rutjc1,animspeed)
					nec.C1 = nec.C1:Lerp(necc1,animspeed)
					rs.C1 = rs.C1:Lerp(rsc1,animspeed)
					ls.C1 = ls.C1:Lerp(lsc1,animspeed)
					rh.C1 = rh.C1:Lerp(rhc1,animspeed)
					lh.C1 = lh.C1:Lerp(lhc1,animspeed)
					swait()
				end
			end)()
		end
	end
end

function grabowo(who)
	if who then
		local tors = who:FindFirstChild("Torso") or who:FindFirstChild("UpperTorso")
		local huma = who:FindFirstChildOfClass("Humanoid")
		if tors and huma then
			local hit,pos,nid = rayc(tors.Position,v3(0,-1000000,0),{char,who},5)
			local oldcf = tors.CFrame * cf(0,0,-9999999)
			local oldRot = tors.Orientation
			if hit then
				anim = "idle"
				using = true
				owowhat = true
				tors.Anchored = true
				hum.PlatformStand = true
				huma.PlatformStand = true
				local gyro = ins("BodyGyro",tors)
				local ccf = cf(pos) * cf(0,.5,0) * angles(rad(90),rad(0),rad(oldRot.Y))
				tors.CFrame = ccf
				gyro.MaxTorque = v3(0,math.huge,0)
				gyro.CFrame = ccf
				local we = createWeld(tors,rut,cf(0,0,-1.5) * angles(rad(0),rad(180),rad(0)),cf(0,0,0))
				for i = 0,1,.075 do
					huma.PlatformStand = true
					hum.PlatformStand = true
					tors.Anchored = true
					rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,0) * angles(rad(20),rad(0),rad(0)),walkanimspeed)
					nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(30),rad(0),rad(0)),walkanimspeed)
					rs.C0 = rs.C0:Lerp(rsc0 * cf(0,.1,0) * angles(rad(0),rad(0),rad(75)),walkanimspeed)
					ls.C0 = ls.C0:Lerp(lsc0 * cf(0,.1,0) * angles(rad(0),rad(0),rad(-70)),walkanimspeed)
					rh.C0 = rh.C0:Lerp(rhc0 * cf(.25,0,0) * angles(rad(0),rad(-5),rad(-17.5)),walkanimspeed)
					lh.C0 = lh.C0:Lerp(lhc0 * cf(-.25,0,0) * angles(rad(0),rad(5),rad(15)),walkanimspeed)
					rutj.C1 = rutj.C1:Lerp(rutjc1,animspeed)
					nec.C1 = nec.C1:Lerp(necc1,animspeed)
					rs.C1 = rs.C1:Lerp(rsc1,animspeed)
					ls.C1 = ls.C1:Lerp(lsc1,animspeed)
					rh.C1 = rh.C1:Lerp(rhc1,animspeed)
					lh.C1 = lh.C1:Lerp(lhc1,animspeed)
					swait()
				end
				wait(.35)
				for i = 0,1,.035 do
					huma.PlatformStand = true
					hum.PlatformStand = true
					tors.Anchored = true
					rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,.25,2.5) * angles(rad(15),rad(0),rad(0)),animspeed)
					nec.C0 = nec.C0:Lerp(necc0 * cf(0,.15,0) * angles(rad(-5),rad(0),rad(0)),animspeed)
					rs.C0 = rs.C0:Lerp(rsc0 * cf(0,.1,0) * angles(rad(0),rad(0),rad(145)),animspeed)
					ls.C0 = ls.C0:Lerp(lsc0 * cf(0,.1,0) * angles(rad(0),rad(0),rad(-150)),animspeed)
					rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,0,0) * angles(rad(0),rad(-5),rad(-10)),animspeed)
					lh.C0 = lh.C0:Lerp(lhc0 * cf(-.35,0,0) * angles(rad(0),rad(5),rad(7.5)),animspeed)
					rutj.C1 = rutj.C1:Lerp(rutjc1,animspeed)
					nec.C1 = nec.C1:Lerp(necc1,animspeed)
					rs.C1 = rs.C1:Lerp(rsc1,animspeed)
					ls.C1 = ls.C1:Lerp(lsc1,animspeed)
					rh.C1 = rh.C1:Lerp(rhc1,animspeed)
					lh.C1 = lh.C1:Lerp(lhc1,animspeed)
					swait()
				end
				for i = 0,1,.05 do
					huma.PlatformStand = true
					hum.PlatformStand = true
					tors.Anchored = true
					rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,2.35) * angles(rad(20),rad(0),rad(0)),animspeed)
					nec.C0 = nec.C0:Lerp(necc0 * cf(0,.15,0) * angles(rad(30),rad(0),rad(0)),animspeed)
					rs.C0 = rs.C0:Lerp(rsc0 * cf(.45,-.25,-.1) * angles(rad(-30),rad(0),rad(165)),animspeed)
					ls.C0 = ls.C0:Lerp(lsc0 * cf(-.45,-.25,-.1) * angles(rad(-30),rad(0),rad(-170)),animspeed)
					rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,0,0) * angles(rad(0),rad(-5),rad(-15)),animspeed)
					lh.C0 = lh.C0:Lerp(lhc0 * cf(-.35,0,0) * angles(rad(0),rad(5),rad(12.5)),animspeed)
					rutj.C1 = rutj.C1:Lerp(rutjc1,animspeed)
					nec.C1 = nec.C1:Lerp(necc1,animspeed)
					rs.C1 = rs.C1:Lerp(rsc1,animspeed)
					ls.C1 = ls.C1:Lerp(lsc1,animspeed)
					rh.C1 = rh.C1:Lerp(rhc1,animspeed)
					lh.C1 = lh.C1:Lerp(lhc1,animspeed)
					swait()
				end
				local val = 0
				local s = 0
				local c = 2
				local ended = false
				repeat
					rut.Velocity = v3(0,0,0)
					tors.Velocity = v3(0,0,0)
					val = val + 2
					if val > 6500 then
						owowhat = false
						ended = true
					end
					s = s + c
					rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,sin(s/20)/35,0) * angles(sin(s/20) * rad(.5),rad(0),rad(0)),animspeed)
					nec.C1 = nec.C1:Lerp(necc1 * cf(0,-sin(s/20)/9,0) * angles(cos(s/20) * rad(2.5),rad(0),rad(0)),animspeed)
					rs.C1 = rs.C1:Lerp(rsc1 * cf(0,sin(s/20)/35,0) * angles(rad(0),rad(0),sin(s/20) * rad(.5)),animspeed)
					ls.C1 = ls.C1:Lerp(lsc1 * cf(0,sin(s/20)/35,0) * angles(rad(0),rad(0),-sin(s/20) * rad(.5)),animspeed)
					rh.C1 = rh.C1:Lerp(rhc1 * cf(0,sin(s/20)/35,0) * angles(rad(0),rad(0),-sin(s/20) * rad(1.5)),animspeed)
					lh.C1 = lh.C1:Lerp(lhc1 * cf(0,sin(s/20)/35,0) * angles(rad(0),rad(0),sin(s/20) * rad(1.5)),animspeed)
					swait()
				until not owowhat or not who.Parent
				if ended then
					for i = 0,1,.005 do
						using = true
						huma.PlatformStand = true
						hum.PlatformStand = true
						tors.Anchored = true
						rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,0,2.5) * angles(rad(20),rad(0),rad(0)),animspeed)
						nec.C0 = nec.C0:Lerp(necc0 * cf(0,.15,0) * angles(rad(25),rad(0),rad(0)),animspeed)
						rs.C0 = rs.C0:Lerp(rsc0 * cf(.45,-.25,-.1) * angles(rad(-30),rad(0),rad(165)),animspeed)
						ls.C0 = ls.C0:Lerp(lsc0 * cf(-.45,-.25,-.1) * angles(rad(-30),rad(0),rad(-170)),animspeed)
						rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,0,0) * angles(rad(0),rad(-5),rad(-15)),animspeed)
						lh.C0 = lh.C0:Lerp(lhc0 * cf(-.35,0,0) * angles(rad(0),rad(5),rad(12.5)),animspeed)
						swait()
					end
					for i = 0,1,.075 do
						using = true
						huma.PlatformStand = true
						hum.PlatformStand = true
						tors.Anchored = true
						rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,-.15,2.5) * angles(rad(30),rad(0),rad(0)),walkanimspeed)
						nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(10),rad(0),rad(0)),walkanimspeed)
						rs.C0 = rs.C0:Lerp(rsc0 * cf(0,.1,0) * angles(rad(0),rad(0),rad(125)),walkanimspeed)
						ls.C0 = ls.C0:Lerp(lsc0 * cf(0,.1,0) * angles(rad(0),rad(0),rad(-130)),walkanimspeed)
						rh.C0 = rh.C0:Lerp(rhc0 * cf(.15,0,0) * angles(rad(0),rad(-5),rad(-30)),walkanimspeed)
						lh.C0 = lh.C0:Lerp(lhc0 * cf(-.15,0,0) * angles(rad(0),rad(5),rad(32.5)),walkanimspeed)
						swait()
					end
				end
				remove(we)
				remove(gyro)
				rut.CFrame = rut.CFrame * cf(0,0,2)
				hum.PlatformStand = false
				rut.Anchored = false
				coroutine.wrap(function()
					wait(.25)
					using = false
					rut.Anchored = false
					wait(.25)
					tors.Anchored = false
					huma.PlatformStand = false
				end)()
			end
		end
	end
end

function sit()
	using = true
	sitting = true
	lying = false
	anim = "idle"
	for i = 0,1,.025 do
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2,.9) * angles(rad(-30),rad(0),rad(0)) * cf(0,-.2,-.1),animspeed)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-10),rad(0),rad(0)),animspeed)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(.35,-.25,-.45) * angles(rad(10),rad(25),rad(36)),animspeed)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(-.35,-.25,-.45) * angles(rad(10),rad(-25),rad(-33)),animspeed)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,-.1,0) * angles(rad(25),rad(-10),rad(120)),animspeed)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,-.1,0) * angles(rad(25),rad(10),rad(-120)),animspeed)
		swait()
	end
	sitting = true
	using = false
end
function lieDown()
	using = true
	lying = true
	sitting = false
	anim = "idle"
	for i = 0,1,.025 do
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2.45,0) * angles(rad(-90),rad(0),rad(0)),animspeed)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-35),rad(0),rad(55)),animspeed)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,.35,-.35) * angles(rad(-25),rad(15),rad(176)),animspeed)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,.35,-.35) * angles(rad(-25),rad(-15),rad(-178)),animspeed)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(-5),rad(-5),rad(0)),animspeed)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(-5),rad(5),rad(0)),animspeed)
		swait()
	end
	using = false
end

function jumpHugAnim()
	using = true
	createBVel(t,rut.CFrame.LookVector + v3(0,.4,0),60,.1)
	canHug = true
	for i = 0,1,.075 do
		if not canHug then
			break
		end
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2,0) * angles(rad(-70),rad(0),rad(0)),walkanimspeed)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-70),rad(0),rad(0)),walkanimspeed)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,.15,0) * angles(rad(0),rad(0),rad(171)),walkanimspeed)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,.15,0) * angles(rad(0),rad(0),rad(-169)),walkanimspeed)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(0),rad(-5),rad(-5)),walkanimspeed)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(0),rad(5),rad(5)),walkanimspeed)
		rutj.C1 = rutj.C1:Lerp(rutjc1,animspeed)
		nec.C1 = nec.C1:Lerp(necc1,animspeed)
		rs.C1 = rs.C1:Lerp(rsc1,animspeed)
		ls.C1 = ls.C1:Lerp(lsc1,animspeed)
		rh.C1 = rh.C1:Lerp(rhc1,animspeed)
		lh.C1 = lh.C1:Lerp(lhc1,animspeed)
		swait()
	end
	if canHug then
		wait(.25)
		using = false
	else
		wait(hugTime)
		using = false
	end
	canHug = false
end

function jumpowo()
	using = true
	canOwo = true
	for i = 0,1,.075 do
		if not canOwo or owowhat then
			break
		end
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2,0) * angles(rad(-70),rad(0),rad(0)),walkanimspeed)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-70),rad(0),rad(0)),walkanimspeed)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(0,.15,0) * angles(rad(0),rad(0),rad(171)),walkanimspeed)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(0,.15,0) * angles(rad(0),rad(0),rad(-169)),walkanimspeed)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(0,0,0) * angles(rad(0),rad(-5),rad(-5)),walkanimspeed)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(0,0,0) * angles(rad(0),rad(5),rad(5)),walkanimspeed)
		rutj.C1 = rutj.C1:Lerp(rutjc1,animspeed)
		nec.C1 = nec.C1:Lerp(necc1,animspeed)
		rs.C1 = rs.C1:Lerp(rsc1,animspeed)
		ls.C1 = ls.C1:Lerp(lsc1,animspeed)
		rh.C1 = rh.C1:Lerp(rhc1,animspeed)
		lh.C1 = lh.C1:Lerp(lhc1,animspeed)
		swait()
	end
	if canOwo then
		wait(.25)
		using = false
	end
	canOwo = false
end

function unsit()
	anim = "idle"
	sitting = false
	using = false
end
function unlie()
	anim = "idle"
	lying = false
	using = false
end

function owo()
	local uwu = sound(8679659744,1,1,h,5)
	remove(uwu,.75)
end

function grabThing()
	for i = 0,1,.025 do
		rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2,0) * angles(rad(-70),rad(0),rad(0)),animspeed)
		nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-60),rad(0),rad(0)),animspeed)
		rs.C0 = rs.C0:Lerp(rsc0 * cf(-.05,.1,-.2) * angles(rad(2.5),rad(-5),rad(71)),animspeed)
		ls.C0 = ls.C0:Lerp(lsc0 * cf(.05,.1,-.2) * angles(rad(2.5),rad(5),rad(-68)),animspeed)
		rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,.45,0) * angles(rad(-3),rad(-5),rad(-15)),animspeed)
		lh.C0 = lh.C0:Lerp(lhc0 * cf(-.5,.5,0) * angles(rad(-3),rad(5),rad(21)),animspeed)
		swait()
	end
end

local mouse = plr:GetMouse()
mouse.KeyDown:Connect(function(key)
	if key == "z" and sitting == false then
		sit()
	elseif key == "z" and sitting == true then
		unsit()
	end
	if key == "x" and lying == false then
		lieDown()
	elseif key == "x" and lying == true then
		unlie()
	end
	if key == "f" then
		jumpHugAnim()
	end
	if key == "t" then
		owo()
	end
	if key == "p" then
		jumpowo()		
	end
end)

h.Touched:Connect(function(hit)
	if canHug then
		if hit.Parent:FindFirstChildOfClass("Humanoid") then
			hug(hit.Parent)
		end
	elseif canOwo then
		if hit.Parent:FindFirstChildOfClass("Humanoid") then
			grabowo(hit.Parent)
		end
	end
end)

function sound(id,vol,pitch,parent,maxdist)
	local newsound
	local mdist = 30 or maxdist
	newsound = Instance.new("Sound",parent)
	newsound.EmitterSize = mdist
	newsound.Volume = vol
	newsound.SoundId = "rbxassetid://"..id
	newsound.Pitch = pitch
	newsound:Play()
	coroutine.resume(coroutine.create(function()
		wait(.1)
		remove(newsound,newsound.TimeLength/newsound.Pitch)
	end))
	return newsound
end

function swait()
	game:GetService("RunService").Stepped:Wait()
end

function rayc(spos,direc,ignore,dist)
    local rai = ray(spos,direc.Unit * dist)
    local rhit,rpos,rrot = workspace:FindPartOnRayWithIgnoreList(rai,ignore,false,false)
    return rhit,rpos,rrot
end

function changesound(hit)
if hit then
	if hit.Material == Enum.Material.Sand then
		footstepsound.SoundId = stepsounds.Sand
		footstepsound.Volume = .5
	elseif hit.Material == Enum.Material.Grass or hit.Material == Enum.Material.Fabric then
		footstepsound.SoundId = stepsounds.Grass
		footstepsound.Volume = 1.5
	elseif hit.Material == Enum.Material.Granite or hit.Material == Enum.Material.Slate or hit.Material == Enum.Material.Concrete or hit.Material == Enum.Material.Marble or hit.Material == Enum.Material.Brick or hit.Material == Enum.Material.Cobblestone then
		footstepsound.SoundId = stepsounds.Stone
		footstepsound.Volume = .5
	elseif hit.Material == Enum.Material.Plastic or hit.Material == Enum.Material.SmoothPlastic or hit.Material == Enum.Material.Neon then
		footstepsound.SoundId = stepsounds.Plastic
		footstepsound.Volume = 1
	elseif hit.Material == Enum.Material.Wood or hit.Material == Enum.Material.WoodPlanks then
		footstepsound.SoundId = stepsounds.Wood
		footstepsound.Volume = .5
	elseif hit.Material == Enum.Material.Ice then
		footstepsound.SoundId = stepsounds.Ice
		footstepsound.Volume = 2
	elseif hit.Material == Enum.Material.Pebble then
		footstepsound.SoundId = stepsounds.Pebble
		footstepsound.Volume = .5
	elseif hit.Material == Enum.Material.Glass then
		footstepsound.SoundId = stepsounds.Glass
		footstepsound.Volume = .5
	elseif hit.Material == Enum.Material.Metal or hit.Material == Enum.Material.DiamondPlate or  hit.Material == Enum.Material.CorrodedMetal then
		footstepsound.SoundId = stepsounds.Metal
		footstepsound.Volume = .5
	end
	end
end

coroutine.wrap(function()
	while true do
		if not footstepsound or not footstepsound.Parent then
			footstepsound = ins("Sound",t)
			footstepsound.Volume = 1
			footstepsound.SoundId = stepsounds.Grass
		end
		local hit,pos,fromNormalId = rayc(rut.Position - v3(0,2,0),v3(rut.Position.x,-10000,rut.Position.z),{char},1.85)
		if hit then
			changesound(hit)
		end
		local rutHorVel = (rut.Velocity * v3(1,0,1)).Magnitude
		local rutVerVel = rut.Velocity.y
		if not takingAStep then
			sine = sine + change
		end
		if not sitting and not lying then
			hum.WalkSpeed = 8
			hum.JumpPower = 35
		else
			hum.WalkSpeed = 0
			hum.JumpPower = 0
		end
		local Ccf=rut.CFrame
		local Walktest1 = hum.MoveDirection*Ccf.LookVector
		local Walktest2 = hum.MoveDirection*Ccf.RightVector
		local rotfb = Walktest1.X+Walktest1.Z
		local rotrl = Walktest2.X+Walktest2.Z
		if hugging then
			nec.C1 = nec.C1:Lerp(necc1 * angles(rad(0),rad(0),cos(sine/12.5)/1.5 * rad(15)),animspeed)
		end
		if not hugging then
			if anim == "idle" and hit then
				rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,0,sin(sine/idledevider)/20) * angles(sin(sine/idledevider)/20 * rad(15),0,rad(0)),animspeed)
				nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(-sin(sine/idledevider)/20 * rad(15),rad(0),sin(sine/(idledevider*2))/20 * rad(25)),animspeed)
				rs.C1 = rs.C1:Lerp(rsc1 * cf(0,sin(sine/idledevider)/20,0) * angles(sin(sine/idledevider)/20 * rad(15),rad(0),rad(0)),animspeed)
				ls.C1 = ls.C1:Lerp(lsc1 * cf(0,sin(sine/idledevider)/20,0) * angles(sin(sine/idledevider)/20 * rad(15),rad(0),rad(0)),animspeed)
				if not sitting then
					rh.C1 = rh.C1:Lerp(rhc1 * cf(-sin(sine/idledevider)/20,0,0) * angles(sin(sine/idledevider)/20 * rad(15),rad(0),rad(0)),animspeed)
					lh.C1 = lh.C1:Lerp(lhc1 * cf(sin(sine/idledevider)/20,0,0) * angles(sin(sine/idledevider)/20 * rad(15),rad(0),rad(0)),animspeed)
				else
					rh.C1 = rh.C1:Lerp(rhc1 * cf(sin(sine/idledevider)/20,0,0) * angles(sin(sine/idledevider)/20 * rad(15),rad(0),rad(0)),animspeed)
					lh.C1 = lh.C1:Lerp(lhc1 * cf(-sin(sine/idledevider)/20,0,0) * angles(sin(sine/idledevider)/20 * rad(15),rad(0),rad(0)),animspeed)
				end
			elseif anim == "walk" and hit then
				coroutine.resume(coroutine.create(function()
					if not takingAStep then
						takingAStep = true
						for i = 0,1,.015 + walkanimspeed do
							if anim ~= "walk" then
								break
							end
							rutj.C1 = rutj.C1:Lerp(rutjc1 * cf(0,0,sin(sine/(walkDivider/2))/10) * angles(sin(sine/(walkDivider/2))/20 * rad(15),sin(sine/walkDivider)/20 * rad(15) + rut.RotVelocity.y/75 - rotrl/7.5,rad(0)),walkanimspeed)
							nec.C1 = nec.C1:Lerp(necc1 * cf(0,0,0) * angles(-sin(sine/walkDivider)/10 * rad(15),sin(sine/walkDivider)/10 * rad(25),sin(sine/walkDivider)/20 * rad(25) + rut.RotVelocity.y/75 + rotrl/2.5),walkanimspeed)
							rs.C1 = rs.C1:Lerp(rsc1 * cf(-cos(sine/walkDivider)/8.5,-cos(sine/walkDivider)/5,0) * angles(rotrl/7 + (sin(sine/walkDivider)/1.5)*rotrl * rad(35),rad((-sin(sine/walkDivider))*rotfb * rad(20)),(-sin(sine/walkDivider)/1.5)*rotfb * rad(35)),walkanimspeed)
							ls.C1 = ls.C1:Lerp(lsc1 * cf(-cos(sine/walkDivider)/8.5,cos(sine/walkDivider)/5,0) * angles(-rotrl/7 + (sin(sine/walkDivider)/1.5)*rotrl * rad(35),rad((-sin(sine/walkDivider))*rotfb * rad(20)),(-sin(sine/walkDivider)/1.5)*rotfb * rad(35)),walkanimspeed)
							rh.C1 = rh.C1:Lerp(rhc1 * cf((-cos(sine/walkDivider)/5) * (rotfb or rotrl),sin(sine/walkDivider)/2.25,0) * angles((sin(sine/walkDivider)/1.5)*rotrl * rad(10),rotrl/7.5 + (cos(sine/walkDivider)/1.5)*rotrl * rad(25),-math.abs(sin(sine/walkDivider)/1.5) * rad(15)),walkanimspeed)
							lh.C1 = lh.C1:Lerp(lhc1 * cf((-cos(sine/walkDivider)/5) * (rotfb or rotrl),-sin(sine/walkDivider)/2.25,0) * angles((sin(sine/walkDivider)/1.5)*rotrl * rad(10),-rotrl/7.5 + (cos(sine/walkDivider)/1.5)*rotrl * rad(25),math.abs(sin(sine/walkDivider)/1.5) * rad(15)),walkanimspeed)
							sine = sine + change
							num = num +.25
							swait()
						end
						if num > 5 then
							footstepsound:Play()
							num = 1
						end
						takingAStep = false
					end
				end))
			end
		end
		if not sitting and not using and not lying and not hugging and not owowhat then
			if rutVerVel > 5 then
				anim = "jump"
				rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,1.75,0) * angles(rad(-50),rad(0),rad(0)),walkanimspeed)
				nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-40),rad(0),rad(0)),walkanimspeed)
				rs.C0 = rs.C0:Lerp(rsc0 * cf(-.05,.1,-.2) * angles(rad(5),rad(-5),rad(81)),walkanimspeed)
				ls.C0 = ls.C0:Lerp(lsc0 * cf(.05,.1,-.2) * angles(rad(-5),rad(5),rad(-78)),walkanimspeed)
				rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,.45,0) * angles(rad(-3),rad(-5),rad(-25)),walkanimspeed)
				lh.C0 = lh.C0:Lerp(lhc0 * cf(-.5,.5,0) * angles(rad(-3),rad(5),rad(31)),walkanimspeed)
			elseif rutVerVel < -5 then
				anim = "fall"
				rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,1.75,0) * angles(rad(-35),rad(0),rad(0)),animspeed/5)
				nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-20),rad(0),rad(0)),animspeed/5)
				rs.C0 = rs.C0:Lerp(rsc0 * cf(-.05,.1,-.2) * angles(rad(5),rad(-5),rad(101)),animspeed/5)
				ls.C0 = ls.C0:Lerp(lsc0 * cf(.05,.1,-.2) * angles(rad(-5),rad(5),rad(-98)),animspeed/5)
				rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,.45,0) * angles(rad(-3),rad(-5),rad(-25)),animspeed/5)
				lh.C0 = lh.C0:Lerp(lhc0 * cf(-.5,.5,0) * angles(rad(-3),rad(5),rad(31)),animspeed/5)
			elseif rutHorVel < 3.5 then
				anim = "idle"
				rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2,0) * angles(rad(-70),rad(0),rad(0)),walkanimspeed)
				nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-60),rad(0),rad(0)),walkanimspeed)
				rs.C0 = rs.C0:Lerp(rsc0 * cf(-.05,.1,-.2) * angles(rad(2.5),rad(-5),rad(71)),walkanimspeed)
				ls.C0 = ls.C0:Lerp(lsc0 * cf(.05,.1,-.2) * angles(rad(2.5),rad(5),rad(-68)),walkanimspeed)
				rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,.45,0) * angles(rad(-3),rad(-5),rad(-15)),walkanimspeed)
				lh.C0 = lh.C0:Lerp(lhc0 * cf(-.5,.5,0) * angles(rad(-3),rad(5),rad(21)),walkanimspeed)
			elseif rutHorVel > 3.5 and rutVerVel > -4.5 and rutVerVel < 4.5 then
				anim = "walk"
				rutj.C0 = rutj.C0:Lerp(rutjc0 * cf(0,2,0) * angles(rad(-70),rad(0),rad(0)),walkanimspeed)
				nec.C0 = nec.C0:Lerp(necc0 * cf(0,0,0) * angles(rad(-60),rad(0),rad(0)),walkanimspeed)
				rs.C0 = rs.C0:Lerp(rsc0 * cf(-.05,.1,-.2) * angles(rad(-2.5),rad(-5),rad(71)),walkanimspeed)
				ls.C0 = ls.C0:Lerp(lsc0 * cf(.05,.1,-.2) * angles(rad(-2.5),rad(5),rad(-68)),walkanimspeed)
				rh.C0 = rh.C0:Lerp(rhc0 * cf(.35,.45,0) * angles(rad(-3),rad(-3),rad(-20)),walkanimspeed)
				lh.C0 = lh.C0:Lerp(lhc0 * cf(-.35,.5,0) * angles(rad(-3),rad(3),rad(20)),walkanimspeed)
			end
		end
		swait()
	end
end)()
--good thing -w-
-- * cf(0,0,0) * angles(rad(0),rad(0),rad(0))
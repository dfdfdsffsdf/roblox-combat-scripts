local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local ServerStorage = game:GetService("ServerStorage")

local Events = ReplicatedStorage:WaitForChild("Events")
local JumpHitAnim = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Styles"):WaitForChild("Breath"):WaitForChild("Water"):WaitForChild("JumpHit")
local HitEffect = ReplicatedStorage.Effects.Skills.Water:WaitForChild("JumpSlash")
local HitAnim = ReplicatedStorage.Animations.Styles.Breath.Water:WaitForChild("Hit1")

local RaycastHitbox = require(ServerStorage.Modules.HitBoxes.RaycastHitboxV4)
local BlockingModule = require(ServerStorage.Modules.BlockingModule)
local StunHandler = require(ServerStorage.Modules.Other.StunHandlerV2)
local StatusHandler = require(ServerStorage.Modules.Status.BreathingStatus)
local StopTrack = require(ReplicatedStorage.Modules.AnimationStopper)

local SpawnEffectEvent = Events.SpawnEffect

local function getStats(char: Model)
	local weapon = char:GetAttribute("Weapon") or "Katana"
	local breathTable = StatusHandler.getStats(char:GetAttribute("BreathStyle") or "Water")
	return breathTable and breathTable[weapon] or { Damage = 5, Stun = 0.3 }
end

local function ApplyHitbox(char: Model, clone: Instance, stats: { Damage: number, Stun: number })
	local hitbox = RaycastHitbox.new(clone)

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = { char }
	params.FilterType = Enum.RaycastFilterType.Exclude
	hitbox.RaycastParams = params

	hitbox.OnHit:Connect(function(hit, targetHumanoid, hitPos)
		if not targetHumanoid then return end

		local targetChar = targetHumanoid.Parent
		if not targetChar or targetChar == char then return end
		if targetChar:GetAttribute("Iframes") then return end
		if targetChar:GetAttribute("NPC") then return end

		if targetChar:GetAttribute("Parry") then
			BlockingModule.Parrying(targetChar, char, hitPos)
			return
		end

		if targetChar:GetAttribute("IsBlocking") then
			BlockingModule.Blocking(targetChar, stats.Damage, hitPos)
			return
		end

		targetHumanoid:TakeDamage(stats.Damage)
		StunHandler.Stun(targetHumanoid, stats.Stun, 4, 0)

		local targetAnimator = targetHumanoid:FindFirstChildOfClass("Animator")
		if targetAnimator and HitAnim then
			local track = targetAnimator:LoadAnimation(HitAnim)
			track:Play()
		end
	end)

	hitbox:HitStart(0.35)
end

local function SpawnHitEffect(char: Model)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local clone = HitEffect:Clone()
	clone.Name = "JumpHitEffect"
	clone.Parent = char

	local weld = clone:FindFirstChild("Weld")
	if weld then
		weld.Part0 = hrp
		weld.Part1 = clone
	end

	Debris:AddItem(clone, 1.5)
	SpawnEffectEvent:FireAllClients(char, clone.Name)

	local stats = getStats(char)
	ApplyHitbox(char, clone, stats)
end

local function cleanup(char, track, lv, attachment, stunConn)
	stunConn:Disconnect()
	StopTrack.StopAllExceptIdle(char)
	track:Stop()

	if lv and lv.Parent then lv:Destroy() end
	if attachment and attachment.Parent then attachment:Destroy() end

	char:SetAttribute("A", false)
end

function module.JumpHit(char)
	if char:GetAttribute("Stunned") then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not hrp or not humanoid or not animator then return end

	local track = animator:LoadAnimation(JumpHitAnim)
	track:Play()

	char:SetAttribute("A", true)

	local attachment = Instance.new("Attachment")
	attachment.Parent = hrp

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = attachment
	lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	lv.MaxForce = 1e5
	lv.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	lv.VectorVelocity = Vector3.new(0, -20, -30)
	lv.Parent = hrp

	local stunConn
	stunConn = char:GetAttributeChangedSignal("Stunned"):Connect(function()
		if char:GetAttribute("Stunned") then
			cleanup(char, track, lv, attachment, stunConn)
		end
	end)

	track:GetMarkerReachedSignal("Hit"):Connect(function()
		SpawnHitEffect(char)
	end)

	task.delay(0.75, function()
		if stunConn.Connected then stunConn:Disconnect() end
		if lv and lv.Parent then lv:Destroy() end
		if attachment and attachment.Parent then attachment:Destroy() end

		char:SetAttribute("A", false)
	end)
end

return module

local module = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local BreathingStats = {
	Water = {
		Katana = { Damage = 12, Stun = 0.3, Damage2 = 18, Stun2 = 0.4 },
		Sword = { Damage = 14, Stun = 0.35, Damage2 = 20, Stun2 = 0.45 },
	},
	Flame = {
		Katana = { Damage = 15, Stun = 0.25, Damage2 = 22, Stun2 = 0.5 },
		Sword = { Damage = 17, Stun = 0.3, Damage2 = 24, Stun2 = 0.55 },
	},
	Thunder = {
		Katana = { Damage = 10, Stun = 0.5, Damage2 = 16, Stun2 = 0.7 },
		Sword = { Damage = 12, Stun = 0.55, Damage2 = 18, Stun2 = 0.75 },
	},
}

function module.getStats(breathStyle: string)
	return BreathingStats[breathStyle]
end

function module.applyStatus(char: Model, breathStyle: string)
	if not char or not breathStyle then return end

	local existing = char:GetAttribute("BreathStyle")
	if existing == breathStyle then return end

	char:SetAttribute("BreathStyle", breathStyle)

	local statsTable = BreathingStats[breathStyle]
	if not statsTable then return end

	local weapon = char:GetAttribute("Weapon") or "Katana"
	local stats = statsTable[weapon]
	if not stats then return end

	char:SetAttribute("BaseDamage", stats.Damage)
	char:SetAttribute("BaseStun", stats.Stun)
end

function module.clearStatus(char: Model)
	if not char then return end
	char:SetAttribute("BreathStyle", nil)
	char:SetAttribute("BaseDamage", nil)
	char:SetAttribute("BaseStun", nil)
end

return module

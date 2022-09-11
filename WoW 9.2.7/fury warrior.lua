local NeP = NeP

local GUI = {
	{type = "texture", texture = "Interface\\AddOns\\"..local_stream_name.."\\media\\logo.blp", width = 35, height = 35, offset = 45, y= -15, align = "center"},
	--{type = 'spinner',text = 'Interrupt at (%): ', key = 'interrupt_at', width = 100, default = 43, step = 1, max = 90, min = 15, size = 11},
	{type = 'spacer', offset = 85},
	{type = 'text', text = 'work in progress'},
}

local ids

local exeOnLoad = function()
	NeP.Interface:AddToggle({
		key = 'ignoreRange',
		name = 'Ignore Rangecheck',
		text = 'Enabling this will ignore rangecheck for melee stuff.',
		icon ='Interface\\Icons\\Ability_creature_cursed_04.png'
	})
	ids = {
		--dps
		Execute = GetSpellInfo(5308),
		Rampage = GetSpellInfo(184367),
		Dragon_Roar = GetSpellInfo(118000),
		Onslaught = GetSpellInfo(315720),
		Raging_Blow = GetSpellInfo(85288),
		Bloodthirst = GetSpellInfo(23881),
		Whirlwind = GetSpellInfo(190411),
		Heroic_Throw = GetSpellInfo(57755),
		Condemn = GetSpellInfo(330325),
		Spear_Bastion = GetSpellInfo(307865),

		--heal
		Impending_Victory = GetSpellInfo(202168),
		Victory_Rush = GetSpellInfo(34428),
		Enraged_Regeneration = GetSpellInfo(184364),
		Ignore_Pain = GetSpellInfo(190456),


		--buffs
		Battle_Shout = GetSpellInfo(6673),
		Enrage = GetSpellInfo(184362),
		Whirlwind_Buff = GetSpellInfo(85739),
		Sudden_Death = GetSpellInfo(280776),
		Recklessness = GetSpellInfo(1719),
		Rallying_Cry = GetSpellInfo(97462),

		
		

		--utility
		Heroic_Leap = GetSpellInfo(6544),
		Pummel = GetSpellInfo(6552),
		Intimidating_Shout = GetSpellInfo(5246),

		

		--debuffs shadowlands


		--enemy buffs shadowlands
		

	}

	
	
end


local exeOnUnload = function()

end

local inCombat = function()
	local Unit = Unit
	local Condition = Condition
	local CanCast = CanCast
	local Cast = Cast

	local player = Unit('player')
	local mouseover = Unit('mouseover')
	
	local lowest = Unit('lowest')
	if not lowest then return end
	
	
	local target = Unit('target')
	local healer = Unit('healer')
	local tank = Unit('tank')
	local friendly = Unit('friendly')


	-- pause
    if Condition('keybind', nil, 'lalt') then
		return
    end
	
	
	-- Recklessness
    if CanCast(ids.Recklessness)
    and Condition('keybind', nil, 'rcontrol') then
        return player:Cast(ids.Recklessness)
    end
	
	-- Spear of Bastion
    if CanCast(ids.Spear_Bastion)
    and Condition('keybind', nil, 'rcontrol') then
        return player:CastGround(ids.Spear_Bastion)
    end
	
	-- trinket use
	--if CanUse('Grim Codex')
	--and Condition('toggle', nil, 'Cooldowns')
	--and Condition('keybind', nil, 'rcontrol')
	--and target:distance() < 6 then
	--	target:UseItem('Grim Codex')
	--end
	
	-- trinket use
	--if CanUse('Grim Codex')
	--and Condition('keybind', nil, 'rcontrol')
	--and Condition('toggle', nil, 'ignoreRange') then
	--	target:UseItem('Grim Codex')
	--end


----  survival  ----
	-- Healthstone 25 percent
	--if CanUse('Healthstone')
	--and player:health() <= 40 then
	--	player:UseItem('Healthstone')
	--end

	if player:health() < 50
	and CanCast(ids.Rallying_Cry) then
		return player:Cast(ids.Rallying_Cry)
	end
	
	if player:health() < 60
	and CanCast(ids.Enraged_Regeneration) then
		return player:Cast(ids.Enraged_Regeneration)
	end
	
	-- health potion 20.000
	--if CanUse('Cosmic Healing Potion')
	--and player:health() <= 60 then
	--	player:UseItem('Spiritual Healing Potion')
	--end
	
	-- health potion 10.000
	--if CanUse('Spiritual Healing Potion')
	--and player:health() <= 60 then
	--	player:UseItem('Spiritual Healing Potion')
	--end
	
	if player:health() < 70
	and CanCast(ids.Ignore_Pain) then
		return player:Cast(ids.Ignore_Pain)
	end


	-- interrupt pummel ignore range
	if target
	and CanCast(ids.Pummel)
	and target:enemy()
	and Condition('toggle', nil, 'ignoreRange')
	and target:interruptAt(60) then
		return target:Cast(ids.Pummel)
	end


	-- interrupt pummel
	if target
	and CanCast(ids.Pummel)
	and target:enemy()
	and target:distance() < 6
	and target:interruptAt(60) then
		return target:Cast(ids.Pummel)
	end
	
	-- off target interrupt pummel in melee range
	if player:spellCooldown(ids.Pummel) == 0 then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 6
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:infront()
			and obj:interruptAt(60) then
				return obj:Cast(ids.Pummel)
			end
		end
	end
	
	
	-- interrupt fear shout ignore range
	--if target
	--and CanCast(ids.Intimidating_Shout)
	--and target:enemy()
	--and Condition('toggle', nil, 'ignoreRange')
	--and target:interruptAt(60) then
	--	return target:Cast(ids.Intimidating_Shout)
	--end


	-- interrupt fear shout
	if target
	and CanCast(ids.Intimidating_Shout)
	and target:enemy()
	and target:distance() < 8
	and target:interruptAt(60) then
		return target:Cast(ids.Intimidating_Shout)
	end
	
	-- off target interrupt(fear) by Intimidating_Shout in melee+ range
	if player:spellCooldown(ids.Intimidating_Shout) == 0 then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 8
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:interruptAt(60) then
				return obj:Cast(ids.Intimidating_Shout)
			end
		end
	end
	

    -- dps ignore range for big hitbox bosses like margrave
    if target
	and Condition('toggle', nil, 'ignoreRange')
    and target:enemy()
	and target:los()
	and target:alive()
	then
	
		if not target:buffAny('Reckless Provocation')
		or not target:buffAny('Sanguine Sphere') then
	
			-- victory rush
			if CanCast(ids.Victory_Rush)
			and player:health() < 100 then
				return target:Cast(ids.Victory_Rush)
			end
		
			-- bloodthirst if Enraged Regeneration
			if CanCast(ids.Bloodthirst)
			and player:health() < 80
			and player:buff(ids.Enraged_Regeneration) then
				return target:Cast(ids.Bloodthirst)
			end
		
			-- recklessness AOE ramp
			--if CanCast(ids.Recklessness)
			--and target:distance() < 8
			--and player:areaEnemies(8) > 3 
			--and not player:buff(ids.Recklessness) then
			--    return target:Cast(ids.Recklessness)
			--end
		
			-- spear of bastion (kyrian AOE)
			--if CanCast(ids.Spear_Bastion)
			--and target:distance() < 25
			--and target:areaEnemies(10) > 3 then
			--    return target:CastGround(ids.Spear_Bastion)
			--end
		
			-- whirlwind AOE buff
			if CanCast(ids.Whirlwind)
			and player:areaEnemies(8) > 2 
			and not player:buff(ids.Whirlwind_Buff) then
				return target:Cast(ids.Whirlwind)
			end
		
			-- Rampage if no enrage
			if CanCast(ids.Rampage)
			and not player:buff(ids.Enrage) then
				return target:Cast(ids.Rampage)
			end
			
			-- Condemn (venthir execute replacer)
			--if CanCast(ids.Condemn)
			--and target:distance() < 6 then
			--    return target:Cast(ids.Condemn)
			--end
			
			-- Execute
			if CanCast(ids.Execute) then
				return target:Cast(ids.Execute)
			end
			
			-- Rampage ragedump
			if CanCast(ids.Rampage)
			and player:rage() > 90 then
				return target:Cast(ids.Rampage)
			end
			
			-- dragon roar while enraged
			if CanCast(ids.Dragon_Roar)
			and player:buff(ids.Enrage) then
				return target:Cast(ids.Dragon_Roar)
			end
			
			-- raging blow while enraged
			if CanCast(ids.Raging_Blow)
			and player:buff(ids.Enrage) then
				return target:Cast(ids.Raging_Blow)
			end
			
			-- bloodthirst
			if CanCast(ids.Bloodthirst) then
				return target:Cast(ids.Bloodthirst)
			end
			
			-- raging blow for rage fill
			if CanCast(ids.Raging_Blow) then
				return target:Cast(ids.Raging_Blow)
			end

			-- whirlwind filler
			if CanCast(ids.Whirlwind) then
				return target:Cast(ids.Whirlwind)
			end

		end

    end



	-- execute off target
	if player:spellCooldown(ids.Execute) == 0 and Condition('toggle', nil, 'Cooldowns') then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 6
			and obj:infront()
			and obj:combat()
			and obj:alive()
			and obj:los()
			and player:rage() > 20
			and obj:health() < 35 then
			print('execute off target')
				return obj:Cast(ids.Execute)
			end
		end
	end


    -- dps
    if target
    and target:enemy()
	and target:los()
	and target:alive()
	then
	
		if not target:buffAny('Reckless Provocation')
		or not target:buffAny('Sanguine Sphere') then
	
			-- victory rush
			if CanCast(ids.Victory_Rush)
			and target:distance() < 6
			and player:health() < 100 then
				return target:Cast(ids.Victory_Rush)
			end
		
			-- bloodthirst if Enraged Regeneration
			if CanCast(ids.Bloodthirst)
			and target:distance() < 6
			and player:health() < 80
			and player:buff(ids.Enraged_Regeneration) then
				return target:Cast(ids.Bloodthirst)
			end
		
			-- recklessness AOE ramp
			--if CanCast(ids.Recklessness)
			--and target:distance() < 8
			--and player:areaEnemies(8) > 3 
			--and not player:buff(ids.Recklessness) then
			--    return target:Cast(ids.Recklessness)
			--end
		
			-- spear of bastion (kyrian AOE)
			--if CanCast(ids.Spear_Bastion)
			--and target:distance() < 25
			--and target:areaEnemies(10) > 3 then
			--    return target:CastGround(ids.Spear_Bastion)
			--end
		
			-- whirlwind AOE buff
			if CanCast(ids.Whirlwind)
			and target:distance() < 8
			and player:areaEnemies(8) > 2 
			and not player:buff(ids.Whirlwind_Buff) then
				return target:Cast(ids.Whirlwind)
			end
		
			-- Rampage if no enrage
			if CanCast(ids.Rampage)
			and target:distance() < 6
			and not player:buff(ids.Enrage) then
				return target:Cast(ids.Rampage)
			end
			
			-- Condemn (venthir execute replacer)
			--if CanCast(ids.Condemn)
			--and target:distance() < 6 then
			--    return target:Cast(ids.Condemn)
			--end
			
			-- Execute
			if CanCast(ids.Execute)
			and target:distance() < 6 then
				return target:Cast(ids.Execute)
			end
			
			-- Rampage ragedump
			if CanCast(ids.Rampage)
			and target:distance() < 6
			and player:rage() > 90 then
				return target:Cast(ids.Rampage)
			end
			
			-- dragon roar while enraged
			if CanCast(ids.Dragon_Roar)
			and target:distance() < 6
			and player:buff(ids.Enrage) then
				return target:Cast(ids.Dragon_Roar)
			end
			
			-- raging blow while enraged
			if CanCast(ids.Raging_Blow)
			and target:distance() < 6
			and player:buff(ids.Enrage) then
				return target:Cast(ids.Raging_Blow)
			end
			
			-- bloodthirst
			if CanCast(ids.Bloodthirst)
			and target:distance() < 6 then
				return target:Cast(ids.Bloodthirst)
			end
			
			-- raging blow for rage fill
			if CanCast(ids.Raging_Blow)
			and target:distance() < 6 then
				return target:Cast(ids.Raging_Blow)
			end

			-- whirlwind filler
			if CanCast(ids.Whirlwind)
			and target:distance() < 8 then
				return target:Cast(ids.Whirlwind)
			end

		end

    end





    

end

local outCombat = function()

	local Unit = Unit
    local Condition = Condition
    local CanCast = CanCast
	local Cast = Cast

    local player = Unit('player')
    local mouseover = Unit('mouseover')
	
	local lowest = Unit('lowest')
    if not lowest then return end
	
	
    local target = Unit('target')
	local healer = Unit('healer')
	local tank = Unit('tank')

	if CanCast(ids.Battle_Shout)
	and not player:buffAny(ids.Battle_Shout) then
		return player:Cast(ids.Battle_Shout)
	end



end

NeP.CR:Add(72, {
	name = '[|cffA330C9ZoDDeL|r] Warrior | Fury 0.18',
	wow_ver = "9.2.7",
	nep_ver = "2.0",
	ic = inCombat,
	ooc = outCombat,
    use_lua_engine = true,
	gui = GUI,
	load = exeOnLoad,
	unload = exeOnUnload
})
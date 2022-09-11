local GUI = {
	{type = "texture", texture = "Interface\\AddOns\\"..local_stream_name.."\\media\\logo.blp", width = 35, height = 35, offset = 45, y= -15, align = "center"},
	--{type = 'spinner',text = 'Interrupt at (%): ', key = 'interrupt_at', width = 100, default = 43, step = 1, max = 90, min = 15, size = 11},
	--{type = 'spinner',text = 'Healthstone at (%): ', key = 'healthstone_at', width = 100, default = 60, step = 1, max = 100, min = 1, size = 11},
	{type = 'spacer', offset = 85},
	{type = 'text', text = 'nothing to see here'},
}

local exeOnLoad = function()
	NeP.Interface:AddToggle({	
		key = 'autoDispel2',
		name = 'AUTO DISPEL ENEMY(in target) MAGIC BUFFS',
		text = 'dispel specific enemy magic buffs in shadowlands dungeons',
		icon ='Interface\\Icons\\Ability_creature_cursed_02.png'
	})
	
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

    -- Power Word: Shield speedboost
    if CanCast('Power Word: Shield')
    and Condition('keybind', nil, 'lshift') then
		return player:Cast('Power Word: Shield')
    end



	-- Dispersion
	if CanCast('Dispersion')
	and player:health() < 20 then
		return player:Cast('Dispersion')
	end

    if player:health() < 40 then
	
		-- Desperate Prayer
		if CanCast('Desperate Prayer') then
			return player:Cast('Desperate Prayer')
		end
		
		-- Vampiric Embrace
		if CanCast('Vampiric Embrace') then
			return player:Cast('Vampiric Embrace')
		end
	
		-- Shadow Mend
		if CanCast('Shadow Mend')
		and not player:moving() then
			return player:Cast('Shadow Mend')
		end

    end
	
	-- Power Word: Shield
	if player:health() < 60
	and CanCast('Power Word: Shield')
	and player:debuff('Weakened Soul') then
		return player:Cast('Power Word: Shield')
	end
	
	
	
	--if player:channelingPercent() > 0 then
	--	return
	--end
	
	if target
    and target.id == 120651
	and target:los() then
		if CanCast('Shadow Word: Pain') then
		return target:Cast('Shadow Word: Pain')
		end
	
	end

    if target
    and target.name == "Explosives"
	and target:los() then
		if CanCast('Shadow Word: Pain') then
		return target:Cast('Shadow Word: Pain')
		end
	
	end
	
	
	
	if target
	and CanCast('Silence')
	and target:interruptAt(60) then
		return target:Cast('Silence')
	end
	
	-- off target interrupt
	if CanCast('Silence') then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 30
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:interruptAt(60) then
				return obj:Cast('Silence')
			end
		end
	end


---- dispel enemy buffs  ----
	if Condition('toggle', nil, 'autoDispel2') and CanCast('Dispel Magic') then
	
		if target and target:enemy() and target:los() and target:distance() < 40 then
			if target:buffAny('Shadewalker')
			or target:buffAny('Mawsworn Shield')
			or target:buffAny('Stygian Shield')
			or target:buffAny("Death's Embrace")
			or target:buffAny('Spectral')
			or target:buffAny('Dying Breath')
			or target:buffAny('Nourish the Forest')
			or target:buffAny('Stimulate Resistance')
			or target:buffAny('Stoneskin')
			or target:buffAny('Forsworn Doctrine')
			or target:buffAny('Imbue Weapon')
			or target:buffAny('Bless Weapon')
			or target:buffAny('Meat Shield')
			or target:buffAny('Boneshatter Shield')
			or target:buffAny('Dark Shroud')
			or target:buffAny('Unholy Fervor')
			or target:buffAny('Spectral Transference')
			or target:buffAny('Bone Shield')
			or target:buffAny('Bubble Shield')
			or target:buffAny('Bone Armor')
			or target:buffAny('Refraction Shield')
			or target:buffAny('Hard Light Barrier')
			or target:buffAny('Hard Light Baton')
			or target:buffAny('Flagellation Protocol')
			or target:buffAny('Stoneskin')	then
				return target:Cast('Dispel Magic')
			end
		end
		
		-- off target dispel enemy buffs
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 40 and obj:los() and obj:alive() and obj:combat() then
				if obj:buffAny('Shadewalker')
				or obj:buffAny('Mawsworn Shield')
				or obj:buffAny('Stygian Shield')
				or obj:buffAny("Death's Embrace")
				or obj:buffAny('Spectral')
				or obj:buffAny('Dying Breath')
				or obj:buffAny('Nourish the Forest')
				or obj:buffAny('Stimulate Resistance')
				or obj:buffAny('Stoneskin')
				or obj:buffAny('Forsworn Doctrine')
				or obj:buffAny('Imbue Weapon')
				or obj:buffAny('Bless Weapon')
				or obj:buffAny('Meat Shield')
				or obj:buffAny('Boneshatter Shield')
				or obj:buffAny('Dark Shroud')
				or obj:buffAny('Unholy Fervor')
				or obj:buffAny('Spectral Transference')
				or obj:buffAny('Bone Shield')
				or obj:buffAny('Bubble Shield')
				or obj:buffAny('Bone Armor')
				or obj:buffAny('Refraction Shield')
				or obj:buffAny('Hard Light Barrier')
				or obj:buffAny('Hard Light Baton')
				or obj:buffAny('Flagellation Protocol')
				or obj:buffAny('Stoneskin')	then
					return obj:Cast('Dispel Magic')
				end	
			end
		end


	end




	-- rotation = 3+  
	if target and target:enemy() and target:los() and target:areaEnemies(10) > 2 then
		
		if CanCast('Mindbender') then
			return target:Cast('Mindbender')
		end
		
		if CanCast('Shadowfiend') then
			return target:Cast('Shadowfiend')
		end
		
		if CanCast('Void Eruption')
		and not player:buff('Voidform')
		and not player:moving() then
			return target:Cast('Void Eruption')
		end
		
		if CanCast('Mindgames')
		and player:buff('Voidform')
		and not player:moving() then
			return target:Cast('Mindgames')
		end
		
		if CanCast('Mindgames')
		and player:buff('Voidform')
		and player:buff('Surrender to Madness') then
			return target:Cast('Mindgames')
		end
		
		if CanCast('Surrender to Madness')
		and target:ttd() < 15
		and not player:buff('Voidform') then
			return target:Cast('Surrender to Madness')
		end
		
		if CanCast('Void Bolt') 
		and player:buff('Voidform') then
			return target:Cast('Void Bolt')
		end

		if CanCast('Shadow Word: Death')
		and target:health() < 20 then
			return target:Cast('Shadow Word: Death')
		end

		if CanCast('Vampiric Touch')
		and target:ttd() > 10
		and not target:debuff('Vampiric Touch')
		and not player:moving() then
			return target:Cast('Vampiric Touch')
		end
		
		if CanCast('Vampiric Touch')
		and player:buff('Surrender to Madness')
		and target:ttd() > 10
		and not target:debuff('Vampiric Touch') then
			return target:Cast('Vampiric Touch')
		end
		
		if CanCast('Shadow Crash') then
			return target:CastGround('Shadow Crash')
		end
		
		if CanCast('Mind Blast')
		and player:buff('Dark Thoughts') 
		and player:channeling('Mind Sear') then
			return target:Cast('Mind Blast')
		end

		if CanCast('Searing Nightmare')
		and player:channeling('Mind Sear') then
			return target:Cast('Searing Nightmare')
		end
		
		if CanCast('Mind Sear')
		and not player:channeling('Mind Sear')
		and not player:moving() then
			return target:Cast('Mind Sear')
		end
		
		if CanCast('Mind Sear')
		and player:buff('Surrender to Madness')
		and not player:channeling('Mind Sear') then
			return target:Cast('Mind Sear')
		end
	
	
	end
	
	
	-- rotation = 2 
	if target and target:enemy() and target:los() and target:areaEnemies(10) > 1 then
		
		if CanCast('Mindbender') then
			return target:Cast('Mindbender')
		end
		
		if CanCast('Shadowfiend') then
			return target:Cast('Shadowfiend')
		end
		
		if CanCast('Void Eruption')
		and not player:buff('Voidform')
		and not player:moving() then
			return target:Cast('Void Eruption')
		end
		
		if CanCast('Mindgames')
		and player:buff('Voidform')
		and not player:moving() then
			return target:Cast('Mindgames')
		end
		
		if CanCast('Mindgames')
		and player:buff('Voidform')
		and player:buff('Surrender to Madness') then
			return target:Cast('Mindgames')
		end
		
		if CanCast('Surrender to Madness')
		and target:ttd() < 15
		and not player:buff('Voidform') then
			return target:Cast('Surrender to Madness')
		end
		
		if CanCast('Void Bolt') 
		and player:buff('Voidform') then
			return target:Cast('Void Bolt')
		end

		if CanCast('Devouring Plague') then
			return target:Cast('Devouring Plague')
		end

		if CanCast('Mind Blast')
		and player:buff('Dark Thoughts') 
		and player:channeling('Mind Sear') then
			return target:Cast('Mind Blast')
		end
		
		if CanCast('Mind Blast')
		and player:buff('Dark Thoughts') 
		and player:channeling('Mind Flay') then
			return target:Cast('Mind Blast')
		end

		if CanCast('Searing Nightmare')
		and player:channeling('Mind Sear')
		and not player:buff('Voidform') then
			return target:Cast('Searing Nightmare')
		end

		if CanCast('Shadow Word: Death')
		and target:health() < 20 then
			return target:Cast('Shadow Word: Death')
		end

		if CanCast('Vampiric Touch')
		and target:ttd() > 10
		and not target:debuff('Vampiric Touch')
		and not player:moving() then
			return target:Cast('Vampiric Touch')
		end

		if CanCast('Vampiric Touch')
		and player:buff('Surrender to Madness')
		and target:ttd() > 10
		and not target:debuff('Vampiric Touch') then
			return target:Cast('Vampiric Touch')
		end

		if CanCast('Shadow Crash') then
			return target:CastGround('Shadow Crash')
		end
		
		if CanCast('Mind Blast')
		and not player:moving() then
			return target:Cast('Mind Blast')
		end

		if CanCast('Mind Blast')
		and player:buff('Surrender to Madness') then
			return target:Cast('Mind Blast')
		end
	
		if CanCast('Mind Sear')
		and target:areaEnemies(10) > 2
		and not player:channeling('Mind Sear')
		and not player:moving() then
			return target:Cast('Mind Sear')
		end
		
		if CanCast('Mind Sear')
		and target:areaEnemies(10) > 2
		and player:buff('Surrender to Madness')
		and not player:channeling('Mind Sear') then
			return target:Cast('Mind Sear')
		end
		
		
		if CanCast('Mind Flay')
		and target:areaEnemies(10) < 3
		and not player:channeling('Mind Flay')
		and not player:moving() then
			return target:Cast('Mind Flay')
		end
		
		if CanCast('Mind Flay')
		and target:areaEnemies(10) < 3
		and player:buff('Surrender to Madness')
		and not player:channeling('Mind Flay') then
			return target:Cast('Mind Flay')
		end
		
	
	
	end


	-- rotation = 1  
	if target and target:enemy() and target:los() then
			
		if CanCast('Void Eruption')
		and not player:buff('Voidform')
		and not player:moving() then
			return target:Cast('Void Eruption')
		end
		
		if CanCast('Mindgames')
		and player:buff('Voidform')
		and not player:moving() then
			return target:Cast('Mindgames')
		end
		
		if CanCast('Mindgames')
		and player:buff('Voidform')
		and player:buff('Surrender to Madness') then
			return target:Cast('Mindgames')
		end
		
		if CanCast('Vampiric Touch')
		and target:ttd() > 10
		and not target:debuff('Vampiric Touch')
		and not player:moving() then
			return target:Cast('Vampiric Touch')
		end
		
		if CanCast('Vampiric Touch')
		and player:buff('Surrender to Madness')
		and target:ttd() > 10
		and not target:debuff('Vampiric Touch') then
			return target:Cast('Vampiric Touch')
		end
		
		if CanCast('Shadow Word: Pain') 
		and not target:debuff('Shadow Word: Pain') then
			return target:Cast('Shadow Word: Pain')
		end
		
		if CanCast('Devouring Plague') then
			return target:Cast('Devouring Plague')
		end
		
		if CanCast('Shadow Word: Death')
		and target:health() < 20 then
			return target:Cast('Shadow Word: Death')
		end
		
		if CanCast('Mind Blast')
		and player:buff('Dark Thoughts') 
		and player:channeling('Mind Flay') then
			return target:Cast('Mind Blast')
		end
		
		if CanCast('Void Bolt') 
		and player:buff('Voidform') then
			return target:Cast('Void Bolt')
		end
		
		if CanCast('Surrender to Madness')
		and target:ttd() < 15
		and not player:buff('Voidform') then
			return target:Cast('Surrender to Madness')
		end

		if CanCast('Mindbender') then
			return target:Cast('Mindbender')
		end
		
		if CanCast('Shadowfiend') then
			return target:Cast('Shadowfiend')
		end

		if CanCast('Shadow Crash') then
			return target:CastGround('Shadow Crash')
		end

		if CanCast('Mind Flay')
		and player:buff('Dark Thoughts')
		and not player:channeling('Mind Flay')
		and not player:moving() then
			return target:Cast('Mind Flay')
		end
		
		if CanCast('Mind Flay')
		and player:buff('Dark Thoughts')
		and player:buff('Surrender to Madness')
		and not player:channeling('Mind Flay') then
			return target:Cast('Mind Flay')
		end
		
		if CanCast('Mind Blast') then
			return target:Cast('Mind Blast')
		end
		
		if CanCast('Mind Blast')
		and player:buff('Surrender to Madness')
		and not player:moving() then
			return target:Cast('Mind Blast')
		end
			
		if CanCast('Mind Flay')
		and not player:channeling('Mind Flay')
		and not player:moving() then
			return target:Cast('Mind Flay')
		end
		
		if CanCast('Mind Flay')
		and not player:channeling('Mind Flay')
		and player:buff('Surrender to Madness') then
			return target:Cast('Mind Flay')
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

    
	-- Power Word: Shield speedboost
    if CanCast('Power Word: Shield')
    and Condition('keybind', nil, 'lshift') then
		return player:Cast('Power Word: Shield')
    end
	
	-- Shadowform
    if CanCast('Shadowform')
    and not player:buff('Shadowform') then
        return player:Cast('Shadowform')
    end
	
	
	-- Power Word: Fortitude check anyone in party/raid
	if CanCast('Power Word: Fortitude') and player:mana() > 80 then
		for _, obj in pairs(NeP.OM:Get('Roster')) do
			if not obj:buffAny('Power Word: Fortitude') then
				if obj:distance() < 40
				and obj:los()
				and obj:alive() then
					return obj:Cast('Power Word: Fortitude')
				end
			end
		end
	end


end

NeP.CR:Add(258, {
	name = '[|cffA330C9ZoDDeL|r] Priest | Shadow 0.12d',
	wow_ver = "9.2.7",
	nep_ver = "2.0",
	ic = inCombat,
	ooc = outCombat,
	gui = GUI,
	load = exeOnLoad,
	unload = exeOnUnload,
	use_lua_engine = true,
})
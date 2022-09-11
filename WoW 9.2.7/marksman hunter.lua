local NeP = NeP

local GUI = {
	{type = "texture", texture = "Interface\\AddOns\\"..local_stream_name.."\\media\\logo.blp", width = 35, height = 35, offset = 45, y= -15, align = "center"},
	--{type = 'spinner',text = 'Interrupt at (%): ', key = 'interrupt_at', width = 100, default = 43, step = 1, max = 90, min = 15, size = 11},
	{type = 'spacer', offset = 85},
	{type = 'text', text = 'work in progress'},
}

local ids

local exeOnLoad = function()

	ids = {
		--dps


		--heal



		--buffs


		
		

		--utility


		

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
	
	
	-- channeling cancel protection
	if player:channelingPercent() > 0 then
		return
	end
	
	-- casting cancel protection
	if player:castingPercent() > 0 then
		return
	end
	
	-- feign death protection
	if player:buff('Feign Death') then
		return
	end
	
	-- Volley
    if CanCast('Volley')
    and Condition('keybind', nil, 'rcontrol') then
        return target:CastGround('Volley')
    end
	
	-- Double Tap
    if CanCast('Double Tap')
    and Condition('keybind', nil, 'rcontrol') then
        return player:Cast('Double Tap')
    end
	
	-- Trueshot
    if CanCast('Trueshot')
    and Condition('keybind', nil, 'rcontrol') then
        return player:Cast('Trueshot')
    end
	
	-- Wild Spirits (nightfae)
    if CanCast('Wild Spirits')
    and Condition('keybind', nil, 'rcontrol') then
        return target:CastGround('Wild Spirits')
    end

	-- tar - flare combo torghast
	--if Condition('keybind', nil, 'lcontrol') and CanCast('Tar Trap') and CanCast('Flare')  then
	--		target:CastGround('Tar Trap')
	--		target:CastGround('Flare')
	--end


----  survival  ----
	-- Healthstone 25 percent
	--if CanUse('Healthstone')
	--and player:health() <= 40 then
	--	player:UseItem('Healthstone')
	--end
	
	-- Exhilaration
	if player:health() < 60
	and CanCast('Exhilaration') then
		return player:Cast('Exhilaration')
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



	-- interrupt Counter Shot
	if target
	and CanCast('Counter Shot')
	and target:enemy()
	and target:los()
	and target:alive()
	and target:infront()
	and target:distance() < 40
	and target:interruptAt(60) then
		return target:Cast('Counter Shot')
	end
	
	
	-- interrupt off target
	if CanCast('Counter Shot') and Condition('toggle', nil, 'Cooldowns') then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 40
			and obj:combat()
			and obj:alive()
			and obj:los()
			and obj:infront()
			and obj:interruptAt(60) then
				return obj:Cast('Counter Shot')
			end
		end
	end
	
	
	-- killshot off target
	if player:spellCooldown('Kill Shot') == 0 and Condition('toggle', nil, 'Cooldowns') then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 40
			and obj:combat()
			and obj:alive()
			and obj:los()
			and obj:infront()
			and player:focus() > 10
			and obj:health() < 20 then
				return obj:Cast('Kill Shot')
			end
		end
	end
	
	
	-- killshot on target
	--if target
	--and Condition('toggle', nil, 'Cooldowns')
	--and CanCast('Kill Shot')
	--and target:enemy()
	--and target:los()
	--and target:alive()
	--and target:distance() < 40
	--and player:focus() > 10
	--and target:health() < 20 then
	--	return target:Cast('Kill Shot')
	--end

	
	


    -- dps multi target
    if target
    and target:enemy()
	and target:los()
	and target:alive()
	and target:infront()
	and target:distance() < 40
	and target:areaEnemies(10) > 2
	then
	
		if not target:buffAny('Reckless Provocation')
		or not target:buffAny('Sanguine Sphere') then
	
			-- multishot to trigger aoe buff trick shots
			if CanCast('Multi-Shot')
			and not player:buff('Trick Shots') then
				return target:Cast('Multi-Shot')
			end
		
			-- rapid fire on buff trick shots and low focus
			if CanCast('Rapid Fire')
			and player:buff('Trick Shots')
			and player:focus() < 60 then
				return target:Cast('Rapid Fire')
			end
		
			-- aimed shot on buff trick shots
			if CanCast('Aimed Shot')
			and player:buff('Trick Shots')
			and target:ttd() > 3
			and not player:moving() then
				return target:Cast('Aimed Shot')
			end
		
			-- rapid fire on buff trick shots
			if CanCast('Rapid Fire')
			and player:buff('Trick Shots') then
				return target:Cast('Rapid Fire')
			end
		
			-- multishot on precise shots procc
			if CanCast('Multi-Shot')
			and player:buff('Precise Shots') then
				return target:Cast('Multi-Shot')
			end
			
			-- multishot focus waste
			if CanCast('Multi-Shot')
			and player:focus() > 70 then
				return target:Cast('Multi-Shot')
			end
		
			-- steady shot
			if CanCast('Steady Shot')
			and target:ttd() > 2 then
				return target:Cast('Steady Shot')
			end
			
			-- multishot filler
			if CanCast('Multi-Shot') then
				return target:Cast('Multi-Shot')
			end


		end

    end


    -- dps single target
    if target
    and target:enemy()
	and target:los()
	and target:alive()
	and target:infront()
	and target:distance() < 40
	then
	
		if not target:buffAny('Reckless Provocation')
		or not target:buffAny('Sanguine Sphere') then
	
			-- arcane shot on precise shots buff
			if CanCast('Arcane Shot')
			and player:buff('Precise Shots') then
				return target:Cast('Arcane Shot')
			end
		
			-- aimed shot 70+
			if CanCast('Aimed Shot')
			and target:health() > 70
			and not player:moving() then
				return target:Cast('Aimed Shot')
			end
		
			-- rapid fire
			if CanCast('Rapid Fire')
			and player:focus() < 70
			--and target:health() < 70  for carefull aim maybe?
			then
				return target:Cast('Rapid Fire')
			end
		
			-- aimed shot
			if CanCast('Aimed Shot')
			and target:ttd() > 3
			and not player:moving() then
				return target:Cast('Aimed Shot')
			end
		
			-- arcane shot
			if CanCast('Arcane Shot') then
				return target:Cast('Arcane Shot')
			end
		
			-- steady shot
			if CanCast('Steady Shot')
			and target:ttd() > 2 then
				return target:Cast('Steady Shot')
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



end

NeP.CR:Add(254, {
	name = '[|cffA330C9ZoDDeL|r] Hunter | Marksman 0.16b',
	wow_ver = "9.2.7",
	nep_ver = "2.0",
	ic = inCombat,
	ooc = outCombat,
    use_lua_engine = true,
	gui = GUI,
	load = exeOnLoad,
	unload = exeOnUnload
})
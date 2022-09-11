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
		Consecration = GetSpellInfo(26573),
		Judgement = GetSpellInfo(275779),
		Crusader_Strike = GetSpellInfo(35395),
		Shield_Righteous = GetSpellInfo(53600),
		Hammer_Wrath = GetSpellInfo(24275),
		Avenger_Shield = GetSpellInfo(31935),
		Hammer_Righteous = GetSpellInfo(53595),
		Divine_Toll = GetSpellInfo(304971),

		--heal
		Word_Glory = GetSpellInfo(85673),
		Flash_Light = GetSpellInfo(19750),
		Lay_Hands = GetSpellInfo(633),


		--buffs
		Consecration_Buff = GetSpellInfo(188370),
		Shield_Righteous_Buff = GetSpellInfo(132403),
		Divine_Purpose_Buff = GetSpellInfo(223819),
		Divine_Steed_Buff = GetSpellInfo(221883),
		Shining_Light_Buff = GetSpellInfo(327510),
		Blessing_Sacrifice = GetSpellInfo(6940),
		Blessing_Protection = GetSpellInfo(1022),
		Forbearance = GetSpellInfo(25771),
		
		

		--utility
		Divine_Steed = GetSpellInfo(190784),
		Rebuke = GetSpellInfo(96231),
		Hammer_Justice = GetSpellInfo(853),
		Cleanse_Toxins = GetSpellInfo(213644),
		

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



    -- divine steed
    if CanCast(ids.Divine_Steed)
    and Condition('keybind', nil, 'lshift')
	and not player:buff(ids.Divine_Steed_Buff) then
		return player:Cast(ids.Divine_Steed)
    end
	
	-- Hammer of Justice
    if CanCast(ids.Hammer_Justice)
    and Condition('keybind', nil, 'lcontrol')
	and target
    and target:enemy()
	and target:los()
	then
		return target:Cast(ids.Hammer_Justice)
    end

	
	-- Healthstone 25 percent
	--if CanUse('Healthstone')
	--and player:health() <= 40 then
	--	player:UseItem('Healthstone')
	--end
	
	-- Lay on Hands
    if CanCast(ids.Lay_Hands)
    and player:health() < 40
	and not player:debuff(ids.Forbearance) then
        return player:Cast(ids.Lay_Hands)
    end
	
	-- Lay on Hands on lowest
    if CanCast(ids.Lay_Hands)
	and lowest:health() < 40
	and player:health() > 70
	and not lowest:debuff(ids.Forbearance) then
        return lowest:Cast(ids.Lay_Hands)
    end
	
	-- Blessing of Protection on lowest
    if CanCast(ids.Blessing_Protection)
    and lowest:health() < 40
	and not lowest:debuff(ids.Forbearance) then
        return lowest:Cast(ids.Blessing_Protection)
    end
	
	-- Blessing of Sacrifice on lowest
    if CanCast(ids.Blessing_Sacrifice)
    and lowest:health() < 40
	and player:health() > 70
	and not lowest:debuff(ids.Forbearance) then
        return lowest:Cast(ids.Blessing_Sacrifice)
    end


	-- Word of Glory shining light buff free cast
	--if CanCast(ids.Word_Glory)
    --and player:health() <= 50 then
    --    return player:Cast(ids.Word_Glory)
    --end


    -- Word of Glory
    if CanCast(ids.Word_Glory)
    and player:health() < 60 then
        return player:Cast(ids.Word_Glory)
    end

	
	-- health potion 20.000
	if CanUse('Cosmic Healing Potion')
	and player:health() <= 60 then
		player:UseItem('Spiritual Healing Potion')
	end
	
	
	-- health potion 10.000
	if CanUse('Spiritual Healing Potion')
	and player:health() <= 60 then
		player:UseItem('Spiritual Healing Potion')
	end
	
	
	-- Word of Glory divine buff lowest
    if CanCast(ids.Word_Glory)
	and player:buff(ids.Divine_Purpose_Buff)
    and lowest:health() < 50 then
        return lowest:Cast(ids.Word_Glory)
    end
	
	-- Word of Glory shining buff lowest
    if CanCast(ids.Word_Glory)
	and player:buff(ids.Shining_Light_Buff)
    and lowest:health() < 50 then
        return lowest:Cast(ids.Word_Glory)
    end



	-- Word of Glory divine buff
    if CanCast(ids.Word_Glory)
	and player:buff(ids.Divine_Purpose_Buff)
    and player:health() < 80 then
        return player:Cast(ids.Word_Glory)
    end
	
	-- Word of Glory shining buff
    if CanCast(ids.Word_Glory)
	and player:buff(ids.Shining_Light_Buff)
    and player:health() < 80 then
        return player:Cast(ids.Word_Glory)
    end






	-- interrupt
	if target
	and CanCast(ids.Rebuke)
	and target:enemy()
	and target:distance() < 6
	and target:interruptAt(60) then
		return target:Cast(ids.Rebuke)
	end


    -- dps
    if target
    and target:enemy()
	and target:los()
	and target:alive()
	then
	
		if not target:buffAny('Reckless Provocation')
		or not target:buffAny('Sanguine Sphere') then
	
			-- ring use
			if CanUse('Ring of Collapsing Futures') and Condition('toggle', nil, 'Cooldowns')
			--and player:debuffCountAny('Temptation') < 3 then	-- Temptation debuff stacks from ring increases chance to trigger 5m cooldown
			and not player:debuffAny('Temptation') then  -- instead just use it every 30 sec after debuff gone off
				target:UseItem('Ring of Collapsing Futures')
			end
		
			-- Hammer of Wrath
			if CanCast(ids.Hammer_Wrath)
			and target:distance() < 30 then
				return target:Cast(ids.Hammer_Wrath)
			end

			-- Shield of Righteous divine buff + ignore range
			if Condition('toggle', nil, 'ignoreRange')
			and CanCast(ids.Shield_Righteous)
			and player:buff(ids.Divine_Purpose_Buff) then
				return target:Cast(ids.Shield_Righteous)
			end
		
			-- Shield of Righteous divine buff
			if CanCast(ids.Shield_Righteous)
			and target:distance() < 6
			and player:buff(ids.Divine_Purpose_Buff) then
				return target:Cast(ids.Shield_Righteous)
			end

			-- Shield of Righteous + ignore range
			if Condition('toggle', nil, 'ignoreRange')
			and CanCast(ids.Shield_Righteous)
			and not player:buff(ids.Shield_Righteous_Buff) then
				return target:Cast(ids.Shield_Righteous)
			end

			-- Shield of Righteous
			if CanCast(ids.Shield_Righteous)
			and target:distance() < 6
			and not player:buff(ids.Shield_Righteous_Buff) then
				return target:Cast(ids.Shield_Righteous)
			end

			-- Consecration + ignore range
			if Condition('toggle', nil, 'ignoreRange')
			and CanCast(ids.Consecration)
			and not player:buff(ids.Consecration_Buff) then
				return target:Cast(ids.Consecration)
			end

			-- Consecration
			if CanCast(ids.Consecration)
			and target:distance() < 6
			and not player:buff(ids.Consecration_Buff) then
				return target:Cast(ids.Consecration)
			end

			-- divine toll
			if CanCast(ids.Divine_Toll)
			and target:distance() < 10
			and target:areaEnemies(20) > 2 then
				return target:Cast(ids.Divine_Toll)
			end
			
			-- divine toll single target
			if CanCast(ids.Divine_Toll)
			and target:distance() < 10
			and player:areaEnemies(40) == 1 then
				return target:Cast(ids.Divine_Toll)
			end

			-- Avenger Shield AOE prio
			if CanCast(ids.Avenger_Shield)
			and target:distance() < 30
			and target:areaEnemies(10) > 2 then
				return target:Cast(ids.Avenger_Shield)
			end

			-- Judgement
			if CanCast(ids.Judgement)
			and target:distance() < 30 then
				return target:Cast(ids.Judgement)
			end

			-- Avenger Shield Single prio
			if CanCast(ids.Avenger_Shield)
			and target:distance() < 30 then
				return target:Cast(ids.Avenger_Shield)
			end

			-- Hammer of Righteous + ignore range
			if Condition('toggle', nil, 'ignoreRange')
			and CanCast(ids.Hammer_Righteous) then
				return target:Cast(ids.Hammer_Righteous)
			end

			-- Hammer of Righteous
			if CanCast(ids.Hammer_Righteous)
			and target:distance() < 6 then
				return target:Cast(ids.Hammer_Righteous)
			end

			-- Crusader Strike + ignore range
			if Condition('toggle', nil, 'ignoreRange')
			and CanCast(ids.Crusader_Strike) then
				return target:Cast(ids.Crusader_Strike)
			end

			-- Crusader Strike
			if CanCast(ids.Crusader_Strike)
			and target:distance() < 6 then
				return target:Cast(ids.Crusader_Strike)
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


	-- Word of Glory divine buff
    if CanCast(ids.Word_Glory)
	and player:buff(ids.Divine_Purpose_Buff)
    and player:health() < 80 then
        return player:Cast(ids.Word_Glory)
    end

    -- Word of Glory
    if CanCast(ids.Word_Glory)
    and player:health() < 60 then
        return player:Cast(ids.Word_Glory)
    end



end

NeP.CR:Add(66, {
	name = '[|cffA330C9ZoDDeL|r] Paladin | Protection 0.19d',
	wow_ver = "9.2.7",
	nep_ver = "2.0",
	ic = inCombat,
	ooc = outCombat,
    use_lua_engine = true,
	gui = GUI,
	load = exeOnLoad,
	unload = exeOnUnload
})
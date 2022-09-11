local NeP = NeP

local GUI = {
	{type = "texture", texture = "Interface\\AddOns\\"..local_stream_name.."\\media\\logo.blp", width = 35, height = 35, offset = 45, y= -15, align = "center"},
	--{type = 'spinner',text = 'Interrupt at (%): ', key = 'interrupt_at', width = 100, default = 43, step = 1, max = 90, min = 15, size = 11},
	{type = 'spacer', offset = 85},
	{type = 'text', text = 'work in progress'},
}

local ids

local OM_Roster = NeP.OM:Get('Roster')
NeP.DSL:Register({"area.roster", "area_roster", "areaRoster"}, function(unit, distance)
  if not NeP.DSL:Get('exists')(unit) then return 0 end
  distance = tonumber(distance) or 0
  local total = 0
  for _, Obj in pairs(OM_Roster) do
    if unit == 'player' then
      if Obj:range() <= distance then
        total = total + 1
      end
    else
      if Obj:range(nil, unit) <= distance then
        total = total + 1
      end
    end
  end
  return total
end)

local exeOnLoad = function()
	NeP.Interface:AddToggle({
		key = 'forceDps',
		name = 'Force DPS',
		text = 'Enabling this will focus on dps while lowest health is above 60%.',
		icon ='Interface\\Icons\\Ability_creature_cursed_04.png'
	})
	NeP.Interface:AddToggle({	
		key = 'autoDispel',
		name = 'AUTO DISPEL DEBUFFS IN PARTY',
		text = 'dispel specific magic debuffs in shadowlands dungeons',
		icon ='Interface\\Icons\\Ability_creature_cursed_01.png'
	})
	NeP.Interface:AddToggle({	
		key = 'autoDispel2',
		name = 'AUTO DISPEL ENEMY(in target) MAGIC BUFFS',
		text = 'dispel specific enemy magic buffs in shadowlands dungeons',
		icon ='Interface\\Icons\\Ability_creature_cursed_02.png'
	})
	ids = {
		--dps
		Smite = GetSpellInfo(585),
		Holy_Nova = GetSpellInfo(132157),
		Mindgames = GetSpellInfo(323673),
		Holy_Fire = GetSpellInfo(14914),
		Divine_Star = GetSpellInfo(110744),
		Holy_Word_Chastise = GetSpellInfo(88625),
		Shadow_Word_Death = GetSpellInfo(32379),
		Shadow_Word_Pain = GetSpellInfo(589),

		--heal
		Circle_of_Healing = GetSpellInfo(204883),
		Holy_Word_Sanctify = GetSpellInfo(34861),
		Flash_Heal = GetSpellInfo(2061),
		Power_Word_Shield = GetSpellInfo(17),
		Weakened_Soul = GetSpellInfo(6788),
		Guardian_Spirit = GetSpellInfo(47788),
		Holy_Word_Serenity = GetSpellInfo(2050),
		Prayer_of_Mending = GetSpellInfo(33076),
		Prayer_of_Healing = GetSpellInfo(596),
		Renew = GetSpellInfo(139),
		Heal = GetSpellInfo(2060),
		Halo = GetSpellInfo(120517),
		Desperate_Prayer = GetSpellInfo(19236),

		--buffs
		Surge_of_Light = GetSpellInfo(114255),
		Angelic_Feather = GetSpellInfo(121536),
		Angelic_Feather_buff = GetSpellInfo(121557),
		Power_Word_Fortitude = GetSpellInfo(21562),
		Spirit_of_Redemption = GetSpellInfo(27827),
		Prayer_of_Mending_buff = GetSpellInfo(41635),
		Power_Infusion = GetSpellInfo(10060),
		Apotheosis = GetSpellInfo(200183),
		Fae_Guardians = GetSpellInfo(327661),
		Haunted_Mask = GetSpellInfo(356968),
		Potion_Hidden_Spirit = GetSpellInfo(307195),
		
		
		--utility
		Psychic_Scream = GetSpellInfo(8122),


		--debuffs shadowlands
		Purify = GetSpellInfo(527),
		Dispel_Magic = GetSpellInfo(528),
		Mass_Dispel = GetSpellInfo(32375),
		Quake_affix = GetSpellInfo(240447),
		Sanguine_affix = GetSpellInfo(226510),
		--Intangible_Presence = GetSpellInfo(227404),
		
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



    -- Angelic Feather
    if CanCast(ids.Angelic_Feather)
    and Condition('keybind', nil, 'lshift')
	and not player:buff(ids.Angelic_Feather_buff) then
		return player:CastGround(ids.Angelic_Feather)
    end

	-- Mass Dispel
    if CanCast(ids.Mass_Dispel)
    and Condition('keybind', nil, 'lcontrol') then
        return mouseover and mouseover:CastGround(ids.Mass_Dispel)
    end
	
	-- Power Infusion Self
    if CanCast(ids.Power_Infusion)
    and Condition('keybind', nil, 'rcontrol') then
        return player:Cast(ids.Power_Infusion)
    end
	
	-- Apotheosis
    if CanCast(ids.Apotheosis)
    and Condition('keybind', nil, 'rcontrol') then
        return player:Cast(ids.Apotheosis)
    end
	
	-- Fae Guardians
    if CanCast(ids.Fae_Guardians)
    and Condition('keybind', nil, 'rcontrol') then
        return player:Cast(ids.Fae_Guardians)
    end
	
	-- channeling cancel protection
	if player:channelingPercent() > 0 then
		return
	end
	
	-- casting cancel protection
	if player:castingPercent() > 0 then
		return
	end
	
	-- invis pot protection
	if player:buffAny(ids.Potion_Hidden_Spirit) then
		return
	end
	
	
	
---- Spirit of Redemption logic (do you even work?)  ----
	if player:buff(ids.Spirit_of_Redemption) and lowest and lowest:los() then


		-- Holy Word: Sanctify
		if CanCast(ids.Holy_Word_Sanctify) then
			for _, obj in pairs(NeP.OM:Get('Roster')) do
				if obj:areaHeal('10,80') > 1
				and obj:los() then
					return obj:CastGround(ids.Holy_Word_Sanctify)
				end
			end
		end

		-- Holy Word: Serenity
		if CanCast(ids.Holy_Word_Serenity)
		and lowest:health() <= 50
		and not lowest:buff(ids.Spirit_of_Redemption) then
			return lowest:Cast(ids.Holy_Word_Serenity)
		end

		-- Power Word: Shield
		if CanCast(ids.Power_Word_Shield)
		and lowest:health() <= 50
		and not lowest:buffAny(ids.Power_Word_Shield)
		and not lowest:debuffAny(ids.Weakened_Soul) then
			return lowest:Cast(ids.Power_Word_Shield)
		end

		-- Circle of Healing
		if CanCast(ids.Circle_of_Healing)
		and lowest:areaHeal('30,80') > 2
		and not lowest:buff(ids.Spirit_of_Redemption) then
			return lowest:Cast(ids.Circle_of_Healing)
		end

		-- Surge of Light
		if CanCast(ids.Flash_Heal)
		and lowest:health() <= 80
		and player:buff(ids.Surge_of_Light)
		and not lowest:buff(ids.Spirit_of_Redemption) then
			return lowest:Cast(ids.Flash_Heal)
		end

		-- Halo (just cast with no logic)
		if CanCast(ids.Halo) then
			return player:Cast(ids.Halo)
		end

		-- Prayer of Mending
		if CanCast(ids.Prayer_of_Mending)
		and lowest:health() < 85
		and lowest:buffCount(ids.Prayer_of_Mending_buff) < 5 then
			return lowest:Cast(ids.Prayer_of_Mending)
		end

		-- Renew
		if CanCast(ids.Renew)
		and lowest:health() < 85
		and not lowest:buff(ids.Renew) then
			return lowest:Cast(ids.Renew)
		end

		-- Flash Heal
		if CanCast(ids.Flash_Heal)
		and lowest:health() < 90 then
			return lowest:Cast(ids.Flash_Heal)
		end

		--return?
    end
	

	
---- dispel party debuffs  ----
	if Condition('toggle', nil, 'autoDispel') and CanCast(ids.Purify)  then
		
		--player
		if player:debuffAny('Glyph of Restraint')
		or player:debuffAny('Empowered Glyph of Restraint')
		or player:debuffAny('Purification Protocol')
		or player:debuffAny('Cosmic Artorice')
		or player:debuffAny('Hex')
		or player:debuffAny('Sinlight Visions')
		or player:debuffAny('Siphon Lore')
		or player:debuffAny('Slime Injection')
		or player:debuffAny('Plague Bomb')
		or player:debuffAny('Violent Detonation')
		or player:debuffAny('Corroded Claws')
		or player:debuffAny('Debilitating Plague')
		or player:debuffAny('Infectious Rain')
		or player:debuffAny('Corrosive Gunk')
		or player:debuffAny('Wrack Soul')
		or player:debuffAny('Forced Confession')
		or player:debuffAny('Lingering Doubt')
		or player:debuffAny('Burden of Knowledge')
		or player:debuffAny('Dark Lance')
		or player:debuffAny('Lost Confidence')
		or player:debuffCountAny('Clinging Darkness') > 4
		or player:debuffCountAny('Burst') > 1
		or player:debuffAny('Soul Corruption')
		or player:debuffAny('Phantasmal Parasite')
		or player:debuffAny("Predator's Howl")
		or player:debuffAny('Rapid Growth')
		or player:debuffAny('Fated Power: Creation Spark')
		or player:debuffAny('Creation Spark')
		or player:debuffAny('Arcing Zap')
		or player:debuffAny('50,000 Volts')
		or player:debuffAny('Shadow Claws')
		or player:debuffAny('Carrion Swarm')
		or player:debuffAny('Arcane Bomb')
		or player:debuffCountAny('Frost Breath') > 1
		or player:debuffCountAny('Withering Soul') > 1
		or player:debuffAny('Flaming Refuse')
		or player:debuffAny('Shrink')
		or player:debuffAny('Magic Binding')
		or player:debuffAny('Sandstorm')
		or player:debuffAny('Despair')
		or player:debuffAny('Scorching Shot')
		or player:debuffAny('Darksoul Drain')
		or player:debuffAny('Festering Rip')
		or player:debuffAny('Flesh to Stone')
		or player:debuffAny('Soul Blade')
		or player:debuffAny('Gift of the Doomsayer')
		or player:debuffAny('Shackles of Servitude')
		or player:debuffAny('Allured')
		or player:debuffAny('Consuming Slime') then
			return player:Cast(ids.Purify)
		end
		
		if player:debuffAny('Frozen Binds') and player:areaRoster(17) == 1 then
			return player:Cast(ids.Purify)
		end

	
		--lowest
		if lowest:debuffAny('Glyph of Restraint')
		or lowest:debuffAny('Empowered Glyph of Restraint')
		or lowest:debuffAny('Purification Protocol')
		or lowest:debuffAny('Cosmic Artorice')
		or lowest:debuffAny('Hex')
		or lowest:debuffAny('Sinlight Visions')
		or lowest:debuffAny('Siphon Lore')
		or lowest:debuffAny('Slime Injection')
		or lowest:debuffAny('Plague Bomb')
		or lowest:debuffAny('Violent Detonation')
		or lowest:debuffAny('Corroded Claws')
		or lowest:debuffAny('Debilitating Plague')
		or lowest:debuffAny('Infectious Rain')
		or lowest:debuffAny('Corrosive Gunk')
		or lowest:debuffAny('Wrack Soul')
		or lowest:debuffAny('Forced Confession')
		or lowest:debuffAny('Lingering Doubt')
		or lowest:debuffAny('Burden of Knowledge')
		or lowest:debuffAny('Dark Lance')
		or lowest:debuffAny('Lost Confidence')
		or lowest:debuffCountAny('Clinging Darkness') > 4
		or lowest:debuffCountAny('Burst') > 1
		or lowest:debuffAny('Soul Corruption')
		or lowest:debuffAny('Phantasmal Parasite')
		or lowest:debuffAny("Predator's Howl")
		or lowest:debuffAny('Rapid Growth')
		or lowest:debuffAny('Nightmare')
		or lowest:debuffAny('Discom-BOMB-ulator')
		or lowest:debuffAny('Fated Power: Creation Spark')
		or lowest:debuffAny('Creation Spark')
		or lowest:debuffAny('Arcing Zap')
		or lowest:debuffAny('50,000 Volts')
		or lowest:debuffAny('Shadow Claws')
		or lowest:debuffAny('Carrion Swarm')
		or lowest:debuffAny('Cloud of Hypnosis')
		or lowest:debuffAny('Arcane Bomb')
		or lowest:debuffAny('Screams of the Dead')
		or lowest:debuffCountAny('Frost Breath') > 1
		or lowest:debuffCountAny('Withering Soul') > 1
		or lowest:debuffAny('Flaming Refuse')
		or lowest:debuffAny('Shrink')
		--or lowest:debuffAny('Chaotic Shadows')
		or lowest:debuffAny('Gooped')
		or lowest:debuffAny('Static Nova')
		or lowest:debuffAny('Stasis Beam')
		--or lowest:debuffAny('Infinite Breath') undispellable?
		or lowest:debuffAny('Polymorph: Fish')
		or lowest:debuffAny('Magic Binding')
		or lowest:debuffAny('Sandstorm')
		or lowest:debuffAny('Despair')
		or lowest:debuffAny('Tormenting Fear')
		or lowest:debuffAny('Scorching Shot')
		or lowest:debuffAny('Darksoul Drain')
		or lowest:debuffAny('Festering Rip')
		or lowest:debuffAny('Flesh to Stone')
		or lowest:debuffAny('Soul Blade')
		or lowest:debuffAny('Gift of the Doomsayer')
		or lowest:debuffAny('Coat Check')
		or lowest:debuffAny('Shackles of Servitude')
		or lowest:debuffAny('Allured')
		or lowest:debuffAny('Consuming Slime') then
			return lowest:Cast(ids.Purify)
		end
	
		if lowest:debuffAny('Frozen Binds') and lowest:areaRoster(17) == 1 then
			return lowest:Cast(ids.Purify)
		end
		
		
		--anyone else in party
		for _,Obj in pairs(NeP.OM:Get('Roster')) do
			if Obj:debuffAny('Glyph of Restraint')
			or Obj:debuffAny('Empowered Glyph of Restraint')
			or Obj:debuffAny('Purification Protocol')
			or Obj:debuffAny('Cosmic Artorice')
			or Obj:debuffAny('Hex')
			or Obj:debuffAny('Sinlight Visions')
			or Obj:debuffAny('Siphon Lore')
			or Obj:debuffAny('Slime Injection')
			or Obj:debuffAny('Plague Bomb')
			or Obj:debuffAny('Violent Detonation')
			or Obj:debuffAny('Corroded Claws')
			or Obj:debuffAny('Debilitating Plague')
			or Obj:debuffAny('Infectious Rain')
			or Obj:debuffAny('Corrosive Gunk')
			or Obj:debuffAny('Wrack Soul')
			or Obj:debuffAny('Forced Confession')
			or Obj:debuffAny('Lingering Doubt')
			or Obj:debuffAny('Burden of Knowledge')
			or Obj:debuffAny('Dark Lance')
			or Obj:debuffAny('Lost Confidence')
			or Obj:debuffCountAny('Clinging Darkness') > 4
			or Obj:debuffCountAny('Burst') > 1
			or Obj:debuffAny('Soul Corruption')
			or Obj:debuffAny('Phantasmal Parasite')
			or Obj:debuffAny("Predator's Howl")
			or Obj:debuffAny('Rapid Growth')
			or Obj:debuffAny('Nightmare')
			or Obj:debuffAny('Blazing Chomp')
			or Obj:debuffAny('Discom-BOMB-ulator')
			or Obj:debuffAny('Fated Power: Creation Spark')
			or Obj:debuffAny('Creation Spark')
			or Obj:debuffAny('Arcing Zap')
			or Obj:debuffAny('50,000 Volts')
			or Obj:debuffAny('Shadow Claws')
			or Obj:debuffAny('Carrion Swarm')
			or Obj:debuffAny('Cloud of Hypnosis')
			or Obj:debuffAny('Arcane Bomb')
			or Obj:debuffAny('Screams of the Dead')
			or Obj:debuffCountAny('Frost Breath') > 1
			or Obj:debuffCountAny('Withering Soul') > 1
			or Obj:debuffAny('Flaming Refuse')
			or Obj:debuffAny('Shrink')
			or Obj:debuffAny('Burning Blast')
			--or Obj:debuffAny('Chaotic Shadows')
			or Obj:debuffAny('Gooped')
			or Obj:debuffAny('Static Nova')
			or Obj:debuffAny('Stasis Beam')
			or Obj:debuffAny('Lockdown')
			--or Obj:debuffAny('Infinite Breath')  undispellable?
			or Obj:debuffAny('Energy Slash')
			or Obj:debuffAny('Polymorph: Fish')
			or Obj:debuffAny('Magic Binding')
			or Obj:debuffAny('Sandstorm')
			or Obj:debuffAny('Despair')
			or Obj:debuffAny('Tormenting Fear')
			or Obj:debuffAny('Scorching Shot')
			or Obj:debuffAny('Darksoul Drain')
			or Obj:debuffAny('Festering Rip')
			or Obj:debuffAny('Flesh to Stone')
			or Obj:debuffAny('Soul Blade')
			or Obj:debuffAny('Gift of the Doomsayer')
			or Obj:debuffAny('Coat Check')
			or Obj:debuffAny('Shackles of Servitude')
			or Obj:debuffAny('Allured')
			--or Obj:debuffAny(227404)		-- Intangible_Presence by attumen
			or Obj:debuffAny('Consuming Slime') then
			 return Obj:Cast(ids.Purify)
			end
			
			if Obj:debuffAny('Frozen Binds') and Obj:areaRoster(17) == 1 then
				return Obj:Cast(ids.Purify)
			end
			
		end


	end
	


----player self heal----

	if not player:debuffAny('Gluttonous Miasma') then

		-- Guardian Spirit
		if CanCast(ids.Guardian_Spirit)
		and player:health() <= 30 then
			return player:Cast(ids.Guardian_Spirit)
		end

		-- Desperate Prayer
		if CanCast(ids.Desperate_Prayer)
		and player:health() <= 40 then
			return player:Cast(ids.Desperate_Prayer)
		end

		-- Holy Word: Serenity
		if CanCast(ids.Holy_Word_Serenity)
		and player:health() <= 50 then
			return player:Cast(ids.Holy_Word_Serenity)
		end

		
		-- Healthstone 25 percent
		--if CanUse('Healthstone')
		--and player:health() <= 40 then
		--	player:UseItem('Healthstone')
		--end

		-- heal trinket Manabound Mirror
		--if CanUse('Manabound Mirror')
		--and player:health() <= 60 then
		--	return player:Use('Manabound Mirror')
		--end
		
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
		
		-- mana potion
		--if CanUse('Spiritual Mana Potion')
		--and player:mana() <= 60 then
		--	return player:Use('Spiritual Mana Potion')
		--end


		-- Power Word: Shield
		if CanCast(ids.Power_Word_Shield) and not player:buffAny(ids.Power_Word_Shield) then
			if player:health() <= 60
			and not player:debuffAny(ids.Weakened_Soul) then
				return player:Cast(ids.Power_Word_Shield)
			end
		end

		-- Surge of Light
		if CanCast(ids.Flash_Heal)
		and player:health() <= 60
		and player:buff(ids.Surge_of_Light) then
			return player:Cast(ids.Flash_Heal)
		end

		-- Prayer of Mending
		--if CanCast(ids.Prayer_of_Mending)
		--and player:health() <= 80
		--and player:buffCount(ids.Prayer_of_Mending_buff) < 5 then
		--	return player:Cast(ids.Prayer_of_Mending)
		--end
		
		-- Prayer of Mending
		--if CanCast(ids.Prayer_of_Mending)
		--and player:health() <= 80
		--and not player:buff(ids.Prayer_of_Mending_buff) then
		--	return player:Cast(ids.Prayer_of_Mending)
		--end

		-- Flash Heal
		if CanCast(ids.Flash_Heal) and not player:moving() then
			if player:health() <= 40
			and not player:debuffAny(ids.Quake_affix) then
				return player:Cast(ids.Flash_Heal)
			end
		end
		
		-- Heal
		if CanCast(ids.Heal) and not player:moving() then
			if player:health() <= 50
			and not player:debuffAny(ids.Quake_affix) then
				return player:Cast(ids.Heal)
			end
		end

	end


---- dispel enemy buffs  ----
	if Condition('toggle', nil, 'autoDispel2') and CanCast('Dispel Magic') then
	
		if target and target:enemy() and target:los() and target:distance() < 30 then
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
				return target:Cast(ids.Dispel_Magic)
			end
		end
		
		-- off target dispel enemy buffs
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 30 and obj:los() and obj:alive() and obj:combat() then
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
					return obj:Cast(ids.Dispel_Magic)
				end	
			end
		end


	end




---- Explosive Orb Cleaner ----
	if CanCast(ids.Shadow_Word_Pain) then
		for _, obj in pairs(NeP.OM:Get('Critters')) do
			if obj.id == 120651
			and obj:distance() < 40
			and obj:los()
			and obj:alive() then
				return obj:Cast(ids.Shadow_Word_Pain)
			end
		end
	end

	if CanCast(ids.Shadow_Word_Pain) then
		for _, obj in pairs(NeP.OM:Get('Critters')) do
			if obj.name == "Explosives"
			and obj:distance() < 40
			and obj:los()
			and obj:alive() then
				return obj:Cast(ids.Shadow_Word_Pain)
			end
		end
	end

    if target
    and target.id == 120651
	and target:los() then
		if CanCast(ids.Shadow_Word_Pain) then
			return target:Cast(ids.Shadow_Word_Pain)
		end
	
	end

    if target
    and target.name == "Explosives"
	and target:los() then
		if CanCast(ids.Shadow_Word_Pain) then
			return target:Cast(ids.Shadow_Word_Pain)
		end
	
	end


---- interrupt and CC ----

	-- off target interrupt(stun) by chastise talent stun
	if player:spellCooldown(ids.Holy_Word_Chastise) == 0 then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 30
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:interruptAt(60) then
				return obj:Cast(ids.Holy_Word_Chastise)
			end
		end
	end
	
	-- off target interrupt(fear) by psychic scream in melee+ range
	if player:spellCooldown(ids.Psychic_Scream) == 0 then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 8
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:interruptAt(60) then
				return obj:Cast(ids.Psychic_Scream)
			end
		end
	end


---- kael'thas heal ----
	if target
    and target.id == 165759
	and target:los() then
		if player:health() > 80
		and lowest:health() > 80 then
		
			-- Holy Word: Serenity
			if CanCast(ids.Holy_Word_Serenity) then
				return target:Cast(ids.Holy_Word_Serenity)
			end

			-- Surge of Light
			if CanCast(ids.Flash_Heal)
			and player:buff(ids.Surge_of_Light) then
				return target:Cast(ids.Flash_Heal)
			end

			-- Renew
			if CanCast(ids.Renew)
			and not target:buff(ids.Renew) then
				return target:Cast(ids.Renew)
			end

			-- Heal
			if CanCast(ids.Heal) and not player:moving() then
				if not player:debuffAny(ids.Quake_affix) then
					return target:Cast(ids.Heal)
				end
			end

		end
		
	end


	-- Shadow Word: Death off target force dps
	if CanCast(ids.Shadow_Word_Death) and player:health() > 80 and lowest:health() > 80 and Condition('toggle', nil, 'forceDps')  then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 40
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:enemy()
			and obj:health() < 15 then
				return obj:Cast(ids.Shadow_Word_Death)
			end
		end
	end
	

	-- spread sw:pain off target on force dps
	if CanCast(ids.Shadow_Word_Pain) and player:mana() > 30 and lowest:health() > 80 and Condition('toggle', nil, 'forceDps') then
		for _, obj in pairs(NeP.OM:Get('Enemy')) do
			if obj:distance() < 40
			and obj:los()
			and obj:alive()
			and obj:combat()
			and obj:enemy()
			and not obj:debuff(ids.Shadow_Word_Pain) then
				return obj:Cast(ids.Shadow_Word_Pain)
			end
		end
	end



---- dps phase  ----
    if target
    and target:enemy()
	and target:los()
    and (
        not lowest
        or lowest:health() > 85
        or (
            Condition('toggle', nil, 'forceDps')
            and lowest:health() >= 60
        )
    ) then
		if not target:buffAny('Reckless Provocation')
		or not target:buffAny('Sanguine Sphere') then
		
		
			-- Shadow Word: Death
			if CanCast(ids.Shadow_Word_Pain) and player:health() > 80 then
				if target:distance() < 39
				and target:alive()
				and target:health() < 15 then
					return target:Cast(ids.Shadow_Word_Pain)
				end
			end
		
			-- Shadow Word: Pain
			if CanCast(ids.Shadow_Word_Pain) and player:mana() > 30 then
				if target:distance() < 39
				and not target:debuff(ids.Shadow_Word_Pain) then
					return target:Cast(ids.Shadow_Word_Pain)
				end
			end

			-- Holy Word: Chastise single target dps waste
			if CanCast(ids.Holy_Word_Chastise) then
				if target:distance() < 29 
				and target:areaEnemies(20) == 1
				--and player:areaEnemies(20) < 2
				and (
					not target:debuffAny(ids.Sanguine_affix)
					or not target:buffAny(ids.Sanguine_affix)
					) then
					return target:Cast(ids.Holy_Word_Chastise)
				end
			end

			-- Holy Word: Chastise force dps
			if CanCast(ids.Holy_Word_Chastise) and player:mana() > 30 and Condition('toggle', nil, 'forceDps')  then
				if target:distance() < 29
				and (
					not target:debuffAny(ids.Sanguine_affix)
					or not target:buffAny(ids.Sanguine_affix)
					) then
					return target:Cast(ids.Holy_Word_Chastise)
				end
			end

			-- Divine Star (no AOE logic)
			if CanCast(ids.Divine_Star) and player:mana() > 30 and Condition('toggle', nil, 'forceDps')  then
				if target:distance() < 20
				and player:infront() then
					return target:Cast(ids.Divine_Star)
				end
			end

			-- holy nova AOE test
			--if CanCast(ids.Holy_Nova)
			--and target:distance() < 8
			--and player:mana() > 30
			--and player:areaEnemies(12) > 4 then
			--	return target:Cast(ids.Holy_Nova)
			--end

			-- Holy Fire
			if CanCast(ids.Holy_Fire) and player:mana() > 30 and not player:moving() then
				if target:distance() < 39
				and target:ttd() > 3
				and not player:debuffAny(ids.Quake_affix) then
					return target:Cast(ids.Holy_Fire)
				end
			end

			-- Mindgames (vampire covenant)
			if CanCast(ids.Mindgames) and player:mana() > 30 and not player:moving() then
				if target:distance() < 39
				and target:ttd() > 3
				and not player:debuffAny(ids.Quake_affix) then
					return target:Cast(ids.Mindgames)
				end
			end

			-- holy nova AOE test
			--if CanCast(ids.Holy_Nova)
			--and target:distance() < 8
			--and player:mana() > 30
			--and player:areaEnemies(12) > 2 then
			--	return target:Cast(ids.Holy_Nova)
			--end

			-- Smite
			if CanCast(ids.Smite) and player:mana() > 10 and not player:moving() then
				if target:distance() < 39
				and not player:debuffAny(ids.Quake_affix) then
					return target:Cast(ids.Smite)
				end
			end
		end
    end

    -- if no one is taking dmg then just stop
    if not lowest or lowest:health() >= 100 then return end



----  aoe heal instant  ----

    -- Circle of Healing
    if CanCast(ids.Circle_of_Healing)
    and lowest:areaHeal('30,85') > 2
	and lowest:los()
	and not lowest:debuffAny('Gluttonous Miasma') then
        return lowest:Cast(ids.Circle_of_Healing)
    end

    -- Holy Word: Sanctify
    if CanCast(ids.Holy_Word_Sanctify) then
        for _, obj in pairs(NeP.OM:Get('Roster')) do
            if obj:areaHeal('10,80') > 2
            and obj:los()
			and not obj:debuffAny('Gluttonous Miasma') then
                return obj:CastGround(ids.Holy_Word_Sanctify)
            end
        end
    end

---- tank heal  ----


    -- tank logic
    if tank and tank:los() and not tank:debuffAny('Gluttonous Miasma') then

		-- Guardian Spirit
		if CanCast(ids.Guardian_Spirit)
		and tank:health() <= 30 then
			return tank:Cast(ids.Guardian_Spirit)
		end

		-- Holy Word: Serenity
		if CanCast(ids.Holy_Word_Serenity)
		and tank:health() <= 60 then
			return tank:Cast(ids.Holy_Word_Serenity)
		end

        -- Power Word: Shield (TANK)
        if CanCast(ids.Power_Word_Shield) and not tank:buffAny(ids.Power_Word_Shield) then
			if not tank:debuffAny(ids.Weakened_Soul) then
				return tank:Cast(ids.Power_Word_Shield)
			end
		end

		-- Prayer of Mending
        if CanCast(ids.Prayer_of_Mending)
		and tank:buffCount(ids.Prayer_of_Mending_buff) < 5 then
            return tank:Cast(ids.Prayer_of_Mending)
        end
		
		-- Prayer of Mending
        if CanCast(ids.Prayer_of_Mending)
		and not tank:buff(ids.Prayer_of_Mending_buff) then
            return tank:Cast(ids.Prayer_of_Mending)
        end

        -- Surge of Light
        if CanCast(ids.Flash_Heal)
        and tank:health() <= 70
        and player:buff(ids.Surge_of_Light) then
            return tank:Cast(ids.Flash_Heal)
        end

		-- Renew
		if CanCast(ids.Renew)
		and tank:health() < 85
		and not tank:buff(ids.Renew) then
			return tank:Cast(ids.Renew)
		end

		-- Flash Heal
		if CanCast(ids.Flash_Heal) and not player:moving() then
			if tank:health() < 50 
			and not player:debuffAny(ids.Quake_affix) then
				return tank:Cast(ids.Flash_Heal)
			end
		end




    end


---- aoe heal casting  ----

    -- Prayer of Healing
    if CanCast(ids.Prayer_of_Healing) and not player:moving() then
		if not player:debuffAny(ids.Quake_affix) then
			if lowest:areaHeal('40,80') > 2 
			and not lowest:debuffAny('Gluttonous Miasma') then
				return lowest:Cast(ids.Prayer_of_Healing)
			end
		end
	end



---- heal rotation  ----

    -- make sure lowest is on LOS
    if lowest and lowest:los() and not lowest:debuffAny('Gluttonous Miasma') then

        -- Power Word: Shield
        if CanCast(ids.Power_Word_Shield) and not lowest:buffAny(ids.Power_Word_Shield) then
			if lowest:health() <= 30
			and not lowest:debuffAny(ids.Weakened_Soul) then
				return lowest:Cast(ids.Power_Word_Shield)
			end
		end

        -- Holy Word: Serenity
        if CanCast(ids.Holy_Word_Serenity)
        and lowest:health() <= 40 then
            return lowest:Cast(ids.Holy_Word_Serenity)
        end

        -- Prayer of Mending
        --if CanCast(ids.Prayer_of_Mending)
        --and lowest:health() < 85 
		--and lowest:buffCount(ids.Prayer_of_Mending_buff) < 5 then
        --    return lowest:Cast(ids.Prayer_of_Mending)
        --end

        -- Prayer of Mending
        --if CanCast(ids.Prayer_of_Mending)
        --and lowest:health() < 85 
		--and not lowest:buff(ids.Prayer_of_Mending_buff) then
        --    return lowest:Cast(ids.Prayer_of_Mending)
        --end

		-- Surge of Light
		if CanCast(ids.Flash_Heal)
		and lowest:health() <= 85
		and player:buff(ids.Surge_of_Light) then
			return lowest:Cast(ids.Flash_Heal)
		end

        -- Renew
        if CanCast(ids.Renew)
        and lowest:health() < 85
        and not lowest:buff(ids.Renew) then
            return lowest:Cast(ids.Renew)
        end

        -- Heal
        if CanCast(ids.Heal) and not player:moving() then
			if lowest:health() < 80 
			and not player:debuffAny(ids.Quake_affix) then
				return lowest:Cast(ids.Heal)
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
	local friendly = Unit('friendly')
	
	
	
	
	-- pause
    if Condition('keybind', nil, 'lalt') then
		return
    end
	

    -- Angelic Feather
    if CanCast(ids.Angelic_Feather)
    and Condition('keybind', nil, 'lshift')
	and not player:buffAny(ids.Angelic_Feather_buff) then
		return player:CastGround(ids.Angelic_Feather)
    end

	-- channeling cancel protection
	if player:channelingPercent() > 0 then
		return
	end
	
	-- casting cancel protection
	if player:castingPercent() > 0 then
		return
	end

	-- Power Word: Fortitude check anyone in party/raid
	if CanCast(ids.Power_Word_Fortitude) and player:mana() > 80 then
		for _, obj in pairs(NeP.OM:Get('Roster')) do
			if not obj:buffAny(ids.Power_Word_Fortitude) then
				if obj:distance() < 40
				and obj:los()
				and obj:alive() then
					return obj:Cast(ids.Power_Word_Fortitude)
				end
			end
		end
	end



	-- Healthstone
	--if CanUse('Healthstone')
	--and player:health() <= 40 then
	--	return player:Use('Healthstone')
	--end

	-- heal trinket Manabound Mirror
	--if CanUse('Manabound Mirror')
	--and player:health() <= 60 then
	--	return player:Use('Manabound Mirror')
	--end
	
	-- mana potion
	--if CanUse('Spiritual Mana Potion')
	--and player:mana() <= 60 then
	--	return player:Use('Spiritual Mana Potion')
	--end




-- make sure lowest is on LOS
    if lowest and lowest:los() then

		-- Circle of Healing
		if CanCast(ids.Circle_of_Healing)
		and player:areaHeal('30,80') > 3 then
			return player:Cast(ids.Circle_of_Healing)
		end

		-- Holy Word: Sanctify
		if CanCast(ids.Holy_Word_Sanctify) then
			for _, obj in pairs(NeP.OM:Get('Roster')) do
				if obj:areaHeal('10,80') > 2
				and obj:los() then
					return obj:CastGround(ids.Holy_Word_Sanctify)
				end
			end
		end

        -- Surge of Light
        if CanCast(ids.Flash_Heal)
        and lowest:health() <= 70
        and player:buff(ids.Surge_of_Light) then
            return lowest:Cast(ids.Flash_Heal)
        end


        -- Holy Word: Serenity
        if CanCast(ids.Holy_Word_Serenity)
		and lowest:health() <= 40 then
            return lowest:Cast(ids.Holy_Word_Serenity)
        end


        -- Renew
        if CanCast(ids.Renew)
        and lowest:health() < 70
        and not lowest:buff(ids.Renew) then
            return lowest:Cast(ids.Renew)
        end


    end



end

NeP.CR:Add(257, {
	name = '[|cffA330C9ZoDDeL|r] Priest | Holy 1.01',
	wow_ver = "9.2.7",
	nep_ver = "2.0",
	ic = inCombat,
	ooc = outCombat,
    use_lua_engine = true,
	gui = GUI,
	load = exeOnLoad,
	unload = exeOnUnload
})
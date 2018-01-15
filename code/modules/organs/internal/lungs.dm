/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = BP_LUNGS
	parent_organ = BP_CHEST
	w_class = ITEM_SIZE_NORMAL
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 60

	var/active_breathing = 1

	var/list/breath_type
	var/list/poison_type
	var/list/exhale_type

	var/min_breath_pressure

	var/oxygen_deprivation = 0
	var/safe_exhaled_max = 10
	var/safe_toxins_max = 0.2
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	var/breathing = 0
	var/list/last_breath
	var/list/last_failed_breath
	var/breath_fail_ratio // How badly they failed a breath. Higher is worse.

	var/holding = 0

	var/last_breath_pressure = 1 ATMOSPHERE
	var/pneumothorax_pressure_dif = 0.5 ATMOSPHERE
	var/max_lung_pressure = 1.5 ATMOSPHERE

/obj/item/organ/internal/lungs/proc/New()
	..()
	max_lung_pressure = species.hazard_high_pressure * 1.05
	if(robotic >= ORGAN_ROBOT)
		max_lung_pressure *= 1.15
	pneumothorax_pressure_dif = max_lung_pressure / 3


/obj/item/organ/internal/lungs/proc/inhale(datum/gas_mixture/breath, var/volume = BREATH_VOLUME, var/forced)
	if(!owner)
		return 1
	if(!breath)
		handle_failed_breath()
		return 1

	var/breath_pressure = breath.total_moles*R_IDEAL_GAS_EQUATION*breath.temperature/volume
	if(abs(breath_pressure - last_breath_pressure) > pneumothorax_pressure_dif) )
		var/lung_rupture_prob =  abs(breath_pressure - last_breath_pressure)/pneumothorax_pressure_dif * 50
		if(robotic >= ORGAN_ROBOT ? lung_rupture_prob *= 0.60) //Robotic lungs are less likely to rupture.
			if(!is_bruised() && lung_rupture_prob) //only rupture if NOT already ruptured
				rupture()

	if(breath_pressure > max_lung_pressure)
		rupture()

	if(breath.total_moles == 0)
		breath_fail_ratio = 1
		handle_failed_breath()
		return 1

	process_breath(breath)


/obj/item/organ/internal/lungs/proc/handle_failed_breath()
	if(holding)
		return

	if(prob(15) && !owner.nervous_system_failure())
		if(!owner.is_asystole())
			if(active_breathing)
				owner.emote("gasp")

	owner.oxygen_alert = max(owner.oxygen_alert, 2)


/obj/item/organ/internal/lungs/proc/process_gas(datum/gas_mixture/breath)
	for(var/V in breath.gas)
		var/gas = breath.gas[V]
		switch(gas)
			if("sleeping_agent")

				var/pp = (breath.gas["sleeping_agent"] / breath.total_moles) * breath_pressure
				if(pp > SA_para_min)		// Enough to make us paralysed for a bit
					owner.Paralyse(3)	// 3 gives them one second to wake up and run away a bit!
					if(pp > SA_sleep_min)	// Enough to make us sleep as well
						owner.Sleeping(5)
				else if(pp > 0.15)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
					if(prob(20))
						owner.emote(pick("giggle", "laugh"))

				breath.adjust_gas("sleeping_agent", -breath.gas["sleeping_agent"]/6) //update after

			if("phoron")
				var/pp = (breath.gas["sleeping_agent"] / breath.total_moles) * breath_pressure
				if(prob(pp/3) && pp > 0.15)
					to_chat(owner, "You smell something sour.")

		if(gas in poison_type)
			var/toxins_pp = (breath.gas[V] / breath.total_moles) * breath_pressure
			// Too much poison in the air.
			if(toxins_pp > safe_toxins_max)
				var/ratio = (poison/safe_toxins_max) * 10
				if(robotic >= ORGAN_ROBOT)
					ratio /= 2 //Robolungs filter out some of the inhaled toxic air.
				owner.reagents.add_reagent(/datum/reagent/toxin, Clamp(ratio, MIN_TOXIN_DAMAGE, MAX_TOXIN_DAMAGE))
				breath.adjust_gas(V, -poison/6, update = 0) //update after
				owner.phoron_alert = 1
			else
				owner.phoron_alert = 0

/obj/item/organ/internal/lungs/proc/process_breath(datum/gas_mixture/breath)

	process_gas(breath)
	var/inhale_efficiency = 0
	var/blood_oxy = owner.get_blood_oxygenation()
	var/required_oxy = (100-blood_oxy) * 32
	var/inhaled_gas_used = min(1,required_oxy)
	for(var/V in breath_type)
		breath.adjust_gas(V, -inhaled_gas_used/breath_type.len, update = 1) //update afterwards
		inhale_efficiency += ( min(1,rand(0.2)+(0.95 * get_damage()/max_damage) ) * inhaled_gas_used/(required_oxy*breath_type.len)
	inhale_efficiency = min(1, inhale_efficiency)

	owner.adjustOxyLoss(inhale_efficiency * -10)

	//
//	need fix
//	owner.oxygen_alert = failed_inhale * 2

	//Sort_poison
	if(exhale_type)
		var/exhale_efficiency = 0
		for(var/V in exhale_type)
			breath.adjust_gas_temp(V, inhaled_gas_used/exhale_type.len, owner.bodytemperature, update = 0) //update afterwards
			exhale_efficiency += min(1,rand(0.2)+(0.95 * get_damage()/max_damage) ) * inhaled_gas_used/exhale_type.len
		exhale_efficiency = min(1,exhale_efficiency)
		exhaled_pp = inhaled_gas_used * exhale_efficiency

		if(exhaled_pp > safe_exhaled_max)
			word = pick("extremely dizzy","short of breath","faint","confused")
			warn_prob = 15
			oxyloss = HUMAN_MAX_OXYLOSS
			alert = 1
			failed_exhale = 1
		else if(exhaled_pp > safe_exhaled_max * 0.7)
			word = pick("dizzy","short of breath","faint","momentarily confused")
			warn_prob = 1
			alert = 1
			failed_exhale = 1
			var/ratio = 1.0 - (safe_exhaled_max - exhaled_pp)/(safe_exhaled_max*0.3)
			if (owner.getOxyLoss() < 50*ratio)
				oxyloss = HUMAN_MAX_OXYLOSS
		else if(exhaled_pp > safe_exhaled_max * 0.6)
			word = pick("a little dizzy","short of breath")
			warn_prob = 1
		else
			owner.co2_alert = 0

		if(!owner.co2_alert && word && prob(warn_prob))
			to_chat(owner, "<span class='warning'>You feel [word].</span>")
			owner.adjustOxyLoss(oxyloss)
			owner.co2_alert = alert

	handle_temperature_effects(breath)

/*
	// Were we able to breathe?
	var/failed_breath = failed_inhale || failed_exhale
	if(failed_breath)
		if(isnull(last_failed_breath))
			last_failed_breath = world.time
	else
		last_failed_breath = null
		owner.adjustOxyLoss(-5 * inhale_efficiency)
		if(robotic < ORGAN_ROBOT && species.breathing_sound && is_below_sound_pressure(get_turf(owner)))
			if(breathing || owner.shock_stage >= 10)
				sound_to(owner, sound(species.breathing_sound,0,0,0,5))
				breathing = 0
			else
				breathing = 1
*/

	breath.update_values()

/obj/item/organ/internal/lungs/proc/hold_breath()
	holding = !holding
	if(holding)
		to_chat(owner, "<span class='notice'>You hold your breath.</span>")
	else
		to_chat(owner, "<span class='notice'>You hold your breath!</span>")

/obj/item/organ/internal/lungs/proc/remove_oxygen_deprivation(var/amount)
	var/last_suffocation = oxygen_deprivation
	oxygen_deprivation = min(species.total_health,max(0,oxygen_deprivation - amount))
	return -(oxygen_deprivation - last_suffocation)

/obj/item/organ/internal/lungs/proc/add_oxygen_deprivation(var/amount)
	var/last_suffocation = oxygen_deprivation
	oxygen_deprivation = min(species.total_health,max(0,oxygen_deprivation + amount))
	return (oxygen_deprivation - last_suffocation)

// Returns a percentage value for use by GetOxyloss().
/obj/item/organ/internal/lungs/proc/get_oxygen_deprivation()
	if(status & ORGAN_DEAD)
		return 100
	return round((oxygen_deprivation/species.total_health)*100)

/obj/item/organ/internal/lungs/robotize()
	. = ..()
	icon_state = "lungs-prosthetic"

/obj/item/organ/internal/lungs/set_dna(var/datum/dna/new_dna)
	..()
	sync_breath_types()

/obj/item/organ/internal/lungs/replaced()
	..()
	sync_breath_types()

/**
 *  Set these lungs' breath types based on the lungs' species
 */
/obj/item/organ/internal/lungs/proc/sync_breath_types()
	min_breath_pressure = species.breath_pressure
	breath_type = species.breath_type.len ? species.breath_type : species.breath_type.Add("oxygen")
	poison_type = species.poison_type.len ? species.poison_type : species.poison_type.Add("phoron")
	exhale_type = species.exhale_type.len ? species.exhale_type : species.poison_type.Add("carbon_dioxide")

/obj/item/organ/internal/lungs/Process()
	..()
	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE && active_breathing)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised() && !owner.is_asystole())
		if(prob(2))
			if(active_breathing)
				owner.visible_message(
					"<B>\The [owner]</B> coughs up blood!",
					"<span class='warning'>You cough up blood!</span>",
					"You hear someone coughing!",
				)
			else
				var/obj/item/organ/parent = owner.get_organ(parent_organ)
				owner.visible_message(
					"blood drips from <B>\the [owner]'s</B> [parent.name]!",
				)

			owner.drip(10)

	if(prob(1-owner.get_blood_oxygenation())
		if(active_breathing)
			owner.visible_message(
				"<B>\The [owner]</B> gasps for air!",
				"<span class='danger'>You can't breathe!</span>",
				"You hear someone gasp for air!",
			)
		if(is_bruised()
			to_chat(owner, "<span class='danger'>You're having trouble getting enough [breath_type]!</span>")

/obj/item/organ/internal/lungs/proc/rupture()
	var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
	if(istype(parent))
		owner.custom_pain("You feel a stabbing pain in your [parent.name]!", 50, affecting = parent)
	bruise()


/obj/item/organ/internal/lungs/proc/handle_temperature_effects(datum/gas_mixture/breath)
	// Hot air hurts :(
	if((breath.temperature < species.cold_level_1 || breath.temperature > species.heat_level_1) && !(COLD_RESISTANCE in owner.mutations))
		var/damage = 0
		if(breath.temperature <= species.cold_level_1)
			if(prob(20))
				to_chat(owner, "<span class='danger'>You feel icicles forming in your lungs!</span>")
			switch(breath.temperature)
				if(species.cold_level_3 to species.cold_level_2)
					damage = COLD_GAS_DAMAGE_LEVEL_3
				if(species.cold_level_2 to species.cold_level_1)
					damage = COLD_GAS_DAMAGE_LEVEL_2
				else
					damage = COLD_GAS_DAMAGE_LEVEL_1

			if(prob(20))
				owner.apply_damage(damage, BURN, BP_HEAD, used_weapon = "Excessive Cold")
			else
				src.damage += damage
			owner.fire_alert = 1
		else if(breath.temperature >= species.heat_level_1)
			if(prob(20))
				to_chat(owner, "<span class='danger'>You feel a searing heat in your lungs!</span>")

			switch(breath.temperature)
				if(species.heat_level_1 to species.heat_level_2)
					damage = HEAT_GAS_DAMAGE_LEVEL_1
				if(species.heat_level_2 to species.heat_level_3)
					damage = HEAT_GAS_DAMAGE_LEVEL_2
				else
					damage = HEAT_GAS_DAMAGE_LEVEL_3

			if(prob(20))
				owner.apply_damage(damage, BURN, BP_HEAD, used_weapon = "Excessive Heat")
			else
				src.damage += damage
			owner.fire_alert = 2

		//breathing in hot/cold air also heats/cools you a bit
		var/temp_adj = breath.temperature - owner.bodytemperature
		if (temp_adj < 0)
			temp_adj /= (BODYTEMP_COLD_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed
		else
			temp_adj /= (BODYTEMP_HEAT_DIVISOR * 5)	//don't raise temperature as much as if we were directly exposed

		var/relative_density = breath.total_moles / (MOLES_CELLSTANDARD * BREATH_PERCENTAGE)
		temp_adj *= relative_density

		if (temp_adj > BODYTEMP_HEATING_MAX) temp_adj = BODYTEMP_HEATING_MAX
		if (temp_adj < BODYTEMP_COOLING_MAX) temp_adj = BODYTEMP_COOLING_MAX
//		log_debug("Breath: [breath.temperature], [src]: [bodytemperature], Adjusting: [temp_adj]")
		owner.bodytemperature += temp_adj

	else if(breath.temperature >= species.heat_discomfort_level)
		species.get_environment_discomfort(owner,"heat")
	else if(breath.temperature <= species.cold_discomfort_level)
		species.get_environment_discomfort(owner,"cold")

/obj/item/organ/internal/lungs/listen()
	if(owner.failed_last_breath || !active_breathing)
		return "no respiration"

	if(robotic == ORGAN_ROBOT)
		if(is_bruised())
			return "malfunctioning fans"
		else
			return "air flowing"

	. = list()
	if(is_bruised())
		. += "[pick("wheezing", "gurgling")] sounds"

	var/list/breathtype = list()
	if(get_oxygen_deprivation() > 50)
		breathtype += pick("straining","labored")
	if(owner.shock_stage > 50)
		breathtype += pick("shallow and rapid")
	if(!breathtype.len)
		breathtype += "healthy"

	. += "[english_list(breathtype)] breathing"

	return english_list(.)
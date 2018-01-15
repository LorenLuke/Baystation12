/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = BP_CHEST
	dead_icon = "heart-off"
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/beat_sound = 'sound/effects/singlebeat.ogg'
	var/tmp/next_blood_squirt = 0
	relative_size = 15
	max_damage = 45
	var/open

	var/target_pulse = 70
	var/pulse_actual = 70
	var/systolic = 120
	var/diastolic = 80

	var/list/pulse_PID = list(0.3, 0.01, 0.5)
	var/pulse_KI = 0
	var/pulse_KD = 0
	var/last_pulse_actual = 0

	var/last_shock_stage = 0
	var/last_pain = 0

/obj/item/organ/internal/heart/New()
	..()
	if(robotic == ORGAN_ASSISTED)
		pulse_PID = list(0.03, 0.001, 0.08)

/obj/item/organ/internal/heart/die()
	if(dead_icon)
		icon_state = dead_icon
	..()

/obj/item/organ/internal/heart/robotize()
	. = ..()
	icon_state = "heart-prosthetic"

/obj/item/organ/internal/heart/Process()
	if(owner)
		handle_pulse()
		handle_blood_pressure()

		if(pulse)
			handle_heartbeat()
			if(pulse == PULSE_2FAST && prob(1))
				take_damage(0.5)
			if(pulse == PULSE_THREADY && prob(5))
				take_damage(0.5)
		handle_blood()
	..()

/obj/itme/organ/internal/heart/proc/handle_blood_pressure()
	var/systolic_base = initial(systolic)
	var/diastolic_base = initial(diastolic)
	var/blood_volume_percent = owner.get_blood_volume()

	var/pain_add = get_total_pain() * (0.95 + rand(0.25))/5

	var/diastolic_ratio = min(100,blood_volume_percent * 1.25) // compensates for hypervolemia
	var/diastolic = diastolic_ratio * diastolic_base /100

	//1.5 times diastolic when healthy, systolic always above diastolic
	systolic = diastolic + pain_add + (diastolic * (0.45 + rand(0.1)) * sqrt((max_damage - get_total_damage())/max_damage))
	diastolic += pain_add/3

	if(heart.robotic >= ORGAN_ROBOT)
		diastolic_base *= 1.25
		diastolic = diastolic_base * sqrt((max_damage - get_total_damage())/max_damage)
		systolic = diastolic
	else
		if(heart.robotic >= ORGAN_ASSISTED)
			//lets our pacemaker still do some of the beating, if not very well
			systolic = ((systolic * 2) + (diastolic * 1.5))/3

		else
			if(pulse == PULSE_NONE)
				systolic = diastolic

	if(pulse == PULSE_FIB && !heart.robotic)
		systolic = random((systolic*1.1)-diastolic) + diastolic

	diastolic = floor(diastolic + 0.5)
	systolic = floor(systolic + 0.5)

	//sanity checks!
	diastolic = min(diastolic, systolic)
	systolic = max(diastolic, systolic)

/obj/item/organ/internal/heart/proc/handle_pulse()

	if(owner.status_flags & FAKEDEATH || owner.chem_effects[CE_NOPULSE] || robotic >= ORGAN_ROBOT)
		target_pulse = 0
		pulse_actual = 0
		pulse_KD = 0
		pulse_PD = 0
		pulse_last_PD = 0
		if(robotic >= ORGAN_ROBOT)
			pulse = PULSE_NONE
		return

	var/pulse_inc = 0

	//so we don't get a cascate to something like 300BPM
	pulse_inc -= last_shock_stage/2
	pulse_inc += owner.shock_stage/2

	last_shock_stage = owner.shock_stage

	pulse_inc -= last_pain
	pulse_inc += sqrt(get_total_pain()/4)

	last_pain = sqrt(get_total_pain()/4)

	var/oxy = owner.get_effective_blood_oxygenation()

	if(oxy < BLOOD_VOLUME_OKAY) //brain wants us to get MOAR OXY
		pulse_inc += 1
	if(oxy < BLOOD_VOLUME_BAD) //MOAR
		pulse_inc += 2


	if(pulse != PULSE_NONE && pulse != PULSE_FIB && pulse_actual > 140) //tachycardia to fibrillation
		var/sum = pulse_actual + get_total_damage()
		if(prob(-1/((pulse_actual-140)+1)+1) )
			pulse = PULSE_FIB
	else
		if( pulse != PULSE_NONE && prob((get_total_health/max_damage)/20) )
			pulse = PULSE_NORM

	//If heart is stopped, it isn't going to restart itself randomly.
	if(pulse == PULSE_NONE)
		return
	else //and if it's beating, let's see if it should
		var/should_stop = 0
		should_stop = (prob(((get_total_damage/2) - min_bruised_damage))/max_damage) && PULSE_FIB) //V-Fib/A-Fib

		should_stop = should_stop || prob(max(0, owner.getBrainLoss() - owner.maxHealth * 0.75)) //brain failing to work heart properly

		should_stop = should_stop || (prob(5) && owner.shock_stage >= 120) //traumatic shock

		if(should_stop) // The heart has stopped due to going into traumatic or cardiovascular shock.
			to_chat(owner, "<span class='danger'>Your heart has stopped!</span>")
			pulse = PULSE_NONE
			return
	if(pulse != PULSE_NONE && oxy <= BLOOD_VOLUME_SURVIVE && !owner.chem_effects[CE_STABLE])	//I SAID MOAR OXYGEN
		pulse = PULSE_FIB
		return

	if(pulse != PULSE_NORM && owner.chem_effects[CE_STABLE])
		if(pulse > PULSE_NORM)
			pulse--
		else
			pulse++

	target_pulse = Clamp(target_pulse * ((owner.bodytemperature - 273)/38), 0, 240)


	//the glorious PID
	target_pulse = pulse_actual + pulse_inc
	var/P = pulse_PID[1]
	var/I = pulse_PID[2]
	var/D = pulse_PID[3]

	pulse_actual += ((target_pulse - pulse_actual) * P) + (KI) - (KD)
	KD = (pulse_actual - last_pulse_actual) / D
	KI += (target_pulse - pulse_actual) * I

	last_pulse_actual = pulse_actual

/obj/item/organ/internal/heart/proc/handle_heartbeat()
	if(systolic-diastolic >= 50 || pulse_actual >= 110 || owner.shock_stage >= 10 || is_below_sound_pressure(get_turf(owner)))
		//PULSE_THREADY - maximum value for pulse, currently it 5.
		//High pulse value corresponds to a fast rate of heartbeat.
		//Divided by 2, otherwise it is too slow.
		var/rate = (pulse_actual)/40

		if(heartbeat >= rate)
			heartbeat = 0
			sound_to(owner, sound(beat_sound,0,0,0,50))
		else
			heartbeat++


/obj/item/organ/internal/heart/proc/handle_blood()

	if(!owner)
		return

	//Dead or cryosleep people do not pump the blood.
	if(!owner || owner.InStasis() || owner.stat == DEAD || owner.bodytemperature < 170)
		return

	if(pulse != PULSE_NONE || robotic >= ORGAN_ROBOT)
		//Bleeding out
		var/blood_max = 0
		var/list/do_spray = list()
		var/list/obj/item/organ/organ_list = list(owner.organs) + list(owner.internal_organs)
		for(var/obj/item/organ/temp in owner.organs)

			if(temp.robotic >= ORGAN_ROBOT)
				continue

			var/open_wound
			if(temp.status & ORGAN_BLEEDING)

				for(var/datum/wound/W in temp.wounds)

					if(!open_wound && (W.damage_type == CUT || W.damage_type == PIERCE) && W.damage && !W.is_treated())
						open_wound = TRUE

					if(W.bleeding())
						if(temp.applied_pressure)
							if(ishuman(temp.applied_pressure))
								var/mob/living/carbon/human/H = temp.applied_pressure
								H.bloody_hands(src, 0)
							//somehow you can apply pressure to every wound on the organ at the same time
							//you're basically forced to do nothing at all, so let's make it pretty effective
							var/min_eff_damage = max(0, W.damage - 10) / 6 //still want a little bit to drip out, for effect
							blood_max += max(min_eff_damage, W.damage - 30) / 40
						else
							blood_max += W.damage / 40

			if(temp.status & ORGAN_ARTERY_CUT)
				var/bleed_amount = Floor((owner.vessel.total_volume / (temp.applied_pressure || !open_wound ? 400 : 250))*temp.arterial_bleed_severity * (systolic/120) * (diastolic/80) * (pulse_actual/70))
				if(bleed_amount)
					if(open_wound)
						blood_max += bleed_amount
						do_spray += "the [temp.artery_name] in \the [owner]'s [temp.name]"
					else
						owner.vessel.remove_reagent(/datum/reagent/blood, bleed_amount)

		var/blood_prop = ( ((pulse_actual/70) * (systolic / 120)) + (diastolic / 80) )/2

		if(CE_STABLE in owner.chem_effects) // inaprovaline
			blood_prop *= min(blood_prop,0.8)

		if(world.time >= next_blood_squirt && istype(owner.loc, /turf) && do_spray.len)
			if(!robotic >= ORGAN_ROBOTIC && (systolic > diastolic+30) )
				owner.visible_message("<span class='danger'>Blood squirts from [pick(do_spray)]!</span>")
				// It becomes very spammy otherwise. Arterial bleeding will still happen outside of this block, just not the squirt effect.
				next_blood_squirt = world.time + 100
				var/turf/sprayloc = get_turf(owner)
				blood_prop -= owner.drip(ceil(blood_prop/3), sprayloc)
				if(blood_prop > 0)
					blood_prop -= owner.blood_squirt(blood_prop, sprayloc)
					if(blood_prop > 0)
						owner.drip(blood_prop, get_turf(owner))
			else
				owner.drip(blood_prop)
		else
			owner.drip(blood_prop)


/obj/item/organ/internal/heart/proc/is_working()
	if(!is_usable())
		return FALSE

	return pulse > PULSE_NONE || robotic == ORGAN_ROBOT || (owner.status_flags & FAKEDEATH)

/obj/item/organ/internal/heart/listen()
	if(robotic == ORGAN_ROBOT && is_working())
		if(is_bruised())
			return "sputtering pump"
		else
			return "steady whirr of the pump"

	if(!pulse || (owner.status_flags & FAKEDEATH))
		return "no pulse"

	var/pulsesound = "normal"

	switch(pulse_actual)
		if(0 to 50)
			pulsesound = "slow"
		if(80 to 125)
			pulsesound = "fast"
		if(125 to 155)
			pulsesound = "very fast"
		if(155 to INFINITY)
			pulsesound = "extremely fast"

	if(systolic < diastolic + 30)
		pulsesound += "weak"
	if(is_bruised() || PULSE_AFIB)
		pulsesound += "irregular"

	if(systolic < diastolic + 5 || pulse_actual == 0)
		pulsesound = "no"

	. = "[pulsesound] pulse"
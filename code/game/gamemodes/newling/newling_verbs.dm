/datum/changeling_power/
	var/name = ""
	var/disp_name = ""
	var/pre_channel = ""
	var/nutrition_cost = 0
	var/nutrition_minimum = 100
	var/cooldown = 10 //in tenths of second
	var/toggle = 0 //determines if it's a toggled ability
	var/active = 0 //used with toggles
	var/active_tick = 0 //nutrition used with toggles per tick
	var/channel = 0 //time required as a do-after, in tenths of second
	var/datum/changeling/changeling
	var/requires_human = 0
	var/mob/living/owner
	var/queued_form


/datum/changeling_power/proc/ability_verb(var/mob/living/target = null)
	set waitfor = 0
	set category = "Changeling"
	set name = src.name

	call_ability_clicked(target)


/datum/changeling_power/proc/call_ability_clicked(var/user = usr, var/mob/living/target = null)
	if(requires_human)
		if(!istype(usr, /mob/living/carbon/human))
			return 0

		if(usr.check_nutrition(nutrition_cost))
			usr.remove_nutrition(nutrition_cost)
		else
			return 0

	if(channel)
		if(pre_channel)
			usr.visible_message(pre_channel)
		if(!do_after(usr, channel))
			return 0

	if(toggle)
		if(active)
			active = 0
			to_chat(usr, "You toggle off your [disp_name].")
			return 0
		else
			active = 1
			to_chat(usr, "You toggle on your [disp_name].")
			return call_ability(usr, target)

	else
		return call_ability(user, target)

/datum/changeling_power/proc/call_ability(var/mob/living/user, var/mob/living/target = null)
	. = ability_proc(user, target)
	if(toggle && active)
		spawn (cooldown)
			if(usr.check_nutrition(nutrition_minimum))
				usr.remove_nutrition(nutrition_cost)
				call_ability(user,target)
			else
				call_ability_clicked(user, target)
				return 0


/datum/changeling_power/proc/ability_proc(var/mob/living/user, var/mob/living/target = null)
	return 0



/datum/changeling_power/moult
	name = "Moult"
	nutrition_cost = 0


/datum/changeling_power/moult/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)
	var/mob/living/carbon/human/H = user
	if(!moulting)

		to_chat(H, "<span class='notice'>We will attempt to regenerate our form.</span>")
		H.status_flags |= FAKEDEATH		//play dead
		H.update_canmove()

		H.emote("gasp")
		H.tod = stationtime2text()

		spawn(300)
			to_chat(H, "<span class='notice'><font size='5'>Our new form is ready.  Click <b>Moult</b> again to shed your skin.</font></span>")
//			H.verbs += /mob/proc/changeling_revive need own revive verb

		return 1

	else
		moulting = 0
		//explode from your old body

/datum/changeling_power/selectform
	name = "Queue Form"
	nutrition_cost = 0

/datum/changeling_power/regenerate_limb
	name = "Regenerate Limb"
	nutrition_cost = 25
	toggle = 1
	cooldown = 10

/datum/changeling_power/regenerate_limb/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)
	var/limb_name = user.input(user, "Limb to regenerate?", "Regenerate Limb") as anything|null in list("Left Arm", "Right Arm", "Left Leg", "Right Leg")
	var/limb_handle
	var/obj/item/organ/external/limb

	switch(limb_name)
		if("Left Arm")	limb_handle "l_arm"
		if("Right Arm")	limb_handle "l_arm"
		if("Left Leg")	limb_handle "l_arm"
		if("Right Leg")	limb_handle "l_arm"

	var/obj/item/organ/external/limb = user.organs_by_name[limb_handle]
	user.visible_message("<span class='danger'>A new [newlimb] bursts out of \the [limb]!</span>")
	limb.droplimb(1, DROPLIMB_BLUNT) //
	var/obj/item/organ/external/newlimb = user.organs_by_name[limb_handle]

//will this work?
	newlimb.status &= ~ORGAN_DESTROYED
	for(var/obj/item/organ/external/C in newlimb.children)
		C.status &= ~ORGAN_DESTROYED
	user.update_body()
	user.updatehealth()
	user.UpdateDamageIcon()



/datum/changeling_power/regenerate
	name = "Toggle Regeneration"
	nutrition_cost = 1
	toggle = 1


/datum/changeling_power/regenerate/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)

	var/mob/living/carbon/human/H = user

	H.adjustBruteLoss(-1)
	H.adjustToxLoss(-1)
	H.adjustFireLoss(-1)
	spawn(0)
		for(var/obj/item/organ/internal/I in internal_organs)
			I.damage -= 1
			//if(prob(5))	stop internal bleeding
			//

	return 1



/datum/changeling_power/dialysis
	name = "Toggle Blood Filtering"
	nutrition_cost = 1
	toggle = 1

/datum/changeling_power/dialysis/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)
	var/mob/living/carbon/human/H = user
	spawn(0)
		for(var/datum/reagent/R in user.bloodstr)
			R.volume -= 2
			R.dose -= 0.5
	spawn(0)
		for(var/datum/reagent/R in user.ingested)
			R.volume -= 2
			R.dose -= 0.5

//	for(var/datum/reagent/R in user.reagents)
//		R.volume -= 1
//		R.dose -= 0.2

//	for(var/datum/reagent/R in user.touching)
//		R.volume -= 1
//		R.dose -= 0.2


/datum/changeling_power/camouflage
	name = "Toggle Camouflage"
	nutrition_cost = 1
	toggle = 1

/datum/changeling_power/oxygenconversion
	name = "Toggle Oxygen Conversion"
	nutrition_cost = 1
	toggle = 1

/datum/changeling_power/oxygenconversion/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)
	if(prob(5))
		user.visible_message("[user] [pick(list("twitches","shivers"))].")

	var/turf/T = get_turf(user)
	var/volume_rate = 40

	var/datum/gas_mixture/environment
	var/datum/gas_mixture/hold = new()
	environment = turf.return_air()

	var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles

	var/datum/gas_mixture/removed = environment.remove(transfer_moles)

	var/oxy = removed.gas["oxygen"]
	removed.add_thermal_energy(oxy*200000)
	removed.gas["carbon_dioxide"] += oxy
	removed.gas["oxy"] = 0
	environment.merge(removed)


/datum/changeling_power/gib
	name = "Lytic Distraction"
	nutrition_cost = 0

/datum/changeling_power/armblade
	name = "Project armblade"
	nutrition_cost = 0

/datum/changeling_power/armblade/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)


/datum/changeling_power/sting
	name = "Create Sting"
	nutrition_cost = 0

///datum/changeling_power/spine
//	name = "Launch Spine"

/datum/changeling_power/radiationburst
	name = "Emit Radiation Burst"
	channel = 50

/datum/changeling_power/radiationburst/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)
	if(prob(20))
		user.visible_message("[user] shivers.")

	var/start_strength = 100
	for(var/mob/living/carbon/human/H in range(get_turf(user), 5) // need stuff for IPCs
		if(H == user)
			continue
		var/dist = get_dist(user, H) + 1
		var/strength = (rand(start_strength * 0.9, start_strength * 1.1))/(dist**2)
		if(prob(strength / 2))
			var/message = pick(list("Your body tingles slightly.", "You feel tingling.", "The air tastes different.", "Your eyes unfocus for a split-second."))
			to_chat(usr, "<span class='notice'>[message]</span>")
		H.apply_effect(strength,IRRADIATE,blocked = H.getarmor(null, "rad"))



/datum/changeling_power/screech
	name = "Screech"
/datum/changeling_power/screech/ability_proc(var/mob/living/user = usr, var/mob/living/target = null)
	set waitfor = 0
	var/strength = 100
	for(var/i = 1, i<=5, i++)
		if(!do_after(user, 5))
			i = 10
		for(var/obj/machinery/door/window/W in range(get_turf(user), 5)
			var/dist = get_dist(user, W) + 1
			W.take_damage((rand(strength * 0.9, strength * 1.1))/(dist**2))
		for(var/obj/structure/window/W in range(get_turf(user), 5))
			if(H == user)
				continue
			var/dist = get_dist(user, W) + 1
			W.take_damage((rand(strength * 0.9, strength * 1.1))/(dist**2))
		for(var/mob/living/carbon/human/H in range(get_turf(user), 5)
			if(H == user)
				continue
			var/dist = get_dist(user, H) + 1

// apply hearing loss and confusion
//			H.apply_effect((rand(strength * 0.9, strength * 1.1))/(dist**2),IRRADIATE,blocked = H.getarmor(null, "rad"))

		for(var/mob/living/silicon/s in range(get_turf(user), 5)
			if(prob(15))
				// shut down robutts



/datum/changeling_power/snare
	name = "Create snare"

/datum/changeling_power/tackle
	name = "Tackle"

/datum/changeling_power/grenade
	name = "Spawn Biogrenade"

/datum/changeling_power/parasite
	name = "Spawn Parasite"

/datum/changeling_power/controlparasite
	name = "Control Parasite"







/mob/living/carbon/human/proc/check_nutrition(var/nut),
	return (nut <= src.nutrition)

/mob/living/carbon/human/proc/remove_nutrition(var/nut),
	src.nutrition -= nut
















/obj/item/weapon/changeling_stinger
	name = "stinger"
	desc = "A stranged barbed stinger"
	var/datum/reagents/reagents

/obj/item/weapon/changeling_stinger/toxic


/obj/item/weapon/changeling_stinger/paralytic

/obj/item/weapon/changeling_stinger/viral


/obj/item/weapon/changeling_armblade
	name = "strange blade"
	desc = "A strange organic scythe."
	force = 25
	edge = 1
	icon_state = "blade"
	force = 15
	armor_penetration = 20
	sharp = 1
	edge = 1
	throwforce = 15
	throw_speed = 25
	throw_range = 7
	var/thrown = 0
	canremove = 0

/obj/item/weapon/changeling_armblade/throw_at(atom/target)
	var/mob/living/carbon/human/H = usr
	if(!thrown)
		canremove = 1
		var/hand
		if(usr.r_hand == src)
			hand = "right"
		else
			hand = "left"
		var/obj/item/organ/external/limb
		if(hand == "right")
			limb = usr.organs_by_name["r_hand"]
		else
			limb = usr.organs_by_name["l_hand"]

		limb.droplimb(1, DROPLIMB_BLUNT) //And our hand goes with it (because it sorta fused to it)

		..()

		Spawn(3)
			throw_speed = 5
			throwforce = 5
			force = 7
			armor_penetration = 5
			thrown = 1
	else
		..()


/obj/item/weapon/spine
	name = "spine"
	desc = "A strange bony spike"















/datum/unarmed_attack/changeling_knockback/
	damage = 25

/datum/unarmed_attack/changeling_knockback/proc/apply_effects((var/mob/living/carbon/human/user,var/mob/living/carbon/human/target,var/armour,var/attack_damage,var/zone)
	var/knockback = round(rand(1,4))
	var/message = "<span class='danger'>[target] goes flying back from the impact!</span>"
	var/self_message = "<span class='danger'>You go flying back from the impact!</span>"

	switch(zone) // strong punches can have effects depending on where they hit
		if(BP_HEAD, BP_EYES, BP_MOUTH)
			// Induce blurriness
			message = "<span class='danger'>[target] goes flying as their head snaps back from the impact!</span>"
			self_message = "<span class='danger'>Your head snaps back as you go flying!</span>"
			target.apply_effect(attack_damage*2, EYE_BLUR, armour)
		if(BP_L_ARM, BP_L_HAND)
			knockback--
			message = "<span class='danger'>The impact on [target]'s arm jerks them backwards, dropping [target.l_hand] as they go flying!</span>"
			self_message = "<span class='danger'>You feel [target.l_hand] knocked from your grasp as you pirouette through the air!</span>"
			target.drop_l_hand()
		if(BP_R_ARM, BP_R_HAND)
			knockback--
			message = "<span class='danger'>The impact on [target]'s arm jerks them backwards, dropping [target.r_hand] as they go flying!</span>"
			self_message = "<span class='danger'>You feel [target.r_hand] knocked from your grasp as you pirouette through the air!</span>"
			target.drop_r_hand()
		if(BP_CHEST)
			knockback++

		if(BP_GROIN)
			message = "<span class='danger'>[target] flies backwards, crumpling midair!</span>"
			self_message = "<span class='danger'>You fly backwards as your lower body explodes in pain!</span>"
			target.apply_effects(stutter = attack_damage * 2, agony = attack_damage* 3, blocked = armour)
		if(BP_L_LEG, BP_L_FOOT, BP_R_LEG, BP_R_FOOT)
			if(!target.lying)
				message = "<span class='danger'>[target] flies backwards, flipping through the air!</span>"
				self_message = "<span class='danger'>You fly backwards as your feet sweep out from under you!</span>"
				target.apply_effect(attack_damage*3, AGONY, armour)

	target.visible_message(message, self_message)

	if(!target.lying)
		for(var/i = 1, i<=knockback, i++)
			var/turf/T = get_step(get_turf(target), get_dir(get_turf(user), get_turf(target)))
			if(!T.density)
				step(target, get_dir(get_turf(user), get_turf(target)))
			else
				target.visible_message("<span class='danger'>[target] slams into [T]!</span>")
				var/knockdif = knockback - i
				target.apply_effect(2.5 * knockdif , WEAKEN, armour)
				//apply 5* knockdif damage here
				i = knockback

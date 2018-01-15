/obj/item/organ/internal/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = BP_KIDNEYS
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	var/min_filtered = 3.5
	var/buildup = 0
	var/max_buildup = 20
	var/clear_rate = 1.5


/obj/item/organ/internal/kidneys/robotize()
	. = ..()
	icon_state = "kidneys-prosthetic"

/obj/item/organ/internal/kidneys/Process()
	..()

	var/min_filter = initial(min_filtered)*(get_damage()/max_damage)
	var/max_buildup = initial(max_buildup)*(get_damage()/max_damage)
	var/clear_rate = initial(clear_rate)*(get_damage()/max_damage)

	var/tox_filtering = 4.5 * Clamp(1.2 - ( (get_damage()-min_bruised_damage)/(2 * max_damage-min_bruised_damage) ) - ( (get_damage()-min_broken_damage)/(max_damage-min_bruised_damage) ), 0, 1)

	buildup += max(0, tox_filtering - min_filtered)
	buildup -= max(0, buildup - clear_rate)
	if(owner.chem_effects[CE_ANTITOX])
		tox_filtering = sqrt(tox_filtering + owner.chem_effects[CE_ANTITOX]/5)
		owner.adjustToxLoss(-tox_filtering * owner.get_blood_circulation()*4.5)
	else
		owner.adjustToxLoss(-tox_filtering * owner.get_blood_circulation()*4.5)

	if(!owner)
		return

	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(is_bruised())
			owner.adjustToxLoss(0.1)
		else if(is_broken())
			owner.adjustToxLoss(0.3)

	//If your kidneys aren't working, your body's going to have a hard time cleaning your blood.
	if(!owner.reagents.has_reagent(/datum/reagent/dylovene))
		if(prob(33))
			if(is_broken())
				owner.adjustToxLoss(0.5)
			if(status & ORGAN_DEAD)
				owner.adjustToxLoss(1)



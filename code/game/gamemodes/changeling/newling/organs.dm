/obj/item/organ/proc/changeling_transform()
	if(!src.changeling)
		var/organ_name = src.name
		for(var/obj/item/organ/O in typesof(/obj/item/organ)
			if(O.name == organ_name && !O.changeling)
				O.changeling = true



/obj/item/organ/
	var/changeling = 0

/obj/item/organ/kidneys/changeling
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	parent_organ = "groin"
	changeling = 1


/obj/item/organ/kidneys/changeling/process()

	..()

	if(!owner)
		return

	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_broken())
			owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)



//TODO
/obj/item/organ/kidneys/changeling/handle_germ_effects()




/obj/item/organ/eyes/changeling
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	var/list/eye_colour = list(0,0,0)
	changeling = 1

/obj/item/organ/eyes/ling/process() //Eye damage replaces the old eye_stat var.
	..()
	if(!owner)
		return
	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20





/obj/item/organ/liver/changeling
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"
	changeling = 1


/obj/item/organ/liver/changeling/process()

	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			owner << "\red Your skin itches."
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * PROCESS_ACCURACY
			//Damaged one shares the fun
			else
				var/obj/item/organ/O = pick(owner.internal_organs)
				if(O)
					O.damage += 0.2  * PROCESS_ACCURACY

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
			src.damage -= 0.2 * PROCESS_ACCURACY

		if(src.damage < 0)
			src.damage = 0

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(is_bruised())
			filter_effect -= 1
		if(is_broken())
			filter_effect -= 2

		// Do some reagent processing.
		if(owner.chem_effects[CE_ALCOHOL_TOXIC])
			if(filter_effect < 3)
				owner.adjustToxLoss(owner.chem_effects[CE_ALCOHOL_TOXIC] * 0.1 * PROCESS_ACCURACY)
			else
				take_damage(owner.chem_effects[CE_ALCOHOL_TOXIC] * 0.1 * PROCESS_ACCURACY, prob(1)) // Chance to warn them



//TODO
/obj/item/organ/liver/changeling/handle_germ_effects()



/obj/item/organ/appendix/changeling
	name = "appendix"
	icon_state = "appendix"
	parent_organ = "groin"
	organ_tag = "appendix"
	var/inflamed = 0
	changeling = 1

/obj/item/organ/appendix/process()
	..()
	if(inflamed && owner)
		inflamed++
		if(prob(5))
			owner << "<span class='warning'>You feel a stinging pain in your abdomen!</span>"
			owner.emote("me",1,"winces slightly.")
		if(inflamed > 200)
			if(prob(3))
				take_damage(0.1)
				owner.emote("me",1,"winces painfully.")
				owner.adjustToxLoss(1)
		if(inflamed > 400)
			if(prob(1))
				germ_level += rand(2,6)
				if (owner.nutrition > 100)
					owner.vomit()
				else
					owner << "<span class='danger'>You gag as you want to throw up, but there's nothing in your stomach!</span>"
					owner.Weaken(10)
		if(inflamed > 600)
			if(prob(1))
				owner << "<span class='danger'>Your abdomen is a world of pain!</span>"
				owner.Weaken(10)

				var/obj/item/organ/external/E = owner.get_organ(parent_organ)
				var/datum/wound/W = new /datum/wound/internal_bleeding(20)
				E.wounds += W
				E.germ_level = max(INFECTION_LEVEL_TWO, E.germ_level)
				owner.adjustToxLoss(25)
				removed()
				qdel(src)



//TODO
/obj/item/organ/appendix/changeling/handle_germ_effects()




/obj/item/organ/heart/changeling
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = "chest"
	dead_icon = "heart-off"
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/beat_sound = 'sound/effects/singlebeat.ogg'
	var/efficiency = 1
	changeling = 1


/obj/item/organ/heart/changeling/handle_pulse()
	if(changeling)
		pulse = PULSE_DEAD
	else
		..()

/obj/item/organ/heart/ling/handle_blood()
	if(changeling)

//		add chance for toxin/oxyloss

		return
	..()


//TODO
/obj/item/organ/heart/changeling/handle_germ_effects()



/obj/item/organ/lungs/changeling
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = "lungs"
	parent_organ = "chest"

	var/breath_type
	var/poison_type
	var/exhale_type

	var/min_breath_pressure

	var/safe_exhaled_max = 10
	var/safe_toxins_max = 0.2
	var/SA_para_min = 1
	var/SA_sleep_min = 5
	changeling = 1

/obj/item/organ/lungs/changeling/process()
	if(changeling)
		return
	else
		//


	..()


//TODO
/obj/item/organ/lungs/changeling/handle_germ_effects()




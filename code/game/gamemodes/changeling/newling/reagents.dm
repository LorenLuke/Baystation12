//Snare

/datum/reagent/changeling_snare
	name = "organic nanopolymer"
	id = "changeling_snare"
	desc = "some sort of fast-acting strange molecular polymer"
	taste_description = "glue"
	taste_mult = 1.2


// /datum/reagent/changeling_snare/touch_turf()

///




/datum/reagent/transformation_toxin
	name = "unknown enzyme"
	id = "transformation_toxin"
	description = "No data found."
	taste_description = "change"
	taste_mult = 1.2
	reagent_state = LIQUID
	color = "#CF3600"
	metabolism = REM // 0.01 by default. They last a while and slowly kill you.
	strength = 4 // How much damage it deals per unit

/datum/reagent/transformation_toxin/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(species = "vox")
		..()
	else
		var/obj/item/organ/O = pick(M.internal_organs)
		if(O)
			if(!O.changeling)
				O.damage += 2 * removed
//				if(prob(1))
//					O.organ.changeling_transform()
		//stuff

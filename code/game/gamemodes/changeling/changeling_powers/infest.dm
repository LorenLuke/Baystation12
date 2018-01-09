
////changeling reagent
////
/datum/reagent/changeling/retrovirus//An OP chemical for admins
	name = "Retroviral pathogen"
	description = "An extraordinarily quick acting retrovirus, its RNA is unlike anything we've seen."
	taste_description = "change"
	reagent_state = LIQUID
	color = "#c8a5dc"
	var/strength = 5
	metabolism = 1
	flags = AFFECTS_DEAD

/datum/reagent/changeling/retrovirus/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(M.stat == DEAD)
		return
	if(M.mind && M.mind.changeling)
		M.add_chemical_effect(CE_PAINKILLER, 15)
		M.add_chemical_effect(CE_ANTITOX, 20)
		M.add_chemical_effect(CE_STABLE, 10)
		M.add_chemical_effect(CE_BRAIN_REGEN, 15)
		M.add_chemical_effect(CE_BLOODRESTORE, 15)
		M.heal_organ_damage(10 * removed, 10 * removed)
		if(M.is_asystole())
			M.resuscitate()
	else
		M.take_organ_damage(removed * strength, removed * strength)
		M.adjustToxLoss(strength * removed)
		M.add_chemical_effect(CE_PULSE, 15)
		var/num = rand(3)+1
		var/list/obj/item/organ/external/organ_list = list()
		for(var/i = 0, i< num, i++)
			var/obj/item/organ/external/org = pick(M.organs)
			if(!(org in organ_list) && org.robotic < ORGAN_ROBOT)
				organ_list.Add(org)
			else
				i--
		for(var/obj/item/organ/external/E in organ_list)
			E.add_pain(removed * strength)
			if(prob(10))
				E.add_pain(removed * strength)
				M.take_organ_damage(removed * strength / 2, removed * strength / 2)
		if(prob(10))
			var/message = pick("You feel a deep burning in your veins!", "Everything is on fire!", "OH GOD, IT HURTS SO MUCH!", "MAKE IT STOP!", "PAIN!")
			to_chat(M, "<span class='danger'>[message]</span>")



///Needs work. Gib on death and make organs explode into nastiness. *nod* -Luke
/*
/datum/reagent/changeling/retrovirus/enhanced/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(M.stat == DEAD && !(M.mind) || !(M.mind.changeling))
		var/list/obj/item/organ/external/organ_list = M.organs
		organ_list += M.internal_organs
		M.Gib()
		for(var/obj/item/organ/O in organ_list)
			spawn(3+(rand(10)*5) )
				if(!isturf(O.loc))
					continue

				var/datum/reagent/reagent = pick(
					/datum/reagent/changeling/paralytic,
					/datum/reagent/toxin/impedrezene,
					/datum/reagent/lexorin,
					/datum/reagent/mutagen
					)
				var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
				steam.set_up(10, 0, get_turf(src))
				steam.attach(src)
				steam.start()

				for(var/atom/A in view(2, src.loc))
					if( A == src ) continue
					reagent.touch(A)

				qdel(O)
	else
		..()

*/


/datum/power/changeling/infest
	name = "Rewrite DNA"
	desc = "Permits us to rewrite DNA from a person, adapting them into one of us... if they survive."
	helptext = "Used to convert people to changelings. You /WILL/ have to repurchase this for each use."
	genomecost = 0
	verbpath = /mob/proc/changeling_infest

//Infests the
//Doesn't cost anything as it's the most basic ability.
/mob/proc/changeling_infest()
	set category = "Changeling"
	set name = "Infect"

	var/datum/changeling/changeling = changeling_power(0,0,100)
	if(!changeling)	return

	var/obj/item/grab/G = src.get_active_hand()
	if(!istype(G))
		to_chat(src, "<span class='warning'>We must be grabbing a creature in our active hand to infect them.</span>")
		return

	var/mob/living/carbon/human/T = G.affecting
	if(!istype(T))
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	if(T.mind)
		if(T.mind.changeling)
			to_chat(src, "<span class='warning'>This one is among us already!</span>")
			return

	if(T.species.flags & NO_SCAN)
		to_chat(src, "<span class='warning'>This creature's DNA cannot be rewritten!</span>")
		return

	if(HUSK in T.mutations)
		to_chat(src, "<span class='warning'>This creature's DNA is ruined beyond useability!</span>")
		return

	if(!G.can_absorb())
		to_chat(src, "<span class='warning'>We must have a tighter grip to absorb this creature.</span>")
		return

	if(changeling.isabsorbing)
		to_chat(src, "<span class='warning'>We are already using our proboscis!</span>")
		return

	changeling.isabsorbing = 1
	for(var/stage = 1, stage<=2, stage++)
		switch(stage)
			if(1)
				to_chat(src, "<span class='notice'>This creature is compatible. We must hold still...</span>")
			if(2)
				to_chat(src, "<span class='notice'>We extend a proboscis.</span>")
				src.visible_message("<span class='warning'>[src] extends a proboscis!</span>")

		feedback_add_details("changeling_powers","A[stage]")
		if(!do_mob(src, T, 150))
			to_chat(src, "<span class='warning'>Our infestation of [T] has been interrupted!</span>")
			changeling.isabsorbing = 0
			return


	for(var/stage = 1, stage<=3, stage++)
		switch(stage)
			if(1)
				var/obj/item/organ/external/affecting = T.get_organ(src.zone_sel.selecting)
				if(!affecting)
					to_chat(src, "<span class='warning'>They are missing that body part!</span>")
					stage--
				if(stage == 1)
					to_chat(src, "<span class='notice'>We stab [T] with the proboscis.</span>")
					src.visible_message("<span class='danger'>[src] stabs [T] with the proboscis!</span>")
					to_chat(T, "<span class='danger'>You feel a sharp stabbing pain!</span>")
					affecting.take_damage(30, 0, DAM_SHARP, "large organic needle")
					changeling.max_geneticpoints -= 2
					src.verbs -= /mob/proc/changeling_infest
					changeling.purchasedpowers.Remove(/datum/power/changeling/infest)

			if(2)

				if(changeling.isabsorbing && changeling.chem_charges > 2)
					stage--
					var/message = pick("quivers", "pulsates", "undulates", "trembles")
					var/accusative = pick("some liquid", "something", "fluids")
					src.visible_message("<span class='danger'>[src]'s proboscis [message] as it pumps [accusative] into [T]!</span>")
					changeling.chem_charges -= 2
					if(T.reagents)
						T.reagents.add_reagent(/datum/reagent/changeling/retrovirus, 5)
						if(prob(85))
							if(alert(T, "Do you wish to give in and join the many?",,"No","Yes") == "Yes")//Confirmation for the victim to join the lings
								if (changeling.isabsorbing)
									stage++
									T.make_changeling()
									var/datum/changeling/T_changeling = T.mind.changeling
									T_changeling.geneticpoints = 5
									T_changeling.infested = 1
									T_changeling.infested_parent = changeling
									T_changeling.readapts = 1
									T_changeling.max_readapts = 2
								else
									to_chat(T, "<span class='danger'>The time for that has passed!</span>")

			if(3)

				if(T.mind)
					if(T.mind.changeling)
						to_chat(src, "<span class='notice'>All traces of [T] have been overwritten. They are among us, now.</span>")
						changeling.isabsorbing = 0
						return
				else

		if(!do_mob(src, T, 50))
			to_chat(src, "<span class='warning'>Our infestation of [T] has been interrupted!</span>")
			src.visible_message("<span class='danger'>[src]'s proboscis retracts!</span>")
			changeling.isabsorbing = 0
			changeling.geneticpoints += 1
			changeling.max_geneticpoints -= 2
			return

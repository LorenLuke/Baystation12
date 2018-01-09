////changeling reagent
////
/datum/reagent/changeling/paralytic//Changeling Paralytic
	name = "Paralytic Nerve Agent"
	description = "A paralytic neurotoxin with an extraordinarily short biological half-life."
	taste_description = "paralysis"
	reagent_state = LIQUID
	color = "#c8a5dc"
	metabolism = 0.5

/datum/reagent/changeling/paralytic/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(M.mind && M.mind.changeling)
		return
	else
		var/effective_dose = M.chem_doses[type]
		var/datum/reagent/reagent = M.bloodstr.reagent_list[name]
		var/volume = reagent.volume

		if(volume < effective_dose)
			to_chat(M, "<span class='danger'>Your muscles seize up, freezing you in place!</span>")

			var/over = (prob(70) ? 0 : 1)
			if(over)
				M.visible_message("<span class='warning'>[M]'s limbs lock up and they topple over as their whole body goes rigid!</span>")
			else
				M.visible_message("<span class='warning'>[M]'s limbs lock up and their whole body goes rigid!</span>")
			while(volume < effective_dose && volume > 0)
				if(over)
					M.weakened = 2
				else
					M.stunned = 2
				M.silent = 2
				M.losebreath = 2


/datum/reagent/changeling/toxin//An OP chemical for admins
	name = "Zootoxin"
	description = "An enzymatic toxin that affects organs over a long duration."
	taste_description = "paralysis"
	reagent_state = LIQUID
	color = "#c8a5dc"
	metabolism = 0.05

/datum/reagent/changeling/toxin/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(M.mind && M.mind.changeling)
		return
	else
		var/strength = 10
		if(alien != IS_DIONA)
			M.add_chemical_effect(CE_TOXIN, strength)
			M.adjustToxLoss(strength * removed / 2)
			for(var/obj/item/organ/internal/I in M.internal_organs)
				if(prob(5))
					I.damage += removed * strength * 2
//			M.take_organ_damage(removed * strength / 2)

/datum/reagent/changeling/toxin//Slow acting poison
	name = "Zootoxin"
	description = "An enzymatic toxin that affects organs over a long duration."
	taste_description = "paralysis"
	reagent_state = LIQUID
	color = "#c8a5dc"
	metabolism = 0.05

/datum/reagent/changeling/toxin/affect_blood(var/mob/living/carbon/human/M, var/alien, var/removed)
	if(M.mind && M.mind.changeling)
		return
	else
		var/strength = 10
		if(alien != IS_DIONA)
			M.add_chemical_effect(CE_TOXIN, strength)
			M.adjustToxLoss(strength * removed / 2)
			for(var/obj/item/organ/internal/I in M.internal_organs)
				if(prob(5))
					I.damage += removed * strength * 2
//			M.take_organ_damage(removed * strength / 2)



/datum/power/changeling/boost_range
	name = "Boost Range"
	desc = "We evolve the ability to shoot our stingers at humans, with some preperation."
	helptext = "We can shoot our stingers from up to 5 tiles away."
	genomecost = 2
	verbpath = /mob/proc/changeling_boost_range

/datum/power/changeling/blind_sting
	name = "Blind Sting"
	desc = "We silently sting a human, completely blinding them for a short time."
	genomecost = 2
	verbpath = /mob/proc/changeling_blind_sting

/datum/power/changeling/extractdna
	name = "Extract DNA"
	desc = "We stealthily sting a target and extract the DNA from them."
	helptext = "Will give you the DNA of your target, allowing you to transform into them. Does not count towards absorb objectives."
	genomecost = 0
	verbpath = /mob/proc/changeling_extract_dna_sting

/datum/power/changeling/LSDSting
	name = "Hallucination Sting"
	desc = "We evolve the ability to sting a target with a pogewerful hallunicationary chemical."
	helptext = "The target does not notice they have been stung.  The effect occurs after 30 to 60 seconds."
	genomecost = 3
	verbpath = /mob/proc/changeling_lsdsting

/datum/power/changeling/DeathSting
	name = "Death Sting"
	desc = "We sting a human, filling them with potent chemicals. Their rapid death is all but assured, but our crime will be obvious."
	helptext = "It will be clear to any surrounding witnesses if you use this power."
	genomecost = 10
	verbpath = /mob/proc/changeling_DEATHsting


	//////////
	//STINGS//	//They get a pretty header because there's just so fucking many of them ;_;
	//////////

//special proc so that ranged stings don't get stopped by counters... somehow... -Luke
turf/proc/AdjacentTurfsRangedSting()
	//Yes this is snowflakey, but I couldn't get it to work any other way.. -Luke
	var/list/allowed = list(
		/obj/structure/table,
		/obj/structure/closet,
		/obj/structure/target_stake,
		/obj/structure/cable,
		/obj/structure/disposalpipe,
		/obj/machinery,
		/mob
	)

	var/L[] = new()
	for(var/turf/simulated/t in oview(src,1))
		var/add = 1
		if(t.density)
			add = 0
		if(add && LinkBlocked(src,t))
			add = 0
		if(add && TurfBlockedNonWindow(t))
			add = 0
			for(var/obj/O in t)
				if(!O.density)
					add = 1
					break
				if(istype(O, /obj/machinery/door))
					//not sure why this doesn't fire on LinkBlocked()
					add = 0
					break
				for(var/type in allowed)
					if (istype(O, type))
						add = 1
						break
				if(!add)
					break
		if(add)
			L.Add(t)
	return L

/mob/proc/sting_can_reach(mob/M as mob, sting_range = 1)
	if(M.loc == src.loc)
		return 1 //target and source are in the same thing
	if(!isturf(src.loc) || !isturf(M.loc))
		to_chat(src, "<span class='warning'>We cannot reach \the [M] with a sting!</span>")
		return 0 //One is inside, the other is outside something.
	// Maximum queued turfs set to 25; I don't *think* anything raises sting_range above 2, but if it does the 25 may need raising
	if(!AStar(src.loc, M.loc, /turf/proc/AdjacentTurfsRangedSting, /turf/proc/Distance, max_nodes=25, max_node_depth=sting_range)) //If we can't find a path, fail
		to_chat(src, "<span class='warning'>We cannot find a path to sting \the [M] by!</span>")
		return 0
	return 1

//Handles the general sting code to reduce on copypasta (seeming as somebody decided to make SO MANY dumb abilities)
/mob/proc/changeling_sting(var/required_chems=0, var/verb_path, var/loud)
	var/datum/changeling/changeling = changeling_power(required_chems)
	if(!changeling)								return

	var/list/victims = list()
	for(var/mob/living/carbon/human/C in oview(changeling.sting_range))
		victims += C
	var/mob/living/carbon/human/T = input(src, "Who will we sting?") as null|anything in victims

	if(!T) return
	if(!(T in view(changeling.sting_range))) return
	if(!sting_can_reach(T, changeling.sting_range)) return
	if(!changeling_power(required_chems)) return
	if(T.isSynthetic())
		to_chat(src, "<span class='warning'>[T] is not compatible with our biology.</span>")
		return

	changeling.chem_charges -= required_chems
	changeling.sting_range = 1
	src.verbs -= verb_path
	spawn(10)	src.verbs += verb_path
	if(!loud)
		to_chat(src, "<span class='notice'>We stealthily sting [T].</span>")
	else
		visible_message("<span class='danger'>[src] fires an organic shard into [T]'s chest, puncturing the stinger into their skin!</span>")
	if(!T.mind || !T.mind.changeling)	return T	//T will be affected by the sting
	to_chat(T, "<span class='warning'>You feel a tiny prick.</span>")
	return


//Boosts the range of your next sting attack by 1
/mob/proc/changeling_boost_range()
	set category = "Changeling"
	set name = "Ranged Sting (10)"
	set desc="Your next sting ability can be used against targets 2 squares away."

	var/datum/changeling/changeling = changeling_power(10,0,100)
	if(!changeling)	return 0
	changeling.chem_charges -= 10
	to_chat(src, "<span class='notice'>Your throat adjusts to launch the sting.</span>")
	if(changeling.recursive_enhancement)
		changeling.sting_range = 5
	else
		changeling.sting_range = 2
	src.verbs -= /mob/proc/changeling_boost_range
	spawn(5)	src.verbs += /mob/proc/changeling_boost_range
	feedback_add_details("changeling_powers","RS")
	return 1

/mob/proc/changeling_lsdsting()
	set category = "Changeling"
	set name = "Hallucination Sting (15)"
	set desc = "Causes terror in the target."

	var/mob/living/carbon/human/T = changeling_sting(15,/mob/proc/changeling_lsdsting)
	if(!T)	return 0
	spawn(rand(300,600))
		if(T)	T.hallucination(400, 80)
	feedback_add_details("changeling_powers","HS")
	return 1

/mob/proc/changeling_silence_sting()
	set category = "Changeling"
	set name = "Silence sting (10)"
	set desc="Sting target"

	var/mob/living/carbon/human/T = changeling_sting(10,/mob/proc/changeling_silence_sting)
	if(!T)	return 0
	T.silent += 30
	feedback_add_details("changeling_powers","SS")
	return 1

/mob/proc/changeling_blind_sting()
	set category = "Changeling"
	set name = "Blind sting (20)"
	set desc="Sting target"

	var/mob/living/carbon/human/T = changeling_sting(20,/mob/proc/changeling_blind_sting)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>Your eyes burn horrificly!</span>")
	T.disabilities |= NEARSIGHTED
	spawn(300)	T.disabilities &= ~NEARSIGHTED
	T.eye_blind = 10
	T.eye_blurry = 20
	feedback_add_details("changeling_powers","BS")
	return 1

/mob/proc/changeling_paralysis_sting()
	set category = "Changeling"
	set name = "Paralysis sting (30)"
	set desc="Sting target"

	var/mob/living/carbon/human/T = changeling_sting(30,/mob/proc/changeling_paralysis_sting)
	if(!T)	return 0
	if(T.reagents)	T.reagents.add_reagent(/datum/reagent/changeling/paralytic, 40)
	feedback_add_details("changeling_powers","PS")
	return 1


/mob/proc/changeling_DEATHsting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms onto death."
	var/loud = 1

	var/mob/living/carbon/human/T = changeling_sting(40,/mob/proc/changeling_DEATHsting,loud)
	if(!T)	return 0
	to_chat(T, "<span class='danger'>You feel a small prick and your chest becomes tight.</span>")
	T.make_jittery(400)
	if(T.reagents)	T.reagents.add_reagent(/datum/reagent/lexorin, 40)
	feedback_add_details("changeling_powers","DTHS")
	return 1

/mob/proc/changeling_extract_dna_sting()
	set category = "Changeling"
	set name = "Extract DNA Sting (40)"
	set desc="Stealthily sting a target to extract their DNA."

	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return 0

	var/mob/living/carbon/human/T = changeling_sting(40, /mob/proc/changeling_extract_dna_sting)
	if(!T)	return 0
	if((HUSK in T.mutations) || (T.species.flags & NO_SCAN))
		to_chat(src, "<span class='warning'>We cannot extract DNA from this creature!</span>")
		return 0

	var/datum/absorbed_dna/newDNA = new(T.real_name, T.dna, T.species.name, T.languages)
	absorbDNA(newDNA)

	feedback_add_details("changeling_powers","ED")
	return 1

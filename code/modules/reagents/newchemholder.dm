//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

var/const/TOUCH = 1
var/const/INGEST = 2
var/const/INHALE = 3
var/const/INJECT = 4

///////////////////////////////////////////////////////////////////////////////////

datum/reagents
	var/list/datum/reagent/reagent_list = new/list()
	var/total_volume = 0
	var/maximum_volume = 100
	var/atom/my_atom = null
	var/temperature = T20C
	var/mixing = 0
	var/list/reactions_in_progress = list()

datum/reagents/New(maximum=100)
	chem_holders.Add(src)

	maximum_volume = maximum

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!chemical_reagents_list)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = typesof(/datum/reagent) - /datum/reagent
		chemical_reagents_list = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			chemical_reagents_list[D.id] = D
	if(!chemical_reactions_list)
		//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
		// It is filtered into multiple lists within a list.
		// For example:
		// chemical_reaction_list["phoron"] is a list of all reactions relating to phoron

		var/paths = typesof(/datum/chemical_reaction) - /datum/chemical_reaction
		chemical_reactions_list = list()

		for(var/path in paths)

			var/datum/chemical_reaction/D = new path()
			var/list/reaction_ids = list()

			if(D.required_reagents && D.required_reagents.len)
				for(var/reaction in D.required_reagents)
					reaction_ids += reaction

			// Create filters based on each reagent id in the required reagents list
			for(var/id in reaction_ids)
				if(!chemical_reactions_list[id])
					chemical_reactions_list[id] = list()
				chemical_reactions_list[id] += D
				break // Don't bother adding ourselves to other reagent ids, it is redundant.


/datum/reagents/Del()
	chem_holders.Remove(src)


/datum/reagents/proc/process()

//if nothing in reagents, then it should be its container's temperature.
	if(src.reagent_list.len != 0)
		for(var/datum/reagent/S in reagent_list)
			S.temperature = src.temperature

//if something in a body, change temperature

	if(istype(src.my_atom, /mob/))
		if(istype(src.my_atom, /mob/living/carbon/human))
			var/mob/living/carbon/human/M = src.my_atom

			var/cap1 = M:vessel.GHC()
			var/thermal_energy = GTE(src.total_volume)
			var/cap = thermal_energy/src.temperature

			var/list/returns = src.CETE(cap, src.temperature, cap1, M.bodytemperature)
			var/delta_e1 = returns[1]
			var/delta_e2 = returns[2]
			src.ATE(delta_e1)
			var/newbtemp = src.CATE(delta_e2, cap1, M.bodytemperature)
			M.bodytemperature = newbtemp

//if non/mob/obj, change temperature based on insulation, and air.

//if turf, change temperature based on a few things,


/*
	else
		var/turf/T
		if(istype(src.my_atom, /obj/))
			T = get_turf(src.my_atom)
		else
			T=src.my_atom
		if(istype(T, /turf/space))
			temp_to = 2.7
			var/heat_cap = 1000000
			var/volume = 1000000

		else if(istype(T, /turf/simulated/wall)||istype(T, /turf/unsimulated/))
			return
			//PLACEHOLDER!!! AHHHHHH! >.<"
		else
			T:zone.air.temperature
*/

//Stuff that ^does^ require reagents goes down here.

	if(reagent_list.len < 0)
		return


//occasionally check for reactions

	if(prob(10))
		handle_reactions()


datum/reagents/proc/remove_any(var/amount=1)
	var/total_transfered = 0
	var/current_list_element = 1

	current_list_element = rand(1,reagent_list.len)

	while(total_transfered != amount)
		if(total_transfered >= amount) break
		if(total_volume <= 0 || !reagent_list.len) break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]

		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		src.update_total()

	handle_reactions()
	return total_transfered

datum/reagents/proc/get_master_reagent()
	var/the_reagent = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_reagent = A

	return the_reagent

datum/reagents/proc/get_master_reagent_name()
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

datum/reagents/proc/get_master_reagent_id()
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

datum/reagents/proc/trans_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//if preserve_data=0, the reagents data will be lost. Usefull if you use data for some strange stuff and don't want it to be transferred.
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0)
		return
	var/datum/reagents/R = target.reagents
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		if (current_reagent.id == "blood" && ishuman(target))
			var/mob/living/carbon/human/H = target
			H.inject_blood(my_atom, amount)
			continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)

		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety checks on these so all chemicals are transferred

		src.remove_reagent(current_reagent.id, current_reagent_transfer, safety = 1)							// to the target container before handling reactions

	src.update_total()
	R.update_total()
	R.handle_reactions()
	src.handle_reactions()
	return amount

datum/reagents/proc/trans_to_ingest(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1)//For items ingested. A delay is added between ingestion and addition of the reagents
	if (!target )
		return
	if (!target.reagents || src.total_volume<=0)
		return

	/*var/datum/reagents/R = target.reagents

	var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		//if (current_reagent.id == "blood" && ishuman(target))
		//	var/mob/living/carbon/human/H = target
		//	H.inject_blood(my_atom, amount)
		//	continue
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = current_reagent.data

		B.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1)	//safety checks on these so all chemicals are transferred
		src.remove_reagent(current_reagent.id, current_reagent_transfer, safety = 1)							// to the target container before handling reactions

	src.update_total()
	B.update_total()
	B.handle_reactions()
	src.handle_reactions()*/

	var/obj/item/weapon/reagent_containers/glass/beaker/noreact/B = new /obj/item/weapon/reagent_containers/glass/beaker/noreact //temporary holder
	B.volume = 1000

	var/datum/reagents/BR = B.reagents
	var/datum/reagents/R = target.reagents

	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)

	src.trans_to(B, amount)

	spawn(95)
		BR.reaction(target, INGEST)
		spawn(5)
			BR.trans_to(target, BR.total_volume)
			del(B)

	return amount

datum/reagents/proc/copy_to(var/obj/target, var/amount=1, var/multiplier=1, var/preserve_data=1, var/safety = 0)
	if(!target)
		return
	if(!target.reagents)
		return
	if(src.total_volume<=0)
		return
	var/datum/reagents/R = target.reagents
	R.temperature = src.temperature
	amount = min(min(amount, src.total_volume), R.maximum_volume-R.total_volume)
	var/part = amount / src.total_volume
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		var/current_reagent_transfer = current_reagent.volume * part
		if(preserve_data)
			trans_data = copy_data(current_reagent)
		R.add_reagent(current_reagent.id, (current_reagent_transfer * multiplier), trans_data, safety = 1, temp=src.temperature)	//safety check so all chemicals are transferred before reacting

	src.update_total()
	R.update_total()
	if(!safety)
		R.handle_reactions()
		src.handle_reactions()
	return amount

datum/reagents/proc/trans_id_to(var/obj/target, var/reagent, var/amount=1, var/preserve_data=1)//Not sure why this proc didn't exist before. It does now! /N
	if (!target)
		return
	if (!target.reagents || src.total_volume<=0 || !src.get_reagent_amount(reagent))
		return

	var/datum/reagents/R = target.reagents
	if(src.get_reagent_amount(reagent)<amount)
		amount = src.get_reagent_amount(reagent)
	amount = min(amount, R.maximum_volume-R.total_volume)
	var/trans_data = null
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if(current_reagent.id == reagent)
			if(preserve_data)
				trans_data = copy_data(current_reagent)
			R.add_reagent(current_reagent.id, amount, trans_data)
			src.remove_reagent(current_reagent.id, amount, 1)
			break

	src.update_total()
	R.update_total()
	R.handle_reactions()
	//src.handle_reactions() Don't need to handle reactions on the source since you're (presumably isolating and) transferring a specific reagent.
	return amount

/*
	if (!target) return
	var/total_transfered = 0
	var/current_list_element = 1
	var/datum/reagents/R = target.reagents
	var/trans_data = null
	//if(R.total_volume + amount > R.maximum_volume) return 0

	current_list_element = rand(1,reagent_list.len) //Eh, bandaid fix.

	while(total_transfered != amount)
		if(total_transfered >= amount) break //Better safe than sorry.
		if(total_volume <= 0 || !reagent_list.len) break
		if(R.total_volume >= R.maximum_volume) break

		if(current_list_element > reagent_list.len) current_list_element = 1
		var/datum/reagent/current_reagent = reagent_list[current_list_element]
		if(preserve_data)
			trans_data = current_reagent.data
		R.add_reagent(current_reagent.id, (1 * multiplier), trans_data)
		src.remove_reagent(current_reagent.id, 1)

		current_list_element++
		total_transfered++
		src.update_total()
		R.update_total()
	R.handle_reactions()
	handle_reactions()

	return total_transfered
*/

datum/reagents/proc/metabolize(var/mob/M,var/alien)

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(M && R)
			R.on_mob_life(M,alien)
	update_total()

datum/reagents/proc/conditional_update_move(var/atom/A, var/Running = 0)
	for(var/datum/reagent/R in reagent_list)
		R.on_move (A, Running)
	update_total()

datum/reagents/proc/conditional_update(var/atom/A, )
	for(var/datum/reagent/R in reagent_list)
		R.on_update (A)
	update_total()

datum/reagents/proc/isolate_reagent(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id != reagent)
			del_reagent(R.id)
			update_total()

datum/reagents/proc/del_reagent(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			reagent_list -= A
			del(A)
			update_total()
			my_atom.on_reagent_change()
			return 0


	return 1

datum/reagents/proc/update_total()
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < 0.1)
			del_reagent(R.id)
		else
			total_volume += R.volume

	return 0

datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/R in reagent_list)
		del_reagent(R.id)
	return 0

datum/reagents/proc/reaction(var/atom/A, var/method=TOUCH, var/volume_modifier=0)

	switch(method)
		if(TOUCH)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A))
					spawn(0)
						if(!R) return
						else R.reaction_mob(A, TOUCH, R.volume+volume_modifier)
				if(isturf(A))
					spawn(0)
						if(!R) return
						else R.reaction_turf(A, R.volume+volume_modifier)
				if(isobj(A))
					spawn(0)
						if(!R) return
						else R.reaction_obj(A, R.volume+volume_modifier)
		if(INGEST)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A) && R)
					spawn(0)
						if(!R) return
						else R.reaction_mob(A, INGEST, R.volume+volume_modifier)
		if(INHALE)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A) && R)
					spawn(0)
						if(!R) return
						else R.reaction_mob(A, INHALE, R.volume+volume_modifier)
		if(INJECT)
			for(var/datum/reagent/R in reagent_list)
				if(ismob(A) && R)
					spawn(0)
						if(!R) return
						else R.reaction_mob(A, INGEST, R.volume+volume_modifier)
	return

datum/reagents/proc/add_reagent(var/reagent, var/amount, var/list/data=null, var/safety = 0, var/temp = src.temperature)
	if(!isnum(amount)) return 1
	update_total()
//	if(!temp)
//		temp = src.temperature
//	if(total_volume == 0)
//		src.temperature = temp
	if(total_volume + amount > maximum_volume) amount = (maximum_volume - total_volume) //Doesnt fit in. Make it disappear. Shouldnt happen. Will happen.

//	var/added_TTE = src.CTE(reagent, amount, temp)
//	var/mystery_TTE = src.CTE(reagent, amount, src.temperature)
//	src.ATE(added_TTE - mystery_TTE)

	for(var/A in reagent_list)

		var/datum/reagent/R = A
//		var/hc1 = R.CTE(R.volume, temp)/temp
//		var/temp1 = temp
//		var/hc2 = src.GTE()/src.temperature
//		var/temp2 = src.temperature

//		var/energy = src.CETE(hc1, temp1, hc2, temp2, 1)

//		src.ATE(energy[2])

		if (R.id == reagent)
			R.volume += amount
			update_total()
			my_atom.on_reagent_change()

			// mix dem viruses
			if(R.id == "blood" && reagent == "blood" && src.temperature <= (T0C + 42))
				if(R.data && data)

					if(R.data["viruses"] || data["viruses"])

						var/list/mix1 = R.data["viruses"]
						var/list/mix2 = data["viruses"]

						// Stop issues with the list changing during mixing.
						var/list/to_mix = list()

						for(var/datum/disease/advance/AD in mix1)
							to_mix += AD
						for(var/datum/disease/advance/AD in mix2)
							to_mix += AD

						var/datum/disease/advance/AD = Advance_Mix(to_mix)
						if(AD)
							var/list/preserve = list(AD)
							for(var/D in R.data["viruses"])
								if(!istype(D, /datum/disease/advance))
									preserve += D
							R.data["viruses"] = preserve

			if(!safety)
				handle_reactions()
			return 0

	var/datum/reagent/D = chemical_reagents_list[reagent]
	if(D)

		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		SetViruses(R, data) // Includes setting data

		//debug
		//world << "Adding data"
		//for(var/D in R.data)
		//	world << "Container data: [D] = [R.data[D]]"
		//debug
		update_total()
		my_atom.on_reagent_change()
		if(!safety)
			handle_reactions()
		return 0
	else
		warning("[my_atom] attempted to add a reagent called '[reagent]' which doesn't exist. ([usr])")

	if(!safety)
		handle_reactions()

	return 1


datum/reagents/proc/remove_reagent(var/reagent, var/amount, var/safety = 0)//Added a safety check for the trans_id_to
	if(!isnum(amount)) return 1

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			R.volume -= amount
			update_total()
			if(!safety)//So it does not handle reactions when it need not to
				handle_reactions()
			my_atom.on_reagent_change()
			return 0

	return 1


datum/reagents/proc/has_reagent(var/reagent, var/amount = -1)

	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			if(!amount) return R
			else
				if(R.volume >= amount) return R
				else return 0

	return 0

datum/reagents/proc/get_reagent_amount(var/reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if (R.id == reagent)
			return R.volume

	return 0

datum/reagents/proc/get_reagents()
	var/res = ""
	for(var/datum/reagent/A in reagent_list)
		if (res != "") res += ","
		res += A.name

	return res

datum/reagents/proc/remove_all_type(var/reagent_type, var/amount, var/strict = 0, var/safety = 1) // Removes all reagent of X type. @strict set to 1 determines whether the childs of the type are included.
	if(!isnum(amount)) return 1

	var/has_removed_reagent = 0

	for(var/datum/reagent/R in reagent_list)
		var/matches = 0
		// Switch between how we check the reagent type
		if(strict)
			if(R.type == reagent_type)
				matches = 1
		else
			if(istype(R, reagent_type))
				matches = 1
		// We found a match, proceed to remove the reagent.	Keep looping, we might find other reagents of the same type.
		if(matches)
			// Have our other proc handle removement
			has_removed_reagent = remove_reagent(R.id, amount, safety)

	return has_removed_reagent

			//two helper functions to preserve data across reactions (needed for xenoarch)
datum/reagents/proc/get_data(var/reagent_id)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "proffering a data-carrying reagent ([reagent_id])"
			return D.data

datum/reagents/proc/set_data(var/reagent_id, var/new_data)
	for(var/datum/reagent/D in reagent_list)
		if(D.id == reagent_id)
			//world << "reagent data set ([reagent_id])"
			D.data = new_data

datum/reagents/proc/delete()
	for(var/datum/reagent/R in reagent_list)
		R.holder = null
	if(my_atom)
		my_atom.reagents = null

datum/reagents/proc/copy_data(var/datum/reagent/current_reagent)
	if (!current_reagent || !current_reagent.data) return null
	if (!istype(current_reagent.data, /list)) return current_reagent.data

	var/list/trans_data = current_reagent.data.Copy()

	// We do this so that introducing a virus to a blood sample
	// doesn't automagically infect all other blood samples from
	// the same donor.
	//
	// Technically we should probably copy all data lists, but
	// that could possibly eat up a lot of memory needlessly
	// if most data lists are read-only.
	if (trans_data["virus2"])
		var/list/v = trans_data["virus2"]
		trans_data["virus2"] = v.Copy()

	return trans_data

///////////////////////////////////////////////////////////////////////////////////


// Convenience proc to create a reagents holder for an atom
// Max vol is maximum volume of holder
atom/proc/create_reagents(var/max_vol)
	reagents = new/datum/reagents(max_vol)
	reagents.my_atom = src

///////////////////////////////////////////////////////////////////////////////////

datum/reagents/proc/handle_reactions(var/shock = 0, var/spark = 0)
	if(!my_atom.flags || (my_atom.flags & NOREACT)) return //Yup, no reactions here. No siree.

	for(var/datum/reagent/R in reagent_list) // Usually a small list
		for(var/reaction in chemical_reactions_list[R.id]) // Was a big list but now it should be smaller since we filtered it with our reagent id

			if(!reaction)
				continue

			var/datum/chemical_reaction/C = reaction

			if(C.requires_heating)
				if((temperature < C.temperature_lower_bound) || (temperature > C.temperature_upper_bound) || (spark && C.temperature_lower_bound <= (T0C + 1650) && C.temperature_upper_bound >= (T0C + 150)))
					continue

			if(C.requires_shock)
				if(!shock && (!prob(mixing*2)))
					continue

			if(C.requires_mixing)
				if(!shock && (mixing < C.requires_mixing))
					continue

			if(C.requires_oxy)
				continue //placeholder, need to add oxydiser code.

			if(C.requires_mixing)
				if(!shock && !mixing)
					continue

			if(C.stable)
				var/stabilised = 0
				for(var/datum/reagent/r in src.reagent_list)
					if(r.id == "stabilizer" && r.volume >= C.stable)
						stabilised = 1
						break
				if(stabilised)
					continue

			var/total_required_reagents = C.required_reagents.len
			var/total_matching_reagents = 0
			var/total_required_catalysts = C.required_catalysts.len
			var/total_matching_catalysts= 0
			var/matching_container = 0
			var/matching_other = 0
			var/list/multipliers = new/list()

			for(var/B in C.required_reagents)
				if(!has_reagent(B, C.required_reagents[B]))
					break
				total_matching_reagents++
				multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
			for(var/B in C.required_catalysts)
				if(!has_reagent(B, C.required_catalysts[B]))	break
				total_matching_catalysts++

			if(!C.required_container)
				matching_container = 1

			else
				if(my_atom.type == C.required_container)
					matching_container = 1

			if(!C.required_other)
				matching_other = 1

			else
				if(istype(my_atom, /obj/item/slime_extract))
					var/obj/item/slime_extract/M = my_atom

					if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
						matching_other = 1

			if(total_matching_reagents == total_required_reagents && total_matching_catalysts == total_required_catalysts && matching_container && matching_other)
				var/reaction_done = 0
				if(C in reactions_in_progress)
					continue

				reactions_in_progress += list(C)
				C.on_reaction_start()
				spawn(0)
					if(C.visible)
						var/list/seen = viewers(4, get_turf(my_atom))
						playsound(get_turf(my_atom), 'sound/effects/bubbles.ogg', 80, 1)
						for(var/mob/M in seen)
							if(!istype(my_atom, /obj/item/slime_extract))
								if(!C.instant)
									M << "\blue \icon[my_atom] The solution begins to bubble."
								else
									M << "\red \icon[my_atom] The solution bubbles violently!"
					var/tempvol = 0
					do
						if(reaction_done)
							src.reactions_in_progress -= list(C)
							break
						for(var/B in C.required_reagents)
							if(!has_reagent(B, C.required_reagents[B]))	break
							multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
						var/tickmixing = mixing
						if (C.requires_mixing)
							tickmixing -= C.requires_mixing
						if (!C.instant)
							sleep(20-(tickmixing**1.7))
						var/templist = react(C, shock, spark)
						reaction_done = templist[1]
						tempvol += templist[2]
						update_total()
						if(istype(my_atom, /obj/item/slime_extract))
							var/obj/item/slime_extract/ME2 = my_atom
							ME2.Uses--
							if(ME2.Uses <= 0) // give the notification that the slime core is dead
								ME2.name = "used slime extract"
								ME2.desc = "This extract has been used up."
						if(reaction_done)
							src.reactions_in_progress -= list(C)
							break
					while (!reaction_done)

					C.on_reaction_end(src, tempvol)
					if(C.visible)
						var/list/seen = viewers(4, get_turf(my_atom))
						for(var/mob/M in seen)
							if(!istype(my_atom, /obj/item/slime_extract))
								M << "\blue \icon[my_atom] The solution stops bubbling."
								playsound(get_turf(my_atom), 'sound/effects/bubbles.ogg', 80, 1)
							else
								M << "\blue \icon[my_atom] The [my_atom]'s power is consumed in the reaction."

				update_total()
				break

	update_total()
	return 0


datum/reagents/proc/react(var/datum/chemical_reaction/C, var/shock = 0, var/spark = 0)

	if(C.requires_heating)
		if((temperature < C.temperature_lower_bound) || (temperature > C.temperature_upper_bound) || (spark && C.temperature_lower_bound <= (T0C + 1650) && C.temperature_upper_bound >= (T0C + 150)))			return list(1,0)
	if(C.requires_shock)
		if(!shock && (!prob(mixing*2)))
			return list(1,0)
	if(C.requires_oxy)
		return list(1,0) //placeholder, need to add oxydiser code.
	if(C.requires_mixing)
		if(!shock && (mixing < C.requires_mixing))
			return list(1,0)
	if(C.stable)
		var/stabilised = 0
		for(var/datum/reagent/r in src.reagent_list)
			if(r.id == "stabilizer" && r.volume <= C.stable)
				stabilised = 1
				break
		if(stabilised)
			return list(1,0)


	var/total_required_reagents = C.required_reagents.len
	var/total_matching_reagents = 0
	var/total_required_catalysts = C.required_catalysts.len
	var/total_matching_catalysts= 0
	var/list/multipliers = new/list()

	for(var/B in C.required_reagents)
		if(!has_reagent(B, C.required_reagents[B]))	break
		total_matching_reagents++
		multipliers += round(get_reagent_amount(B) / C.required_reagents[B])
	for(var/B in C.required_catalysts)
		if(!has_reagent(B, C.required_catalysts[B]))	break
		total_matching_catalysts++

	if(total_matching_reagents != total_required_reagents || total_matching_catalysts != total_required_catalysts)
		return list(1, 0)

	var/max_created_volume = 0
	var/created_volume = 0

	if(C.results.len)
		for(var/S in C.results)
			max_created_volume += (C.results[S] * min(multipliers))
	else
		max_created_volume = C.result_amount * min(multipliers)

	if(!C.instant)
		if(shock)
			multipliers += 15
		else
			multipliers += max((C.requires_mixing - mixing), 1)

	if(C.results.len)
		for(var/S in C.results)
			created_volume += (C.results[S] * min(multipliers))
	else
		created_volume = C.result_amount * min(multipliers)

	var/multiplier = min(multipliers)
// check our max_potenital created volume to see if the reaction runs out

	var/preserved_data = null
	for(var/B in C.required_reagents)
		if(!preserved_data)
			preserved_data = get_data(B)
		remove_reagent(B, (multiplier * C.required_reagents[B]))

	C.on_reaction_tick(src, created_volume)
	if(C.results)
		for(var/S in C.results)
			multiplier = max(multiplier, 1) //this shouldnt happen ...
			add_reagent(S, C.results[S] * multiplier)
			created_volume += C.results[S]
			feedback_add_details("chemical_reaction","[S]|[C.results[S]*multiplier]")

			set_data(S, preserved_data)
	else
		feedback_add_details("chemical_reaction","[C]|[C.result_amount*multiplier]")

	if (created_volume > max_created_volume || max_created_volume == 0)
		return list(1, created_volume)
	else
		return list(0,created_volume)


//////////////////////////////////////////////////////////////////////
//Utility Code
//////////////////////////////////////////////////////////////////////

datum/reagents/proc/GTE() // Get Thermal Energy; returns total thermal energy of a datum/reagents in joules
	var/TE = 0 //heat required to heat the solution 1 degree
	for (var/datum/reagent/current_reagent in src.reagent_list)
		if (!current_reagent)
			continue
		var/heat_add = current_reagent.volume * current_reagent.density * current_reagent.specific_heat * (current_reagent.molarmass ** -1) * temperature
		//delta-T = ml * g/ml * joul/mol * mol/g
		//formula for heat capacity = volume * denisty * specific_heat * (molarmass ** -1)
		//forumula for thermal energy = heat_capacity * temperature (K)
		TE += heat_add
	return TE

datum/reagents/proc/GHC() // Get Heat Capacity. returns heat capacity of a datum/reagents,
	var/TTE = src.GTE()
	var/HC = TTE/src.temperature
	return HC

datum/reagents/proc/CTE(var/datum/reagent/R, var/v, var/t) // Get Thermal Energy; returns total thermal energy of a datum/reagents in joules
	var/HC = v * R.density * R.specific_heat * (R.molarmass ** -1)
	var/TE = HC * t
	return TE
		//delta-T = ml * g/ml * joul/mol * mol/g
		//formula for heat capacity = volume * denisty * specific_heat * (molarmass ** -1)
		//forumula for thermal energy = heat_capacity * temperature (K)


datum/reagents/proc/CATE(var/delta_e, var/hc, var/t) //calculate added thermal energy; (in joules) returns a new temp from parameters

	var/totalenergy = hc*t
	var/new_energy = totalenergy + delta_e
	var/newtemp = new_energy/hc

	return newtemp

datum/reagents/proc/ATE(var/amount)// Add thermal Energy; Add x energy, in joules to a datum/reagents (use negatives for endothermic)
	if(src.reagent_list.len == 0)	return
	var/TTE = src.GTE()
	var/HC = TTE/src.temperature
	var/new_total = (TTE + amount)/HC

	return new_total


datum/reagents/proc/EWB(var/datum/reagents/R, var/mob/M) //equalise with body
	if(!istype(M, /mob/living/carbon/human))
		return
		//PLACEHOLDER, NEED FIGURE OUT MONKEYS AND SIMPLES!
//	M.vessel


datum/reagents/proc/CETE(var/hc1, var/t1, var/hc2, var/t2, var/equalisation_ratio = 0.01) //calculate equalised thermal energy

	var/totalenergy1 = hc1*t1
	var/totalenergy2 = hc2*t2

	var/totalenergy = totalenergy1 + totalenergy2

	var/heat_cap_ratio = hc1/hc2 // src to H

	var/proportion1 = heat_cap_ratio/(heat_cap_ratio+1)
	var/proportion2 = 1 - proportion1

	var/delta_e1 = (totalenergy * proportion1) - totalenergy1
	var/delta_e2 = (totalenergy * proportion2) - totalenergy2

	return list(delta_e1, delta_e2)

datum/reagents/proc/ETE(var/datum/reagents/H, var/equalisation_ratio = 0.01) //equalise thermal energy
	if(!reagent_list.len)
		temperature = H.temperature
		return
	else if(!H.reagent_list.len)
		H.temperature = temperature
		return

	var/src_totalenergy = src.GTE()
	var/src_heatcapacity = src.GHC()
	var/H_totalenergy = H.GTE()
	var/H_heatcapacity = H.GHC()

	var/totalenergy = src_totalenergy + H_totalenergy
	var/heat_cap_ratio = src_heatcapacity/H_heatcapacity // src to H

	var/src_proportion = heat_cap_ratio/(heat_cap_ratio+1)
	var/H_proportion = 1 - src_proportion

	var/src_delta_e = (totalenergy * src_proportion) - src_totalenergy
	var/H_delta_e = (totalenergy * H_proportion) - H_totalenergy

	src.ATE(src_delta_e * equalisation_ratio)
	src.ATE(H_delta_e * equalisation_ratio)
/*
datum/reagents/proc/ETEWO(var/heat_capacity, var/temp = T20C, var/equalisation_ratio = 0.01) //equalise thermal energy with other
	if(!reagent_list.len)
		temperature = temp
		return
	else if(!H.reagent_list.len)
		temp = temperature
		return

	var/src_totalenergy = src.GTE()
	var/src_heatcapacity = src.GHC()
	var/other_totalenergy = heat_capacity * temp

	var/totalenergy = src_totalenergy + other_totalenergy
	var/heat_cap_ratio = src_heatcapacity/other_heatcapacity // src to H

	var/src_proportion = heat_cap_ratio/(heat_cap_ratio+1)
	var/other_proportion = 1 - src_proportion

	var/src_delta_e = (totalenergy * src_proportion) - src_totalenergy
	var/other_delta_e = (totalenergy * other_proportion) - other_totalenergy

	src.ATE(src_delta_e * equalisation_ratio)
*/



////////////////////////////////////////////////
//potential ticker stuff
///////////////////////////////////////////////


/*
datum/controller/game_controller
	var/processing = 0
	var/breather_ticks = 2		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/air_cost 		= 0
	var/sun_cost		= 0
	var/mobs_cost		= 0
	var/diseases_cost	= 0
	var/machines_cost	= 0
	var/objects_cost	= 0
	var/networks_cost	= 0
	var/powernets_cost	= 0
	var/nano_cost		= 0
	var/events_cost		= 0
	var/chem_cost		= 0
	var/ticker_cost		= 0
	var/total_cost		= 0

	var/last_thing_processed
	var/mob/list/expensive_mobs = list()
	var/rebuild_active_areas = 0

	var/list/shuttle_list	                    // For debugging and VV
	var/datum/ore_distribution/asteroid_ore_map // For debugging and VV.


datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			Recover()
			del(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		world << "\red \b Job setup complete"

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/emergency_shuttle_controller()
	if(!shuttle_controller)			shuttle_controller = new /datum/shuttle_controller()

datum/controller/game_controller/proc/setup()
	world.tick_lag = config.Ticklag

	spawn(20)
		createRandomZlevel()

	if(!air_master)
		air_master = new /datum/controller/air_system()
		air_master.Setup()

	if(!ticker)
		ticker = new /datum/controller/gameticker()

	setup_objects()
	setupgenetics()
	setupfactions()
	setup_economy()
	SetupXenoarch()

	transfer_controller = new

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

	spawn(0)
		if(ticker)
			ticker.pregame()

	lighting_controller.Initialize()


datum/controller/game_controller/proc/setup_objects()
	world << "\red \b Initializing objects"
	sleep(-1)
	for(var/atom/movable/object in world)
		object.initialize()

	world << "\red \b Initializing pipe networks"
	sleep(-1)
	for(var/obj/machinery/atmospherics/machine in machines)
		machine.build_network()

	world << "\red \b Initializing atmos machinery."
	sleep(-1)
	for(var/obj/machinery/atmospherics/unary/U in machines)
		if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_pump/T = U
			T.broadcast_status()
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/T = U
			T.broadcast_status()

	//Create the mining ore distribution map.
	asteroid_ore_map = new /datum/ore_distribution()
	asteroid_ore_map.populate_distribution_map()

	//Shitty hack to fix mining turf overlays, for some reason New() is not being called.
	for(var/turf/simulated/floor/plating/airless/asteroid/T in world)
		T.updateMineralOverlays()
		T.name = "asteroid"

	//Set up spawn points.
	populate_spawn_points()

	//Set up gear list.
	populate_gear_list()

	//Set up roundstart seed list.
	populate_seed_list()

	world << "\red \b Initializations complete."
	sleep(-1)


datum/controller/game_controller/proc/process()
	processing = 1
	spawn(0)
		set background = 1
		while(1)	//far more efficient than recursively calling ourself
			if(!Failsafe)	new /datum/controller/failsafe()

			var/currenttime = world.timeofday
			last_tick_duration = (currenttime - last_tick_timeofday) / 10
			last_tick_timeofday = currenttime

			if(processing)
				var/timer
				var/start_time = world.timeofday
				controller_iteration++

				vote.process()
				transfer_controller.process()
				shuttle_controller.process()
				process_newscaster()

				//AIR

				if(!air_processing_killed)
					timer = world.timeofday
					last_thing_processed = air_master.type

					if(!air_master.Tick()) //Runtimed.
						air_master.failed_ticks++
						if(air_master.failed_ticks > 5)
							world << "<font color='red'><b>RUNTIMES IN ATMOS TICKER.  Killing air simulation!</font></b>"
							world.log << "### ZAS SHUTDOWN"
							message_admins("ZASALERT: unable to run [air_master.tick_progress], shutting down!")
							log_admin("ZASALERT: unable run zone/process() -- [air_master.tick_progress]")
							air_processing_killed = 1
							air_master.failed_ticks = 0

					air_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//SUN
				timer = world.timeofday
				last_thing_processed = sun.type
				sun.calc_position()
				sun_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MOBS
				timer = world.timeofday
				process_mobs()
				mobs_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//DISEASES
				timer = world.timeofday
				process_diseases()
				diseases_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//MACHINES
				timer = world.timeofday
				process_machines()
				machines_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//OBJECTS
				timer = world.timeofday
				process_objects()
				objects_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//PIPENETS
				if(!pipe_processing_killed)
					timer = world.timeofday
					process_pipenets()
					networks_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//POWERNETS
				timer = world.timeofday
				process_powernets()
				powernets_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//NANO UIS
				timer = world.timeofday
				process_nano()
				nano_cost = (world.timeofday - timer) / 10

				sleep(breather_ticks)

				//EVENTS
				timer = world.timeofday
				process_events()
				events_cost = (world.timeofday - timer) / 10

				//CHEMSTRY
				timer = world.timeofday
				process_chemistry()
				events_cost = (world.timeofday - timer) / 10

				//TICKER
				timer = world.timeofday
				last_thing_processed = ticker.type
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

				//TIMING
				total_cost = air_cost + sun_cost + mobs_cost + diseases_cost + machines_cost + objects_cost + networks_cost + powernets_cost + nano_cost + events_cost + chem_cost + ticker_cost

				var/end_time = world.timeofday
				if(end_time < start_time)	//why not just use world.time instead?
					start_time -= 864000    //deciseconds in a day
				sleep( round(minimum_ticks - (end_time - start_time),1) )
			else
				sleep(10)
*/

///^go through master controller add chem stuff, check to see if they added anything...

//var/global/list/chem_holders = list()

//^add to global.dm
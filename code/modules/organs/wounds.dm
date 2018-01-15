
/****************************************************
					WOUNDS
****************************************************/
/datum/wound
	var/current_stage = 0      // number representing the current stage
	var/desc = "wound"         // description of the wound. default in case something borks
	var/damage = 0             // amount of damage this wound causes
	var/min_damage = 0         // amount of damage this wound can be reuced to
	var/bleed_timer = 0        // ticks of bleeding left.
	var/bleed_threshold = 30   // Above this amount wounds you will need to treat the wound to stop bleeding, regardless of bleed_timer
	var/min_damage = 0         // amount of damage the current wound type requires(less means we need to apply the next healing stage)
	var/bandaged = 0           // is the wound bandaged?
	var/clamped = 0            // Similar to bandaged, but works differently
	var/salved = 0             // is the wound salved?
	var/disinfected = 0        // is the wound disinfected?
	var/created = 0
	var/amount = 1             // number of wounds of this type
	var/germ_level = 0         // amount of germs in the wound
	var/permanent = 0          // a permanent wound
	var/bleed_size = 1         // scalar multiplied by other factors to tell how much blood you're leaking.

	/*  These are defined by the wound type and should not be changed */
	var/list/stages            // stages such as "cut", "deep cut", etc.
	var/list/stages_plural     // plurals of stages such as "cuts", "deep cuts", etc.
	var/max_bleeding_stage = 0 // maximum stage at which bleeding should still happen. Beyond this stage bleeding is prevented.
	var/damage_type = CUT      // one of CUT, PIERCE, BRUISE, BURN
	var/autoheal_cutoff = 15   // the maximum amount of damage that this wound can have and still autoheal

	// helper lists
	var/tmp/list/embedded_objects = list()
	var/tmp/list/desc_list = list()
	var/tmp/list/damage_list = list()

/datum/wound/New(var/damage)

	created = world.time

	// reading from a list("stage" = damage) is pretty difficult, so build two separate
	// lists from them instead
	for(var/V in stages)
		desc_list += V
		damage_list += stages[V]

	src.damage = damage
	if(src.damage > min_damage)
		min_damage += (src.damage - min_damage)/(10*amount)

	// initialize with the appropriate stage
	src.init_stage(damage)

	bleed_timer += damage

// returns 1 if there's a next stage, 0 otherwise
/datum/wound/proc/init_stage(var/initial_damage)
	current_stage = stages.len

	while(src.current_stage > 1 && src.damage_list[current_stage-1] <= initial_damage / src.amount)
		src.current_stage--

	src.min_damage = damage_list[current_stage]
	src.desc = desc_list[current_stage]

// the amount of damage per wound
/datum/wound/proc/wound_damage()
	return src.damage / src.amount

/datum/wound/proc/can_autoheal()
	if(embedded_objects.len)
		return 0
	return (wound_damage() <= autoheal_cutoff) ? 1 : is_treated()

// checks whether the wound has been appropriately treated
/datum/wound/proc/is_treated()
	if(!embedded_objects.len)
		switch(damage_type)
			if(BRUISE, CUT, PIERCE)
				return bandaged
			if(BURN)
				return salved

	// Checks if an injury can go from a non-permanent to a permanent injury
/datum/wound/proc/transform_permanent(var/datum/wound/)
	return

	// Checks whether other other can be merged into src.
/datum/wound/proc/can_merge(var/datum/wound/other)
	if (other.type != src.type) return 0
	if (other.current_stage != src.current_stage) return 0
	if (other.damage_type != src.damage_type) return 0
	if (!(other.can_autoheal()) != !(src.can_autoheal())) return 0
	if (other.is_surgical() != src.is_surgical()) return 0
	if (!(other.bandaged) != !(src.bandaged)) return 0
	if (!(other.clamped) != !(src.clamped)) return 0
	if (!(other.salved) != !(src.salved)) return 0
	if (!(other.disinfected) != !(src.disinfected)) return 0
	return 1

/datum/wound/proc/merge_wound(var/datum/wound/other)
	src.embedded_objects |= other.embedded_objects
	src.damage += other.damage
	src.amount += other.amount
	src.bleed_timer += other.bleed_timer
	src.germ_level = max(src.germ_level, other.germ_level)
	src.created = max(src.created, other.created)	//take the newer created time

// checks if wound is considered open for external infections
// untreated cuts (and bleeding bruises) and burns are possibly infectable, chance higher if wound is bigger
/datum/wound/proc/infection_check()
	if (damage < 10)	//small cuts, tiny bruises, and moderate burns shouldn't be infectable.
		return 0
	if (is_treated() && damage < 25)	//anything less than a flesh wound (or equivalent) isn't infectable if treated properly
		return 0
	if (disinfected)
		germ_level = 0	//reset this, just in case
		return 0

	if (damage_type == BRUISE && !bleeding()) //bruises only infectable if bleeding
		return 0

	var/dam_coef = round(damage/10)
	switch (damage_type)
		if (BRUISE)
			return prob(dam_coef*5)
		if (BURN)
			return prob(dam_coef*10)
		if (CUT)
			return prob(dam_coef*20)

	return 0

/datum/wound/proc/bandage()
	bandaged = 1

/datum/wound/proc/salve()
	salved = 1

/datum/wound/proc/disinfect()
	disinfected = 1

// heal the given amount of damage, and if the given amount of damage was more
// than what needed to be healed, return how much heal was left
/datum/wound/proc/heal_damage(amount)
	if(embedded_objects.len)
		return amount // heal nothing
	var/healed_damage = min(src.damage, amount)
	amount -= healed_damage
	src.damage -= healed_damage

	while(src.wound_damage() < damage_list[current_stage] && current_stage < src.desc_list.len)
		current_stage++
	desc = desc_list[current_stage]
	src.min_damage = damage_list[current_stage]

	// return amount of healing still leftover, can be used for other wounds
	return amount

// opens the wound again
/datum/wound/proc/open_wound(damage)
	src.damage += damage
	bleed_timer += damage

	while(src.current_stage > 1 && src.damage_list[current_stage-1] <= src.damage / src.amount)
		src.current_stage--

	src.desc = desc_list[current_stage]
	src.min_damage = damage_list[current_stage]

// returns whether this wound can absorb the given amount of damage.
// this will prevent large amounts of damage being trapped in less severe wound types
/datum/wound/proc/can_worsen(damage_type, damage)
	if (src.damage_type != damage_type)
		return 0	//incompatible damage types

	if (src.amount > 1)
		return 0	//merged wounds cannot be worsened.

	//with 1.5*, a shallow cut will be able to carry at most 30 damage,
	//37.5 for a deep cut
	//52.5 for a flesh wound, etc.
	var/max_wound_damage = 1.5*src.damage_list[1]
	if (src.damage + damage > max_wound_damage)
		return 0
	return 1

/datum/wound/proc/bleeding()
	for(var/obj/item/thing in embedded_objects)
		if(thing.w_class > ITEM_SIZE_SMALL)
			return FALSE
	if(bandaged || clamped)
		return FALSE
	return ((bleed_timer > 0 || wound_damage() > bleed_threshold) && current_stage <= max_bleeding_stage)

/datum/wound/proc/is_surgical()
	return 0

//Creating a wound
/obj/item/organ/proc/createwound(var/type = CUT, var/damage, var/surgical)
	if(damage == 0)
		return


	// first check whether we can widen an existing wound
	if(!surgical && wounds && wounds.len > 0 && prob(max(50+(number_wounds-1)*10,90)))
		if((type == CUT || type == BRUISE) && damage >= 5)
			//we need to make sure that the wound we are going to worsen is compatible with the type of damage...
			var/list/compatible_wounds = list()
			for (var/datum/wound/W in wounds)
				if (W.can_worsen(type, damage))
					compatible_wounds += W

			if(compatible_wounds.len)
				var/datum/wound/W = pick(compatible_wounds)
				W.open_wound(damage)
				if(prob(25))
					if(robotic >= ORGAN_ROBOT)
						owner.visible_message("<span class='danger'>The damage to [owner.name]'s [name] worsens.</span>",\
						"<span class='danger'>The damage to your [name] worsens.</span>",\
						"<span class='danger'>You hear the screech of abused metal.</span>")
					else
						owner.visible_message("<span class='danger'>The wound on [owner.name]'s [name] widens with a nasty ripping noise.</span>",\
						"<span class='danger'>The wound on your [name] widens with a nasty ripping noise.</span>",\
						"<span class='danger'>You hear a nasty ripping noise, as if flesh is being torn apart.</span>")
				return W


	var/wound_type = get_wound_type(type, damage)

	if(wound_type)
		var/datum/wound/W = new wound_type(damage)

		//Check whether we can add the wound to an existing wound
		if(istype(src, /obj/item/organ/external) && surgical)
			W.autoheal_cutoff = 0
		else
			for(var/datum/wound/other in wounds)
				if(other.can_merge(W))
					other.merge_wound(W)
					return
		wounds += W
		return W


	//moved these before the open_wound check so that having many small wounds for example doesn't somehow protect you from taking internal damage (because of the return)
	//Brute damage can possibly trigger an internal wound, too.

/*
	if(!surgical && (type in list(CUT, PIERCE, BRUISE)))
		for(var/datum/bone/B in bones)
			B.take_damage(damage)
*/


	var/local_damage = brute_dam + burn_dam + damage
	if(!surgical && (type in list(CUT, PIERCE, BRUISE)) && damage > 15 && local_damage > 30)
		var/internal_damage
		if(prob(damage) && sever_artery())
			internal_damage = TRUE
		if(prob(ceil(damage/4)) && sever_tendon())
			internal_damage = TRUE
		if(internal_damage)
			owner.custom_pain("You feel something rip in your [name]!", 50, affecting = src)

	//Burn damage can cause fluid loss due to blistering and cook-off
	if((type in list(BURN, LASER)) && (damage > 5 || damage + burn_dam >= 15) && (robotic < ORGAN_ROBOT))
		var/fluid_loss_severity
		switch(type)
			if(BURN)  fluid_loss_severity = FLUIDLOSS_WIDE_BURN
			if(LASER) fluid_loss_severity = FLUIDLOSS_CONC_BURN
		var/fluid_loss = 5 * damage * fluid_loss_severity
		owner.remove_blood(fluid_loss)




/** WOUND DEFINITIONS **/
//Note that the MINIMUM damage before a wound can be applied should correspond to
//the damage amount for the stage with the same name as the wound.
//e.g. /datum/wound/cut/deep should only be applied for 15 damage and up,
//because in it's stages list, "deep cut" = 15.
/proc/get_wound_type(var/type, var/damage)
	switch(type)
		if(CUT)
			switch(damage)
				if(70 to INFINITY)
					return /datum/wound/cut/massive
				if(60 to 70)
					return /datum/wound/cut/gaping_big
				if(50 to 60)
					return /datum/wound/cut/gaping
				if(25 to 50)
					return /datum/wound/cut/flesh
				if(15 to 25)
					return /datum/wound/cut/deep
				if(0 to 15)
					return /datum/wound/cut/small
		if(PIERCE)
			switch(damage)
				if(60 to INFINITY)
					return /datum/wound/puncture/massive
				if(50 to 60)
					return /datum/wound/puncture/gaping_big
				if(30 to 50)
					return /datum/wound/puncture/gaping
				if(15 to 30)
					return /datum/wound/puncture/flesh
				if(0 to 15)
					return /datum/wound/puncture/small
		if(BRUISE)
			return /datum/wound/bruise
		if(BURN, LASER)
			switch(damage)
				if(50 to INFINITY)
					return /datum/wound/burn/carbonised
				if(40 to 50)
					return /datum/wound/burn/deep
				if(30 to 40)
					return /datum/wound/burn/severe
				if(15 to 30)
					return /datum/wound/burn/large
				if(0 to 15)
					return /datum/wound/burn/moderate
		if(AVULSION_PERMANENT)
			return /datum/wound/permanent/avulsion
		if(CRUSH_PERMANENT)
			return /datum/wound/permanent/crush


	return null //no wound

/** CUTS **/
/datum/wound/cut
	bleed_threshold = 5
	damage_type = CUT

/datum/wound/cut/bandage()
	..()
	if(!autoheal_cutoff)
		autoheal_cutoff = initial(autoheal_cutoff)

/datum/wound/cut/is_surgical()
	return autoheal_cutoff == 0

/datum/wound/cut/proc/close()
	current_stage = max_bleeding_stage + 1
	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]
	damage = min(min_damage, damage)

/datum/wound/cut/small
	// link wound descriptions to amounts of damage
	// Minor cuts have max_bleeding_stage set to the stage that bears the wound type's name.
	// The major cut types have the max_bleeding_stage set to the clot stage (which is accordingly given the "blood soaked" descriptor).
	max_bleeding_stage = 3
	stages = list(
		"ugly ripped cut" = 20,
		"ripped cut" = 10,
		"cut" = 5,
		"healing cut" = 2,
		"small scab" = 0
		)

	stages_plural = list(
		"ugly ripped cuts" = 20,
		"ripped cuts" = 10,
		"cuts" = 5,
		"healing cuts" = 2,
		"small scabs" = 0
		)



/datum/wound/cut/deep
	max_bleeding_stage = 3
	stages = list(
		"ugly deep ripped cut" = 25,
		"deep ripped cut" = 20,
		"deep cut" = 15,
		"clotted cut" = 8,
		"scab" = 2,
		"fresh skin" = 0
		)

	stages_plural = list(
		"ugly deep ripped cuts" = 25,
		"deep ripped cuts" = 20,
		"deep cuts" = 15,
		"clotted cuts" = 8,
		"scabs" = 2,
		"fresh skins" = 0
		)

/datum/wound/cut/flesh
	max_bleeding_stage = 4
	stages = list(
		"ugly ripped flesh wound" = 35,
		"ugly flesh wound" = 30,
		"flesh wound" = 25,
		"blood soaked clot" = 15,
		"large scab" = 5,
		"fresh skin" = 0
		)

	stages_plural = list(
		"ugly ripped flesh wounds" = 35,
		"ugly flesh wounds" = 30,
		"flesh wounds" = 25,
		"blood soaked clots" = 15,
		"large scabs" = 5,
		"fresh skins" = 0
		)

/datum/wound/cut/gaping
	max_bleeding_stage = 3
	stages = list(
		"gaping wound" = 50,
		"large blood soaked clot" = 25,
		"blood soaked clot" = 15,
		"small angry scar" = 5,
		"small straight scar" = 0
		)

	stages_plural = list(
		"gaping wounds" = 50,
		"large blood soaked clots" = 25,
		"blood soaked clots" = 15,
		"small angry scars" = 5,
		"small straight scars" = 0
		)

/datum/wound/cut/gaping_big
	max_bleeding_stage = 3
	stages = list(
		"big gaping wound" = 60,
		"healing gaping wound" = 40,
		"large blood soaked clot" = 25,
		"large angry scar" = 10,
		"large straight scar" = 0
		)

	stages_plural = list(
		"big gaping wounds" = 60,
		"healing gaping wounds" = 40,
		"large blood soaked clots" = 25,
		"large angry scars" = 10,
		"large straight scars" = 0
		)

datum/wound/cut/massive
	max_bleeding_stage = 3
	stages = list(
		"massive wound" = 70,
		"massive healing wound" = 50,
		"massive blood soaked clot" = 25,
		"massive angry scar" = 10,
		"massive jagged scar" = 0
		)

	stages_plural = list(
		"massive wounds" = 70,
		"massive healing wounds" = 50,
		"massive blood soaked clots" = 25,
		"massive angry scars" = 10,
		"massive jagged scars" = 0
		)

/** PUNCTURES **/
/datum/wound/puncture
	bleed_threshold = 10
	damage_type = PIERCE

/datum/wound/puncture/can_worsen(damage_type, damage)
	return 0 //puncture wounds cannot be enlargened

/datum/wound/puncture/small
	max_bleeding_stage = 2
	stages = list(
		"puncture" = 5,
		"healing puncture" = 2,
		"small scab" = 0
		)

	stages_plural = list(
		"punctures" = 5,
		"healing punctures" = 2,
		"small scabs" = 0
		)

/datum/wound/puncture/flesh
	max_bleeding_stage = 2
	stages = list(
		"puncture wound" = 15,
		"blood soaked clot" = 5,
		"large scab" = 2,
		"small round scar" = 0
		)

	stages_plural = list(
		"puncture wounds" = 15,
		"blood soaked clots" = 5,
		"large scabs" = 2,
		"small round scars" = 0
		)

/datum/wound/puncture/gaping
	max_bleeding_stage = 3
	stages = list(
		"gaping hole" = 30,
		"large blood soaked clot" = 15,
		"blood soaked clot" = 10,
		"small angry scar" = 5,
		"small round scar" = 0
		)

	stages_plural = list(
		"gaping holes" = 30,
		"large blood soaked clots" = 15,
		"blood soaked clots" = 10,
		"small angry scars" = 5,
		"small round scars" = 0
		)

/datum/wound/puncture/gaping_big
	max_bleeding_stage = 3
	stages = list(
		"big gaping hole" = 50,
		"healing gaping hole" = 20,
		"large blood soaked clot" = 15,
		"large angry scar" = 10,
		"large round scar" = 0
		)

	stages_plural = list(
		"big gaping holes" = 50,
		"healing gaping holes" = 20,
		"large blood soaked clots" = 15,
		"large angry scars" = 10,
		"large round scars" = 0
		)

datum/wound/puncture/massive
	max_bleeding_stage = 3
	stages = list(
		"massive wound" = 60,
		"massive healing wound" = 30,
		"massive blood soaked clot" = 25,
		"massive angry scar" = 10,
		"massive jagged scar" = 0
		)

	stages_plural = list(
		"massive wounds" = 60,
		"massive healing wounds" = 30,
		"massive blood soaked clots" = 25,
		"massive angry scars" = 10,
		"massive jagged scars" = 0
		)

/** BRUISES **/
/datum/wound/bruise
	bleed_threshold = 20
	max_bleeding_stage = 3 //only large bruise and above can bleed.
	autoheal_cutoff = 30
	damage_type = BRUISE

	stages = list(
		"massive bruise" = 50,
		"huge bruise" = 35,
		"large bruise" = 25,
		"moderate bruise" = 15,
		"small bruise" = 10,
		"tiny bruise" = 5
		)

	stages_plural = list(
		"massive bruises" = 50,
		"huge bruises" = 35,
		"large bruises" = 25,
		"moderate bruises" = 15,
		"small bruises" = 10,
		"tiny bruises" = 5
		)

/** BURNS **/
/datum/wound/burn
	damage_type = BURN
	max_bleeding_stage = 0

/datum/wound/burn/bleeding()
	return 0

/datum/wound/burn/moderate
	stages = list(
		"ripped burn" = 10,
		"moderate burn" = 5,
		"healing moderate burn" = 2,
		"fresh skin" = 0
		)

	stages_plural = list(
		"ripped burns" = 10,
		"moderate burns" = 5,
		"healing moderate burns" = 2,
		"fresh skins" = 0
		)

/datum/wound/burn/large
	stages = list(
		"ripped large burn" = 20,
		"large burn" = 15,
		"healing large burn" = 5,
		"fresh skin" = 0
		)

	stages_plural = list(
		"ripped large burns" = 20,
		"large burns" = 15,
		"healing large burns" = 5,
		"fresh skins" = 0
		)

/datum/wound/burn/severe
	stages = list(
		"ripped severe burn" = 35,
		"severe burn" = 30,
		"healing severe burn" = 10,
		"burn scar" = 0
		)

	stages_plural = list(
		"ripped severe burns" = 35,
		"severe burns" = 30,
		"healing severe burns" = 10,
		"burn scars" = 0
		)

/datum/wound/burn/deep
	stages = list(
		"ripped deep burn" = 45,
		"deep burn" = 40,
		"healing deep burn" = 15,
		"large burn scar" = 0
		)

	stages_plural = list(
		"ripped deep burns" = 45,
		"deep burns" = 40,
		"healing deep burns" = 15,
		"large burn scars" = 0
		)

/datum/wound/burn/carbonised
	stages = list(
		"carbonised area" = 50,
		"healing carbonised area" = 20,
		"massive burn scar" = 0
		)

	stages_plural = list(
		"carbonised areas" = 50,
		"healing carbonised areas" = 20,
		"massive burn scars" = 0
		)

/** PERMANENT WOUNDS **/

/** AVULSIONS **/
/datum/wound/permanent/avulsion
	damage_type = AVULSION_PERMANENT
	max_bleeding_stage = 0
	stages = list(
		"massive missing chunk of flesh"
	)

	stages_plural = list(
		"massive missing chunks of flesh"
	)

/** CRUSH **/
/datum/wound/permanent/crush
	damage_type = CRUSH_PERMANENT
	max_bleeding_stage = 0
	stages = list(
		"massive patch of mangled flesh"
	)

	stages_plural = list(
		"massive patches of mangled flesh"
	)


/** EXTERNAL ORGAN LOSS **/
/datum/wound/lost_limb

/datum/wound/lost_limb/New(var/obj/item/organ/external/lost_limb, var/losstype, var/clean)
	var/damage_amt = lost_limb.max_damage
	if(clean) damage_amt /= 2

	switch(losstype)
		if(DROPLIMB_EDGE, DROPLIMB_BLUNT, DROPLIMB_AVULSION, DROPLIMB_CRUSH)
			damage_type = CUT
			max_bleeding_stage = 3 //clotted stump and above can bleed.
			stages = list(
				"ripped stump" = damage_amt*1.3,
				"bloody stump" = damage_amt,
				"clotted stump" = damage_amt*0.5,
				"scarred stump" = 0
				)
		if(DROPLIMB_BURN)
			damage_type = BURN
			stages = list(
				"ripped charred stump" = damage_amt*1.3,
				"charred stump" = damage_amt,
				"scarred stump" = damage_amt*0.5,
				"scarred stump" = 0
				)

	..(damage_amt)

/datum/wound/lost_limb/can_merge(var/datum/wound/other)
	return 0 //cannot be merged



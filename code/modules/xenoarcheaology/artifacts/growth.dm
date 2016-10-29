#define CRYSTAL_MOOD_PASSIVE    0
#define CRYSTAL_MOOD_INTERESTED 1
#define CRYSTAL_MOOD_WARY       2
#define CRYSTAL_MOOD_AGGRESSIVE 3
#define CRYSTAL_MOOD_HOSTILE    4

#define CRYSTAL_INTEREST_THRESHOLD   75
#define CRYSTAL_WARY_THRESHOLD       300
#define CRYSTAL_AGGRESSIVE_THRESHOLD 500
#define CRYSTAL_HOSTILE_THRESHOLD    650
#define CRYSTAL_MAX_TENSION          750

#define CRYSTAL_SPLIT_RANDOM    0
#define CRYSTAL_SPLIT_TARGETED  1
#define CRYSTAL_SPLIT_HOSTILE   2

#define CRYSTAL_SPLITFORCE_RANDOM    10
#define CRYSTAL_SPLITFORCE_TARGETED  20
#define CRYSTAL_SPLITFORCE_HOSTILE   35


#define CRYSTAL_HEAT_SCALAR     500
#define CRYSTAL_BODYHEAT_SCALAR 750
#define CRYSTAL_GROWTH_SCALAR   3000

#define CRYSTAL_GROWTH_STAGE_1 250
#define CRYSTAL_GROWTH_STAGE_2 750
#define CRYSTAL_GROWTH_STAGE_3 1250



/obj/structure/crystal_growth
	name = "strange crystal"
	desc = "A strange crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "crystal_1"

	var/growth=250
	var/health=25
	var/max_health = 25
	var/mood = 0 // 0-passive, 1-interested, 2-wary, 3-aggressive, 4-hostile
	var/mob/living/target
	var/tension = 0 //used to interact with mood, mood is a more salient indicator.

	var/min_temp= T0C
	var/splitting = 0


	anchored = 0

/obj/structure/crystal_growth/New()
	..()
	processing_objects.Add(src)


/obj/structure/crystal_growth/Destroy()
	processing_objects.Remove(src)
	if(health <= 0)
		src.visible_message("<span class='danger'>\The [src] shatters!</span>")
	return ..()


/obj/structure/crystal_growth/attack_hand()
	tension = max(CRYSTAL_INTEREST_THRESHOLD, tension + 20)
	..()

/obj/structure/crystal_growth/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(W.damtype == "fire")
		src.growth += (4*W.force)
		src.health += (W.force)
		src.tension -= (10*W.force)
	else
		src.health -= W.force
		tension = max(CRYSTAL_WARY_THRESHOLD, tension + max(20, 25*W.force) )

		for(var/obj/structure/crystal_growth/C in orange(src.loc, 7))
			spawn(rand(15,50))
				C.call_hostile(target, tension, max(20, 20*W.force) )
	..()


/obj/structure/crystal_growth/process()
	if(health <= 0)
		qdel()
		return

	var/turf/T = get_turf(src)
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && environment.temperature > min_temp)
		var/removed_heat = CRYSTAL_HEAT_SCALAR * max(0,environment.temperature - min_temp)**(1/3)
		environment.add_thermal_energy(-removed_heat)
		growth += removed_heat/CRYSTAL_GROWTH_SCALAR

	max_health = max(0, growth/10)
	health = min(health, max_health)

	process_behavior()




/obj/structure/crystal_growth/proc/process_behavior()
	var/min_light_power = 2
	var/max_light_power = 10
	var/min_light_range = 1.5
	var/add_light_range = 3
	if(tension > CRYSTAL_MAX_TENSION)
		tension = CRYSTAL_MAX_TENSION
	if(tension < 0)
		tension = 0

	switch(tension)
		if(0 to CRYSTAL_INTEREST_THRESHOLD-1)
			mood = CRYSTAL_MOOD_PASSIVE
			set_light((tension*(add_light_range+min_light_range)/CRYSTAL_INTEREST_THRESHOLD), min_light_power + (tension/CRYSTAL_MAX_TENSION) * (max_light_power-min_light_power), "#FF0000")

		if(CRYSTAL_INTEREST_THRESHOLD to CRYSTAL_WARY_THRESHOLD-1)
			mood = CRYSTAL_MOOD_INTERESTED
			set_light(((tension-CRYSTAL_INTEREST_THRESHOLD)*add_light_range/(CRYSTAL_WARY_THRESHOLD - CRYSTAL_INTEREST_THRESHOLD))+min_light_range, min_light_power + (tension/CRYSTAL_MAX_TENSION) * (max_light_power-min_light_power), "#0000FF")

		if(CRYSTAL_WARY_THRESHOLD to CRYSTAL_AGGRESSIVE_THRESHOLD-1)
			mood = CRYSTAL_MOOD_WARY
			set_light(((tension-CRYSTAL_WARY_THRESHOLD)*add_light_range/(CRYSTAL_AGGRESSIVE_THRESHOLD - CRYSTAL_WARY_THRESHOLD))+min_light_range, min_light_power + (tension/CRYSTAL_MAX_TENSION) * (max_light_power-min_light_power), "#FF00FF")

		if(CRYSTAL_AGGRESSIVE_THRESHOLD to CRYSTAL_HOSTILE_THRESHOLD-1)
			mood = CRYSTAL_MOOD_AGGRESSIVE
			set_light(((tension-CRYSTAL_AGGRESSIVE_THRESHOLD)*add_light_range/(CRYSTAL_HOSTILE_THRESHOLD - CRYSTAL_AGGRESSIVE_THRESHOLD))+min_light_range, min_light_power + (tension/CRYSTAL_MAX_TENSION) * (max_light_power-min_light_power), "#00FFFF")

		else
			mood = CRYSTAL_MOOD_HOSTILE
			set_light(((tension-CRYSTAL_HOSTILE_THRESHOLD)*add_light_range/(CRYSTAL_MAX_TENSION - CRYSTAL_HOSTILE_THRESHOLD))+min_light_range, min_light_power + (tension/CRYSTAL_MAX_TENSION) * (max_light_power-min_light_power), "#00FF00")


	var/mobs_near = 0
	var/turf/T = get_turf(src)
	var/list/turf/cardinal_turfs = T.CardinalTurfs()

	for(var/mob/living/M in range(9, get_turf(src)) )
		if(M.stat != DEAD)
			mobs_near = 1

	if(!mobs_near)
		tension -= 15
	else
		process_mobsnear()

	switch(mood)
		if(CRYSTAL_MOOD_PASSIVE)
			src.target = null
		if(CRYSTAL_MOOD_AGGRESSIVE)
			if(target)
				split(CRYSTAL_SPLIT_HOSTILE, target)
		if(CRYSTAL_MOOD_HOSTILE)
			if(target)
				split(CRYSTAL_SPLIT_HOSTILE, target)

	switch (growth)
		if(CRYSTAL_GROWTH_STAGE_1 to CRYSTAL_GROWTH_STAGE_2 - 1)
			var/CT = pick(cardinal_turfs)
			if(!mobs_near && prob(3))
				src.forceMove(CT) // Did someone move my rocks?
				playsound(src.loc, 'sound/effects/stonedoor_openclose.ogg', 20, 1)
			anchored = 0
			density = 0
		if(CRYSTAL_GROWTH_STAGE_2 to CRYSTAL_GROWTH_STAGE_3 - 1)
			icon_state = "crystal_2"
			if(mobs_near)
				if(prob(1))
					split(CRYSTAL_SPLIT_TARGETED)
			anchored = 1
			density = 1
		if(CRYSTAL_GROWTH_STAGE_3 to INFINITY)
			icon_state = "crystal_3"
			if(mobs_near)
				if(prob(4))
					split(CRYSTAL_SPLIT_TARGETED)
			else
				if(prob(30))
					split(CRYSTAL_SPLIT_RANDOM)
			anchored = 1
			density = 1

/obj/structure/crystal_growth/proc/process_mobsnear()
	var/list/mob/living/mobs = list()
	for(var/mob/living/L in view(8, get_turf(src)) )
		if(L.stat != DEAD)
			mobs.Add(L)
	var/closest_dist = 8
	for(var/mob/living/M in mobs)
		var/distance = get_dist(M.loc, src.loc) //hah, 'Mloc'
		if(distance < closest_dist)
			closest_dist = min(distance, closest_dist)
			src.target = M

	if(mood == CRYSTAL_MOOD_PASSIVE)
		tension += (4-closest_dist)
	else if(mood == CRYSTAL_MOOD_INTERESTED)
		tension += (4-closest_dist)/2
	else
		tension += (4-closest_dist)*2


/obj/structure/crystal_growth/Bumped(atom/AM as mob|obj)
	tension = max(CRYSTAL_INTEREST_THRESHOLD, tension + 20)

/obj/structure/crystal_growth/proc/call_hostile(var/mob/living/targeted, var/new_tension = CRYSTAL_WARY_THRESHOLD, var/tension_mod = 20)
	src.tension = max(new_tension, tension + tension_mod)
	if(get_dist(targeted.loc, src.loc)<=5)
		target = targeted
	if(target && get_dist(target.loc,src.loc)<=5 && tension >= CRYSTAL_HOSTILE_THRESHOLD)
		split(CRYSTAL_SPLIT_HOSTILE, target)


/obj/structure/crystal_growth/proc/split(var/split_type = CRYSTAL_SPLIT_RANDOM, var/mob/living/targeted)
	set waitfor = 0

	if(splitting)
		return

	var/shards = 0
	switch(growth)
		if(0 to CRYSTAL_GROWTH_STAGE_2 - 1)
			return 0
		if(CRYSTAL_GROWTH_STAGE_2 to CRYSTAL_GROWTH_STAGE_3 - 1)
			shards = 2
		if(CRYSTAL_GROWTH_STAGE_3 to INFINITY)
			shards = 4

	splitting = 1
	playsound(src.loc, 'sound/machines/airlock_creaking.ogg', 20, 1)
	var/msg = pick("<span class ='warning'>\The [src] groans!</span>","<span class ='warning'>\The [src] strains!</span>","<span class ='warning'>\The [src] emits a low creaking!</span>")
	visible_message(msg)
	sleep(30)

	var/throw_at_force = CRYSTAL_SPLITFORCE_RANDOM
	switch(split_type)
		if (CRYSTAL_SPLIT_TARGETED)
			throw_at_force = CRYSTAL_SPLITFORCE_TARGETED
		if(CRYSTAL_SPLIT_HOSTILE)
			throw_at_force = CRYSTAL_SPLITFORCE_HOSTILE

	if(split_type != CRYSTAL_SPLIT_RANDOM)
		for(var/obj/structure/crystal_growth/C in orange(src.loc, 7))
			spawn(rand(15,50))
				C.call_hostile(target)


	var/list/used_directions = list()
	var/range = 5
	var/list/turf/targets = list()
	var/list/mob/living/mobs = list()
	for(var/mob/living/M in view(src, 5))
		if(M && M.stat != DEAD)
			mobs.Add(M)
	var/dir

	if(!target)
		split_type = CRYSTAL_SPLIT_RANDOM

	//pick targets from the line
	else
		if(mobs.len && !(target in mobs))
			target = mobs[0]
		else
			mobs.Remove(target)
			mobs = list(target) + mobs //puts the target in front

		dir = src.get_target_direction(target)



	for(var/i=1, i<=min(4,shards)/2, i++) //sanity
		if(split_type == CRYSTAL_SPLIT_RANDOM)
			dir = pick(cardinal - used_directions)

		used_directions.Add(dir)
		var/turf/target_turf = null
		var/x_steps = 0
		var/y_steps = 0
		switch(dir)
			if(NORTH)
				used_directions.Add(SOUTH)

				if(CRYSTAL_SPLIT_RANDOM)
					var/plus_minus = pick(0,1)
					y_steps = round(sqrt(rand(25)))
					if(plus_minus)
						x_steps = round(sqrt(25 - (y_steps**2)))
					else
						x_steps = -round(sqrt(25 - (y_steps**2)))

				else
					target_turf = get_turf(target)
					mobs.Remove(target)

			if(SOUTH)
				used_directions.Add(NORTH)

				if(split_type == CRYSTAL_SPLIT_RANDOM)
					var/plus_minus = pick(0,1)
					y_steps = -round(sqrt(rand(25)))
					if(plus_minus)
						x_steps = -round(sqrt(25 - (y_steps**2)))
					else
						x_steps = round(sqrt(25 - (y_steps**2)))

				else
					target_turf = get_turf(target)
					mobs.Remove(target)

			if(EAST)
				used_directions.Add(WEST)

				if(split_type == CRYSTAL_SPLIT_RANDOM)
					var/plus_minus = pick(0,1)
					x_steps = round(sqrt(rand(25)))
					if(plus_minus)
						y_steps = -round(sqrt(25 - (x_steps**2)))
					else
						y_steps = round(sqrt(25 - (x_steps**2)))

				else
					target_turf = get_turf(target)
					mobs.Remove(target)

			if(WEST)
				used_directions.Add(EAST)

				if(split_type == CRYSTAL_SPLIT_RANDOM)
					var/plus_minus = pick(0,1)
					x_steps = -round(sqrt(rand(25)))
					if(plus_minus)
						y_steps = round(sqrt(25 - (x_steps**2)))
					else
						y_steps = -round(sqrt(25 - (x_steps**2)))

				else
					target_turf = get_turf(target)
					mobs.Remove(target)

		if(!target_turf)
			for(var/j = 0, j<abs(x_steps), j++)
				var/turf/workturf = get_turf(src)
				if(x_steps<0)
					workturf = get_step(workturf, WEST)
				else
					workturf = get_step(workturf, EAST)
				target_turf = workturf
			for(var/j = 0, j<abs(y_steps), j++)
				var/turf/workturf = target_turf
				if(x_steps<0)
					workturf = get_step(workturf, SOUTH)
				else
					workturf = get_step(workturf, EAST)
				target_turf = workturf

		world << target_turf

		targets.Add(target_turf)
		var/turf/targturf2 = get_mirror_turf(get_turf(src),target_turf)
		targets.Add(targturf2)

		if(i < min(4,shards/2) ) //if no shards are left, no need to do this.
			if(split_type != CRYSTAL_SPLIT_RANDOM) //see if we still have more targets
				for(var/mob/living/M in mobs)
					var/test_dir = src.get_target_direction(M)
					if(test_dir in used_directions || M.stat == DEAD || M == target)
						mobs.Remove(M)
						if(M == target)
							target = null
					else
						target = M
						dir = test_dir
						break

			if(!mobs.len)
				target = null
				split_type = CRYSTAL_SPLIT_RANDOM

	for(var/i = 1, i<=targets.len, i++)
		var/obj/item/weapon/crystal_shard/CS = new(src.loc)
		CS.throw_at(targets[i], range, throw_at_force, src)
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 30, 1)
	msg = pick("<span class='danger'>\The [src] bursts!</span>","<span class='danger'>\The [src] explodes!</span>","<span class='danger'>\The [src] flies apart!</span>")
	visible_message(msg)

	//finally_delete the big guy
	qdel(src)



/obj/structure/crystal_growth/proc/get_target_direction(var/mob/living/targeted)
	var/turf/start_turf = get_turf(src)
	var/turf/target_turf = get_turf(targeted)
	var/x_diff = target_turf.x - start_turf.x
	var/y_diff = target_turf.y - start_turf.y

	if(x_diff > 0) //easternly
		if(abs(y_diff) >= abs(x_diff)) //beyond NE/SE line
			if (y_diff>0) //NE line
				return NORTH
			else //SE line
				return SOUTH
		else  //Below NE/SE line
			return EAST
	else //westernly
		if(abs(y_diff) >= abs(x_diff)) //beyond NE/SE line
			if (y_diff>0) //NE line
				return NORTH
			else //SE line
				return SOUTH
		else  //Below NE/SE line
			return WEST

/proc/get_mirror_turf(var/turf/start_turf, var/turf/target_turf)
	var/x_diff = start_turf.x - target_turf.x
	var/y_diff = start_turf.y - target_turf.y
	var/turf/working_turf = start_turf
	for(var/i = 0, i<abs(x_diff), i++)
		if(x_diff < 0)
			working_turf = get_step(working_turf, WEST)
		else
			working_turf = get_step(working_turf, EAST)

	for(var/j = 0, j<abs(y_diff), j++)
		if(y_diff < 0)
			working_turf = get_step(working_turf, SOUTH)
		else
			working_turf = get_step(working_turf, NORTH)

	return working_turf

/obj/item/weapon/crystal_shard
	name = "strange crystal shard"
	desc = "A shard of some strange crystal"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "shard"
	sharp = 1
	w_class = 5
	throw_speed = 5
	throwforce = 5
	var/growth = 0
	var/obj/item/organ/internal/affect_crystal
	var/min_temp = T0C

/obj/item/weapon/crystal_shard/small
	icon_state = "shard_small"
	name = "strange crystal shard"
	desc = "A small shard of some strange crystal"
	throw_speed = 4
	throwforce = 1
	force = 1
	w_class = 2

/obj/item/weapon/crystal_shard/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/crystal_shard/Destroy()
	processing_objects.Remove(src)
	..()


#define BLOOD_SPECIFIC_HEAT 37.8 //for 10ml
/obj/item/weapon/crystal_shard/process()
	var/turf/T = get_turf(src)
	if(src.loc == T)
		var/datum/gas_mixture/environment = T.return_air()
		if(environment && environment.temperature > min_temp)
			var/removed_heat
			if(istype(src, /obj/item/weapon/crystal_shard/small))
				removed_heat = CRYSTAL_HEAT_SCALAR * max(0,environment.temperature - min_temp)**(1/3) //we're in a body so it should do more
				//small shards don't grow
			else
				removed_heat = CRYSTAL_HEAT_SCALAR * max(0,environment.temperature - min_temp)**(1/3) //we're in a body so it should do more
				growth += removed_heat/CRYSTAL_GROWTH_SCALAR
			environment.add_thermal_energy(-removed_heat)

	//if embedded
	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src.loc
		for(var/obj/item/organ/external/organ in H.organs)
			for(var/obj/item/weapon/crystal_shard/O in organ.implants)

				if(istype(O, /obj/item/weapon/crystal_shard/small))
					if(H.bodytemperature > min_temp)
						var/blood_thermalenergy = H.vessel.total_volume * BLOOD_SPECIFIC_HEAT * H.bodytemperature
						var/removed_heat = CRYSTAL_BODYHEAT_SCALAR * max(0,H.bodytemperature - min_temp)**(1/3) //we're in a nice warm body so it should do more
						blood_thermalenergy -= removed_heat
						H.bodytemperature = (blood_thermalenergy) / (H.vessel.total_volume * BLOOD_SPECIFIC_HEAT)


						if (prob(1))
							to_chat(H, "<span class='danger'>You feel something slicing inside your [organ]!</span>")
							affect_crystal.take_damage(rand(0.5,1), 0, 0)



/*
					if(istype(src, /obj/item/weapon/crystal_shard/small))
						removed_heat = CRYSTAL_BODYHEAT_SCALAR * max(0,H.bodytemperature - min_temp)**(1/3)
						//small shards don't grow
*/

				else

					if(prob(3)) // pain messages.
						switch(growth)
							if(0 to 99)
								to_chat(H, "<span class='warning'>You feel something pushing from inside your [organ]!</span>")
							if(100 to 174)
								to_chat(H, "<span class='warning'>You feel something straining against the inside of your [organ]!</span>")
							if(175 to 250)
								to_chat(H, "<span class='danger'>You feel something about to burst from inside your [organ]!</span>")


					//Body heat growth and processing
					if(H.bodytemperature > min_temp)
						var/blood_thermalenergy = H.vessel.total_volume * BLOOD_SPECIFIC_HEAT * H.bodytemperature
						var/removed_heat = CRYSTAL_BODYHEAT_SCALAR * max(0,H.bodytemperature - min_temp)**(1/3) //we're in a nice warm body so it should do more
						growth += removed_heat/CRYSTAL_GROWTH_SCALAR
						blood_thermalenergy -= removed_heat
						H.bodytemperature = (blood_thermalenergy) / (H.vessel.total_volume * BLOOD_SPECIFIC_HEAT)

						//Damage from growth.
						if(prob(1))
							to_chat(H, "<span class='danger'>You feel something sharp growing inside you!</span>")
							var/obj/item/organ/affected_organ = pick(organ.internal_organs + organ)
							affected_organ.take_damage(rand(1,2), 0, 0)

					//Chance to make tiny crystal shards break off inside you.
					if(growth > 100)
						if( prob(1)  && prob(20) ) //Prevents spam
							to_chat(H, "<span class='danger'>You feel something break off and move around inside you!</span>")
							growth -= 20
							var/obj/item/weapon/crystal_shard/small/CS = new(H)
							organ.implants.Add(CS)
							var/affected_organ = pick(organ.internal_organs)
							CS.affect_crystal = affected_organ

					//damage from growing up. YOU HAD PLENTY OF TIME TO PULL IT OUT!
					if(growth >= CRYSTAL_GROWTH_STAGE_1)
						organ.implants -= src
						organ.take_damage(rand(35,60), 0, 0)
						src.visible_message("<span class='danger'>\The [src] tears out of \the [H]'s [organ]!</span>")
						H.shock_stage+=40

						if(prob(85)) //something ripping out of you will probably cause IB.
							var/datum/wound/internal_bleeding/I = new (25)
							organ.wounds += I

	if(growth >= CRYSTAL_GROWTH_STAGE_1)
		var/obj/structure/crystal_growth/crystal = new(get_turf(src))
		qdel(src)
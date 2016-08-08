
/datum/newling/proc/controlparasite(var/mob/living/simple_animal/parasite/P)


/datum/newling/proc/spawnparasite(var/mob/living/carbon/human/user, var/bugtype,)
	var/turf/T = get_turf(user)
	switch(bugtype)
		if("stun")
			bugtype = /obj/mob/living/simple_animal/parasite/stun
		if("hallucenogenic")
			bugtype = /obj/mob/living/simple_animal/parasite/hall
		if("sulphuric")
			bugtype = /obj/mob/living/simple_animal/parasite/sulphuric
		if("snare")
			bugtype = /obj/mob/living/simple_animal/parasite/snare
		if("teargas")
			bugtype = /obj/mob/living/simple_animal/parasite/teargas
		else
			return
	var/
	var/obj/mob/living/simple_animal/parasite/P = new bugtype(loc)



/obj/item/weapon/holder/parasite
	w_class = 1

/obj/item/weapon/holder/parasite/attack_self(mob/living/user as mob)
	for (var/mob/living/simple_animal/parasite/P in contents)
		if(istype(P))
			P.prime()

/mob/living/simple_animal/parasite
	name = "strange insect"
	desc = "Some sort of strange beetle... bug... thing..."
	wander = 0
	holder_type = /obj/item/weapon/holder/parasite
	var/RC = 0
	var/mob/living/carbon/human/controlled
	var/lifetime = 0
	var/payload = ""
	var/datum/reagents/holder
	var/mob/living/carbon/human/owner = 0
	var/mob/living/carbon/human/attached
	var/mob/living/carbon/human/target
	var/turf/target_turf
	var/attaching= 0
	var/primed = 0

	New()
		holder = create_reagents(40)
		holder |= NOREACT
		switch(payload)
			if("stun")
				holder.add_reagent("potassium", 10)
				holder.add_reagetn("water", 10)
			if("hallucenogenic")
				holder.add_reagent("space_drugs", 20)
				holder.add_reagent("mindbreaker", 20)
			if("sulphuric")
				holder.add_reagent("sacid", 40)
			if("snare")
				holder.add_reagent("changeling_snare", 40)
			if("teargas")
				holder.add_reagent("phosphorus",9)
				holder.add_reagent("potassium",9)
				holder.add_reagent("sugar",9)
				holder.add_reagent("condensedcapsaicin",13)


/mob/living/simple_animal/parasite/stun
	payload = "stun"
/mob/living/simple_animal/parasite/hall
	payload = "hallucenogenic"
/mob/living/simple_animal/parasite/sulphuric
	payload = "sulphuric"
/mob/living/simple_animal/parasite/snare
	payload = "snare"
/mob/living/simple_animal/parasite/teargas
	payload = "teargas"


/mob/living/simple_animal/parasite/proc/prime(var/inhand = 0)
	primed = 1
	visible_message("<span class='warning'>\The [src] begins to vibrate.</span>", "<span class='warning'>You prime your chemical payload, </span>", "You hear a strange gurgling noise.")
	if(inhand)
		RC = 0
		initialize()
	spawn (50)
		if(src)
			src.detonate()

/mob/living/simple_animal/parasite/proc/detonate()
	if(istype(src.loc, /obj/item/weapon/holder)
		var/H = src.loc
		src.loc = src.loc.loc
		qdel(H)
	src.loc = get_turf(src)
	visible_message("<span class='danger'>\The [src] bursts!</span>")
	for(var/datum/reagents/R in holder)
			R.trans_to_obj(src, R.total_volume)

	if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
		var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
		steam.set_up(10, 0, get_turf(src))
		steam.attach(src)
		steam.start()

		for(var/atom/A in view(1, src.loc))
			if( A == src ) continue
			src.reagents.touch(A)

	if(istype(loc, /mob/living/carbon))		//drop dat grenade if it goes off in your hand
		var/mob/living/carbon/C = loc
		C.drop_from_inventory(src)
		C.throw_mode_off()

	src.invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
	spawn(10)		   //To make sure all reagents can work
		qdel(src)	   //correctly before deleting the grenade.



/mob/living/simple_animal/parasite/proc/attach(mob/living/carbon/human/M as mob)
	src << "We've attached ourself to [M]!"
	src.attached = M
	src.attaching = 0
	src.attached << "<span class='notice'>You feel a tiny prick!</span>"

	//mob holder stuff
	src.loc = M
	var/obj/item/organ/external/head/head = M.get_organ("head")
	var/obj/item/weapon/holder/H = new holder_type(get_turf(src))
	M.organ.embed(H)
	src.forceMove(H)
	H.sync(src)

/mob/living/simple_animal/parasite/proc/attempt_attach_visible(mob/living/carbon/human/M as mob)
	attaching = 1
	src.visible_message("<span class = "danger">[src] tries to attach itself to [M].", "You try to attach yourself to [M]")
	if(do_mob(src,M, 15)
		src.visible_message("<span class = "danger">[src] attaches itself to [M].", "You attach yourself to [M]!")
		src.attach(M)
		return 1
	else
		attaching = 0
		src << "They must hold still!"
		return 0


/mob/living/simple_animal/parasite/proc/attempt_attach_invisible(mob/living/carbon/human/M as mob)
	attaching = 1
	if(do_mob(src,M, 15)
		src.attach(M)
		return 1
	else
		src << "They must hold still!"
		attaching = 0
		return 0


/mob/living/simple_animal/parasite/proc/attack_hand(mob/living/carbon/human/M as mob)
	attempt_attach_invisible(M)


/mob/living/simple_animal/parasite/proc/initialize()
	while(src.loc != get_turf(src))
		if(istype(src.loc, /mob/living/carbon/human)
			if(src.loc in ignored)
				sleep (1)

		else
			visible_message()
			src.loc = src.loc.loc
		else
			sleep(1)
	src.FindTarget()



/mob/living/simple_animal/parasite/proc/FindTarget()
	while(src.loc != get_turf(src))
		if(istype(src.loc, /mob/living/carbon/human)
			if(src.loc in ignored)
				sleep (1)

	for(var/mob/living/carbon/human/H in orange(5,src))

		if(!(H in parasite_targets))
			parasite_target.Add(H)
			src.target = H
			src.prime()
			src.track_target()
			break

	sleep(5)
	if(!target)
		.()


/mob/living/simple_animal/parasite/proc/track_target()
	while(src.loc != get_turf(src))
		if(src.loc == target)
			src.attempt_attach_visible(target)
		else
			visible_message("<span class = 'warning'>\The [src] pops out of \the [src.loc]!</span>")
			src.loc = src.loc.loc
			sleep(10)

	if(attached)
		return
	if(target && target in range(7))
		if(target in range(1))
			src.attempt_attach_visible(target)
			while(attaching)
				sleep(0)
			track_target()
		target_turf = get_turf(target)
		walk_to(src, target_turf, 1, 1)
	else if(target_turf && target_turf != get_turf(src))
		walk_to(src, target_turf, 1, 1)
	else
		target = null
		src.FindTarget()


/mob/living/simple_animal/parasite/Life()
	if(attached && !istype(src.loc, /obj/item/weapon/holder))
		death(0)
	if(lifetime > 180 &&  !primed)
		death(0)
	else
		lifetime += 1
		sleep(1)

	if(src.attached)
		lifetime -= 0.8
		if(prob(1))
			attached << "<span class='notice'>Your head itches!</span>"

	. = ..()

/mob/living/simple_animal/parasite/death(var/gibbed = 0)
	if(src.primed)
		detonate()
	..()


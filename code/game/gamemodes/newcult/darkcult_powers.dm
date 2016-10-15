/datum/darkcultpower/
	var/name = "Cult power"
	var/desc = "An ability of great darkness"
	var/cost


/datum/darkcultpower/darkvision
	name = "dark vision"
	desc = "Ability to see in the dark"
	var/active = 0
	var/vision = 0

/datum/darkcultpower/jaunt
	name = "darkjaunt"
	desc = "Leap through darkness"
	var/duration = 2





/obj/item/darkcultpower/


/obj/item/darkcultpower/shadowball
	name = "shadow ball"
	desc = "A ball of darkness that pulls in light around it. "
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"
	throwforce = 0
	force = 0

/obj/item/darkcultpower/shadowball/dropped()
	..()

	src.anchored = 1
	src.set_light(4, -4, "#FFFFFF")

	spawn(150)
		if(src) qdel(src)



/spell/targeted/ethereal_jaunt/cast(mob/living/target) //magnets, so mostly hardcoded
	set waitfor = 0
	target.transforming = 1
	if(target.buckled)
		target.buckled.unbuckle_mob()
	spawn(0)
		var/turf/T = get_turf(target.loc)
		var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( T )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( T )
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'icons/mob/mob.dmi'
		animation.layer = 5
		animation.master = holder
		target.ExtinguishMob()
		if(target.buckled)
			target.buckled = null
		jaunt_disappear(animation, target)
		target.loc = holder
		target.transforming=0 //mob is safely inside holder now, no need for protection.
		jaunt_steam(mobloc)
		sleep(duration)
		mobloc = holder.last_valid_turf
		animation.loc = mobloc
		jaunt_steam(mobloc)
		target.canmove = 0
		holder.reappearing = 1
		sleep(20)
		jaunt_reappear(animation, target)
		sleep(5)
		if(!target.forceMove(mobloc))
			for(var/direction in list(1,2,4,8,5,6,9,10))
				var/turf/T = get_step(mobloc, direction)
				if(T)
					if(target.forceMove(T))
						break
		target.canmove = 1
		target.client.eye = target
		qdel(animation)
		qdel(holder)







/spell/targeted/ethereal_jaunt/cast(list/targets) //magnets, so mostly hardcoded
	set waitfor = 0
	for(var/mob/living/target in targets)
		target.transforming = 1 //protects the mob from being transformed (replaced) midjaunt and getting stuck in bluespace
		if(target.buckled)
			target.buckled.unbuckle_mob()
		spawn(0)
			var/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "water"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/mob/mob.dmi'
			animation.layer = 5
			animation.master = holder
			target.ExtinguishMob()
			if(target.buckled)
				target.buckled = null
			jaunt_disappear(animation, target)
			target.loc = holder
			target.transforming=0 //mob is safely inside holder now, no need for protection.
			jaunt_steam(mobloc)
			sleep(duration)
			mobloc = holder.last_valid_turf
			animation.loc = mobloc
			jaunt_steam(mobloc)
			target.canmove = 0
			holder.reappearing = 1
			sleep(20)
			jaunt_reappear(animation, target)
			sleep(5)
			if(!target.forceMove(mobloc))
				for(var/direction in list(1,2,4,8,5,6,9,10))
					var/turf/T = get_step(mobloc, direction)
					if(T)
						if(target.forceMove(T))
							break
			target.canmove = 1
			target.client.eye = target
			qdel(animation)
			qdel(holder)


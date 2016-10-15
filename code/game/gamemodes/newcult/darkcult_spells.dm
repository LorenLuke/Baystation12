
/spell/targeted/ethereal_jaunt/darkcult
	name = "Darkshift"
	desc = "Become one with darkness, allowing you to move incorporeally through solid objects."
	charge_max = 200
	spell_flags = Z2NOCAST | INCLUDEUSER
	invocation = "none"
	invocation_type = SpI_NONE
	range = -1
	duration = 50 //in deciseconds

	hud_state = "wiz_jaunt"

/spell/targeted/ethereal_jaunt/darkcult/cast(list/targets) //magnets, so mostly hardcoded
	for(var/mob/living/target in targets)
		target.transforming = 1 //protects the mob from being transformed (replaced) midjaunt and getting stuck in bluespace
		if(target.buckled)
			target.buckled.unbuckle_mob()
		spawn(0)
			var/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/darkcult/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			animation.name = "darkness"
			animation.density = 0
			animation.anchored = 1
			animation.icon = 'icons/obj/darkcult/darkcult.dmi'
			animation.layer = 5
			animation.master = holder
			target.ExtinguishMob()
			if(target.buckled)
				target.buckled = null
			jaunt_disappear(animation, target)
			target.loc = holder
			target.transforming=0 //mob is safely inside holder now, no need for protection.
			var/run_time = duration
			while(!holder.canceled && run_time > 0)
				sleep(1)
				run_time--
			mobloc = holder.last_valid_turf
			animation.loc = mobloc
			target.canmove = 0
			holder.reappearing = 1
			sleep(20)
			jaunt_reappear(animation, target)
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


/spell/targeted/ethereal_jaunt/darkcult/jaunt_disappear(var/atom/movable/overlay/animation, var/mob/living/target)
	animation.icon = 'icons/obj/darkcult/darkcult.dmi'
	animation.icon_state = "darkcult_teleport_in"
	flick("darkcult_teleport_in",animation)

/spell/targeted/ethereal_jaunt/darkcult/jaunt_reappear(var/atom/movable/overlay/animation, var/mob/living/target)
	animation.icon = 'icons/obj/darkcult/darkcult.dmi'
	animation.icon_state = "darkcult_teleport_out"
	flick("darkcult_teleport_out",animation)

/obj/effect/dummy/spell_jaunt/darkcult
	name = "darkness"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	canmove = 1
	reappearing = 0
	density = 0
	anchored = 1
	turf/last_valid_turf
	var/canceled = 0
	var/robecheck = 0

/obj/effect/dummy/spell_jaunt/darkcult/relaymove(var/mob/user, direction)
	if (!src.canmove || reappearing) return
	var/turf/newLoc = get_step(src,direction)
	loc = newLoc
	var/turf/T = get_turf(loc)
	if(!T.contains_dense_objects())
		last_valid_turf = T
	src.canmove = 0

	var/light_amount = 0 //
	if(isturf(T)) //else, there's considered to be no light
		var/atom/movable/lighting_overlay/L = locate(/atom/movable/lighting_overlay) in T
		if(L)
			light_amount = (L.lum_r + L.lum_g + L.lum_b) - 5 //hardcapped so it's not abused by having a ton of flashlights
		else
			light_amount =  0
		if(light_amount >= 4 && !robecheck)
			canceled = 1

	spawn(10) src.canmove = 1




/mob/living/simple_animal/changeling_parasite


/mob/living/simple_animal/changeling_head
	var/wander = 0
	var/growth = 0
	var/obj/item/organ/external/head/head = null

/obj/item/organ/external/head/proc/changeling_formhead()
	var/mob/living/simple_animal/changling_head/headchan = new(get_turf(src))

	headchan.icon = src.icon
	headchan.icon_state = src.icon_state
	headchan.overlays = src.overlays
	headchan.overlays += //


/datum/newcultpower/
	var/name = "Cult power"
	var/desc = "An ability of great darkness"
	var/cost


/datum/newcultpower/darkvision
	var/name = "dark vision"
	var/desc = "Ability to see in the dark
	var/active = 0
	var/vision = 0



/obj/item/newcultpower/





/obj/item/newcultpower/shadowball
	name = "shadow ball"
	desc = "A ball of darkness that pulls in light around it. "
	icon = 'icons/effects/effects.dmi'
	icon_state = "energynet"
	throwforce = 0
	force = 0

/obj/item/newcultpower/shadowball/dropped()
	..()

	src.anchored = 1
	src.set_light(4, -4, "#FFFFFF")

	spawn(150)
		if(src) qdel(src)



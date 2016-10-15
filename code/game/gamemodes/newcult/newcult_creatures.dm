/obj/structure/newcult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/newcult/voidartefact
	name = "Pillar"
	desc = "A strange altar that seems to absorb the light around it"

/obj/structure/newcult/voidartefact/New()
	..()
		set_light(7, -8, "#FFFFFF")


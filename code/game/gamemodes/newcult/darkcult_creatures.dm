/obj/structure/darkcult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/darkcult/voidartefact
	name = "Pillar"
	desc = "A strange altar that seems to absorb the light around it"

/obj/structure/darkcult/voidartefact/New()
	..()
		set_light(7, -6, "#FFFFFF")


/obj/structure/crystal
	name = "strange crystal"
	desc = "A strange crystal"

	var/growth=100
	var/health

/obj/structure/crystal/New()
	..()



/obj/structure/crystal/Destroy()
	if(parts)
		new parts(loc)
	..()


/obj/structure/crystal/proc/process()

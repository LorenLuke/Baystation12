/datum/power/changeling/gun
	name = "Generate spike launcher"
	desc = "Shapes our arm into a deadly projectile weapon."
	genomecost = 0
	verbpath = /mob/proc/changeling_gun


/obj/item/weapon/spike/changeling
	name = "bone spike"
	desc = "It's about a foot of bone wrapped in flesh, sharpened to a nasty point."
	throwforce = 5
	icon = 'icons/obj/weapons.dmi'
	icon_state = "quill"
	item_state = "bolt"


/obj/item/weapon/gun/launcher/changeling
	name = "strange weapon"
	desc = "Some sort of grotesque amalgom. Parts of it quiver gelatinously, as though the thing is insectile and alive."
	w_class = ITEM_SIZE_LARGE
	release_force = 30
	icon = 'icons/obj/gun.dmi'
	icon_state = "spikethrower3"
	item_state = "spikethrower"
	fire_sound_text = "a strange noise"
	fire_sound = 'sound/weapons/bladeslice.ogg'

	var/mob/living/creator
	var/weapType = "weapon"
	var/weapLocation = "arm"

	var/ammo_type = "bony spike"
	var/ammo_name = /obj/item/weapon/spike/changeling
	var/last_regen = 0
	var/ammo_gen_time = 100
	var/max_ammo = 4
	var/ammo = 2


/obj/item/weapon/gun/launcher/changeling/New(location)
	..()
	START_PROCESSING(SSobj, src)
	last_regen = world.time
	if(ismob(loc))
		visible_message("<span class='warning'>A grotesque weapon forms around [loc.name]\'s arm!</span>",
		"<span class='warning'>Our arm twists and mutates, transforming it into a deadly weapon.</span>",
		"<span class='italics'>You hear flesh ripping and tearing!</span>")
		src.creator = loc

/obj/item/weapon/gun/launcher/changeling/dropped(mob/user)
	visible_message("<span class='warning'>With a sickening crunch, [creator] reforms their arm!</span>",
	"<span class='notice'>We assimilate the weapon back into our body.</span>",
	"<span class='italics'>You hear organic matter ripping and tearing!</span>")
	playsound(src, 'sound/effects/blobattack.ogg', 30, 1)
	spawn(1)
		if(src)
			qdel(src)

/obj/item/weapon/gun/launcher/changeling/Destroy()
	STOP_PROCESSING(SSobj, src)
	creator = null
	..()

/obj/item/weapon/gun/launcher/changeling/process()  //Stolen from ninja swords.
	if(!creator || loc != creator || !creator.item_is_in_hands(src))
		// Tidy up a bit.
		if(istype(loc,/mob/living))
			var/mob/living/carbon/human/host = loc
			if(istype(host))
				for(var/obj/item/organ/external/organ in host.organs)
					for(var/obj/item/O in organ.implants)
						if(O == src)
							organ.implants -= src
			host.pinned -= src
			host.embedded -= src
			host.drop_from_inventory(src)
		spawn(1)
			if(src)
				qdel(src)

	if(ammo < max_ammo && world.time > last_regen + ammo_gen_time)
		ammo++
		last_regen = world.time

/obj/item/weapon/gun/launcher/changeling/examine(mob/user)
	..(user)
	to_chat(user, "It has [ammo] [ammo_name]\s remaining.")

/obj/item/weapon/gun/launcher/alien/consume_next_projectile()
	if(ammo < 1) return null
	if(ammo == max_ammo) //stops people from buffering a reload (gaining effectively +1 to the clip)
		last_regen = world.time
	ammo--
	return new ammo_type

/obj/item/weapon/gun/launcher/changeling/consume_next_projectile()
	if(ammo < 1) return null
	if(ammo == max_ammo) //stops people from buffering a reload (gaining effectively +1 to the clip)
		last_regen = world.time
	ammo--
	return new ammo_type

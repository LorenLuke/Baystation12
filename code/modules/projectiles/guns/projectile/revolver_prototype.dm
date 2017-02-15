/obj/item/weapon/gun/projectile/revolver
	name = "revolver"
	desc = "The Lumoco Arms HE Colt is a choice revolver for when you absolutely, positively need to put a hole in the other guy. Uses .357 ammo."
	icon_state = "revolver"
	item_state = "revolver"
	caliber = "357"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	handle_casings = CYCLE_CASINGS
	max_shells = 6
	ammo_type = /obj/item/ammo_casing/a357
	var/obj/item/weapon/storage/internal/pockets/revolver/chambers
	var/open = 0

/obj/item/weapon/storage/internal/pockets/revolver
	storage_slots = 0
	max_w_class = 0 //Max size of objects that this object can store (in effect only if can_hold isn't set)
	var/caliber
	var/obj/item/weapon/gun/projectile/revolver/gun
	use_sound = 0

/obj/item/revolver_storage_proxy
	name = "empty chamber"
	icon = 'icons/obj/gun.dmi'
	icon_state = "rev_prox"
	var/caliber
	var/obj/item/weapon/gun/projectile/revolver/gun


/obj/item/weapon/gun/projectile/revolver/examine(mob/user)
	. = ..(user)
	var/count=0
	for(var/obj/item/ammo_casing in chambers.contents)
		count++
	to_chat(user, "Has [count] round\s remaining.")
	if(open)
		to_chat(user, "The cylinder is open.")
	return


/obj/item/revolver_storage_proxy/attack_hand(mob/user as mob)

	var/num = gun.chambers.contents.Find(src)
	gun.advance_cylinder(num-1, 1, user)


/obj/item/revolver_storage_proxy/attackby(var/obj/item/A, mob/user as mob)
	if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = A
		if(AC.caliber == caliber)
			var/index = gun.chambers.contents.Find(src)
			AC.loc = gun.chambers
			gun.chambers.contents.Insert(index, AC)
			gun.chambers.contents -= src
			qdel(src)

		gun.update_revolver()


/obj/item/weapon/gun/projectile/revolver/New()
	chambers = new(src)
	chambers.gun = src
	chambers.caliber = caliber
	chambers.storage_slots = max_shells
	for(var/i = 1, i<=max_shells, i++)
		if(starts_loaded)
			if(ispath(ammo_type) && (load_method & (SINGLE_CASING|SPEEDLOADER)))
				chambers.contents += new ammo_type(chambers)
		else
			var/obj/item/revolver_storage_proxy/chamber = new(chambers)
			chambers.contents += chamber
			chamber.caliber = caliber
			chamber.gun = src
	update_revolver()


/obj/item/weapon/gun/projectile/revolver/proc/update_revolver()
	if(chambers.contents.len < max_shells)
		for(var/i = chambers.contents.len+1, i<= max_shells, i++)
			var/obj/item/revolver_storage_proxy/prox = new()
			prox.loc = chambers
			chambers.contents += prox
	else if(chambers.contents.len > max_shells)
		for(var/i = max_shells + 1, i<= chambers.contents.len, i)
		 var/obj/O = chambers.contents[i]
		 chambers.contents -= O
		 qdel(O)

	if(istype(chambers.contents[1], /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = chambers.contents[1]
		chambered = C
	else
		chambered = null

	loaded = list()
	for(var/obj/item/ammo_casing/C in chambers)
		loaded += C

	if(open)
		chambers.close(chambers.gun.loc)
		chambers.open(chambers.gun.loc)


/obj/item/weapon/gun/projectile/revolver/proc/advance_cylinder(var/advance_by = 1, var/inform = 0,var/mob/user as mob)
	for(var/i = 1, i<= advance_by, i++)
		var/index = chambers.contents[1]
		chambers.contents -= index
		chambers.contents += index

	if(inform)
		to_chat(user, "<span class='warning'>You advance \the [src]'s cylinder [advance_by] times.</span>")

	update_revolver()

	if(open)
		chambers.close(user)
		chambers.open(user)

/obj/item/weapon/gun/projectile/revolver/consume_next_projectile()
	if(chambered.contents.len)
		chambered = chambers.contents[1] //load next casing.

	if (chambered)
		. = chambered.BB

	update_revolver()
	return


/obj/item/weapon/gun/projectile/revolver/attack_hand(mob/user as mob)
	if(user.get_inactive_hand() == src)
		if(open)
			toggle_cylinder(user)
			return
		else
			unload_ammo(user, allow_dump=0)//single cartridge
	else
		return ..()

/obj/item/weapon/gun/projectile/revolver/attack_self(mob/user as mob)
	if(!open)
		toggle_cylinder(user)
	else
		//dump
		unload_ammo(user, allow_dump=1)//dump ammo


/obj/item/weapon/gun/projectile/revolver/proc/toggle_cylinder(mob/user as mob)
	if(!open)
		open = 1
		chambers.open(user)
		to_chat(user, "<span class='warning'>You open \the [src]'s cylinder.</span>")
	else
		open = 0
		chambers.close()
		to_chat(user, "<span class='warning'>You close \the [src]'s cylinder.</span>")
	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)


/obj/item/weapon/gun/projectile/revolver/load_ammo(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_magazine))
		var/obj/item/ammo_magazine/AM = A
		if(!(load_method & AM.mag_type) || caliber != AM.caliber)
			return //incompatible

		if(!open)
			to_chat(user, "<span class='warning'>\The [src]'s cylinder needs to be open!</span>")
			return

		if(locate(/obj/item/ammo_casing) in chambers.contents)
			//not empty
			to_chat(user, "<span class='warning'>\The [src] needs to be empty first!</span>")
			return

		var/count = 0
		for(var/obj/item/ammo_casing/C in AM.stored_ammo)
			if(C.caliber == caliber)
				AM.stored_ammo -= C
				C.loc = chambers
				chambers.contents.Insert(1, C)
				count++
		if(count)
			user.visible_message("[user] reloads [src].", "<span class='notice'>You load [count] round\s into [src].</span>")
		playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)


	else if(istype(A, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = A
		if(!(load_method & SINGLE_CASING) || caliber != C.caliber)
			return //incompatible

		if(!istype(chambers.contents[1], /obj/item/revolver_storage_proxy))
			to_chat(user, "<span class='warning'>\The [src]'s chamber is already loaded.</span>")
			return


		user.remove_from_mob(C)
		C.loc = src
		loaded.Insert(1, C) //add to the head of the list
		user.visible_message("[user] inserts \a [C] into [src].", "<span class='notice'>You insert \a [C] into [src].</span>")
		playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)

	update_icon()




/obj/item/weapon/gun/projectile/revolver/unload_ammo(mob/user, var/allow_dump=1)
	if(!chambers.contents.len)//ifempty
		to_chat(user, "<span class='warning'>[src] is empty.</span>")
		return

	if(allow_dump)
		if(!open) //shouldn't happen
			return
		else
			//dump
			if(allow_dump && (load_method & SPEEDLOADER))
				var/count = 0
				var/turf/T = get_turf(user)
				if(T)
					for(var/obj/item/ammo_casing/C in chambers.contents)
						C.loc = T
						count++
					chambers.contents.Cut()
				if(count)
					user.visible_message("[user] dumps \the [src]'s bullets onto the ground.", "<span class='notice'>You dump out [count] round\s from \the [src]'s cylinder.</span>")
	else
		if(!istype(chambers.contents[1], /obj/item/ammo_casing))
			return
		if(load_method & SINGLE_CASING)
			var/obj/item/ammo_casing/C = chambers.contents[1]
			chambers.contents -= C
			user.put_in_hands(C)
			var/obj/item/revolver_storage_proxy/prox = new(chambers)
			chambers.contents.Insert(1, prox)
			user.visible_message("[user] removes \a [C] from [src].", "<span class='notice'>You remove \a [C] from [src].</span>")

	update_revolver()


/obj/item/weapon/gun/projectile/revolver/Fire(atom/target, mob/living/user, clickparams, pointblank=0, reflex=0)
	if(open)
		to_chat(user, "<span class='warning'>You have to close the cylinder to do fire!")
	else
		..()
	advance_cylinder()


/obj/item/weapon/gun/projectile/revolver/verb/spin_cylinder()
	set name = "Spin cylinder"
	set desc = "Fun when you're bored out of your skull."
	set category = "Object"

	visible_message("<span class='warning'>\The [usr] spins the cylinder of \the [src]!</span>", \
	"<span class='notice'>You hear something metallic spin and click.</span>")
	playsound(src.loc, 'sound/weapons/revolver_spin.ogg', 100, 1)
	advance_cylinder(rand(1,max_shells))

/obj/item/weapon/gun/projectile/revolver/verb/advance_cylinder_verb()
	set name = "Advance cylinder"
	set desc = "Advances the cylinder of your revolver."
	set category = "Object"

	advance_cylinder(1, 1, usr)

/obj/item/weapon/gun/projectile/revolver/mateba
	name = "mateba"
	icon_state = "mateba"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)

/obj/item/weapon/gun/projectile/revolver/detective
	name = "revolver"
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
	icon_state = "detective"
	max_shells = 6
	caliber = "38"
	origin_tech = list(TECH_COMBAT = 2, TECH_MATERIAL = 2)
	ammo_type = /obj/item/ammo_casing/c38

/obj/item/weapon/gun/projectile/revolver/detective/verb/rename_gun()
	set name = "Name Gun"
	set category = "Object"
	set desc = "Click to rename your gun. If you're the detective."

	var/mob/M = usr
	if(!M.mind)	return 0
	if(!M.mind.assigned_role == "Detective")
		to_chat(M, "<span class='notice'>You don't feel cool enough to name this gun, chump.</span>")
		return 0

	var/input = sanitizeSafe(input("What do you want to name the gun?", ,""), MAX_NAME_LEN)

	if(src && input && !M.stat && in_range(M,src))
		name = input
		to_chat(M, "You name the gun [input]. Say hello to your new friend.")
		return 1

// Blade Runner pistol.
/obj/item/weapon/gun/projectile/revolver/deckard
	name = "Deckard .44"
	desc = "A custom-built revolver, based off the semi-popular Detective Special model."
	icon_state = "deckard-empty"
	ammo_type = /obj/item/ammo_magazine/c38/rubber

/obj/item/weapon/gun/projectile/revolver/deckard/emp
	ammo_type = /obj/item/ammo_casing/c38/emp

/obj/item/weapon/gun/projectile/revolver/deckard/update_icon()
	..()
	if(loaded.len)
		icon_state = "deckard-loaded"
	else
		icon_state = "deckard-empty"

/obj/item/weapon/gun/projectile/revolver/deckard/load_ammo(var/obj/item/A, mob/user)
	if(istype(A, /obj/item/ammo_magazine))
		flick("deckard-reload",src)
	..()

/obj/item/weapon/gun/projectile/revolver/capgun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up."
	icon_state = "revolver"
	item_state = "revolver"
	caliber = "caps"
	origin_tech = list(TECH_COMBAT = 1, TECH_MATERIAL = 1)
	handle_casings = CYCLE_CASINGS
	max_shells = 7
	ammo_type = /obj/item/ammo_casing/cap


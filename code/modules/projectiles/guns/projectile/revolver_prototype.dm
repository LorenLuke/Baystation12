/datum/revolver_ui/tgui/tg_ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = tg_physical_state)
	ui = tgui_process.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "storage", storage.name, 340, 440, master_ui, state)
		ui.open()

/datum/storage_ui/tgui/ui_data()
	if(!cached_ui_data)

		var/list/items_by_name_and_type = list()
		for(var/obj/item/W in storage)
			group_by(items_by_name_and_type, "[W.name]§[W.type]", W)

		var/list/item_list = list()
		for(var/name_and_type in items_by_name_and_type)
			var/list/items = items_by_name_and_type[name_and_type]
			var/obj/item/first_item = items[1]
			item_list[++item_list.len] = list("name" = first_item.name, "type" = first_item.type, "amount" = items.len)

		cached_ui_data = list(
			"items" = item_list
		)

	return cached_ui_data

/datum/storage_ui/tgui/ui_act(action, params)
	if(..())
		return TRUE

	if(action == "remove_item")
		if(remove_item_by_name_and_type(params["name"], params["type"]))
			return TRUE

/datum/storage_ui/tgui/proc/remove_item_by_name_and_type(var/name, var/type_name)
	if(!istext(name) || !istext(type_name))
		return FALSE
	var/type = text2path(type_name)
	if(!type)
		return FALSE
	for(var/obj/item/W in storage)
		if(W.name == name && W.type == type)
			if(storage.remove_from_storage(W))
				return TRUE
	return FALSE
















// To clarify:
// For use_to_pickup and allow_quick_gather functionality,
// see item/attackby() (/game/objects/items.dm)
// Do not remove this functionality without good reason, cough reagent_containers cough.
// -Sayu


/obj/item/weapon/revolver
	//initializes the contents of the storage with some items based on an assoc list. The assoc key must be an item path,
	//the assoc value can either be the quantity, or a list whose first value is the quantity and the rest are args.

	var/list/startswith
	var/datum/storage_ui/storage_ui = /datum/storage_ui/default



/obj/item/weapon/revolver/attack_hand(mob/user as mob)

	if(user.get_inactive_hand() == src)
		playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
		prepare_ui()
		storage_ui.on_open(user)
		storage_ui.show_to(user)
	else
		return ..()

/obj/item/weapon/revolver/Destroy()
	qdel_null(storage_ui)
	. = ..()


/obj/item/weapon/storage/proc/return_inv()

	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/weapon/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/weapon/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/weapon/storage))
			L += G.gift:return_inv()
	return L

/obj/item/weapon/storage/proc/show_to(mob/user as mob)
	storage_ui.show_to(user)

/obj/item/weapon/storage/proc/hide_from(mob/user as mob)
	storage_ui.hide_from(user)

/obj/item/weapon/storage/proc/open(mob/user as mob)
	if (src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)

	prepare_ui()
	storage_ui.on_open(user)
	storage_ui.show_to(user)

/obj/item/weapon/storage/proc/prepare_ui()
	storage_ui.prepare_ui()

/obj/item/weapon/storage/proc/close(mob/user as mob)
	hide_from(user)
	storage_ui.after_close(user)

/obj/item/weapon/storage/proc/close_all()
	storage_ui.close_all()

/obj/item/weapon/storage/proc/storage_space_used()
	. = 0
	for(var/obj/item/I in contents)
		. += I.get_storage_cost()

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/weapon/storage/proc/can_be_inserted(obj/item/W, mob/user, stop_messages = 0)
	if(!istype(W)) return //Not an item

	if(user && user.isEquipped(W) && !user.canUnEquip(W))
		return 0

	if(src.loc == W)
		return 0 //Means the item is already in the storage item
	if(storage_slots != null && contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [src] is full, make some space.</span>")
		return 0 //Storage item is full

	if(W.anchored)
		return 0

	if(can_hold.len)
		if(!is_type_in_list(W, can_hold))
			if(!stop_messages && ! istype(W, /obj/item/weapon/hand_labeler))
				to_chat(user, "<span class='notice'>\The [src] cannot hold \the [W].</span>")
			return 0
		var/max_instances = can_hold[W.type]
		if(max_instances && instances_of_type_in_list(W, contents) >= max_instances)
			if(!stop_messages && !istype(W, /obj/item/weapon/hand_labeler))
				to_chat(user, "<span class='notice'>\The [src] has no more space specifically for \the [W].</span>")
			return 0

	// Don't allow insertion of unsafed compressed matter implants
	// Since they are sucking something up now, their afterattack will delete the storage
	if(istype(W, /obj/item/weapon/implanter/compressed))
		var/obj/item/weapon/implanter/compressed/impr = W
		if(!impr.safe)
			stop_messages = 1
			return 0

	if(cant_hold.len && is_type_in_list(W, cant_hold))
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [src] cannot hold \the [W].</span>")
		return 0

	if (max_w_class != null && W.w_class > max_w_class)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [W] is too big for this [src.name].</span>")
		return 0

	var/total_storage_space = W.get_storage_cost()
	if(total_storage_space == ITEM_SIZE_NO_CONTAINER)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [W] cannot be placed in [src].</span>")
		return 0

	total_storage_space += storage_space_used() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if(total_storage_space > max_storage_space)
		if(!stop_messages)
			to_chat(user, "<span class='notice'>\The [src] is too full, make some space.</span>")
		return 0

	return 1

//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/weapon/storage/proc/handle_item_insertion(var/obj/item/W, var/prevent_warning = 0, var/NoUpdate = 0)
	if(!istype(W))
		return 0
	if(istype(W.loc, /mob))
		var/mob/M = W.loc
		M.remove_from_mob(W)
	W.forceMove(src)
	W.on_enter_storage(src)
	if(usr)
		add_fingerprint(usr)

		if(!prevent_warning)
			for(var/mob/M in viewers(usr, null))
				if (M == usr)
					to_chat(usr, "<span class='notice'>You put \the [W] into [src].</span>")
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is... TODO replace with distance check
					M.show_message("<span class='notice'>\The [usr] puts [W] into [src].</span>")
				else if (W && W.w_class >= ITEM_SIZE_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message("<span class='notice'>\The [usr] puts [W] into [src].</span>")

		if(!NoUpdate)
			update_ui_after_item_insertion()
	update_icon()
	return 1

/obj/item/weapon/storage/proc/update_ui_after_item_insertion()
	prepare_ui()
	storage_ui.on_insertion(usr)

/obj/item/weapon/storage/proc/update_ui_after_item_removal()
	prepare_ui()
	storage_ui.on_post_remove(usr)

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
/obj/item/weapon/storage/proc/remove_from_storage(obj/item/W as obj, atom/new_location, var/NoUpdate = 0)
	if(!istype(W)) return 0
	new_location = new_location || get_turf(src)

	storage_ui.on_pre_remove(usr, W)

	if(ismob(loc))
		W.dropped(usr)
	if(ismob(new_location))
		W.hud_layerise()
	else
		W.reset_plane_and_layer()
	W.forceMove(new_location)

	if(usr && !NoUpdate)
		update_ui_after_item_removal()
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	update_icon()
	return 1

//This proc is called when you want to place an item into the storage item.
/obj/item/weapon/storage/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if(isrobot(user))
		return //Robots can't interact with storage items.

	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LP = W
		var/amt_inserted = 0
		var/turf/T = get_turf(user)
		for(var/obj/item/weapon/light/L in src.contents)
			if(L.status == 0)
				if(LP.uses < LP.max_uses)
					LP.AddUses(1)
					amt_inserted++
					remove_from_storage(L, T)
					qdel(L)
		if(amt_inserted)
			to_chat(user, "You inserted [amt_inserted] light\s into \the [LP.name]. You have [LP.uses] light\s remaining.")
			return

	if(!can_be_inserted(W, user))
		return

	if(istype(W, /obj/item/weapon/tray))
		var/obj/item/weapon/tray/T = W
		if(T.calc_carry() > 0)
			if(prob(85))
				to_chat(user, "<span class='warning'>The tray won't fit in [src].</span>")
				return
			else
				if(user.unEquip(W))
					to_chat(user, "<span class='warning'>God damnit!</span>")
	W.add_fingerprint(user)
	return handle_item_insertion(W)

/obj/item/weapon/storage/attack_hand(mob/user as mob)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(src)
			H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			H.put_in_hands(src)
			H.r_store = null
			return

	if (src.loc == user)
		src.open(user)
	else
		..()
		storage_ui.on_hand_attack(user)
	src.add_fingerprint(user)
	return

/obj/item/weapon/storage/proc/gather_all(var/turf/T, var/mob/user)
	var/success = 0
	var/failure = 0

	for(var/obj/item/I in T)
		if(!can_be_inserted(I, user, 0))	// Note can_be_inserted still makes noise when the answer is no
			failure = 1
			continue
		success = 1
		handle_item_insertion(I, 1, 1) // First 1 is no messages, second 1 is no ui updates
	if(success && !failure)
		to_chat(user, "<span class='notice'>You put everything into \the [src].</span>")
		update_ui_after_item_insertion()
	else if(success)
		to_chat(user, "<span class='notice'>You put some things into \the [src].</span>")
		update_ui_after_item_insertion()
	else
		to_chat(user, "<span class='notice'>You fail to pick anything up with \the [src].</span>")

/obj/item/weapon/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	collection_mode = !collection_mode
	switch (collection_mode)
		if(1)
			to_chat(usr, "\The [src] now picks up all items in a tile at once.")
		if(0)
			to_chat(usr, "\The [src] now picks up one item at a time.")

/obj/item/weapon/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	for(var/obj/item/I in contents)
		remove_from_storage(I, T, 1)
	update_ui_after_item_removal()

/obj/item/weapon/storage/New()
	..()
	if(allow_quick_empty)
		verbs += /obj/item/weapon/storage/verb/quick_empty
	else
		verbs -= /obj/item/weapon/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/weapon/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/weapon/storage/verb/toggle_gathering_mode

	if(isnull(max_storage_space) && !isnull(storage_slots))
		max_storage_space = storage_slots*base_storage_cost(max_w_class)

	spawn(5)
		var/total_storage_space = 0
		for(var/obj/item/I in contents)
			total_storage_space += I.get_storage_cost()
		max_storage_space = max(total_storage_space,max_storage_space) //prevents spawned containers from being too small for their contents

	storage_ui = new storage_ui(src)
	prepare_ui()

	if(startswith)
		for(var/item_path in startswith)
			var/list/data = startswith[item_path]
			if(islist(data))
				var/qty = data[1]
				var/list/argsl = data.Copy()
				argsl[1] = src
				for(var/i in 1 to qty)
					new item_path(arglist(argsl))
			else
				for(var/i in 1 to (isnull(data)? 1 : data))
					new item_path(src)
		update_icon()

/obj/item/weapon/storage/emp_act(severity)
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/item/weapon/storage/attack_self(mob/user as mob)
	//Clicking on itself will empty it, if it has the verb to do that.
	if(user.get_active_hand() == src)
		if(src.verbs.Find(/obj/item/weapon/storage/verb/quick_empty))
			src.quick_empty()
			return 1

/obj/item/weapon/storage/proc/make_exact_fit()
	storage_slots = contents.len

	can_hold.Cut()
	max_w_class = 0
	max_storage_space = 0
	for(var/obj/item/I in src)
		can_hold[I.type]++
		max_w_class = max(I.w_class, max_w_class)
		max_storage_space += I.get_storage_cost()

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while (cur_atom && !(cur_atom in container.contents))
		if (isarea(cur_atom))
			return -1
		if (istype(cur_atom.loc, /obj/item/weapon/storage))
			depth++
		cur_atom = cur_atom.loc

	if (!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while (cur_atom && !isturf(cur_atom))
		if (isarea(cur_atom))
			return -1
		if (istype(cur_atom.loc, /obj/item/weapon/storage))
			depth++
		cur_atom = cur_atom.loc

	if (!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/proc/get_storage_cost()
	//If you want to prevent stuff above a certain w_class from being stored, use max_w_class
	return base_storage_cost(w_class)

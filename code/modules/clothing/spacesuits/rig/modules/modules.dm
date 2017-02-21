/*
 * Rigsuit upgrades/abilities.
 */

/datum/rig_charge
	var/short_name = "undef"
	var/display_name = "undefined"
	var/product_type = "undefined"
	var/charges = 0

/obj/item/rig_module
	name = "hardsuit upgrade"
	desc = "It looks pretty sciency."
	icon = 'icons/obj/rig_modules.dmi'
	icon_state = "module"
	matter = list(DEFAULT_WALL_MATERIAL = 20000, "plastic" = 30000, "glass" = 5000)

	var/obj/item/weapon/rig/holder
	var/permanent                       // If set, the module can't be removed.
	var/redundant                       // Set to 1 to ignore duplicate module checking when installing.
	var/disruptive = 1                  // Can disrupt by other effects.
	var/activates_on_touch              // If set, unarmed attacks will call engage() on the target.

	var/list/stat_rig_module/stat_modules = new()
	var/list/rig_submodules/sub_modules = list()


/datum/rig_submodule
	var/name = ""
	var/damage = 0
	var/obj/item/rig_module/parent

	var/module_cooldown = 10
	var/next_use = 0

	var/toggleable                      // Set to 1 for the device to show up as an active effect.
	var/usable                          // Set to 1 for the device to have an on-use effect.
	var/selectable                      // Set to 1 to be able to assign the device as primary system.

	var/active                          // Basic module status
	var/disruptable                     // Will deactivate if some other powers are used.
	var/allowed_prone                   // Can be used while lying down.

	// Now in joules/watts!
	var/use_power_cost = 0              // Power used when single-use ability called.
	var/active_power_cost = 0           // Power used when turned on.
	var/passive_power_cost = 0          // Power used when turned off.

	var/list/charges                    // Associative list of charge types and remaining numbers.
	var/charge_selected                 // Currently selected option used for charge dispensing.

	// Icons.
	var/suit_overlay
	var/suit_overlay_active             // If set, drawn over icon and mob when effect is active.
	var/suit_overlay_inactive           // As above, inactive.
	var/suit_overlay_used               // As above, when engaged.

	//Display fluff
	var/interface_name = "hardsuit upgrade"
	var/interface_desc = "A generic hardsuit upgrade."
	var/engage_string = "Engage"
	var/activate_string = "Activate"
	var/deactivate_string = "Deactivate"

	var/list/stat_rig_module/stat_modules = new()

/obj/item/rig_module/examine()
	. = ..()
	for(var/datum/rig_submodule/S in sub_modules)
	switch(damage)
		if(0)
			to_chat(usr, "\The [S.name] is undamaged.")
		if(1)
			to_chat(usr, "\The [S.name] is badly damaged.")
		if(2)
			to_chat(usr, "\The [S.name] is almost completely destroyed.")


/obj/item/rig_module/attackby(obj/item/W as obj, mob/user as mob)
	var/max_repair = 0
	var/cable_lengths = 0
	var/datum/rig_submodule/selected
	if(istype(W, /obj/item/stack/nanopaste))
		max_repair = 2
	else (if(istype(W, /obj/item/stack/cable_coil))
		max_repair = 1
		var/obj/item/stack/cable_coil/cable = W
		cable_lengths = cable.amount
	if(!max_repair)
		return

	var/list/datum/rig_submodule/M = list()
	var/datum/rig_submodule/selected
	for(var/datum/rig_submodule/S in M)
		if(S.damage != 0)
			M += S

	if(!M.len)
		to_chat(user, "There is no damage to mend.")
		return
	else
		selected = input("Select the module to repair") null|anything in M
		if(!selected)
			return

		if(selected.damage > max_repair)
			to_chat(user, "There is no damage that you are capable of mending with such crude tools.")
			return

		if(max_repair == 1)
			if(cable_lengths < 5)
				to_chat(user, "You need five units of cable to repair \the [src].")
				return

		to_chat(user, "You start mending the damaged portions of \the [src]...")
		if(!do_after(user,30,src) || !W || !src)
			return

	switch(max_repair)
		if(1)
			var/obj/item/stack/cable_coil/repair = W
			repair.use(5)
		if(2)
			var/obj/item/stack/nanopaste/repair = W
			repair.use(1)
	to_chat(user, "You mend some of damage to [selected] with [W].")
	..()


/datum/rig_submodule/New()
	if(charges && charges.len)
		var/list/processed_charges = list()
		for(var/list/charge in charges)
			var/datum/rig_charge/charge_dat = new

			charge_dat.short_name   = charge[1]
			charge_dat.display_name = charge[2]
			charge_dat.product_type = charge[3]
			charge_dat.charges      = charge[4]

			if(!charge_selected) charge_selected = charge_dat.short_name
			processed_charges[charge_dat.short_name] = charge_dat

		charges = processed_charges

	stat_modules +=	new/stat_rig_module/activate(src)
	stat_modules +=	new/stat_rig_module/deactivate(src)
	stat_modules +=	new/stat_rig_module/engage(src)
	stat_modules +=	new/stat_rig_module/select(src)
	stat_modules +=	new/stat_rig_module/charge(src)


/obj/item/rig_module/New()
	..()
	if(suit_overlay_inactive)
		suit_overlay = suit_overlay_inactive

	for(var/datum/rig_submodule/S in sub_modules)
		S.New()


// Called when the module is installed into a suit.
/obj/item/rig_module/proc/installed(var/obj/item/weapon/rig/new_holder)
	holder = new_holder
	return


/datum/rig_submodule/proc/can_be_used()

	if(damage >= 2)
		to_chat(usr, "<span class='warning'>The [interface_name] is damaged beyond use!</span>")
		return 0

	if(world.time < next_use)
		to_chat(usr, "<span class='warning'>You cannot use the [interface_name] again so soon.</span>")
		return 0

	if(!parent.holder || parent.holder.canremove)
		to_chat(usr, "<span class='warning'>The suit is not initialized.</span>")
		return 0

	if(usr.lying || usr.stat || usr.stunned || usr.paralysis || usr.weakened)
		to_chat(usr, "<span class='warning'>You cannot use the suit in this state.</span>")
		return 0

	if(parent.holder.wearer && parent.holder.wearer.lying && !allowed_prone)
		to_chat(usr, "<span class='warning'>The suit cannot function while the wearer is prone.</span>")
		return 0

	if(parent.holder.security_check_enabled && !parent.holder.check_suit_access(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return 0

	if(!parent.holder.check_power_cost(usr, use_power_cost, 0, src, (istype(usr,/mob/living/silicon ? 1 : 0) ) ) )
		return 0

	next_use = world.time + module_cooldown

	return 1

//Proc for one-use abilities like teleport.
/datum/rig_submodule/proc/engage()

	return can_be_used()


// Proc for toggling on active abilities.
/datum/rig_submodule/proc/activate()

	if(active || !can_be_used())
		return 0

	active = 1

	spawn(1)
		if(suit_overlay_active)
			suit_overlay = suit_overlay_active
		else
			suit_overlay = null
		holder.update_icon()

	return 1

// Proc for toggling off active abilities.
/datum/rig_submodule/proc/deactivate()

	if(!active)
		return 0

	active = 0

	spawn(1)
		if(suit_overlay_inactive)
			suit_overlay = suit_overlay_inactive
		else
			suit_overlay = null
		if(holder)
			holder.update_icon()

	return 1

// Called when the module is uninstalled from a suit.
/obj/item/rig_module/proc/removed()
	deactivate()
	holder = null
	return

// Called by the hardsuit each rig process tick.
/obj/item/rig_module/process()
	if(active)
		return active_power_cost
	else
		return passive_power_cost

// Called by holder rigsuit attackby()
// Checks if an item is usable with this module and handles it if it is
/obj/item/rig_module/proc/accepts_item(var/obj/item/input_device)
	return 0

/mob/living/carbon/human/Stat()
	. = ..()

	if(. && istype(back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/R = back
		SetupStat(R)


/mob/proc/SetupStat(var/obj/item/weapon/rig/R)
	if(R && !R.canremove && R.installed_modules.len && statpanel("Hardsuit Modules"))
		var/cell_status = R.cell ? "[R.cell.charge]/[R.cell.maxcharge]" : "ERROR"
		stat("Suit charge", cell_status)
		for(var/obj/item/rig_module/module in R.installed_modules)
			for(var/datum/rig_submodule/sub in module.sub_modules)
			{
				for(var/stat_rig_module/SRM in module.stat_modules)
					if(SRM.CanUse())
						stat(SRM.module.interface_name,SRM)
			}


/stat_rig_module
	parent_type = /atom/movable
	var/module_mode = ""
	var/obj/item/rig_module/module
	var/list/datum/rig_submodule/subs

/stat_rig_submodule
	parent_type = /datum/rig_submodule
	var/datum/rig_submodule/module
	var/module_mode = ""



/stat_rig_module/New(var/obj/item/rig_module/module, var/datum/rig_submodule/subs)
	src.module.stat_modules += src
	src.subs = subs
	for(/datum/rig_submodule/S in subs)
		new stat_rig_submodule(S)

/stat_rig_submodule/New(var/datum/rig_submodule/S)


/stat_rig_submodule/proc/AddHref(var/list/href_list)
	return


/stat_rig_submodule/proc/CanUse()
	return 0


/stat_rig_submodule/Click()
	if(CanUse())
		var/list/href_list = list(
							"interact_module" = module.holder.installed_modules.Find(module),
							"module_mode" = module_mode
							)
		AddHref(href_list)
		module.parent.holder.Topic(usr, href_list)


/stat_rig_module/DblClick()
	return Click()

/stat_rig_module/activate/New(var/datum/rig_submodule/sub)
	..()
	name = sub.activate_string
	if(sub.active_power_cost)
		name += " ([sub.active_power_cost*10]A)"
	module_mode = "activate"

/stat_rig_module/activate/CanUse()
	return sub.toggleable && !sub.active

/stat_rig_module/deactivate/New(var/datum/rig_submodule/sub)
	..()
	name = sub.deactivate_string
	// Show cost despite being 0, if it means changing from an active cost.
	if(sub.active_power_cost || sub.passive_power_cost)
		name += " ([sub.passive_power_cost*10]P)"

	module_mode = "deactivate"

/stat_rig_module/deactivate/CanUse()
	return sub.toggleable && sub.active

/stat_rig_module/engage/New(var/datum/rig_submodule/sub)
	..()
	name = sub.engage_string
	if(sub.use_power_cost)
		name += " ([sub.use_power_cost*10]E)"
	module_mode = "engage"

/stat_rig_module/engage/CanUse()
	return module.usable

/stat_rig_module/select/New(var/datum/rig_submodule/sub)
	..()
	name = "Select"
	module_mode = "select"

/stat_rig_module/select/CanUse(var/datum/rig_submodule/sub)
	if(sub.selectable)
		name = sub.holder.selected_module == module ? "Selected" : "Select"
		return 1
	return 0

/stat_rig_module/charge/New()
	..()
	name = "Change Charge"
	module_mode = "select_charge_type"

/stat_rig_module/charge/AddHref(var/list/href_list)
	var/charge_index = module.charges.Find(module.charge_selected)
	if(!charge_index)
		charge_index = 0
	else
		charge_index = charge_index == module.charges.len ? 1 : charge_index+1

	href_list["charge_type"] = module.charges[charge_index]

/stat_rig_module/charge/CanUse()
	if(module.charges && module.charges.len)
		var/datum/rig_charge/charge = module.charges[module.charge_selected]
		name = "[charge.display_name] ([charge.charges]C) - Change"
		return 1
	return 0

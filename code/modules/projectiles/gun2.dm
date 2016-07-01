/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun, what do you expect?"
	icon = 'icons/obj/gun.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_guns.dmi',
		)
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	matter = list(DEFAULT_WALL_MATERIAL = 2000)
	w_class = 3
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5
	origin_tech = list(TECH_COMBAT = 1)
	attack_verb = list("struck", "hit", "bashed")
	zoomdevicename = "scope"

	var/obj/item/gun_item/magazine/magazine = null
	var/list/datum/gun_attach_point/attach_points = list()
	var/list/obj/item_gun_item/accessory/attached = list()
	var/list/necessary_parts = list()
	var/list/obj/item/gun_item/parts = list()
	var/datum/gun_action = ""
	var/power_source



/obj/item/weapon/gun/proc/initialize_attachment_points()
	return

/obj/item/gun_item/magazine
	name = "magazine"
	var/capacity = 0
	var/list/compatible_ammo = list()
	var/loaded/

/datum/gun_action/
	var/name = ""
	var/action_type = 0
	var/firemode = 0
	var/cyclic_rate = 0
	var/jam_chance = 0
	var/jammed = 0
	var/heat = 0
	var/max_heat = 0
	var/overheated = 0
	var/heat_threshold = 0
	var/heat_dissipation = 0

	//Binary 1 = manual, 2 = semi, 4 = burst, 8 = automatic,


/datum/gun_attach_point/
	var/name = ""
	var/list/compatible_attachments = list()


/obj/item/gun_item/
	name = "gun item"
	desc = "An external accessory for a gun"

/obj/item/gun_item/part
	name = "gun item"
	desc = "An integral part for a gun"
	var/part_name = ""


/obj/item/gun_item/accessory
	name = "gun item"
	desc = "An external accessory for a gun"
	var/attachment_type = ""

	var/compatable_attachment = list()




/*
/obj/item/weapon/gun/rifle

	attach_points = list("rifle_rail_scope_top", "rifle_rail_top", "rifle_lightmount_side", "rifle_rail_bottom", "rifle_stock", "rifle_foregrip")
*/


//Action = pistol_revolver, pistol_break, pistol_manual, pistol_semiauto, pistol_automatic, rifle_break, rifle_manual, rifle_semiauto, rifle_automatic, rifle_burst, shotgun_break, shotgun_manual, shotgun_semiauto, shotgun_burst, shotgun_automatic, energy_manual, energy_semiauto, energy_burst, energy_automatic
//magazine = energy, cylinder, tube, pump_tube, clip
//frame = pistol, pistol_large, longgun, longgun_bullpup, longgun_sub
//receiver = caliber
//barrel = caliber,length

//power = power_cell
//gain_medium = types
//capacitor_bank = max load
//focusing_array = narrow, columnar, coherent, spread


/obj/item/gun_item/part/magazine
	var/magazine_type = ""
	var/internal = 0
	var/caliber = 0


/obj/item/gun_item/part/receiver
	var/caliber = 0
	var/chambered = null

/obj/item/gun_item/part/barrel

	var/caliber = 0
	var/choke = 0 //º spread at 40ft. Doesn't affect solid projectiles


/obj/item/gun_item/part/gain_medium
	var/efficiency = 0
	var/integrity = 100
	var/output = list("agony" = 0, "damage" = 0, "stun" = 0)

/obj/item/gun_item/part/focusing_array
	var/array_type = ""

/obj/item/gun_item/part/capacitor_bank
	var/efficiency
	var/charge
	var/load
	var/max_load
	var/draw_per_second


/obj/item/weapon/gun/projectile/revolver
	var/list/parts = list("357_cylinder_revolver","357_barrel_pistol","frame_pistol")

/obj/item/gun_item/part/magazine/cylinder/revolver/revolver_357
	var/magazine_type = "revolver"
	part_type = "revolver_cylinder"
	part_name = "357_cylinder_revolver"
























/////////////////////////////////////////////////////////////////////////

/obj/item/weapon/gun
	name = "gun"
	desc = "It's a gun, what do you expect?"
	icon = 'icons/obj/gun.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/items/lefthand_guns.dmi',
		slot_r_hand_str = 'icons/mob/items/righthand_guns.dmi',
		)
	icon_state = "detective"
	item_state = "gun"
	flags =  CONDUCT
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	matter = list(DEFAULT_WALL_MATERIAL = 2000)
	w_class = 3
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5
	origin_tech = list(TECH_COMBAT = 1)
	attack_verb = list("struck", "hit", "bashed")
	zoomdevicename = "scope"

	var/list/obj/item/gun_item/part/parts = list()
	var/list/obj/item/gun_item/accessory/accessories = list()
	var/list/obj/item/gun_item/part/frame/frame = null

/obj/item/gun_item/part/frame
	var/list/datum/gun_attach_point/attach_points = list()
	w_class = 2.0
	var/max_w_class = 4.0
	var/list/datum/gun_part_slot/part_slots = list()
	var/available_size = 30

/obj/item/gun_item/part/frame/rifle
	var/list/datum/gun_attach_point/attach_points = list("stock_rifle", "rail_rifle","rail_rifle","optic_rifle")
	list/datum/gun_part_slot/part_slots = list("barrel_rifle","receiver_rifle","gainmedium","lasingchamber_rifle","capacitorbank","powercell","condenserunit")

/obj/item/gun_item/part
	var/part_type = ""
	var/occupied_size = 1
	var/caliber = 0

/obj/item/gun_item/part/barrel
	part_type = "barrel"
	caliber = 0
	occupied_size = 4

/obj/item/gun_item/part/receiver
	part_type = "receiver"
	caliber = 0
	var/internal_magazine = 0
	var/internal_magazine_size = 0
	var/list/compatible_ammo = list()
	var/chambered
	var/revolver = 0
	var/list/revolver_bullets = list()
	occupied_size = 16



/obj/item/gun_item/part/gainmedium
	var/efficiency = 0
	var/colour = ""
	occupied_size = 2


/obj/item/gun_item/part/lasingchamber
	occupied_size = 6

/obj/item/gun_item/part/capacitorbank
	var/power = 0
	var/load = 0
	var/maxload = 0
	var/heatperpower = 0
	occupied_size = 4

/obj/item/gun_item/part/focusing_array
	var/spread = 0.01 //º at 40ft.
	occupied_size = 6

/obj/item/gun_item/part/condenserunit
	var/heat_dissipated = 0
	occupied_size = 8


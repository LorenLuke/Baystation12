/obj/item/weapon/computer_hardware/tesla_link
	name = "tesla link"
	desc = "A high-performance tesla link that wirelessly recharges connected devices from a nearby area power controller."
	critical = 0
	enabled = 5
	icon_state = "teslalink"
	hardware_size = 2
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 3, TECH_ENGINEERING = 2)
	var/transfer_rate = 400			// W

/obj/item/weapon/computer_hardware/tesla_link/femto
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 1
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 1, TECH_ENGINEERING = 2)
	transfer_rate = 20			// W

/obj/item/weapon/computer_hardware/tesla_link/pico
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 2
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 1, TECH_ENGINEERING = 2)
	transfer_rate = 60			// W

/obj/item/weapon/computer_hardware/tesla_link/nano
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 3
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 1, TECH_ENGINEERING = 2)
	transfer_rate = 125			// W

/obj/item/weapon/computer_hardware/tesla_link/micro
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 4
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 1, TECH_ENGINEERING = 2)
	transfer_rate = 225			// W

/obj/item/weapon/computer_hardware/tesla_link/macro
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 6
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 1, TECH_ENGINEERING = 2)
	transfer_rate = 850			// W

/obj/item/weapon/computer_hardware/tesla_link/console
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 7
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 1, TECH_ENGINEERING = 2)
	transfer_rate = 1250			// W


/obj/item/weapon/computer_hardware/tesla_link/server
	name = "console tesla link"
	desc = "An advanced tesla link designed to provide significant power to console computers."
	critical = 1
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 8
	origin_tech = list(TECH_DATA = 1, TECH_POWER = 3, TECH_ENGINEERING = 2)
	transfer_rate = 2250			// W


/obj/item/weapon/computer_hardware/tesla_link/Destroy()
	if(holder2 && (holder2.tesla_link == src))
		holder2.tesla_link = null
	return ..()
/obj/item/weapon/computer_hardware/tesla_link
	name = "tesla link"
	desc = "A high-performance tesla link that wirelessly recharges connected devices from a nearby area power controller."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 2
	origin_tech = list(TECH_DATA = 3, TECH_POWER = 4, TECH_ENGINEERING = 4)
	var/transfer_rate = 650			// W

/obj/item/weapon/computer_hardware/tesla_link/micro
	name = "micro tesla link"
	desc = "An miniaturised tesla link designed to wirelessly charge tablet and laptop computers from nearby area power controllers."
	critical = 0
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 2
	origin_tech = list(TECH_DATA = 3, TECH_POWER = 3, TECH_ENGINEERING = 2)
	transfer_rate = 250			// W


/obj/item/weapon/computer_hardware/tesla_link/wired
	name = "console tesla link"
	desc = "An advanced tesla link designed to provide significan power to console computers."
	critical = 1
	enabled = 1
	icon_state = "teslalink"
	hardware_size = 3
	origin_tech = list(TECH_DATA = 2, TECH_POWER = 3, TECH_ENGINEERING = 2)
	transfer_rate = 1750			// W


/obj/item/weapon/computer_hardware/tesla_link/Destroy()
	if(holder2 && (holder2.tesla_link == src))
		holder2.tesla_link = null
	return ..()
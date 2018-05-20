/obj/item/weapon/computer_hardware/portable
	name = "USB device"
	desc = "A portable multifunction device."
	icon_state = "battery_normal"
	malfunction_probability = 1
	origin_tech = list(TECH_POWER = 1, TECH_ENGINEERING = 1)
	var/usb_type = 0
	var/obj/item/weapon/computer_hardware/internal_device = null

// These are basically USB data sticks and may be used to transfer files between devices
/obj/item/weapon/computer_hardware/hard_drive/portable/
	name = "standard data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 32 GQ."
	power_usage = 20
	standby_power_usage = 20
	icon_state = "flashdrive_32"
	hardware_size = 0
	max_capacity = 32
	origin_tech = list(TECH_DATA = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/New()
	..()
	var/obj/item/weapon/computer_hardware/portable/P  = new /obj/item/weapon/computer_hardware/portable(get_turf(src))
	src.portable_holder = P
	P.usb_type = 1
	P.internal_device = src
	src.forceMove(P)
	P.name = src.name
	P.desc = src.desc
	P.power_usage = src.power_usage
	P.origin_tech = src.origin_tech
	P.icon_state = src.icon_state

/obj/item/weapon/computer_hardware/hard_drive/portable/basic
	name = "basic data crystal"
	desc = "Small crystal with imprinted high-density photonic circuits that can be used to store data. Its capacity is 16 GQ."
	power_usage = 10
	standby_power_usage = 10
	icon_state = "flashdrive_16"
	hardware_size = 1
	max_capacity = 16
	origin_tech = list(TECH_DATA = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/advanced
	name = "advanced data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 64 GQ."
	power_usage = 40
	standby_power_usage = 40
	icon_state = "flashdrive_64"
	hardware_size = 1
	max_capacity = 64
	origin_tech = list(TECH_DATA = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/super
	name = "super data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 128 GQ."
	power_usage = 80
	standby_power_usage = 80
	icon_state = "flashdrive_128"
	hardware_size = 1
	max_capacity = 128
	origin_tech = list(TECH_DATA = 3)

/obj/item/weapon/computer_hardware/hard_drive/portable/ultra
	name = "ultra data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 256 GQ."
	power_usage = 160
	standby_power_usage = 160
	icon_state = "flashdrive_256"
	hardware_size = 1
	max_capacity = 256
	origin_tech = list(TECH_DATA = 4)

/obj/item/weapon/computer_hardware/hard_drive/portable/New()
	..()
	stored_files = list()
	recalculate_size()

/obj/item/weapon/computer_hardware/hard_drive/portable/Destroy()
	if(portable_holder && (portable_holder.internal_device == src))
		portable_holder.internal_device = null
	return ..()

/obj/item/weapon/computer_hardware/battery_module/portable
	name = "standard external battery"
	desc = "A standard power cell, commonly seen in high-end portable microcomputers or low-end laptops. It's rating is 75 Wh."
	icon_state = "battery_normal"
	malfunction_probability = 1
	origin_tech = list(TECH_POWER = 1, TECH_ENGINEERING = 1)

/obj/item/weapon/computer_hardware/battery_module/portable/New()
	..()
	var/obj/item/weapon/computer_hardware/portable/P  = new /obj/item/weapon/computer_hardware/portable(get_turf(src))
	src.portable_holder = P
	P.usb_type = 2
	P.internal_device = src
	src.forceMove(P)
	P.name = src.name
	P.desc = src.desc
	P.power_usage = src.power_usage
	P.standby_power_usage = src.standby_power_usage
	P.origin_tech = src.origin_tech
	P.icon_state = src.icon_state

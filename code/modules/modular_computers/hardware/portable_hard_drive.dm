// These are basically USB data sticks and may be used to transfer files between devices
/obj/item/weapon/computer_hardware/hard_drive/portable/
	name = "standard data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 32 GQ."
	power_usage = 10
	icon_state = "flashdrive_32"
	hardware_size = 1
	max_capacity = 32
	origin_tech = list(TECH_DATA = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/basic
	name = "basic data crystal"
	desc = "Small crystal with imprinted high-density photonic circuits that can be used to store data. Its capacity is 16 GQ."
	power_usage = 5
	icon_state = "flashdrive_16"
	hardware_size = 1
	max_capacity = 16
	origin_tech = list(TECH_DATA = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/advanced
	name = "advanced data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 64 GQ."
	power_usage = 20
	icon_state = "flashdrive_64"
	hardware_size = 1
	max_capacity = 64
	origin_tech = list(TECH_DATA = 1)

/obj/item/weapon/computer_hardware/hard_drive/portable/super
	name = "super data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 128 GQ."
	power_usage = 40
	icon_state = "flashdrive_128"
	hardware_size = 1
	max_capacity = 128
	origin_tech = list(TECH_DATA = 3)


/obj/item/weapon/computer_hardware/hard_drive/portable/ultra
	name = "ultra data crystal"
	desc = "Small crystal with imprinted photonic circuits that can be used to store data. Its capacity is 256 GQ."
	power_usage = 80
	icon_state = "flashdrive_256"
	hardware_size = 1
	max_capacity = 256
	origin_tech = list(TECH_DATA = 4)

/obj/item/weapon/computer_hardware/hard_drive/portable/New()
	..()
	stored_files = list()
	recalculate_size()

/obj/item/weapon/computer_hardware/hard_drive/portable/Destroy()
	if(holder2 && (holder2.portable_drive == src))
		holder2.portable_drive = null
	return ..()
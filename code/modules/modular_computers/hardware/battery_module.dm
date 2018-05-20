// This device is wrapper for actual power cell. I have decided to not use power cells directly as even low-end cells available on station
// have tremendeous capacity in comparsion. Higher tier cells would provide your device with nearly infinite battery life, which is something i want to avoid.

/obj/item/weapon/computer_hardware/battery_module
	name = "standard battery"
	desc = "A standard power cell capable of fitting inside tablets, laptops, and consoles. Its rating is 75 Wh."
	icon_state = "battery_standard"
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_POWER = 1, TECH_ENGINEERING = 1)
	hardware_size = 5
	var/battery_rating = 75
	var/obj/item/weapon/cell/battery = null
	var/max_load

/obj/item/weapon/computer_hardware/battery_module/femto
	name = "femto battery"
	desc = "A miniscule power cell capabile of fitting in PDA devices. Its rating is 10 Wh."
	icon_state = "battery_femto"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	hardware_size = 1
	battery_rating = 10

/obj/item/weapon/computer_hardware/battery_module/pico
	name = "pico battery"
	desc = "A tiny power cell, capable of fitting in PDA devices and tablets. Its rating is 20 Wh."
	icon_state = "battery_pico"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	hardware_size = 2
	battery_rating = 20

/obj/item/weapon/computer_hardware/battery_module/nano
	name = "nano battery"
	desc = "A small power cell, capable of fitting in PDA devices, tablets, and laptops. Its rating is 35 Wh."
	icon_state = "battery_nano"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	hardware_size = 3
	battery_rating = 35

/obj/item/weapon/computer_hardware/battery_module/micro
	name = "micro battery"
	desc = "A smaller power cell, capable of fitting in tablets and laptops.Its rating is 55 Wh."
	icon_state = "battery_micro"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	hardware_size = 4
	battery_rating = 55

/obj/item/weapon/computer_hardware/battery_module/macro
	name = "macro battery"
	desc = "A large power cell, capable of fitting in laptops and consoles. Its rating is 100 Wh."
	icon_state = "battery_macro"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	hardware_size = 6
	battery_rating = 100

/obj/item/weapon/computer_hardware/battery_module/console
	name = "console battery"
	desc = "An enormous power cell, capable of fitting in consoles and servers. It's rating is 150 Wh."
	icon_state = "battery_console"
	origin_tech = list(TECH_POWER = 2, TECH_ENGINEERING = 2)
	hardware_size = 7
	battery_rating = 150

/obj/item/weapon/computer_hardware/battery_module/server
	name = "server battery"
	desc = "A backup battery array, used only in servers. It's rating is 250 Wh."
	icon_state = "battery_server"
	origin_tech = list(TECH_POWER = 4, TECH_ENGINEERING = 3)
	hardware_size = 10
	battery_rating = 250

// This is not intended to be obtainable in-game. Intended for adminbus and debugging purposes.
/obj/item/weapon/computer_hardware/battery_module/lambda
	name = "lambda coil"
	desc = "A quantumly layered battery that draws power from a bluespace pocket. It is capable of providing power for nearly unlimited duration."
	icon_state = "battery_lambda"
	origin_tech = list(TECH_POWER = 7, TECH_ENGINEERING = 6)
	hardware_size = 0
	battery_rating = 3000

/obj/item/weapon/computer_hardware/battery_module/New()
	..()
	max_load = battery_rating/20

/obj/item/weapon/computer_hardware/battery_module/lambda/New()
	..()
	battery = new/obj/item/weapon/cell/infinite(src)


/obj/item/weapon/computer_hardware/battery_module/diagnostics(var/mob/user)
	..()
	to_chat(user, "Internal battery charge: [battery.charge]/[battery.maxcharge] Wh")

/obj/item/weapon/computer_hardware/battery_module/New()
	battery = new/obj/item/weapon/cell(src)
	battery.maxcharge = battery_rating
	battery.charge = 0
	..()

/obj/item/weapon/computer_hardware/battery_module/Destroy()
	QDEL_NULL(battery)
	if(holder2 && (holder2.battery_module == src))
		holder2.ai_slot = null
	return ..()

/obj/item/weapon/computer_hardware/battery_module/proc/charge_to_full()
	if(battery)
		battery.charge = battery.maxcharge
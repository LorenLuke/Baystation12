// CPU that allows the computer to run programs.
// Better CPUs are obtainable via research and can run more programs on background.

/obj/item/weapon/computer_hardware/processor_unit
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run up to three programs simultaneously."
	icon_state = "cpu_normal"
	hardware_size = 5
	power_usage = 80
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 3, TECH_ENGINEERING = 2)
	var/max_idle_programs = 1 // 2 idle, + 1 active = 3 as said in description.


/obj/item/weapon/computer_hardware/processor_unit/femto
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 1
	power_usage = 10
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 0

/obj/item/weapon/computer_hardware/processor_unit/femto/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 1
	power_usage = 25
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 1

/obj/item/weapon/computer_hardware/processor_unit/pico
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 2
	power_usage = 20
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 0


/obj/item/weapon/computer_hardware/processor_unit/pico/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 2
	power_usage = 35
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 1


/obj/item/weapon/computer_hardware/processor_unit/nano

	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 3
	power_usage = 30
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 0

/obj/item/weapon/computer_hardware/processor_unit/nano/photonic

	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 3
	power_usage = 55
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 2


/obj/item/weapon/computer_hardware/processor_unit/micro
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 4
	power_usage = 45
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 1

/obj/item/weapon/computer_hardware/processor_unit/micro/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 4
	power_usage = 70
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 2

/obj/item/weapon/computer_hardware/processor_unit/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 5
	power_usage = 90
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 3


/obj/item/weapon/computer_hardware/processor_unit/macro
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 6
	power_usage = 95
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 3

/obj/item/weapon/computer_hardware/processor_unit/macro/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 6
	power_usage = 120
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 4

/obj/item/weapon/computer_hardware/processor_unit/console
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 7
	power_usage = 115
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 3

/obj/item/weapon/computer_hardware/processor_unit/console/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 7
	power_usage = 165
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 4

/obj/item/weapon/computer_hardware/processor_unit/server
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 7
	power_usage = 175
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 4

/obj/item/weapon/computer_hardware/processor_unit/server/photonic
	name = "standard processor"
	desc = "A standard CPU used in most computers. It can run only one program."
	icon_state = "cpu_normal"
	hardware_size = 8
	power_usage = 175
	critical = 1
	malfunction_probability = 1
	origin_tech = list(TECH_DATA = 0, TECH_ENGINEERING = 0)
	max_idle_programs = 4

/obj/item/weapon/computer_hardware/processor_unit/Destroy()
	if(holder2 && (holder2.processor_unit == src))
		holder2.processor_unit = null
	return ..()
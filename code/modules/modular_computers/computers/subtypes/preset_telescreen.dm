/obj/item/modular_computer/telescreen/preset/install_default_hardware()
	..()
	processor_unit = new/obj/item/weapon/computer_hardware/processor_unit(src)
	tesla_link = new/obj/item/weapon/computer_hardware/tesla_link/wired(src)
	hard_drive = new/obj/item/weapon/computer_hardware/hard_drive(src)
	network_card = new/obj/item/weapon/computer_hardware/network_card(src)

/obj/item/modular_computer/telescreen/preset/generic/install_default_programs()
	..()
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/camera_monitor())
	hard_drive.store_file(new/datum/computer_file/program/email_client())
	set_autorun("cammon")

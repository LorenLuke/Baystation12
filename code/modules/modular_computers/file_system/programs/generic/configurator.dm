// This is special hardware configuration program.
// It is to be used only with modular computers.
// It allows you to toggle components of your device.

/datum/computer_file/program/computerconfig
	filename = "compconfig"
	filedesc = "Computer Configuration Tool"
	extended_desc = "This program allows configuration of computer's hardware"
	program_icon_state = "generic"
	program_key_state = "generic_key"
	program_menu_icon = "gear"
	unsendable = 1
	undeletable = 1
	size = 4
	available_on_ntnet = 0
	requires_ntnet = 0
	nanomodule_path = /datum/nano_module/program/computer_configurator/
	usage_flags = PROGRAM_ALL

/datum/nano_module/program/computer_configurator
	name = "NTOS Computer Configuration Tool"
	var/obj/item/modular_computer/movable = null

/datum/nano_module/program/computer_configurator/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
	if(program)
		movable = program.computer
	if(!istype(movable))
		movable = null

	// No computer connection, we can't get data from that.
	if(!movable)
		return 0

	var/list/data = list()

	if(program)
		data = program.get_header_data()

	var/list/hardware = movable.get_all_components()

	data["processor_exists"] = movable.processor_unit ? 1 : 0
	data["networkcard_exists"] = movable.network_card ? 1 : 0
	data["harddisk_exists"] = movable.hard_drive ? 1 : 0
	data["battery_exists"] = movable.battery_module ? 1 : 0
	data["tesla_exists"] = movable.tesla_link ? 1 : 0
	data["usb_exists"] = movable.usb_slot ? 1 : 0

	if(movable.processor_unit)
		data["processor_name"] = movable.processor_unit.name
		data["processor_desc"] = movable.processor_unit.desc
		data["processor_running"] = movable.idle_threads.len + 1
		data["processor_maxrunning"] = movable.processor_unit.max_idle_programs + 1
		data["processor_power"] = movable.processor_unit.power_usage
		data["processor_standby"] = movable.processor_unit.standby_power_usage

	if(movable.network_card)
		data["networkcard_name"] = movable.network_card.name
		data["networkcard_desc"] = movable.network_card.desc
		data["networkcard_signal"] = movable.network_card.get_signal()
		data["networkcard_wired"] = movable.network_card.ethernet
		data["networkcard_enabled"] = movable.network_card.enabled
		data["networkcard_power"] = movable.network_card.power_usage
		data["networkcard_standby"] = movable.network_card.standby_power_usage

	if(movable.hard_drive)
		data["harddisk_name"] = movable.hard_drive.name
		data["harddisk_desc"] = movable.hard_drive.desc
		data["harddisk_size"] = movable.hard_drive.max_capacity
		data["harddisk_used"] = movable.hard_drive.used_capacity
		data["harddisk_power"] = movable.hard_drive.power_usage
		data["harddisk_standby"] = movable.hard_drive.standby_power_usage

	if(movable.tesla_link)
		data["tesla_name"] = movable.tesla_link.name
		data["tesla_desc"] = movable.tesla_link.desc
		data["tesla_power"] = movable.tesla_link.transfer_rate

		var/areapower = movable.tesla_link.check_functionality()
		var/area/A = get_area(movable)
		if(istype(A) && A.powered(EQUIP))
			areapower = areapower * 1
		else
			areapower = areapower * 0

		data["tesla_rate"] = areapower * movable.tesla_link.transfer_rate

	if(movable.usb_slot)
		data["usb_name"] = movable.usb_slot.name
		data["usb_desc"] = movable.usb_slot.desc
		data["usb_type"] = movable.usb_slot.usb_type
		data["usb_enabled"] = movable.usb_slot.enabled
		switch (movable.usb_slot.usb_type)
			if(1) // Hard disk
				var/obj/item/weapon/computer_hardware/hard_drive/USB = movable.usb_slot.internal_device
				data["usb_upper"] = USB.max_capacity
				data["usb_current"] = USB.used_capacity
				data["usb_power"] = USB.power_usage
				data["usb_standby"] = USB.standby_power_usage

			if(2) // battery
				var/obj/item/weapon/computer_hardware/battery_module/USB = movable.usb_slot.internal_device
				data["usb_upper"] = USB.battery_rating
				data["usb_current"] = USB.battery.charge
				data["usb_percent"] = USB.battery.percent()
				data["usb_power"] = USB.power_usage

			if(3) // network card - not supported yet
				var/obj/item/weapon/computer_hardware/network_card/USB = movable.usb_slot.internal_device

			if(4) // tesla relay - not supported yet
				var/obj/item/weapon/computer_hardware/tesla_link/USB = movable.usb_slot.internal_device


	if(movable.battery_module)
		data["battery_name"] = movable.battery_module.name
		data["battery_desc"] = movable.battery_module.desc
		data["battery_rating"] = movable.battery_module.battery.maxcharge
		data["battery_percent"] = round(movable.battery_module.battery.percent())

	data["power_usage"] = movable.last_power_usage


	var/list/all_entries[0]
	for(var/obj/item/weapon/computer_hardware/H in hardware)
		if(H in list(movable.processor_unit, movable.network_card, movable.hard_drive, movable.battery_module, movable.usb_slot, movable.tesla_link))
			continue
		all_entries.Add(list(list(
		"name" = H.name,
		"desc" = H.desc,
		"enabled" = H.enabled,
		"critical" = H.critical,
		"powerusage" = H.power_usage,
		"standby" = H.standby_power_usage
		)))

	data["hardware"] = all_entries
	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "laptop_configuration.tmpl", "NTOS Configuration Utility", 575, 700, state = state)
		ui.auto_update_layout = 1
		ui.set_initial_data(data)
		ui.open()
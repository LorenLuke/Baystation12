/obj/item/modular_computer/proc/power_failure(var/malfunction = 0)
	if(enabled) // Shut down the computer
		visible_message("<span class='danger'>\The [src]'s screen flickers briefly and then goes dark.</span>", range = 1)
		if(active_program)
			active_program.event_powerfailure(0)
		for(var/datum/computer_file/program/PRG in idle_threads)
			PRG.event_powerfailure(1)
		shutdown_computer(0)


// Handles power-related things, such as battery interaction, recharging, shutdown when it's discharged
/obj/item/modular_computer/proc/handle_power(var/check = 0)

	var/power_usage = (!screen_on || standby) ? base_idle_power_usage : base_active_power_usage
	for(var/obj/item/weapon/computer_hardware/H in get_all_components())
		if(H.enabled)
			if(standby)
				power_usage += H.standby_power_usage
			else
				power_usage += H.power_usage
	last_power_usage = power_usage

	var/power_demand = last_power_usage
	var/battery_demand = 0
	if(battery_module)
		battery_demand = (battery_module.battery.maxcharge - battery_module.battery.charge)
	var/usb_demand = 0
	if(usb_slot)
		if(usb_slot.usb_type == 2)
			var/obj/item/weapon/computer_hardware/battery_module/B = usb_slot.internal_device
			usb_demand = (B.battery.maxcharge - B.battery.charge)

	var/tesla_power = 0
	if(tesla_link)
		tesla_power = min(power_demand + battery_demand + usb_demand, tesla_link.transfer_rate)
		if(!tesla_link.check_functionality())
			tesla_power = 0
		var/area/A = get_area(src)
		if(istype(A) && A.powered(EQUIP))
			A.use_power(power_usage, EQUIP)
		else
			tesla_power = 0

	if(check)
		power_demand -= tesla_power
		if(battery_module)
			power_demand -= min(battery_module.max_load/CELLRATE, battery_module.battery.charge)
		if(usb_slot)
			if(usb_slot.usb_type == 2)
				var/obj/item/weapon/computer_hardware/battery_module/B = usb_slot.internal_device
				power_demand -= min(B.max_load/CELLRATE, B.battery.charge)
		if(power_demand > 0)
			return 0
		else
			return 1


	var/power_dif = tesla_power - power_demand

	if(power_dif >= 0)
		tesla_power -= power_demand
		power_demand = 0
	else
		power_demand -= tesla_power

	if(battery_module)
		if(power_demand > 0)
			battery_module.battery.use(min(power_demand * CELLRATE, battery_module.max_load, battery_module.battery.charge))
			power_demand -= min(power_demand, battery_module.max_load/CELLRATE)
		else

			battery_module.battery.give(min(battery_demand, battery_module.max_load/CELLRATE, tesla_power * CELLRATE))
			tesla_power -= min(battery_demand, battery_module.max_load/CELLRATE)
			battery_demand -= min(battery_demand, battery_module.max_load/CELLRATE)

	if(usb_slot)
		if(usb_slot.usb_type == 2)
			var/obj/item/weapon/computer_hardware/battery_module/B = usb_slot.internal_device
			if(power_demand > 0)
				B.battery.use(min(power_demand * CELLRATE, B.max_load, B.battery.charge))
				power_demand -= min(power_demand, B.max_load/CELLRATE, B.battery.charge)
			else if(battery_demand > 0)
				battery_module.battery.give(min(battery_demand * CELLRATE, B.max_load, B.battery.charge))
				B.battery.use(min(battery_demand * CELLRATE, B.max_load, B.battery.charge))
				battery_demand -= min(battery_demand, B.max_load/CELLRATE)
			else
				B.battery.give(min(usb_demand * CELLRATE, B.max_load, tesla_power * CELLRATE))

	// First tries to charge from an APC, if APC is unavailable switches to battery power. If neither works the computer fails.
	if(power_demand>0)
		power_failure()
		return 0
	if(power_demand<=0)
		if(power_dif > 0)
			//We charging
			return 2
		else
			return 1

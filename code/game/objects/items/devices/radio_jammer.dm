#define JAMMER_MAX_RANGE world.view*2

var/global/list/obj/item/device/radio_jammer/radio_jamming_sources = list()

/obj/item/device/radio_jammer
	name = "small device"
	desc = "This object menaces with tiny, dull spikes of plastic."
	icon_state = "jammer"
	w_class = ITEM_SIZE_SMALL
	var/active = FALSE
	var/range = 5 // This is a radius, thus a range of 7 covers the entire visible screen
	var/obj/item/weapon/cell/bcell = /obj/item/weapon/cell/high

/obj/item/device/radio_jammer/New()
	..()
	if(ispath(bcell))
		bcell = new bcell(src)
	radio_jamming_sources.Add(src)
	update_icon()

/obj/item/device/radio_jammer/Destroy()
	. = ..()
	qdel(bcell)
	bcell = null
	radio_jamming_sources.Remove(src)
	disable()

/obj/item/device/radio_jammer/attack_self(var/mob/user)
	if (active)
		disable()
	else
		enable()

/obj/item/device/radio_jammer/attackby(obj/item/I as obj, mob/user as mob)
	if(isCrowbar(I))
		if(bcell)
			to_chat(user, "<span class='notice'>You remove \the [bcell].</span>")
			disable()
			bcell.dropInto(loc)
			bcell = null
		else
			to_chat(user, "<span class='warning'>There is no cell to remove.</span>")
	else if(istype(I, /obj/item/weapon/cell))
		if(bcell)
			to_chat(user, "<span class='warning'>There's already a cell in \the [src].</span>")
		else if(user.unEquip(I))
			I.forceMove(src)
			bcell = I
			to_chat(user, "<span class='notice'>You insert \the [bcell] into \the [src]..</span>")
		else
			to_chat(user, "<span class='warning'>You're unable to insert the battery.</span>")

/obj/item/device/radio_jammer/update_icon()
	overlays.Cut()
	if(bcell)
		var/percent = bcell.percent()
		switch(percent)
			if(0 to 25)
				overlays += "forth_quarter"
			if(25 to 50)
				overlays += "one_quarter"
				overlays += "third_quarter"
			if(50 to 75)
				overlays += "two_quarters"
				overlays += "second_quarter"
			if(75 to 99)
				overlays += "three_quarters"
				overlays += "first_quarter"
			else
				overlays += "four_quarters"

		if(active)
			overlays += "active"

/obj/item/device/radio_jammer/emp_act(var/severity)
	..()
	if(bcell)
		bcell.emp_act(severity)

	if(prob(70/severity))
		enable()
	else
		disable()

obj/item/device/radio_jammer/examine(var/user)
	. = ..(user, 3)
	if(.)
		var/list/message = list()
		message += "This device appears to be [active ? "" : "in"]active and "
		if(bcell)
			message += "displays a charge level of [bcell.percent()]%."
		else
			message += "is lacking a cell."
		to_chat(user, jointext(message,.))


/obj/item/device/suit_sensor_jammer/Process(var/wait)
	if(bcell)
		// With a range of 2 and jammer cost of 3 the default (high capacity) cell will last for almost 14 minutes, give or take
		// 10000 / (2^2 * 3 / 10) ~= 8333 ticks ~= 13.8 minutes
		var/drain = (max(0.75, range)**2 * wait) / 5
		if(!bcell.use(drain))
			disable()
	else
		disable()
	update_icon()

/obj/item/device/radio_jammer/proc/enable()
	if(active)
		return FALSE
	active = TRUE
	START_PROCESSING(SSobj, src)
	update_icon()
	return TRUE

/obj/item/device/radio_jammer/proc/disable()
	if(!active)
		return FALSE
	active = FALSE
	STOP_PROCESSING(SSobj, src)
	update_icon()
	return TRUE

/obj/item/device/radio_jammer/proc/set_range(var/new_range = "")
	if (new_range == "")
		new_range = input("Set jammer range", "Set radio jammer range") as num
	range = Clamp(round(new_range), 0, JAMMER_MAX_RANGE) // 0 range still covers the current turf
	to_chat(usr, "<span class='notice'>Jammer radius set to [range]</span>"
	return range != new_range

#undef JAMMER_MAX_RANGE

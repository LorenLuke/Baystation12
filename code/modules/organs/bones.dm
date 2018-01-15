
/****************************************************
					bones
****************************************************/
/datum/bone
	var/obj/item/organ/external/organ
	var/least_damage = 0
	var/damage = 0
	var/resistance = 20 //resistance to breaking
	var/list/fractures = list("hairline" = 0, "fractures" = 0, "compound" = 0, "shattered" = 0)
	var/list/fractures_set = list()
	var/total_fractures = 0

/datum/bone/proc/take_damage(var/amount)
	if(prob(100*(amount+damage)/resistance))
		damage += ((amount+damage)/resistance)
		var/temp = 100*(amount+damage)/resistance
		if(prob(temp))
			switch(temp)
				if(0)
					return
				if(0 to 60)
					fracture()
				if(60 to 110)
					if(prob(temp-60))
						fracture()
					else
						fracture("fractures")
				if(110 to 160)
					if(prob(temp-110))
						fracture("fractures")
					else
						fracture("compund")
				if(160 to 230)
					if(prob(temp-160))
						fracture("compound")
					else
						fracture("shattered")
				else
					fracture("shattered")

/datum/bone/proc/get_total_fractures()
	if(fractures["shattered"])
		return -1
	else
		return (fractures["hairline"] + fractures["fractures"] + fractures["compound"])

/datum/bone/proc/fracture(var/frac_type = "hairline", var/frac_number = 1)
	if(frac_type == "shattered")
		if(fractures["shattered"])
			return 0
		else
			fractures["shattered"]++
	else
		fractures[frac_type] += frac_number

	fracture_effect(frac_type)

/datum/bone/proc/worsen_fracture()
	if(!total_fractures)
		return 0//nothing to worsen

	var/fracture_class = pickweight(fractures)
	switch(fracture_class)
		if("hairline")
			fractures["hairline"]--
			fracture("fractures)
		if ("fractures")
			fractures["fractures"]--
			fracture("compund")
		if ("compound")
			fracture("shattered")
			//shattered means its completely fucked, you're not growing that back soon.
	return 1

/datum/bone/proc/fracture_effect(var/frac_type = "hairline")
	if(organ && organ.owner)
		switch(frac_type)
			if("hairline")
				if(prob(40))
					return

		organ.owner.visible_message(\
			"<span class='danger'>You hear a loud cracking sound coming from \the [organ.owner].</span>",\
			"<span class='danger'>Something feels like it shattered in your [organ.name]!</span>",\
			"<span class='danger'>You hear a sickening crack.</span>")
		jostle_bone()
		if(can_feel_pain())
			organ.owner.emote("scream")
		playsound(src.loc, "fracture", 100, 1, -2)


/datum/bone/proc/set_bone(var/frac_type = "hairline")
	if(fractures[shattered])
		return
	else
		return


//	status |= ORGAN_BROKEN

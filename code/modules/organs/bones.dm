/obj/item/bone
	name = "bone"
	icon = 'icons/obj/surgery.dmi'
	germ_level = 0

	// Strings.
	var/organ_tag = "bone"           // Unique identifier.
	var/parent_organ = BP_CHEST       // Organ holding this object.

	// Status tracking.
	var/damage = 0                    // Current damage to the organ
	var/breaks = 0                    // how many breaks it has
	var/breaks_to_shatter = 10        // how many breaks before it becomes shattered

	// Reference data.
	var/mob/living/carbon/human/owner // Current mob owning the organ.
	var/list/autopsy_data = list()    // Trauma data for forensics.

	// Damage vars.
	var/single_hit_break_min = 5     // Amount for it to even think about breaking in one hit.
	var/single_hit_break_max = 40     // Amount for it to certainly break in one hit.
	var/single_hit_break_min_chance = 0 //Chance for it to break at single_hit_break_min
	var/single_hit_shatter_min = 30     // Amount for it to even think about shattering in one hit.
	var/single_hit_shatter_max = 80     // Amount for it to certainly shatter in one hit.
	var/min_break_threshold = 15        //


	var/max_damage                    // Damage cap


/obj/item/organ/bone/proc/receive_damage(var/amount)
	switch(amount)
		if(single_hit_shatter_max to INFINITY)
			shatter()
		if(single_hit_break_min to single_hit_break_max)
			if(amount > single_hit_shatter_min)
		if(single_hit_break_max to INFINITY)
			fracture()






/obj/item/organ/bone/proc/chip()

/obj/item/organ/bone/proc/fracture()


/obj/item/organ/bone/proc/shatter()
	breaks=breaks_to_shatter
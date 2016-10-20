/datum/newling
	var/form = "impure"
	var/absorbtion = 0
	var/kit = "stealth"
	var/queuedkit = "stealth"
	var/queuedform = "impure"
	var/canmoult = 0 // 1=transform prepped, 2=newbody prepped
	var/mob/living/carbon/human/host = null
	var/vocalmimic = ""
	var/list/datum/lingform/forms = list()
	var/list/parasite_ignore= list(src)
	var/datum/mind/mind

/datum/newling_power


/datum/newling_power/proc/checknutrition(var/nutr)


/datum/newling_power/proc/usepower(var/nutr = 0, var/ignore_stat, var/mob/living/target = null)
	if(!checknutrition(nutr))
		return
	if(!ignore_stat && host.stat)
		return

/datum/newling_power/sting()
	var/stingtype
	switch(kit)
		if("stealth") //viral
			stingtype = /obj/item/weapon/changelingsting/viral
		if("defensive") //para
			stingtype = /obj/item/weapon/changelingsting/paralysis
		if("offensive") //toxic
			stingtype = /obj/item/weapon/changelingsting/toxin

	var/obj/item/weapon/changelingsting/stinger = new stingtype(host.loc)
	stinger.target = target
	stinger.throw_at(target)




/obj/item/weapon/changelingsting
	name = "barbed stinger"
	desc = "It looks like a massive stinger!"
	force = 1
	throw_speed = 50

	var/attached = 0
	var/stingtype = ""
	var/datum/reagents/holder
	var/mob/living/carbon/human/target

	New()

		holder = create_reagents(50)
		holder |= NOREACT
		switch (stingtype)
			if("paralysis")
				holder.add_reagent("potassium_chlorophoride",5)
				holder.add_reagent("chloralhydrate", 5)
				holder.add_reagent("inaprovaline", 20)
				holder.add_reagent("tricordrazine", 20)
			if("toxin")
				holder.add_reagent("toxin", 10)
				holder.add_reagent("amatoxin", 10)
				holder.add_reagent("carpotoxin", 10)
				holder.add_reagent("phoron", 5)
				holder.add_reagent("slimejelly", 5)
				holder.add_reagent("cryptobiolin", 10)

			if("viral")
				holder.add_reagent("transformation_toxin", 50)

			if(!"")
				qdel(src)
				return 0

		spawn(50) //give them a chance to get it out quick
			processing_objects.Add(src)

		return 1

/obj/item/weapon/changelingsting/process()
	if(!attached && target)
		if(target == src.loc)
			attached = 1
	else if((attached && src.loc != target) || !reagents.total_volume)
		processing_objects.Remove(src)
		return 0
	else
		holder.trans_to_mob(target, 2, CHEM_BLOOD)


/obj/item/weapon/changelingsting/paralysis
	stingtype = "paralysis"

/obj/item/weapon/changelingsting
	stingtype = "toxin"

/obj/item/weapon/changelingsting
	stingtype = "viral"



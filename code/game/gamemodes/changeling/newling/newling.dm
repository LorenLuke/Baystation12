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

	New()


	proc/check_nutrition(var/nut = 0)
		if( < nut)
			return 0
		return 1


/mob/proc/make_newling()
	if(!src.mind)				return
	if(!src.mind.changeling)
		src.mind.changeling = new /datum/newling()
		src.mind.changeling.mind = src.mind




/datum/newlingpower
	var/name = "name"
	var/desc = "description"
	var/lastused = 0
	var/datum/newling/owner

	New(var/owned)
		src.owner=owned


	proc/usepower(var/datum/newling/ling, var/mob/living/carbon/target)
		return



/datum/lingform
	var/name = ""
	var/species = ""
	var/datum/dna/DNA
	var/generalflavor = ""
	var/headflavor = ""
	var/faceflavor = ""
	var/eyeflavor = ""
	var/bodyflavor = ""
	var/armflavor = ""
	var/handflavor = ""
	var/legflavor = ""
	var/footflavor = ""

	New(var/newname, var/newspecies, var/newDNA, var/newgeneralflavor, var/newheadflavor, var/newfaceflavor, var/neweyeflavor, var/newbodyflavor, var/newarmflavor, var/newhandflavor, var/newlegflavor, var/newfootflavor)
		src.name = newname
		src.species = newspecies
		src.DNA = newDNA
		src.generalflavor = newgeneralflavor
		src.headflavor = newheadflavor
		src.faceflavor = newfaceflavor
		src.eyeflavor = neweyeflavor
		src.bodyflavor = newbodyflavor
		src.armflavor = newarmflavor
		src.handflavor = newhandflavor
		src.legflavor = newlegflavor
		src.footflavor = newfootflavor



/datum/newling/proc/caneat()
		var/list/bodypartscovered
		var/caneat = 1

		if(FACE in bodypartscovered)
			caneat= 0
		var/timetoeat = 30
		if(ling.form = "pure")
			timetoeat = 15
			if(ling.kit = "offensive")
				if(!UPPER_TORSO in bodypartscovered)
					caneat = 1
				timetoeat = 8

		else
			if()
				caneat = 1

		if(caneat)
			return timetoeat

		return 0


/datum/newling/proc/newlingdevour()

	if(host.stomach_contents.len)

		return 0

	var/eattime = caneat()
	if(!eattime)
		return 0

	var/obj/item/weapon/grab/G = src.get_active_hand()
	if(!istype(G))
		src << "<span class='warning'>We must be grabbing a creature in our active hand to absorb them.</span>"
		return 0

	if(G.state < GRAB_AGGRESSIVE)
		src << "<span class='warning'>We must have a better grip to absorb this creature.</span>"
		return 0

	src.visible_message("<span class='danger'>\The [host] is attempting to devour \the [victim]!</span>")
		if(!do_mob(src, victim, eattime))
			return 0
	src.visible_message("<span class='danger'>\The [host] devours \the [victim]!</span>")
	admin_attack_log(host, victim, "Devoured.", "Was devoured by.", "devoured")
	victim.forceMove(host)
	host.stomach_contents.Add(victim)




////////////
//////


/datum/newling/proc/newlingabsorb()

	if(HUSK in target.mutations)
		return 0


	var/name = target.name
	var/species = target.species
	var/datum/dna/DNA = target.dna
	var/generalflavor = target.flavor_texts["general"]
	var/headflavor = target.flavor_texts["head"]
	var/faceflavor = target.flavor_texts["face"]
	var/eyeflavor = target.flavor_texts["eyes"]
	var/bodyflavor = target.flavor_texts["torso"]
	var/armflavor = target.flavor_texts["arms"]
	var/handflavor = target.flavor_texts["hands"]
	var/legflavor = target.flavor_texts["legs"]
	var/footflavor = target.flavor_texts["feet"]

	var/datum/lingform = New(name, species, DNA, generalflavor, headflavor, faceflavor, eyeflavor, bodyflavor, armflavor, handflavor, legflavor, footflavor)
	src.forms.Add(lingform)
	if(target.client)
		src.absorbtion += 100
	else
		src.absorbtion += 25

	target.Drain()


/datum/newling/proc/armblade()
	usepower()

/datum/newling/proc/camouflage()


/datum/newling/proc/controlparasite()
	usepower()



/datum/newling/proc/deadmanswitch()
	usepower()
		if(owner.kit = "offensive" && owner.form = "pure")
			if(owner.host.stat = 2)
				//kersplode
			else
				//confirm then kersplode
		return 0





/datum/newling/proc/formbody
	usepower()



/datum/newling/proc/formlimb
	usepower()



/datum/newling/proc/dialysis
	usepower()




/datum/newling/proc/leap
	usepower()




/datum/newling/proc/moult
	if(canmoult == 1)

	else if(canmoult == 2)

	return 0

/datum/newling/proc/oxyconversion
	usepower()

/datum/newling/proc/radburst
	usepower()

/datum/newling/proc/regenerate
	usepower()

/datum/newling/proc/screech()


/datum/newling/proc/sliphandcuffs()


/datum/newling/proc/snare
	usepower()

/datum/newling/proc/spawnparasite
	usepower()

/datum/newling/proc/spawncluster


/datum/newling/proc/spine(var/mob/living/target)

	var/obj/item/projectile/bullet/spine = new(src)
	projectile.throw_at(target, 8, 3, src)


/datum/newling/proc/sting(var/mob/living/carbon/human/target, var/type = "")



/datum/newling/proc/ventcrawl
	usepower()

/datum/newling/proc/voicechange
	usepower()







/mob/living/carbon/human/purechan

/mob/living/simple_animal/headspider
	var/head




/obj/item/weapon/changelingsting
	name = "barbed stinger"
	desc = "It looks like a massive stinger!"
	throw_force = 50
	thrown_force_divisor = 0.1

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

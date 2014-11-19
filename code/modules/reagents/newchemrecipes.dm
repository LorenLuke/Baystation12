#define ANTIDEPRESSANT_MESSAGE_DELAY 5*60*10


///////////////////////////////////////////////////////////////////////////////////
datum/chemical_reaction
	var/name = null
	var/id = null
	var/result = null
	var/list/required_reagents = new/list()
	var/list/required_catalysts = new/list()

	// Both of these variables are mostly going to be used with slime cores - but if you want to, you can use them for other things
	var/atom/required_container = null // the container required for the reaction to happen
	var/required_other = 0 // an integer required for the reaction to happen

	var/result_amount = 0  //scheduled for obselescence outside on_reagent()
	var/secondary = 0 // set to nonzero if secondary reaction
	var/list/secondary_results = list()		//additional reagents produced by the reaction

	var/list/results = list() // format similar to required {list("reagent" = 1; "reactant" = 1)}

	var/requires_heating = 0 //the reaction can only take place in the bounds below
	var/temperature_lower_bound = 0
	var/temperature_upper_bound = 0

	var/requires_mixing = 0 //determines whether the reaction needs mixing (and if so, how much {0 = none, 1-5})
	var/requires_oxy = 0 //requires some sort of oxydizer
	var/requires_shock = 0 //required to be jarred to trigger (nitroglycerine), called when thrown, hit, exploded, or used as a weapon.-WIP


	var/energy_generated = 0 //In joules per necessary 1 units. use negative numbers for endothermic reactions
	var/instant = 0 //determines whether this reaction should take place instantaneously.
	var/stable = 1 // determines if the reaction can be stabilised by a stabilising agent
	var/visible = 1 //determines if the reaction is seen/heard

datum/chemical_reaction/proc/on_reaction_start(var/datum/reagents/holder)
	return

datum/chemical_reaction/proc/on_reaction_end(var/datum/reagents/holder, var/created_volume)
	return

datum/chemical_reaction/proc/on_reaction_tick(var/datum/reagents/holder, var/created_volume)
	return

		//I recommend you set the result amount to the total volume of all components.

datum/chemical_reaction/explosion_potassium
	name = "Explosion"
	id = "explosion_potassium"
	result = null
	required_reagents = list("water" = 1, "potassium" = 1)
	result_amount = 2
	instant = 1
	visible = 0
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(round (created_volume/10, 1), holder.my_atom, 0, 0)
		e.holder_damage(holder.my_atom)
		if(isliving(holder.my_atom))
			e.amount *= 0.5
			var/mob/living/L = holder.my_atom
			if(L.stat!=DEAD)
				e.amount *= 0.5
		e.start()

//Splash everyone around them?
		holder.handle_reactions(shock=1)
		sleep(2)
		holder.clear_reagents()

		return


datum/chemical_reaction/heroin
	name = "Space Heroin"
	id = "heroin"
	result = "heroin"
	required_reagents = list("oxycodone" = 1, "ethanol" = 1)
	result_amount = 1
//	results = list("heroin" = 1)

datum/chemical_reaction/emp_pulse
	name = "EMP Pulse"
	id = "emp_pulse"
	result = null
	required_reagents = list("uranium" = 1, "iron" = 1) // Yes, laugh, it's the best recipe I could think of that makes a little bit of sense
	result_amount = 2
	instant= 1
	visible = 0

	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		// 100 created volume = 4 heavy range & 7 light range. A few tiles smaller than traitor EMP grandes.
		// 200 created volume = 8 heavy range & 14 light range. 4 tiles larger than traitor EMP grenades.
		empulse(location, round(created_volume / 24), round(created_volume / 14), 1)
		return

/*
		silicate
			name = "Silicate"
			id = "silicate"
			result = "silicate"
			required_reagents = list("aluminum" = 1, "silicon" = 1, "oxygen" = 1)
			result_amount = 3
*/

datum/chemical_reaction/nitric_oxide
	name = "Nitric Oxide"
	id = "nitric_oxide"
	result = "nitric_oxide"
	results = list("nitric_oxide" = 1)
	result_amount = 1
	required_reagents = list("ammonia" = 1)
	required_catalysts = list("platinum" = 5)
	requires_oxy = 1
	requires_heating = 1
	temperature_upper_bound = T0C + 900
	temperature_lower_bound = T0C + 750
	results = list("nitric_oxide" = 1, "water" = 1)



datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	result = "stoxin"
	results = list("stoxin" = 1)
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	result_amount = 5

datum/chemical_reaction/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	result = "sterilizine"
	results = list("sterilizine" = 3)
	required_reagents = list("ethanol" = 1, "anti_toxin" = 1, "chlorine" = 1)
	result_amount = 3

datum/chemical_reaction/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	result = "inaprovaline"
	results = list("inaprovaline" = 3)
	required_reagents = list("oxygen" = 1, "carbon" = 1, "sugar" = 1)
	result_amount = 3

datum/chemical_reaction/anti_toxin
	name = "Dylovene"
	id = "anti_toxin"
	result = "anti_toxin"
	results = list("anti_toxin" = 3)
	required_reagents = list("silicon" = 1, "potassium" = 1, "nitrogen" = 1)
	result_amount = 3

datum/chemical_reaction/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	result = "mutagen"
	results = list("mutagen" = 3)
	required_reagents = list("radium" = 1, "phosphorus" = 1, "chlorine" = 1)
	result_amount = 3

datum/chemical_reaction/tramadol
	name = "Tramadol"
	id = "tramadol"
	result = "tramadol"
	results = list("tramadal" = 3)
	required_reagents = list("inaprovaline" = 1, "ethanol" = 1, "oxygen" = 1)
	result_amount = 3

datum/chemical_reaction/paracetamol
	name = "Paracetamol"
	id = "paracetamol"
	result = "paracetamol"
	results = list("paracetamol" = 3)
	required_reagents = list("tramadol" = 1, "sugar" = 1, "water" = 1)
	result_amount = 3

datum/chemical_reaction/oxycodone
	name = "Oxycodone"
	id = "oxycodone"
	result = "oxycodone"
	results = list("oxycodone" = 1)
	required_reagents = list("ethanol" = 1, "tramadol" = 1)
	required_catalysts = list("phoron" = 1)
	result_amount = 1

//datum/chemical_reaction/cyanide
//	name = "Cyanide"
//	id = "cyanide"
//	result = "cyanide"
//	results = list("cyanide" = 1)
//	required_reagents = list("hydrogen" = 1, "carbon" = 1, "nitrogen" = 1)
//	result_amount = 1

//datum/chemical_reaction/water //I can't believe we never had this.
//	name = "Water"
//	id = "water"
//	result = "water"
//	required_reagents = list("oxygen" = 1, "hydrogen" = 2)
//	result_amount = 1

datum/chemical_reaction/thermite
	name = "Thermite"
	id = "thermite"
	result = "thermite"
	results = list("thermite" = 3)
	required_reagents = list("aluminum" = 1, "iron" = 1, "oxygen" = 1)
	result_amount = 3

datum/chemical_reaction/lexorin
	name = "Lexorin"
	id = "lexorin"
	result = "lexorin"
	results = list("lexorin" = 3)
	required_reagents = list("phoron" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3

datum/chemical_reaction/space_drugs
	name = "Space Drugs"
	id = "space_drugs"
	result = "space_drugs"
	results = list("space_drugs" = 3)
	required_reagents = list("mercury" = 1, "sugar" = 1, "lithium" = 1)
	result_amount = 3

datum/chemical_reaction/lube
	name = "Space Lube"
	id = "lube"
	result = "lube"
	results = list("lube" = 4)
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 4

datum/chemical_reaction/pacid
	name = "Polytrinic acid"
	id = "pacid"
	result = "pacid"
	results = list("pacid" = 3)
	required_reagents = list("sacid" = 1, "chlorine" = 1, "potassium" = 1)
	result_amount = 3

datum/chemical_reaction/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	result = "synaptizine"
	results = list("synaptizine" = 3)
	required_reagents = list("sugar" = 1, "lithium" = 1, "water" = 1)
	result_amount = 3

datum/chemical_reaction/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	result = "hyronalin"
	results = list("hyronalin" = 2)
	required_reagents = list("radium" = 1, "anti_toxin" = 1)
	result_amount = 2

datum/chemical_reaction/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	result = "arithrazine"
	results = list("arithrazine" = 3)
	required_reagents = list("hyronalin" = 1, "hydrogen" = 1)
	result_amount = 2

datum/chemical_reaction/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	result = "impedrezene"
	results = list("impedrezene" = 2)
	required_reagents = list("mercury" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 2

datum/chemical_reaction/kelotane
	name = "Kelotane"
	id = "kelotane"
	result = "kelotane"
	results = list("kelotane" = 2)
	required_reagents = list("silicon" = 1, "carbon" = 1)
	result_amount = 2

datum/chemical_reaction/peridaxon
	name = "Peridaxon"
	id = "peridaxon"
	result = "peridaxon"
	results = list("peridaxon" = 2)
	required_reagents = list("bicaridine" = 2, "clonexadone" = 2)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	results = list("virusfood" = 5)
	required_reagents = list("water" = 1, "milk" = 1)
	result_amount = 5

datum/chemical_reaction/leporazine
	name = "Leporazine"
	id = "leporazine"
	result = "leporazine"
	results = list("leporazine" = 2)
	required_reagents = list("silicon" = 1, "copper" = 1)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

datum/chemical_reaction/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	result = "cryptobiolin"
	results = list("cryptobiolin" = 3)
	required_reagents = list("potassium" = 1, "oxygen" = 1, "sugar" = 1)
	result_amount = 3

datum/chemical_reaction/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	result = "tricordrazine"
	results = list("tricordrazine" = 2)
	required_reagents = list("inaprovaline" = 1, "anti_toxin" = 1)
	result_amount = 2

datum/chemical_reaction/alkysine
	name = "Alkysine"
	id = "alkysine"
	result = "alkysine"
	results = list("alkysine" = 2)
	required_reagents = list("chlorine" = 1, "nitrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

datum/chemical_reaction/dexalin
	name = "Dexalin"
	id = "dexalin"
	result = "dexalin"
	results = list("dexalin" = 1)
	required_reagents = list("oxygen" = 2, "phoron" = 0.1)
	required_catalysts = list("phoron" = 5)
	result_amount = 1

datum/chemical_reaction/dermaline
	name = "Dermaline"
	id = "dermaline"
	result = "dermaline"
	results = list("dermaline" = 3)
	required_reagents = list("oxygen" = 1, "phosphorus" = 1, "kelotane" = 1)
	result_amount = 3

datum/chemical_reaction/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	result = "dexalinp"
	results = list("dexalinp" = 3)
	required_reagents = list("dexalin" = 1, "carbon" = 1, "iron" = 1)
	result_amount = 3

datum/chemical_reaction/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	result = "bicaridine"
	results = list("bicaridine" = 2)
	required_reagents = list("inaprovaline" = 1, "carbon" = 1)
	result_amount = 2

datum/chemical_reaction/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	result = "hyperzine"
	results = list("hyperzine" = 3)
	required_reagents = list("sugar" = 1, "phosphorus" = 1, "sulfur" = 1,)
	result_amount = 3

datum/chemical_reaction/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	result = "ryetalyn"
	results = list("ryetalyn" = 3)
	required_reagents = list("arithrazine" = 1, "carbon" = 1)
	result_amount = 2

datum/chemical_reaction/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	result = "cryoxadone"
	results = list("cryoxadone" = 3)
	required_reagents = list("dexalin" = 1, "water" = 1, "oxygen" = 1)
	result_amount = 3

datum/chemical_reaction/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	result = "clonexadone"
	results = list("clonexadone" = 2)
	required_reagents = list("cryoxadone" = 1, "sodium" = 1, "phoron" = 0.1)
	required_catalysts = list("phoron" = 5)
	result_amount = 2

datum/chemical_reaction/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	result = "spaceacillin"
	results = list("spaceacillin" = 2)
	required_reagents = list("cryptobiolin" = 1, "inaprovaline" = 1)
	result_amount = 2

datum/chemical_reaction/imidazoline
	name = "imidazoline"
	id = "imidazoline"
	result = "imidazoline"
	required_reagents = list("carbon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 2

datum/chemical_reaction/ethylredoxrazine
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	result = "ethylredoxrazine"
	results = list("ethylredoxrazine" = 3)
	required_reagents = list("oxygen" = 1, "anti_toxin" = 1, "carbon" = 1)
	result_amount = 3

datum/chemical_reaction/ethanoloxidation
	name = "ethanoloxidation"	//Kind of a placeholder in case someone ever changes it so that chemicals
	id = "ethanoloxidation"		//	react in the body. Also it would be silly if it didn't exist.
	result = "water"
	results = list("water" = 2)
	required_reagents = list("ethylredoxrazine" = 1, "ethanol" = 1)
	result_amount = 2

datum/chemical_reaction/glycerol
	name = "Glycerol"
	id = "glycerol"
	result = "glycerol"
	results = list("glycerol" = 1)
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	result_amount = 1

datum/chemical_reaction/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	result = "nitroglycerin"
	results = list("nitroglycerin" = 2)
	required_reagents = list("glycerol" = 1, "pacid" = 1, "sacid" = 1)
	result_amount = 2

datum/chemical_reaction/nitroglycerin_explosion
	name = "Nitroglycerin_explosion"
	id = "nitroglycerin_explosion"
	result = null
	required_reagents = list("nitroglycerin" = 1)
	result_amount = 1
	instant = 1
	requires_shock = 1

	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(round (created_volume/2, 0.5), holder.my_atom, 0, 0)
		e.holder_damage(holder.my_atom)
		if(isliving(holder.my_atom))
			e.amount *= 0.5
			var/mob/living/L = holder.my_atom
			if(L.stat!=DEAD)
				e.amount *= 0.5
		e.start()

		holder.handle_reactions(shock=1)
		sleep(2)
		holder.clear_reagents()
		return

datum/chemical_reaction/sodiumchloride
	name = "Sodium Chloride"
	id = "sodiumchloride"
	result = "sodiumchloride"
	results = list("sodiumchloride" = 1)
	required_reagents = list("sodium" = 1, "chlorine" = 1)
	result_amount = 2

datum/chemical_reaction/flash_powder
	name = "Flash powder"
	id = "flash_powder"
	result = null
	required_reagents = list("aluminum" = 1, "potassium" = 1, "sulfur" = 1 )
	result_amount = null
	instant = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, location)
		s.start()
		for(var/mob/living/carbon/M in viewers(world.view, location))
			switch(get_dist(M, location))
				if(0 to 3)
					if(hasvar(M, "glasses"))
						if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
							continue

					flick("e_flash", M.flash)
					M.Weaken(15)

				if(4 to 5)
					if(hasvar(M, "glasses"))
						if(istype(M:glasses, /obj/item/clothing/glasses/sunglasses))
							continue

					flick("e_flash", M.flash)
					M.Stun(5)

datum/chemical_reaction/napalm
	name = "Napalm"
	id = "napalm"
	result = "napalm"
	results = list("napalm" = 1)
	required_reagents = list("aluminum" = 1, "phoron" = 1, "sacid" = 1 )
	result_amount = 1

datum/chemical_reaction/napalmburn
	name = "Napalm"
	id = "napalmburn"
	result = null
	required_reagents = list("napalm" = 1 )
	result_amount = 1
	instant = 1
	visible = 0
	requires_heating = 1
	temperature_upper_bound = INFINITY
	temperature_lower_bound = T0C + 150
	on_reaction_tick(var/datum/reagents/holder, var/created_volume)
		var/turf/location = get_turf(holder.my_atom.loc)
		for(var/turf/simulated/floor/target_tile in range(0,location))
			target_tile.assume_gas("volatile_fuel", created_volume, 400+T0C)
			spawn (0) target_tile.hotspot_expose(700, 400)
		holder.del_reagent("napalm")
		return

/*
datum/chemical_reaction/smoke
	name = "Smoke"
	id = "smoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1 )
	result_amount = null
	secondary = 1
	on_reaction(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		var/datum/effect/system/bad_smoke_spread/S = new /datum/effect/system/bad_smoke_spread
		S.attach(location)
		S.set_up(10, 0, location)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
			sleep(10)
			S.start()
			sleep(10)
			S.start()
			sleep(10)
			S.start()
			sleep(10)
			S.start()
		holder.clear_reagents()
		return	*/

datum/chemical_reaction/chemsmoke
	name = "Chemsmoke"
	id = "chemsmoke"
	result = null
	required_reagents = list("potassium" = 1, "sugar" = 1, "phosphorus" = 1)
	result_amount = 0.4
	secondary = 1
	instant = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		var/datum/effect/effect/system/smoke_spread/chem/S = new /datum/effect/effect/system/smoke_spread/chem
		S.attach(location)
		S.set_up(holder, created_volume, 0, location)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		spawn(0)
			S.start()
		holder.clear_reagents()
		return

datum/chemical_reaction/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	result = "chloralhydrate"
	required_reagents = list("ethanol" = 1, "chlorine" = 3, "water" = 1)
	result_amount = 1

datum/chemical_reaction/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	result = "potassium_chloride"
	required_reagents = list("sodiumchloride" = 1, "potassium" = 1)
	result_amount = 2

datum/chemical_reaction/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	result = "potassium_chlorophoride"
	required_reagents = list("potassium_chloride" = 1, "phoron" = 1, "chloralhydrate" = 1)
	result_amount = 4

datum/chemical_reaction/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	result = "stoxin"
	required_reagents = list("chloralhydrate" = 1, "sugar" = 4)
	result_amount = 5

datum/chemical_reaction/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	result = "zombiepowder"
	required_reagents = list("carpotoxin" = 5, "stoxin" = 5, "copper" = 5)
	result_amount = 2

datum/chemical_reaction/rezadone
	name = "Rezadone"
	id = "rezadone"
	result = "rezadone"
	required_reagents = list("carpotoxin" = 1, "cryptobiolin" = 1, "copper" = 1)
	result_amount = 3

datum/chemical_reaction/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	result = "mindbreaker"
	required_reagents = list("silicon" = 1, "hydrogen" = 1, "anti_toxin" = 1)
	result_amount = 3

datum/chemical_reaction/lipozine
	name = "Lipozine"
	id = "Lipozine"
	result = "lipozine"
	required_reagents = list("sodiumchloride" = 1, "ethanol" = 1, "radium" = 1)
	result_amount = 3

datum/chemical_reaction/phoronsolidification
	name = "Solid Phoron"
	id = "solidphoron"
	result = null
	required_reagents = list("iron" = 5, "frostoil" = 5, "phoron" = 20)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/stack/sheet/mineral/phoron(location)
		return

datum/chemical_reaction/plastication
	name = "Plastic"
	id = "solidplastic"
	result = null
	required_reagents = list("pacid" = 10, "plasticide" = 20)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder)
		new /obj/item/stack/sheet/mineral/plastic(get_turf(holder.my_atom),10)
		return

datum/chemical_reaction/virus_food
	name = "Virus Food"
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 5, "milk" = 5, "oxygen" = 5)
	result_amount = 15
/*
datum/chemical_reaction/mix_virus
	name = "Mix Virus"
	id = "mixvirus"
	result = "blood"
	required_reagents = list("virusfood" = 5)
	required_catalysts = list("blood")
	var/level = 2

	on_reaction(var/datum/reagents/holder, var/created_volume)

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
		if(B && B.data)
			var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
			if(D)
				D.Evolve(level - rand(0, 1))


datum/chemical_reaction/mix_virus_2

	name = "Mix Virus 2"
	id = "mixvirus2"
	required_reagents = list("mutagen" = 5)
	level = 4

datum/chemical_reaction/rem_virus

	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("synaptizine" = 5)

	on_reaction(var/datum/reagents/holder, var/created_volume)

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
		if(B && B.data)
			var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
			if(D)
				D.Devolve()
*/
datum/chemical_reaction/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("phoron" = 5)
	result_amount = 1
///////////////////////////////////////////////////////////////////////////////////

//  Added antidepressants from other file here


/datum/reagent/antidepressant/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	description = "Improves the ability to concentrate."
	reagent_state = LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(src.volume <= 0.1) if(data != -1)
			data = -1
			M << "\red You lose focus.."
		else
			if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
				data = world.time
				M << "\blue Your mind feels focused and undivided."
		..()
		return

/datum/chemical_reaction/methylphenidate
	name = "Methylphenidate"
	id = "methylphenidate"
	result = "methylphenidate"
	required_reagents = list("mindbreaker" = 1, "hydrogen" = 1)
	result_amount = 3

/datum/reagent/antidepressant/citalopram
	name = "Citalopram"
	id = "citalopram"
	description = "Stabilizes the mind a little."
	reagent_state = LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(src.volume <= 0.1) if(data != -1)
			data = -1
			M << "\red Your mind feels a little less stable.."
		else
			if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
				data = world.time
				M << "\blue Your mind feels stable.. a little stable."
		..()
		return

/datum/chemical_reaction/citalopram
	name = "Citalopram"
	id = "citalopram"
	result = "citalopram"
	required_reagents = list("mindbreaker" = 1, "carbon" = 1)
	result_amount = 3


/datum/reagent/antidepressant/paroxetine
	name = "Paroxetine"
	id = "paroxetine"
	description = "Stabilizes the mind greatly, but has a chance of adverse effects."
	reagent_state = LIQUID
	color = "#C8A5DC"
	custom_metabolism = 0.01
	data = 0

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(src.volume <= 0.1) if(data != -1)
			data = -1
			M << "\red Your mind feels much less stable.."
		else
			if(world.time > data + ANTIDEPRESSANT_MESSAGE_DELAY)
				data = world.time
				if(prob(90))
					M << "\blue Your mind feels much more stable."
				else
					M << "\red Your mind breaks apart.."
					M.hallucination += 200
		..()
		return

/datum/chemical_reaction/paroxetine
	name = "Paroxetine"
	id = "paroxetine"
	result = "paroxetine"
	required_reagents = list("mindbreaker" = 1, "oxygen" = 1, "inaprovaline" = 1)
	result_amount = 3




///////////////////////////////////////////////////////////////////////////////////













// foam and foam precursor

datum/chemical_reaction/surfactant
	name = "Foam surfactant"
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
	result_amount = 5


datum/chemical_reaction/foam
	name = "Foam"
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	result_amount = 2
	instant = 1

	on_reaction_end(var/datum/reagents/holder, var/created_volume)


		var/location = get_turf(holder.my_atom)
		for(var/mob/M in viewers(5, location))
			M << "\red The solution violently bubbles!"

		location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			M << "\red The solution spews out foam!"

		//world << "Holder volume is [holder.total_volume]"
		//for(var/datum/reagent/R in holder.reagent_list)
		//	world << "[R.name] = [R.volume]"

		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 0)
		s.start()
		holder.clear_reagents()
		return

datum/chemical_reaction/metalfoam
	name = "Metal Foam"
	id = "metalfoam"
	result = null
	required_reagents = list("aluminum" = 3, "foaming_agent" = 1, "pacid" = 1)
	result_amount = 5
	instant = 1

	on_reaction_end(var/datum/reagents/holder, var/created_volume)


		var/location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			M << "\red The solution spews out a metalic foam!"

		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 1)
		s.start()
		return

datum/chemical_reaction/ironfoam
	name = "Iron Foam"
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "foaming_agent" = 1, "pacid" = 1)
	result_amount = 5
	instant = 1

	on_reaction_end(var/datum/reagents/holder, var/created_volume)


		var/location = get_turf(holder.my_atom)

		for(var/mob/M in viewers(5, location))
			M << "\red The solution spews out a metalic foam!"

		var/datum/effect/effect/system/foam_spread/s = new()
		s.set_up(created_volume, location, holder, 2)
		s.start()
		return



datum/chemical_reaction/foaming_agent
	name = "Foaming Agent"
	id = "foaming_agent"
	result = "foaming_agent"
	required_reagents = list("lithium" = 1, "hydrogen" = 1)
	result_amount = 1


datum/chemical_reaction/halon
	name = "Halon"
	id = "halon"
	result = "halon"
	required_reagents = list("carbon" = 1, "hydrogen" = 2, "fluorine" = 1)
	result_amount = 2

		// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
datum/chemical_reaction/ammonia
	name = "Ammonia"
	id = "ammonia"
	result = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	result_amount = 3

datum/chemical_reaction/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	result_amount = 2

datum/chemical_reaction/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1)
	result_amount = 2

datum/chemical_reaction/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	result = "plantbgone"
	required_reagents = list("toxin" = 1, "water" = 4)
	result_amount = 5


/////////////////////////////////////////////NEW SLIME CORE REACTIONS/////////////////////////////////////////////

//Grey
datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red Infused with phoron, the core begins to quiver and grow, and soon a new baby slime emerges from it!"), 1)
		var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
		S.loc = get_turf(holder.my_atom)


datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	result = null
	required_reagents = list("blood" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/grey
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/i = 1, i <= 3, i++)
			var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
			M.loc = get_turf(holder.my_atom)

//Green
datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	result = "mutationtoxin"
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/green

//Metal
datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/metal
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		var/obj/item/stack/sheet/metal/M = new /obj/item/stack/sheet/metal
		M.amount = 15
		M.loc = get_turf(holder.my_atom)
		var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
		P.amount = 5
		P.loc = get_turf(holder.my_atom)

//Gold
datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/gold
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)

		/*var/blocked = list(/mob/living/simple_animal/hostile,
			/mob/living/simple_animal/hostile/pirate,
			/mob/living/simple_animal/hostile/pirate/ranged,
			/mob/living/simple_animal/hostile/russian,
			/mob/living/simple_animal/hostile/russian/ranged,
			/mob/living/simple_animal/hostile/syndicate,
			/mob/living/simple_animal/hostile/syndicate/melee,
			/mob/living/simple_animal/hostile/syndicate/melee/space,
			/mob/living/simple_animal/hostile/syndicate/ranged,
			/mob/living/simple_animal/hostile/syndicate/ranged/space,
			/mob/living/simple_animal/hostile/alien/queen/large,
			/mob/living/simple_animal/hostile/faithless,
			/mob/living/simple_animal/hostile/panther,
			/mob/living/simple_animal/hostile/snake,
			/mob/living/simple_animal/hostile/retaliate,
			/mob/living/simple_animal/hostile/retaliate/clown
			)//exclusion list for things you don't want the reaction to create.
		var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
			if(M:eyecheck() <= 0)
				flick("e_flash", M.flash)

		for(var/i = 1, i <= 5, i++)
			var/chosen = pick(critters)
			var/mob/living/simple_animal/hostile/C = new chosen
			C.faction = "slimesummon"
			C.loc = get_turf(holder.my_atom)
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(C, pick(NORTH,SOUTH,EAST,WEST))*/
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red The slime core fizzles disappointingly,"), 1)

//Silver
datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/silver
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)

		var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - /obj/item/weapon/reagent_containers/food/snacks
		// BORK BORK BORK

		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

		for(var/mob/living/carbon/human/M in viewers(get_turf(holder.my_atom), null))
			if(M:eyecheck() <= 0)
				flick("e_flash", M.flash)

		for(var/i = 1, i <= 4 + rand(1,2), i++)
			var/chosen = pick(borks)
			var/obj/B = new chosen
			if(B)
				B.loc = get_turf(holder.my_atom)
				if(prob(50))
					for(var/j = 1, j <= rand(1, 3), j++)
						step(B, pick(NORTH,SOUTH,EAST,WEST))


//Blue
datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	result = "frostoil"
	required_reagents = list("phoron" = 5)
	result_amount = 10
	required_container = /obj/item/slime_extract/blue
	required_other = 1
//Dark Blue
datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
		sleep(50)
		playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
			M.bodytemperature -= 140
			M << "\blue You feel a chill!"

//Orange
datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	result = "capsaicin"
	required_reagents = list("blood" = 5)
	result_amount = 10
	required_container = /obj/item/slime_extract/orange
	required_other = 1

datum/chemical_reaction/slimefire
	name = "Slime fire"
	id = "m_fire"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/orange
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
		sleep(50)
		var/turf/location = get_turf(holder.my_atom.loc)
		for(var/turf/simulated/floor/target_tile in range(0,location))
			target_tile.assume_gas("phoron", 25, 1400)
			spawn (0) target_tile.hotspot_expose(700, 400)

//Yellow
datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	result = null
	required_reagents = list("blood" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		empulse(get_turf(holder.my_atom), 3, 7)


datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/obj/item/weapon/cell/slime/P = new /obj/item/weapon/cell/slime
		P.loc = get_turf(holder.my_atom)

datum/chemical_reaction/slimeglow
	name = "Slime Glow"
	id = "m_glow"
	result = null
	required_reagents = list("water" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/yellow
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red The contents of the slime core harden and begin to emit a warm, bright light."), 1)
		var/obj/item/device/flashlight/slime/F = new /obj/item/device/flashlight/slime
		F.loc = get_turf(holder.my_atom)

//Purple

datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/purple
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
		P.loc = get_turf(holder.my_atom)



datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	result = "slimejelly"
	required_reagents = list("sugar" = 5)
	result_amount = 10
	required_container = /obj/item/slime_extract/purple
	required_other = 1


//Dark Purple
datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		var/obj/item/stack/sheet/mineral/phoron/P = new /obj/item/stack/sheet/mineral/phoron
		P.amount = 10
		P.loc = get_turf(holder.my_atom)

//Red
datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	result = "glycerol"
	required_reagents = list("phoron" = 5)
	result_amount = 8
	required_container = /obj/item/slime_extract/red
	required_other = 1


datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	result = null
	required_reagents = list("blood" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/red
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
			slime.rabid = 1
			for(var/mob/O in viewers(get_turf(holder.my_atom), null))
				O.show_message(text("\red The [slime] is driven into a frenzy!."), 1)

//Pink
datum/chemical_reaction/slimeppotion
	name = "Slime Potion"
	id = "m_potion"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/pink
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
		P.loc = get_turf(holder.my_atom)


//Black
datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	result = "amutationtoxin"
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_other = 1
	required_container = /obj/item/slime_extract/black

//Oil
datum/chemical_reaction/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/oil
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		for(var/mob/O in viewers(get_turf(holder.my_atom), null))
			O.show_message(text("\red The slime extract begins to vibrate violently !"), 1)
		sleep(50)
		explosion(get_turf(holder.my_atom), 1 ,3, 6)

//Light Pink
datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	result = null
	result_amount = 1
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("phoron" = 5)
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
		P.loc = get_turf(holder.my_atom)

//Adamantine
datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	result = null
	required_reagents = list("phoron" = 5)
	result_amount = 1
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1
	on_reaction_end(var/datum/reagents/holder)
		var/obj/effect/golemrune/Z = new /obj/effect/golemrune
		Z.loc = get_turf(holder.my_atom)
		Z.announce_to_ghosts()

//////////////////////////////////////////FOOD MIXTURES////////////////////////////////////

datum/chemical_reaction/tofu
	name = "Tofu"
	id = "tofu"
	result = null
	required_reagents = list("soymilk" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/tofu(location)
		return

datum/chemical_reaction/chocolate_bar
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("soymilk" = 2, "coco" = 2, "sugar" = 2)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
		return

datum/chemical_reaction/chocolate_bar2
	name = "Chocolate Bar"
	id = "chocolate_bar"
	result = null
	required_reagents = list("milk" = 2, "coco" = 2, "sugar" = 2)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		for(var/i = 1, i <= created_volume, i++)
			new /obj/item/weapon/reagent_containers/food/snacks/chocolatebar(location)
		return

datum/chemical_reaction/hot_coco
	name = "Hot Coco"
	id = "hot_coco"
	result = "hot_coco"
	required_reagents = list("water" = 5, "coco" = 1)
	result_amount = 5

datum/chemical_reaction/soysauce
	name = "Soy Sauce"
	id = "soysauce"
	result = "soysauce"
	required_reagents = list("soymilk" = 4, "sacid" = 1)
	result_amount = 5

datum/chemical_reaction/cheesewheel
	name = "Cheesewheel"
	id = "cheesewheel"
	result = null
	required_reagents = list("milk" = 40)
	required_catalysts = list("enzyme" = 5)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/weapon/reagent_containers/food/snacks/sliceable/cheesewheel(location)
		return

datum/chemical_reaction/syntiflesh
	name = "Syntiflesh"
	id = "syntiflesh"
	result = null
	required_reagents = list("blood" = 5, "clonexadone" = 1)
	result_amount = 1
	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/location = get_turf(holder.my_atom)
		new /obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh(location)
		return

datum/chemical_reaction/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	result = "hot_ramen"
	required_reagents = list("water" = 1, "dry_ramen" = 3)
	result_amount = 3

datum/chemical_reaction/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	result = "hell_ramen"
	required_reagents = list("capsaicin" = 1, "hot_ramen" = 6)
	result_amount = 6


////////////////////////////////////////// COCKTAILS //////////////////////////////////////


datum/chemical_reaction/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	result = "goldschlager"
	results = list("goldshlager" = 10)
	required_reagents = list("vodka" = 10, "gold" = 1)
	result_amount = 10
	requires_mixing = 1

datum/chemical_reaction/patron
	name = "Patron"
	id = "patron"
	result = "patron"
	results = list("patron" = 10)
	required_reagents = list("tequilla" = 10, "silver" = 1)
	result_amount = 10
	requires_mixing = 1

datum/chemical_reaction/bilk
	name = "Bilk"
	id = "bilk"
	result = "bilk"
	results = list("bilk" = 2)
	required_reagents = list("milk" = 1, "beer" = 1)
	result_amount = 2

/*
datum/chemical_reaction/icetea
	name = "Iced Tea"
	id = "icetea"
	result = "icetea"
	required_reagents = list("ice" = 1, "tea" = 3)
	result_amount = 4
*/
/*
datum/chemical_reaction/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	result = "icecoffee"
	required_reagents = list("ice" = 1, "coffee" = 3)
	result_amount = 4
*/

datum/chemical_reaction/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	result = "nuka_cola"
	results = list("nuka_cola" = 6)
	required_reagents = list("uranium" = 1, "cola" = 6)
	result_amount = 6
	requires_mixing = 3

datum/chemical_reaction/moonshine
	name = "Moonshine"
	id = "moonshine"
	result = "moonshine"
	results = list("moonshine" = 10)
	required_reagents = list("nutriment" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10


datum/chemical_reaction/grenadine
	name = "Grenadine Syrup"
	id = "grenadine"
	result = "grenadine"
	results = list("grenadine" = 10)
	required_reagents = list("berryjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/wine
	name = "Wine"
	id = "wine"
	result = "wine"
	results = list("wine" = 10)
	required_reagents = list("grapejuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/pwine
	name = "Poison Wine"
	id = "pwine"
	result = "pwine"
	results = list("pwine" = 10)
	required_reagents = list("poisonberryjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/melonliquor
	name = "Melon Liquor"
	id = "melonliquor"
	result = "melonliquor"
	results = list("melonliquor" = 10)
	required_reagents = list("watermelonjuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	result = "bluecuracao"
	results = list("blucuracao" = 10)
	required_reagents = list("orangejuice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/spacebeer
	name = "Space Beer"
	id = "spacebeer"
	result = "beer"
	results = list("beer" = 10)
	required_reagents = list("cornoil" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/vodka
	name = "Vodka"
	id = "vodka"
	result = "vodka"
	results = list("vodka" = 10)
	required_reagents = list("potato" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/sake
	name = "Sake"
	id = "sake"
	result = "sake"
	results = list("sake" = 10)
	required_reagents = list("rice" = 10)
	required_catalysts = list("enzyme" = 5)
	result_amount = 10

datum/chemical_reaction/kahlua
	name = "Kahlua"
	id = "kahlua"
	result = "kahlua"
	results = list("kahlua" = 5)
	required_reagents = list("coffee" = 5, "sugar" = 5)
	required_catalysts = list("enzyme" = 5)
	result_amount = 5
	requires_mixing = 1

datum/chemical_reaction/gin_tonic
	name = "Gin and Tonic"
	id = "gintonic"
	result = "gintonic"
	results = list("gintonic" = 3)
	required_reagents = list("gin" = 2, "tonic" = 1)
	result_amount = 3
	requires_mixing = 2

datum/chemical_reaction/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	result = "cubalibre"
	results = list("cubalibre" = 3)
	required_reagents = list("rum" = 2, "cola" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/martini
	name = "Classic Martini"
	id = "martini"
	result = "martini"
	results = list("martini" = 3)
	required_reagents = list("gin" = 2, "vermouth" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	result = "vodkamartini"
	results = list("vodkamartini" = 3)
	required_reagents = list("vodka" = 2, "vermouth" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/white_russian
	name = "White Russian"
	id = "whiterussian"
	result = "whiterussian"
	results = list("whiterussian" = 5)
	required_reagents = list("blackrussian" = 3, "cream" = 2)
	result_amount = 5


datum/chemical_reaction/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	result = "whiskeycola"
	results = list("whiskeycola" = 3)
	required_reagents = list("whiskey" = 2, "cola" = 1)
	result_amount = 3

datum/chemical_reaction/screwdriver
	name = "Screwdriver"
	id = "screwdrivercocktail"
	result = "screwdrivercocktail"
	results = list("screwdrivercocktail" = 3)
	required_reagents = list("vodka" = 2, "orangejuice" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	result = "bloodymary"
	results = list("bloodymary" = 4)
	required_reagents = list("vodka" = 1, "tomatojuice" = 2, "limejuice" = 1)
	result_amount = 4
	requires_mixing = 1

datum/chemical_reaction/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	result = "gargleblaster"
	results = list("gargleblaster" = 5)
	required_reagents = list("vodka" = 1, "gin" = 1, "whiskey" = 1, "cognac" = 1, "lemonjuice" = 1)
	result_amount = 5
	requires_mixing = 2

datum/chemical_reaction/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	result = "bravebull"
	results = list("bravebull" = 3)
	required_reagents = list("tequilla" = 2, "kahlua" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/tequilla_sunrise
	name = "Tequilla Sunrise"
	id = "tequillasunrise"
	result = "tequillasunrise"
	results = list("tequillasunrise" = 3)
	required_reagents = list("tequilla" = 2, "orangejuice" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/phoron_special
	name = "Toxins Special"
	id = "phoronspecial"
	result = "phoronspecial"
	results = list("phoronspecial" = 5)
	required_reagents = list("rum" = 2, "vermouth" = 1, "phoron" = 2)
	result_amount = 5
	requires_mixing = 2

datum/chemical_reaction/beepsky_smash
	name = "Beepksy Smash"
	id = "beepksysmash"
	result = "beepskysmash"
	results = list("beepskysmash" = 4)
	required_reagents = list("limejuice" = 2, "whiskey" = 2, "iron" = 1)
	result_amount = 4
	requires_mixing = 3

datum/chemical_reaction/doctor_delight
	name = "The Doctor's Delight"
	id = "doctordelight"
	result = "doctorsdelight"
	results = list("doctorsdelight" = 5)
	required_reagents = list("limejuice" = 1, "tomatojuice" = 1, "orangejuice" = 1, "cream" = 1, "tricordrazine" = 1)
	result_amount = 5
	requires_mixing = 2

datum/chemical_reaction/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	result = "irishcream"
	results = list("irishcream" = 3)
	required_reagents = list("whiskey" = 2, "cream" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	result = "manlydorf"
	results = list("manlydorf" = 3)
	required_reagents = list ("beer" = 1, "ale" = 2)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/hooch
	name = "Hooch"
	id = "hooch"
	result = "hooch"
	results = list("hooch" = 3)
	required_reagents = list ("sugar" = 1, "ethanol" = 2, "fuel" = 1)
	result_amount = 3
	requires_mixing = 3

datum/chemical_reaction/irish_coffee
	name = "Irish Coffee"
	id = "irishcoffee"
	result = "irishcoffee"
	results = list("irishcoffee" = 2)
	required_reagents = list("irishcream" = 1, "coffee" = 1)
	result_amount = 2

datum/chemical_reaction/b52
	name = "B-52"
	id = "b52"
	result = "b52"
	results = list("b52" = 3)
	required_reagents = list("irishcream" = 1, "kahlua" = 1, "cognac" = 1)
	result_amount = 3

datum/chemical_reaction/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	result = "atomicbomb"
	required_reagents = list("b52" = 10, "uranium" = 1)
	result_amount = 10
	requires_mixing = 1

datum/chemical_reaction/margarita
	name = "Margarita"
	id = "margarita"
	result = "margarita"
	results = list("margarita" = 3)
	required_reagents = list("tequilla" = 2, "limejuice" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	result = "longislandicedtea"
	results = list("longislandicedtea" = 4)
	required_reagents = list("vodka" = 1, "gin" = 1, "tequilla" = 1, "cubalibre" = 1)
	result_amount = 4
	requires_mixing = 1

datum/chemical_reaction/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	result = "threemileisland"
	results = list("threemileisland" = 10)
	required_reagents = list("longislandicedtea" = 10, "uranium" = 1)
	result_amount = 10
	requires_mixing = 1


datum/chemical_reaction/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	result = "whiskeysoda"
	results = list("whiskeysoda" = 3)
	required_reagents = list("whiskey" = 2, "sodawater" = 1)
	result_amount = 3

datum/chemical_reaction/black_russian
	name = "Black Russian"
	id = "blackrussian"
	result = "blackrussian"
	results = list("blackrussian" = 5)
	required_reagents = list("vodka" = 3, "kahlua" = 2)
	result_amount = 5

datum/chemical_reaction/manhattan
	name = "Manhattan"
	id = "manhattan"
	result = "manhattan"
	results = list("manhattan" = 3)
	required_reagents = list("whiskey" = 2, "vermouth" = 1)
	result_amount = 3

datum/chemical_reaction/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	result = "manhattan_proj"
	results = list("manhattan_proj" = 10)
	required_reagents = list("manhattan" = 10, "uranium" = 1)
	result_amount = 10
	requires_mixing = 1

datum/chemical_reaction/vodka_tonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	result = "vodkatonic"
	results = list("vodkatonic" = 3)
	required_reagents = list("vodka" = 2, "tonic" = 1)
	result_amount = 3

datum/chemical_reaction/gin_fizz
	name = "Gin Fizz"
	id = "ginfizz"
	result = "ginfizz"
	results = list("ginfizz" = 4)
	required_reagents = list("gin" = 2, "sodawater" = 1, "limejuice" = 1)
	result_amount = 4
	requires_mixing = 1

datum/chemical_reaction/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	result = "bahama_mama"
	results = list("bahama_mama" = 6)
	required_reagents = list("rum" = 2, "orangejuice" = 2, "limejuice" = 1, "ice" = 1)
	result_amount = 6
	requires_mixing = 2

datum/chemical_reaction/singulo
	name = "Singulo"
	id = "singulo"
	result = "singulo"
	results = list("singulo" = 10)
	required_reagents = list("vodka" = 5, "radium" = 1, "wine" = 5)
	result_amount = 10
	requires_mixing = 3

	on_reaction_end(var/datum/reagents/holder, var/created_volume)
//		if(prob(0.5*(created_volume/5)))
		if(1)

			sleep(10 + rand(5)**2)
			var/list/seen = viewers(4, get_turf(holder.my_atom))
			for(var/mob/M in seen)
				M << "\red \icon[holder.my_atom] The drink begins to vibrate slightly..."
				spawn(10)
					M << "\red \icon[holder.my_atom] You feel something pulling you towards the drink!"
			sleep(10)
			for(var/i = 1, i < 8, i++)
//				if(prob(20))
//					var/location = get_turf(holder.my_atom)
//					empulse(location, rand(2), 2 + rand(2))
//					if(prob(15))
//						continue

				for(var/atom/X in orange(round((i*3)**0.5,1), get_turf(holder.my_atom)))
					// Movable atoms only
					if(istype(X, /atom/movable))
						if(is_type_in_list(X, uneatable))	continue
						if((X) &&(!X:anchored) && (!istype(X,/mob/living/carbon/human)))

							step_towards(X,get_turf(holder.my_atom))
						else if(istype(X,/mob/living/carbon/human) && i >= 4)
							var/mob/living/carbon/human/H = X
							if(istype(H.shoes,/obj/item/clothing/shoes/magboots))
								var/obj/item/clothing/shoes/magboots/M = H.shoes
								if(M.magpulse)
									continue
							step_towards(H,get_turf(holder.my_atom))
							H << "\red \icon[holder.my_atom] <B> You are pulled towards the drink!<B>"

				sleep(10)
			seen = viewers(4, get_turf(holder.my_atom))
			for(var/mob/M in seen)
				M << "\red \icon[holder.my_atom] <B> The drink rattles violently!</B>"
			sleep(10)
//			var/location = get_turf(holder.my_atom)
//			empulse(location, 2+rand(2), 4 + rand(3))
			spawn (10)
				var/obj/machinery/singularity/singulo = new /obj/machinery/singularity(get_turf(holder.my_atom),7 * created_volume, 3 * created_volume)
				singulo.energy = 10 * created_volume //should make it a bit bigger~
				seen = viewers(4, get_turf(holder.my_atom))
				for(var/mob/M in seen)
					M << "\red \icon[singulo] <B> The drink collapses in on itself!</B>"
				message_admins("A mixed drink has gone critical!")
				log_game("A mixed drink has gone critical")
		return



datum/chemical_reaction/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	result = "alliescocktail"
	results = list("alliescocktail" = 2)
	required_reagents = list("martini" = 1, "vodka" = 1)
	result_amount = 2

datum/chemical_reaction/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	result = "demonsblood"
	results = list("demonsblood" = 4)
	required_reagents = list("rum" = 1, "spacemountainwind" = 1, "blood" = 1, "dr_gibb" = 1)
	result_amount = 4
	requires_mixing = 3

datum/chemical_reaction/booger
	name = "Booger"
	id = "booger"
	result = "booger"
	results = list("booger" = 4)
	required_reagents = list("cream" = 1, "banana" = 1, "rum" = 1, "watermelonjuice" = 1)
	result_amount = 4

datum/chemical_reaction/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	result = "antifreeze"
	results = list("antifreeze" = 4)
	required_reagents = list("vodka" = 2, "cream" = 1, "ice" = 1)
	result_amount = 4

datum/chemical_reaction/barefoot
	name = "Barefoot"
	id = "barefoot"
	result = "barefoot"
	results = list("barefoot" = 3)
	required_reagents = list("berryjuice" = 1, "cream" = 1, "vermouth" = 1)
	result_amount = 3

datum/chemical_reaction/grapesoda
	name = "Grape Soda"
	id = "grapesoda"
	result = "grapesoda"
	results = list("grapesoda" = 3)
	required_reagents = list("grapejuice" = 2, "cola" = 1)
	result_amount = 3

datum/chemical_reaction/grapesoda2
	name = "Grape Soda"
	id = "grapesoda2"
	result = "grapesoda"
	results = list("grapesoda" = 3)
	required_reagents = list("grapejuice" = 2, "sodawater" = 1)
	result_amount = 3


////DRINKS THAT REQUIRED IMPROVED SPRITES BELOW:: -Agouri/////

datum/chemical_reaction/sbiten
	name = "Sbiten"
	id = "sbiten"
	result = "sbiten"
	results = list("sbiten" = 10)
	required_reagents = list("vodka" = 10, "capsaicin" = 1)
	result_amount = 10
	requires_mixing = 1

datum/chemical_reaction/red_mead
	name = "Red Mead"
	id = "red_mead"
	result = "red_mead"
	results = list("red_mead" = 2)
	required_reagents = list("blood" = 1, "mead" = 1)
	result_amount = 2

datum/chemical_reaction/mead
	name = "Mead"
	id = "mead"
	result = "mead"
	results = list("mead" = 2)
	required_reagents = list("sugar" = 1, "water" = 1)
	required_catalysts = list("enzyme" = 5)
	result_amount = 2
	requires_mixing = 2
/*
datum/chemical_reaction/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 10, "frostoil" = 1)
	result_amount = 10

datum/chemical_reaction/iced_beer2
	name = "Iced Beer"
	id = "iced_beer"
	result = "iced_beer"
	required_reagents = list("beer" = 5, "ice" = 1)
	result_amount = 6
*/

datum/chemical_reaction/grog
	name = "Grog"
	id = "grog"
	result = "grog"
	results = list("grog" = 2)
	required_reagents = list("rum" = 1, "water" = 1)
	result_amount = 2

datum/chemical_reaction/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	result = "soy_latte"
	results = list("soy_latte" = 2)
	required_reagents = list("coffee" = 1, "soymilk" = 1)
	result_amount = 2
	requires_mixing = 2

datum/chemical_reaction/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	result = "cafe_latte"
	results = list("cafe_late" = 2)
	required_reagents = list("coffee" = 1, "milk" = 1)
	result_amount = 2
	requires_mixing = 2

datum/chemical_reaction/acidspit
	name = "Acid Spit"
	id = "acidspit"
	result = "acidspit"
	results = list("acidspit" = 6)
	required_reagents = list("sacid" = 1, "wine" = 5)
	result_amount = 6
	requires_mixing = 3

datum/chemical_reaction/amasec
	name = "Amasec"
	id = "amasec"
	result = "amasec"
	results = list("amasec" = 10)
	required_reagents = list("iron" = 1, "wine" = 5, "vodka" = 5)
	result_amount = 10
	requires_mixing = 2

datum/chemical_reaction/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	result = "changelingsting"
	results = list("changelingsting" = 5)
	required_reagents = list("screwdrivercocktail" = 1, "limejuice" = 1, "lemonjuice" = 1)
	result_amount = 5
	requires_mixing = 3

datum/chemical_reaction/aloe
	name = "Aloe"
	id = "aloe"
	result = "aloe"
	results = list("aloe" = 2)
	required_reagents = list("cream" = 1, "whiskey" = 1, "watermelonjuice" = 1)
	result_amount = 2

datum/chemical_reaction/andalusia
	name = "Andalusia"
	id = "andalusia"
	result = "andalusia"
	results = list("andalusia" = 3)
	required_reagents = list("rum" = 1, "whiskey" = 1, "lemonjuice" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	result = "neurotoxin"
	results = list("neurotoxin" = 2)
	required_reagents = list("gargleblaster" = 1, "stoxin" = 1)
	result_amount = 2
	requires_mixing = 3

datum/chemical_reaction/snowwhite
	name = "Snow White"
	id = "snowwhite"
	result = "snowwhite"
	results = list("snowwhite" = 2)
	required_reagents = list("beer" = 1, "lemon_lime" = 1)
	result_amount = 2

datum/chemical_reaction/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	result = "irishcarbomb"
	results = list("irishcarbomb" = 10)
	required_reagents = list("ale" = 1, "irishcream" = 1)
	result_amount = 2

datum/chemical_reaction/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	result = "syndicatebomb"
	results = list("syndicatebomb" = 2)
	required_reagents = list("beer" = 1, "whiskeycola" = 1)
	result_amount = 2
	requires_mixing = 1

datum/chemical_reaction/syndicateboom
	name = "Syndicate Boom"
	id = "syndicateboom"
	results = list("syndicateboom2" = 2)
	required_reagents = list("beer" = 1, "whiskeycola" = 1)
	result_amount = 2
	requires_mixing = 3
	instant = 1
	visible = 0

	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		holder.handle_reactions(shock=1)
		return


datum/chemical_reaction/syndicateboom2
	name = "Syndicate Boom"
	id = "syndicateboom2"
	result = null
	required_reagents = list("syndicatebomb" = 1)
	result_amount = 2
	requires_mixing = 3
	instant = 1
	visible = 0

	on_reaction_end(var/datum/reagents/holder, var/created_volume)
		var/datum/effect/effect/system/reagents_explosion/e = new()
		e.set_up(round((created_volume**0.5)/1.85, 1), holder.my_atom, 0, 0)
		e.holder_damage(holder.my_atom)
		if(isliving(holder.my_atom))
			e.amount *= 0.5
			var/mob/living/L = holder.my_atom
			if(L.stat!=DEAD)
				e.amount *= 0.5
		e.start()

//Splash everyone around them?
		holder.handle_reactions(shock=1)
		sleep(2)
		holder.clear_reagents()

		return



/*
datum/chemical_reaction/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	result = "erikasurprise"
	required_reagents = list("ale" = 1, "limejuice" = 1, "whiskey" = 1, "banana" = 1, "ice" = 1)
	result_amount = 5
*/

datum/chemical_reaction/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	result = "devilskiss"
	results = list("devilskiss" = 3)
	required_reagents = list("blood" = 1, "kahlua" = 1, "rum" = 1)
	result_amount = 3
	requires_mixing = 3

datum/chemical_reaction/hippiesdelight
	name = "Hippies Delight"
	id = "hippiesdelight"
	result = "hippiesdelight"
	results = list("hippiesdelight" = 2)
	required_reagents = list("psilocybin" = 1, "gargleblaster" = 1)
	result_amount = 2
	requires_mixing = 3

datum/chemical_reaction/bananahonk
	name = "Banana Honk"
	id = "bananahonk"
	result = "bananahonk"
	results = list("bananahonk" = 3)
	required_reagents = list("banana" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/silencer
	name = "Silencer"
	id = "silencer"
	result = "silencer"
	results = list("silencer" = 3)
	required_reagents = list("nothing" = 1, "cream" = 1, "sugar" = 1)
	result_amount = 3

datum/chemical_reaction/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	result = "driestmartini"
	results = list("driestmartini" = 2)
	required_reagents = list("nothing" = 1, "gin" = 1)
	result_amount = 2
	requires_mixing = 1

datum/chemical_reaction/driestmartini2
	name = "Driest Martini"
	id = "driestmartini2"
	result = "driestmartini"
	results = list("driestmartini" = 2)
	required_reagents = list("nothing" = 1, "vodka" = 1)
	result_amount = 2
	requires_mixing = 1

datum/chemical_reaction/driestmartini3
	name = "Driest Martini"
	id = "driestmartini2"
	result = "driestmartini"
	results = list("driestmartini" = 2)
	required_reagents = list("nothing" = 1, "vermouth" = 1)
	result_amount = 2
	requires_mixing = 1

datum/chemical_reaction/lemonade
	name = "Lemonade"
	id = "lemonade"
	result = "lemonade"
	results = list("lemonade" = 3)
	required_reagents = list("lemonjuice" = 1, "sugar" = 1, "water" = 1)
	result_amount = 3
	requires_mixing = 1

datum/chemical_reaction/kiraspecial
	name = "Kira Special"
	id = "kiraspecial"
	result = "kiraspecial"
	results = list("kiraspecial" = 2)
	required_reagents = list("orangejuice" = 1, "limejuice" = 1, "sodawater" = 1)
	result_amount = 2
	requires_mixing = 1

datum/chemical_reaction/brownstar
	name = "Brown Star"
	id = "brownstar"
	result = "brownstar"
	results = list("brownstar" = 2)
	required_reagents = list("orangejuice" = 2, "cola" = 1)
	result_amount = 2
	requires_mixing = 1

datum/chemical_reaction/milkshake
	name = "Milkshake"
	id = "milkshake"
	result = "milkshake"
	results = list("milkshake" = 5)
	required_reagents = list("cream" = 1, "ice" = 2, "milk" = 2)
	result_amount = 5
	requires_mixing = 2

datum/chemical_reaction/rewriter
	name = "Rewriter"
	id = "rewriter"
	result = "rewriter"
	results = list("rewriter" = 2)
	required_reagents = list("spacemountainwind" = 1, "coffee" = 1)
	result_amount = 2

datum/chemical_reaction/suidream
	name = "Sui Dream"
	id = "suidream"
	result = "suidream"
	results = list("suidream" = 4)
	required_reagents = list("space_up" = 2, "bluecuracao" = 1, "melonliquor" = 1)
	result_amount = 4
	requires_mixing = 1

//monoelemental reagents


datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, used as antidepressant."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
			step(M, pick(cardinal))
		if(prob(5)) M.emote(pick("twitch","drool","moan"))
		..()
		return

datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0

	custom_metabolism = 0.01

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(!istype(T, /turf/space))
			var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
			if (!dirtoverlay)
				dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
				dirtoverlay.alpha = volume*30
			else
				dirtoverlay.alpha = min(dirtoverlay.alpha+volume*30, 255)

datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

	on_mob_life(var/mob/living/M as mob, var/alien)
		if(M.stat == 2) return
		if(alien && alien == IS_VOX)
			M.adjustOxyLoss(-2*REM)
			holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
			return
		..()

datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

	on_mob_life(var/mob/living/M as mob, var/alien)
		if(M.stat == 2) return
		if(alien && alien == IS_VOX)
			M.adjustToxLoss(REAGENTS_METABOLISM)
			holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
			return
		..()

datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		M.adjustToxLoss(1*REM)
		..()
		return

datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

datum/reagent/magnesium
	name = "Magnesium"
	id = "magnesium"
	description = "placeholder"
	reagent_state = SOLID

datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40

	custom_metabolism = 0.01

datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0

	custom_metabolism = 0.01

datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element with a characteristic odour."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		M.take_organ_damage(1*REM, 0)
		..()
		return

datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160

	custom_metabolism = 0.01

datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE

datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08" // rgb: 110, 59, 8

	custom_metabolism = 0.01

datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208

datum/reagent/platinum
	name = "Platinum"
	id = "platinum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48

datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	overdose = REAGENTS_OVERDOSE

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		if(M.canmove && !M.restrained() && istype(M.loc, /turf/space))
			step(M, pick(cardinal))
		if(prob(5)) M.emote(pick("twitch","drool","moan"))
		M.adjustBrainLoss(2)
		..()
		return

datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		M.apply_effect(2*REM,IRRADIATE,0)
		// radium may increase your chances to cure a disease
		if(istype(M,/mob/living/carbon)) // make sure to only use it on carbon mobs
			var/mob/living/carbon/C = M
			if(C.virus2.len)
				for (var/ID in C.virus2)
					var/datum/disease2/disease/V = C.virus2[ID]
					if(prob(5))
						if(prob(50))
							M.radiation += 50 // curing it that way may kill you instead
							var/mob/living/carbon/human/H
							if(istype(C,/mob/living/carbon/human))
								H = C
							if(!H || (H.species && !(H.species.flags & RAD_ABSORB))) M.adjustToxLoss(100)
						M:antibodies |= V.antigen
		..()
		return

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(volume >= 3)
			if(!istype(T, /turf/space))
				var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
				if(!glow)
					new /obj/effect/decal/cleanable/greenglow(T)
				return

datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		M.apply_effect(1,IRRADIATE,0)
		..()
		return

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(volume >= 3)
			if(!istype(T, /turf/space))
				var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
				if(!glow)
					new /obj/effect/decal/cleanable/greenglow(T)
				return


datum/reagent/toxin/phoron // Not necessarily an element, but eh.
	name = "Phoron"
	id = "phoron"
	description = "Phoron in its liquid form."
	reagent_state = LIQUID
	color = "#E71B00" // rgb: 231, 27, 0
	toxpwr = 3

	on_mob_life(var/mob/living/M as mob)
		if(!M) M = holder.my_atom
		holder.remove_reagent("inaprovaline", 2*REM)
		..()
		return
	reaction_obj(var/obj/O, var/volume)
		src = null
		/*if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/slime))
			var/obj/item/weapon/reagent_containers/food/snacks/egg/slime/egg = O
			if (egg.grown)
				egg.Hatch()*/
		if((!O) || (!volume))	return 0
		var/turf/the_turf = get_turf(O)
		the_turf.assume_gas("volatile_fuel", volume, holder.temperature)
	reaction_turf(var/turf/T, var/volume)
		src = null
		T.assume_gas("volatile_fuel", volume, holder.temperature)
		return

//simple base reagent compounds





//organic compounds




//oxydisers




//reducers




//salts




//synthetic compounds




//medicine




//misc





/datum/power/changeling/bioelectrogenesis
	name = "Bioelectrogenesis"
	desc = "We reconfigure a large number of cells in our body to generate an electric charge shocking what we are grabbing."
	helptext = "We can shock someone or something in our hands. Use for free with nothing in hand for an intimidating display."
	genomecost = 2
	verbpath = /mob/living/carbon/human/proc/changeling_bioelectrogenesis

//Recharge whatever's in our hand, or shock people.
/mob/living/carbon/human/proc/changeling_bioelectrogenesis()
	set category = "Changeling"
	set name = "Bioelectrogenesis (15)"
	set desc = "Recharges anything in your hand, or shocks people."

	var/datum/changeling/changeling = changeling_power(15,0,100,CONSCIOUS)

	var/obj/held_item = get_active_hand()

	if(!changeling)
		return 0

	if(world.time < changeling.last_shock + (changeling.recursive_enhancement ? changeling.shock_delay_rec : changeling.shock_delay))
		to_chat(src, "<span class='notice'>We must wait a bit longer to use this ability.</span>")
		return 0

	if(gloves && !gloves.siemens_coefficient)
		//add exception for changling claws
		to_chat(src, "<span class='warning'>Our gloves prevent us from using this ability.</span>")
		return 0

	if(!held_item)
		visible_message("<span class='warning'>Electrical arcs form around [src]'s hand!</span>")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(2, 1, src)
		s.start()
		src.mind.changeling.last_shock = world.time
		return 0

	else
		// Handle glove conductivity.
		var/obj/item/clothing/gloves/gloves = src.gloves
		var/siemens = 1
		if(gloves)
			siemens = gloves.siemens_coefficient

		//If we're grabbing someone, electrocute them.
		if(istype(held_item,/obj/item/grab))
			var/obj/item/grab/G = held_item
			if(G.affecting)
				G.affecting.electrocute_act(20 * siemens * (1 + changeling.recursive_enhancement/2), src, 1.0, G.target_zone)

				visible_message("<span class='warning'>[src] channels of electricity into [G.affecting]!</span>",
				"<span class='warning'>Our hand channels raw electricity into [G.affecting].</span>",
				"<span class='italics'>You hear sparks!</span>")
				src.mind.changeling.chem_charges -= 15
				return 1

		//Otherwise, charge up whatever's in their hand.
		else
			//This checks both the active hand, and the contents of the active hand's held item.
			var/success = 0
			var/list/L = new() //We make a new list to avoid copypasta.

			//Check our hand.
			if(istype(held_item,/obj/item/weapon/cell))
				L.Add(held_item)

			//Now check our hand's item's contents, so we can recharge guns and other stuff.
			for(var/obj/item/weapon/cell/cell in held_item.contents)
				L.Add(cell)

			//Now for the actual recharging.
			for(var/obj/item/weapon/cell/cell in L)
				visible_message("<span class='warning'>Some sparks fall out from \the [src.name]\'s [held_item]!</span>",
				"<span class='warning'>Our hand channels raw electricity into \the [held_item].</span>",
				"<span class='italics'>You hear sparks!</span>")
				var/i = 10
				if(siemens)
					while(i)
						cell.charge += 100 * siemens //This should be a nice compromise between recharging guns and other batteries.
						if(cell.charge > cell.maxcharge)
							cell.charge = cell.maxcharge
							break
						var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
						s.set_up(2, 1, src)
						s.start()
						held_item.update_icon()
						i--
						sleep(1 SECOND)
					success = 1
			if(success == 0) //If we couldn't do anything with the ability, don't deduct the chemicals.
				src << "<span class='warning'>We are unable to affect \the [held_item].</span>"
			else
				src.mind.changeling.chem_charges -= 15
			return success

/datum/power/changeling/DigitalCamoflague
	name = "Digital Camoflauge"
	desc = "We evolve the ability to distort our form and proprtions, defeating common altgorthms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera while using this skill.  However, humans looking at us will find us.. uncanny.  We must constantly expend chemicals to maintain our form like this."
	genomecost = 1
	verbpath = /mob/proc/changeling_digitalcamo

/datum/power/changeling/visible_camouflage
	name = "Visual Camouflage"
	desc = "We rapidly shape the color of our skin and secrete easily reversible dye on our clothes, to blend in with our surroundings.  \
	We are undetectable, so long as we move slowly.(Toggle)"
	helptext = "Running, and performing most acts will reveal us.  Our chemical regeneration is halted while we are hidden."
	enhancedtext = "Can run while hidden."
	genomecost = 3
	verbpath = /mob/proc/changeling_visible_camouflage


//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/mob/proc/changeling_digitalcamo()
	set category = "Changeling"
	set name = "Toggle Digital Camoflague"
	set desc = "The AI can no longer track us, but we will look different if examined.  Has a constant cost while active."

	var/datum/changeling/changeling = changeling_power()
	if(!changeling)	return 0

	var/mob/living/carbon/human/C = src
	if(C.digitalcamo)	to_chat(C, "<span class='notice'>We return to normal.</span>")
	else				to_chat(C, "<span class='notice'>We distort our form to prevent AI-tracking.</span>")
	C.digitalcamo = !C.digitalcamo

	changeling.chem_recharge_modifiers.Add("digitalcamo" = 0.25)
	while(C && C.digitalcamo && C.mind && C.mind.changeling)
		sleep(10)
	changeling.chem_recharge_modifiers.Remove("digitalcamo")

	feedback_add_details("changeling_powers","CAM")
	return 1

//Hide us from anyone who would do us harm.
/mob/proc/changeling_visible_camouflage()
	set category = "Changeling"
	set name = "Visible Camouflage (10)"
	set desc = "Turns yourself almost invisible, as long as you move slowly."


	if(istype(src,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = src

		if(H.mind.changeling.cloaked)
			H.mind.changeling.cloaked = 0
			return 1

		//We delay the check, so that people can uncloak without needing 10 chemicals to do so.
		var/datum/changeling/changeling = changeling_power(10,0,100,CONSCIOUS)

		if(!changeling)
			return 0
		changeling.chem_charges -= 10
		var/old_regen_rate = H.mind.changeling.chem_recharge_rate

		H << "<span class='notice'>We vanish from sight, and will remain hidden, so long as we move carefully.</span>"
		H.mind.changeling.cloaked = 1
		H.mind.changeling.chem_recharge_rate = 0
		animate(src,alpha = 10, time = 10)

		var/move_intent = H.m_intent
		var/must_walk = TRUE
		if(src.mind.changeling.recursive_enhancement)
			must_walk = FALSE
			to_chat(src, "<span class='notice'>We may move at our normal speed while hidden.</span>")

		if(must_walk)
			H.set_m_intent("walk")

		var/remain_cloaked = TRUE
		while(remain_cloaked) //This loop will keep going until the player uncloaks.
			sleep(1 SECOND) // Sleep at the start so that if something invalidates a cloak, it will drop immediately after the check and not in one second.

			if(H.m_intent != "walk" && must_walk) // Moving too fast uncloaks you.
				remain_cloaked = 0
			if(!H.mind.changeling.cloaked)
				remain_cloaked = 0
			if(H.stat) // Dead or unconscious lings can't stay cloaked.
				remain_cloaked = 0
			if(H.incapacitated(INCAPACITATION_DISABLED)) // Stunned lings also can't stay cloaked.
				remain_cloaked = 0

			if(mind.changeling.chem_recharge_rate != 0) //Without this, there is an exploit that can be done, if one buys engorged chem sacks while cloaked.
				old_regen_rate += mind.changeling.chem_recharge_rate //Unfortunately, it has to occupy this part of the proc.  This fixes it while at the same time
				mind.changeling.chem_recharge_rate = 0 //making sure nobody loses out on their bonus regeneration after they're done hiding.



		H.invisibility = initial(invisibility)
		visible_message("<span class='warning'>[src] suddenly fades in, seemingly from nowhere!</span>",
		"<span class='notice'>We revert our camouflage, revealing ourselves.</span>")
		H.set_m_intent(move_intent)
		H.mind.changeling.cloaked = 0
		H.mind.changeling.chem_recharge_rate = old_regen_rate

		animate(src,alpha = 255, time = 10)
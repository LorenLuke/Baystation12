/mob/living/carbon/human
	var/XC_emotion = ""


/mob/living/simple_animal/XC/verb/release_host()
	set category = "Xenochromata"
	set name = "Leave Host"
	set desc = "Leave your host"

	if(!host)
		to_chat(src, "<span class='notice'>You are not inside a host body.</span>")
		return


	if(src.stat)
		to_chat(src, "<span class='notice'>You cannot infest a target in your current state.</span>")
		return

	if(!host || !src) return

	to_chat(src,"<span class='notice'>You dislodge yourself from [host]'s chest cavity and begin to worm your way up.</span>")

	host.vomit()
	if(!host.stat)
		to_chat(host, "<span class='warning'>You feel a large uncomfortable pressure begin to slowly slither up your throat!</span>")

	spawn(250)
		var/message = ""
		if(!host || !src) return

		var/obj/item/organ/external/E = host.organs_by_name[BP_HEAD]

		if(!E || E.is_stump())
			message = "<span class='danger'>\The [src] emerges from \the [host]'s neck stump!</span>"
		else
			message=  "<span class='danger'>\The [src] emerges from \the [host]'s mouth!</span>."
		if(host.mind)
			if(!host.stat)
				host << "<span class='danger'>Something slimy wiggles out of your ear and plops to the ground!</span>"
			host << "<span class='danger'>As though waking from a dream, you shake off the insidious mind control of the brain worm. Your thoughts are your own again.</span>"

		src.visible_message(message)
		detatch()
		leave_host()


/mob/living/simple_animal/XC/verb/infest_host()
	set category = "Xenochromata"
	set name = "Enter Host"
	set desc = "Enter a suitable humanoid host."

	if(host)
		src << "You are already within a host."
		return

	if(stat)
		src << "You cannot infest a target in your current state."
		return

	var/list/choices = list()
	for(var/mob/living/carbon/human/C in view(1,src))
		if(src.Adjacent(C) && !(C.species in src.restricted_species) )
			choices += C

	if(!choices.len)
		src << "There are no viable hosts within range..."
		return

	var/mob/living/carbon/M = input(src,"Who do you wish to infest?") in null|choices

	if(!M || !src) return

	if(!(src.Adjacent(M))) return

	var/message="<span class='warning>\The [src] attempts to stuff itself down [M]'s throat!</span>"
	var/wait = 30

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M

		var/obj/item/organ/external/E = H.organs_by_name[BP_HEAD]

		if(!E || E.is_stump())
			message = "<span class='danger'>\The [src] begins forcing itself down [M]'s neck stump!</span>"
			wait = 5

		else if(H.check_mouth_coverage()) //done to prevent checking stuff on head if they have no head.
			to_chat(src, "You cannot get through that host's protective gear.")
			return


	src.visible_message(message)

	if(!do_after(src, wait, progress = 0))
		to_chat(src, "As [M] moves away, you are dislodged and fall to the ground.")
		return

	if(!M || !src) return

	message = "<span class='danger'>\The [src] forces itself into [M]!</span>"

	if(M in view(1, src))
		src.visible_message(message)

		src.host = M
//		src.host.status_flags |= PASSEMOTES
		src.loc = M


/*
		//Update their traitor status.
		if(host.mind)
			borers.add_antagonist_mind(host.mind, 1, borers.faction_role_text, borers.faction_welcome)

		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/I = H.internal_organs_by_name[BP_BRAIN]
			if(!I) // No brain organ, so the borer moves in and replaces it permanently.
				replace_brain()
			else
				// If they're in normally, implant removal can get them out.
				var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
				head.implants += src
*/


		return
	else
		to_chat(src, "They are no longer in range!")
		return


/mob/living/simple_animal/XC/proc/enter_host(var/mob/living/carbon/human/M)

	src.host = M
	src.host.status_flags |= PASSEMOTES
	src.loc = M

/*
	//Update their traitor status.
	if(host.mind)
		borers.add_antagonist_mind(host.mind, 1, borers.faction_role_text, borers.faction_welcome)
*/

/*  //Maybe use this for implanting into chest.
	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/I = H.internal_organs_by_name[BP_BRAIN]
		if(!I) // No brain organ, so the borer moves in and replaces it permanently.
			replace_brain()
		else
			// If they're in normally, implant removal can get them out.
			var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
			head.implants += src
	return
*/

/mob/living/simple_animal/XC/proc/leave_host()

	//Update their traitor status.
	if(host.mind)
		borers.add_antagonist_mind(host.mind, 1, borers.faction_role_text, borers.faction_welcome)

	if(istype(M,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/I = H.internal_organs_by_name[BP_BRAIN]
		if(!I) // No brain organ, so the borer moves in and replaces it permanently.
			replace_brain()
		else
			// If they're in normally, implant removal can get them out.
			var/obj/item/organ/external/head = H.get_organ(BP_HEAD)
			head.implants += src
	return

/mob/living/simple_animal/XC/proc/commune()
	set category = "Xenochromata"
	set name = "Commune"
	set desc = "Reach out and touch the thoughts of the others of your kind."




/mob/living/simple_animal/XC/proc/meditate()
	set category = "Xenochromata"
	set name = "Meditate"
	set desc = "Channel energy from the void around you."

	src.meditation_timer = src.meditation_ticks
	if(!src.meditating)
		src.meditating = 1
		src.meditate_process()
	else
		src.meditating = 0


/mob/living/simple_animal/XC/proc/meditate_process()

//	set meditation interruptable

	if(!src.meditating)
		src.meditation_timer = src.meditation_ticks
		return

	if(src.energy >=5)
		src.meditating = 0
		src.meditation_timer = src.meditation_ticks
		return

	if(src.meditation_timer <= 0)
		src.energy = min(src.energy + 1, 5)
		src.meditation_timer = src.meditation_ticks

	if(src.energy >=5) //doublecheck, I know, but it's for different messages to the XC
		src.meditating = 0
		src.meditation_timer = src.meditation_ticks
		return

	spawn(10)
		src.meditation_timer--
		src.meditate_process()



/mob/living/simple_animal/XC/proc/store_energy()
	set category = "Xenochromata"
	set name = "Store energy"
	set desc = "Store energy in our reserve."

	if(src.energy <= 0)
		src.energy = 0
		return

	if(src.reserve >= 25)
		src.reserve = 25
		return

	src.energy--
	src.reserve++

/mob/living/simple_animal/XC/proc/retrieve_energy()
	set category = "Xenochromata"
	set name = "Retrieve energy"
	set desc = "Retrieve energy from our reserve."

	if(src.energy >= 5)
		src.energy = 5
		return

	if(src.reserve <= 0)
		src.reserve = 0
		return

	src.energy++
	src.reserve--


/mob/living/simple_animal/XC/proc/psychic_lance(var/mob/living/carbon/human/H)
	if(H.species in src.psychic_restricted_species)
		return

	if (!H.can_feel_pain())
		H.host_brain << "<span class='notice'>You feel a strange sensation travel through your mind.</span>"
		return

	H.show_message("<span class='danger'><FONT size=3>Horrific, burning agony lances through your mind!</FONT></span>")
	if(prob(25))
		H.say("*scream")
		H.Weaken(15)
		if(prob(25))
			H.adjustBrainLoss(1)
	else
		H.Weaken(10)


/mob/living/simple_animal/XC/proc/project_thought(var/mob/living/carbon/human/H, var/say)
	if(H.species in psychic_restricted_species)
		return

	H.show_message("<span class='notice'> You hear a voice that seems to echo around the room: [say]</span>")
	log_say("[key_name(src)] sent a telepathic message to [key_name(H)]: [say]")
	for(var/mob/observer/ghost/G in world)
		G.show_message("<i>Telepathic message from <b>[src]</b> to <b>[target]</b>: [say]</i>")

/*
/mob/living/simple_animal/XC/proc/project_emotion(var/mob/living/carbon/human/H, var/emote_color, var/energy_used) //proc handling only the emotion message.

	if(H.species in psychic_restricted_species)
		return

	var/emotion = null
	switch(emote_color)
		if("infrared")
			if(energy_used >= 4)
				emotion = "rage"
			else
				emotion = "anger"
		if("red")
			if(energy_used >= 4)
				emotion = "distrust"
			else
				emotion = "wariness"
		if("orange")
			if(energy_used >= 4)
				emotion = "disgust"
			else
				emotion = "aversion"
		if("yellow")
			if(energy_used >= 4)
				emotion = "terror"
			else
				emotion = "fear"
		if("green")
			if(energy_used >= 4)
				emotion = "joy"
			else
				emotion = "happiness"
		if("blue")
			if(energy_used >= 4)
				emotion = "despair"
			else
				emotion = "sadness"
		if("indigo")
			if(energy_used >= 4)
				emotion = "trust"
			else
				emotion = "confidence"
		if("violet")
			if(energy_used >= 4)
				emotion = "love"
			else
				emotion = "caring"
		if("grey")
			if(energy_used >= 4)
				emotion = "apathy"
			else
				emotion = "ambivalence"
		if("white")
			if(energy_used >= 4)
				emotion = "tranquility"
			else
				emotion = "calm"
		if("black")
			if(energy_used >= 4)
				emotion = "madness"
			else
				emotion = "agitation"

	var/intensifier = ""
	switch(energy_used)
		if(1)
			intensifier = pick("slight","a small amount of","a bit of")
		if(2)
			intensifier = pick("","a sense of","a good amount of")
		if(3 to infinity)
			intensifier = pick("total","absolute","complete")

	H.show_message("You feel [energy_used > 2 ? "a wave of" : ""] [intensifier] [emotion] [pick ("envelop", "flow over", "surround", "wrap around") you[energy_used > 2 ? "!" : "."]")
	H.XC_emotion = emotion
	var/emotion_time = 30 + ((intensity -1) * rand (5, 15))*10

	spawn( min(emotion_time, 3000) ) //no more than 5 minutes
		H.show_message("You feel the [pick ("wave", "bout", "sense", "swell")] of [emotion] no longer [pick ("grip", "grasp", "surround", "control", "encircle") you like [pick ("it had", "it once did", "a moment ago", "just before")].")
		H.XC_emotion = ""

	//DSAY/ADMIN LOG THINGY NEEDED!!!!!
*/

/mob/living/simple_animal/XC/verb/psychic_lance_target() //proc handling only the emotion message.
	set category = "Xenochromata"
	set name = "Psychic Lance"
	set desc = "Projects agony into a target's mind."

	var/list/mob/living/carbon/human/mob_list = list()
	for(var/mob/living/carbon/human/H in range(7))
		mob_list.Add(H)

	var/list/name_list = list()

	for(var/mob/living/H in mob_list)
		if(target.species in src.psychic_restricted_species)
			continue
		else
			name_list.Add(H.real_name)

	var/name = src.input("Whose mind do you wish to assault?") in name_list|null
	if(!name)
		return

	var/index = name_list.Find(name)
	var/mob/living/carbon/human/target = mob_list[index]

	if(!target in range(7))
		//They ran away
		return

	if(src.energy < 3)
		//NOT ENOUGH ENERGY!
		return

	src.use_energy(3) //plus one for the ability.
	src.show_message("<span class='notice'>You project agony into the mind of [name]: [say]</span>")
	src.psychic_lance(target)


/mob/living/simple_animal/XC/verb/project_thought_target() //proc handling only the emotion message.
	set category = "Xenochromata"
	set name = "Project thought"
	set desc = "Projects a thought into a target's mind."

	var/say = src.input("What do you wish to say to your target?", "project thought") as text|null
	if(!say)
		return

	var/list/mob/living/carbon/human/mob_list = list()
	for(var/mob/living/carbon/human/H in range(7))
		mob_list.Add(H)

	var/list/name_list = list()

	for(var/mob/living/H in mob_list)
		if(target.species in src.psychic_restricted_species)
			continue
		else
			name_list.Add(H.real_name)

	var/name = src.input("Whose thoughts do you wish to tap?") in name_list|null
	if(!name)
		return


	var/index = name_list.Find(name)
	var/mob/living/carbon/human/target = mob_list[index]

	if(!target in range(7))
		//They ran away
		return

	if(src.energy < 1)
		//NOT ENOUGH ENERGY!
		return

	src.use_energy(1) //plus one for the ability.
	src.show_message("<span class='notice'>You project your thought into the mind of [name]: [say]</span>")
	src.project_thought(target,say)



/mob/living/simple_animal/XC/verb/project_emotion_target() //proc handling only the emotion message.
	set category = "Xenochromata"
	set name = "Project Emotion"
	set desc = "Colors a target's emotions."

	var/list/color_list = list("infrared","red","orange","yellow","green","blue","indigo","violet","grey","white","black")
	var/emote_color = src.input("How do you wish to color your target?.", "project emotion") in color_list|null
	if(!emote_color)
		return


	var/list/mob/living/carbon/human/mob_list = list()
	for(var/mob/living/carbon/human/H in range(7))
		if(target.species in src.psychic_restricted_species)
			continue
		else
			name_list.Add(H.real_name)

	var/list/name_list = list()

	for(var/mob/living/H in mob_list)
		name_list.Add(H.real_name)

	var/name = src.input("Who do you wish to color?") in name_list|null
	if(!name)
		return

	var/index = name_list.Find(name)
	var/mob/living/carbon/human/target = mob_list[index]

	if(!target in range(7))
		//They ran away
		return

	if(src.energy < 1)
		//NOT ENOUGH ENERGY!
		return

	if(!emote_color)
		return

	var/energy_used = src.use_energy(min(src.energy, 4))
	src.project_emotion(target,emote_color,energy_used)

	var/intensity = ""
	switch(energy_used)
		if(1) intensity = pick("lightly ","gently ","subtlely ")
		if(2) intensity = pick("","perceptably")
		if(3) intensity = pick("significantly", "noticeably", "palpably")
		if(4 to INFINITY) intensity = pick("greatly", "vehemently", "strongly")
	src.show_message("<span class='notice'>You [intensity]color the emotions of [name] [emote_color].</span>")


/mob/living/simple_animal/XC/verb/psychic_lance_area() //proc handling only the emotion message.
	set category = "Xenochromata"
	set name = "Psychic Lance(area)"
	set desc = "Projects agony in the minds of those around you."


	if(src.energy < 5)
		//NOT ENOUGH ENERGY!
		return
		src.use_energy(5) //requires two to do an area projection, plus one for the ability.

	for(var/mob/living/carbon/human/H in range(7))
		src.psychic_lance(H)

	src.show_message("<span class='warning'>You project agony into the space around you.</span>")


/mob/living/simple_animal/XC/verb/project_thought_area() //proc handling only the emotion message.
	if(src.energy < 3)
		//NOT ENOUGH ENERGY!
		return

	var/say = src.input("What do you wish to say to all around?", "project thought") as text|null
	if(!say)
		return

	src.use_energy(3) //requires two to do an area projection, plus one for the ability.

	for(var/mob/living/carbon/human/H in range(7))
		src.project_thought(H,say)

	src.show_message("<span class='notice'>You project your thought into the space around you: [say]</span>")


/mob/living/simple_animal/XC/verb/project_emotion_area() //proc handling only the emotion message.
	set category = "Xenochromata"
	set name = "Project Emotion(area)"
	set desc = "Colors emotions in an area around you."


	var/list/color_list = list("infrared","red","orange","yellow","green","blue","indigo","violet","grey","white","black")
	var/emote_color = src.input("How do you wish to color those around you?.", "project emotion") in color_list|null
	if(!emote_color)
		return

	if(src.energy < 3)
		//NOT ENOUGH ENERGY!
		return


	src.use_energy(2) //requires two to do an area projection.
	var/energy_used = src.use_energy(min(src.energy, 4))

	for(var/mob/living/carbon/human/H in range(7))
		src.project_emotion(H,emote_color,energy_used)

	var/intensity = ""
	switch(energy_used)
		if(1) intensity = pick("lightly ","gently ","subtlely ")
		if(2) intensity = pick("","perceptably")
		if(3) intensity = pick("significantly", "noticeably", "palpably")
		if(4 to INFINITY) intensity = pick("greatly", "vehemently", "strongly")
	src.show_message("<span class='notice'>You [intensity]color the space around you [emote_color].</span>")

/mob/living/simple_animal/XC/verb/project_thought_area() //proc handling only the emotion message.
	set category = "Xenochromata"
	set name = "Project Thought(area)"
	set desc = "Projects a thought in an area around you."


	var/say = src.input("What do you wish to say to all around?.", "project thought") as text|null

	if(src.energy < 3)
		//NOT ENOUGH ENERGY!
		return

	src.use_energy(3) //requires two to do an area projection, plus one for the ability.

	for(var/mob/living/carbon/human/H in range(7))
		src.project_thought(H,say)

	src.show_message("<span class='notice'>You project your thought into the space around you: [say]</span>")

/mob/living/simple_animal/XC/proc/camouflage()
	set category = "Xenochromata"
	set name = "Camouflage"
	set desc = "Hides us in our surroundings"

/mob/living/simple_animal/XC/proc/moult()
	set category = "Xenochromata"
	set name = "Moult"
	set desc = "Sheds our skin, taking us to our smaller form"

//Matronly stuff
/mob/living/simple_animal/XC/matron/camouflage()
	set category = "Xenochromata"
	set name = "Camouflage"
	set desc = "Makes us nearly invisible"

/mob/living/simple_animal/XC/matron/proc/bioluminescent_pulse()
	set category = "Xenochromata"
	set name = "Bioluminescent Pulse"
	set desc = "Blinds anyone around us"

/mob/living/simple_animal/XC/matron/proc/devour()
	set category = "Xenochromata"
	set name = "Devour"
	set desc = "Devours anyone underneath us."

/mob/living/simple_animal/XC/matron/proc/harpoon()
	set category = "Xenochromata"
	set name = "Harpoon"
	set desc = "You shouldn't see this."

/mob/living/simple_animal/XC/matron/proc/absorb()
	set category = "Xenochromata"
	set name = "Absorb"
	set desc = "Drains blood from our victim."

/mob/living/simple_animal/XC/matron/proc/construct()
	set category = "Xenochromata"
	set name = "Construct"
	set desc = "Construct structures."

/mob/living/simple_animal/XC/matron/proc/inject()
	set category = "Xenochromata"
	set name = "Inject"
	set desc = "Injects the victim with a chemical cocktail."

/mob/living/simple_animal/XC/matron/proc/plant_embryo()
	set category = "Xenochromata"
	set name = "Plant Embryo"
	set desc = "Gestates one of our own inside them."


// Brute/Guardian stuff
/mob/living/simple_animal/XC/apex/proc/roar()
	set category = "Xenochromata"
	set name = "Roar"
	set desc = "Intimidate those around us."

/mob/living/simple_animal/XC/apex/proc/launch_spine()
	set category = "Xenochromata"
	set name = "Launch Spine"
	set desc = "You shouldn't see this."

/mob/living/simple_animal/XC/apex/proc/charge()
	set category = "Xenochromata"
	set name = "Charge"
	set desc = "Allows us to knock our enemies out of the way."

/mob/living/simple_animal/XC/apex/proc/withdraw()
	set category = "Xenochromata"
	set name = "Withdraw"
	set desc = "Allows us to weather the damage done to us."





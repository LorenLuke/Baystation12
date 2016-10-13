mob/living/simple_animal/XC
	name = "xenochromata"
	stop_automated_movement = 1
	wander = 0
	universal_understand = 1
	var/energy = 5
	var/reserve = 0
	var/meditating = 0
	var/meditation_timer = 0
	var/meditation_ticks = 10
	var/list/abilites_used = list()

	var/mob/living/carbon/human/host        // Human host for the brain worm.
	var/list/restricted_species = list("Machine", "Diona")
	var/list/psychic_restricted_species = list("Machine")
//	var/list/living/carbon/human/host/noded = list()


mob/living/simple_animal/XC/base
	name = "strange creature"
	real_name = "strange creature"
	desc = "A small, colorful... eyeball... thing"
	health = 50
	maxHealth = 50
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes"
	response_disarm = "prods"
	response_harm   = "stomps on"
	icon_state = "brainslug"
	item_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = I_HURT
	status_flags = CANPUSH
	attacktext = "attacked"
	friendly = "pokes"
	pass_flags = PASSTABLE
	holder_type = /obj/item/weapon/holder/borer
	mob_size = MOB_SMALL

/*
/mob/living/simple_animal/XC/Life()
	..()


	if(host)

		if(!stat && !host.stat)

			if(host.reagents.has_reagent("sugar"))
				if(!docile)
					if(controlling)
						host << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					else
						src << "\blue You feel the soporific flow of sugar in your host's blood, lulling you into docility."
					docile = 1
			else
				if(docile)
					if(controlling)
						host << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					else
						src << "\blue You shake off your lethargy as the sugar leaves your host's blood."
					docile = 0

			if(chemicals < 250)
				chemicals++
			if(controlling)

				if(docile)
					host << "\blue You are feeling far too docile to continue controlling your host..."
					host.release_control()
					return

				if(prob(5))
					host.adjustBrainLoss(0.1)

				if(prob(host.brainloss/20))
					host.say("*[pick(list("blink","blink_r","choke","aflap","drool","twitch","twitch_s","gasp"))]")
*/


//Might need a new statpanel for each
/mob/living/simple_animal/XC/Stat()
	. = ..()
	statpanel("Status")

	if(evacuation_controller)
		var/eta_status = evacuation_controller.get_status_panel_eta()
		if(eta_status)
			stat(null, eta_status)

	if (client.statpanel == "Status")
		stat("Energy", energy)
		stat("Reserve", reserve)



//Matron/stuff
mob/living/simple_animal/XC/matron
	name = "strange creature"
	real_name = "strange creature"
	desc = "A weird spider type thing."
	health = 50
	maxHealth = 50
	speak_emote = list("chirrups")
	emote_hear = list("chirrups")
	response_help  = "pokes"
	response_disarm = "prods"
	response_harm   = "stomps on"
	icon_state = "brainslug"
	item_state = "brainslug"
	icon_living = "brainslug"
	icon_dead = "brainslug_dead"
	speed = 5
	a_intent = I_HURT
	status_flags = CANPUSH
	attacktext = "attacked"
	friendly = "pokes"
	pass_flags = 0
	mob_size = MOB_MEDIUM

	var/mob/living/carbon/human/devoured


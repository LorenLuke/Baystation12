/datum/power/changeling/rapidregeneration
	name = "Rapid Regeneration"
	desc = "We evolve the ability to rapidly regenerate, negating the need for stasis."
	helptext = "Heals a moderate amount of damage every tick."
	genomecost = 7
	verbpath = /mob/proc/changeling_rapidregen

//Starts healing you every second for 10 seconds. Can be used whilst unconscious.
/mob/proc/changeling_rapidregen()
	set category = "Changeling"
	set name = "Rapid Regeneration (30)"
	set desc = "Begins rapidly regenerating.  Does not effect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	src.mind.changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = src
	spawn(0)
		for(var/i = 0, i<10,i++)
			if(C)
				C.adjustBruteLoss(-10)
				C.adjustToxLoss(-10)
				C.adjustOxyLoss(-10)
				C.adjustFireLoss(-10)
				sleep(10)

	src.verbs -= /mob/proc/changeling_rapidregen
	spawn(5)	src.verbs += /mob/proc/changeling_rapidregen
	feedback_add_details("changeling_powers","RR")
	return 1



/datum/power/changeling/fleshmend
	name = "Fleshmend"
	desc = "Begins a slow rengeration of our form.  Does not effect stuns or chemicals."
	helptext = "Can be used while unconscious."
//	enhancedtext = "Healing is twice as effective."
	genomecost = 1
	verbpath = /mob/proc/changeling_fleshmend

//Starts healing you every second for 50 seconds. Can be used whilst unconscious.
/mob/proc/changeling_fleshmend()
	set category = "Changeling"
	set name = "Fleshmend (10)"
	set desc = "Begins a slow rengeration of our form.  Does not effect stuns or chemicals."

	var/datum/changeling/changeling = changeling_power(10,0,100,UNCONSCIOUS)
	if(!changeling)
		return 0
	src.mind.changeling.chem_charges -= 10

	var/mob/living/carbon/human/C = src
	var/heal_amount = 2
	if(src.mind.changeling.recursive_enhancement)
		heal_amount = heal_amount * 2
		src << "<span class='notice'>We will heal much faster.</span>"

	spawn(0)
		src << "<span class='notice'>We begin to heal ourselves.</span>"
		for(var/i = 0, i<50,i++)
			if(C)
				C.adjustBruteLoss(-heal_amount)
				C.adjustOxyLoss(-heal_amount)
				C.adjustFireLoss(-heal_amount)
				sleep(1 SECOND)

	src.verbs -= /mob/proc/changeling_fleshmend
	spawn(50 SECONDS)
		src << "<span class='notice'>Our regeneration has slowed to normal levels.</span>"
		src.verbs += /mob/proc/changeling_fleshmend
	feedback_add_details("changeling_powers","FM")
	return 1
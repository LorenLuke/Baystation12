/datum/reagent/changeling/synaptizine
	name = "Cyclobenzo-Synaptizine"
	description = "A biological synaptic stimulant similar in structure to synaptizine."
	taste_description = "bitterness"
	reagent_state = LIQUID
	color = "#99ccff"
	metabolism = REM * 0.05
	overdose = REAGENTS_OVERDOSE
	scannable = 1

/datum/reagent/changeling/synaptizine/affect_blood(var/mob/living/carbon/M, var/alien, var/removed)
	if(alien == IS_DIONA)
		return
	M.drowsyness = max(M.drowsyness - 10, 0)
	M.sleeping = max(M.sleeping - 5, 0)
	M.AdjustParalysis(-2)
	M.AdjustStunned(-2)
	M.AdjustWeakened(-2)
	holder.remove_reagent(/datum/reagent/mindbreaker, 5)
	M.adjust_hallucination(-10)
	M.add_chemical_effect(CE_MIND, 2)
	M.adjustToxLoss(2.5 * removed) // It used to be incredibly deadly due to an oversight. Not anymore!
	M.add_chemical_effect(CE_PAINKILLER, 20)

/datum/power/changeling/Epinephrine
	name = "Synaptic Jolt"
	desc = "We reconfigure our synapses to better respond to stuns."
	helptext = "Gives the ability to more quickly recover from stuns."
	genomecost = 3
	verbpath = /mob/proc/changeling_unstun

//Recover from stuns.
/mob/proc/changeling_unstun()
	set category = "Changeling"
	set name = "Synaptic Jolt"
	set desc = "Allows us to recover from stuns quickly"

	var/datum/changeling/changeling = changeling_power(30,0,100,UNCONSCIOUS)
	if(!changeling)	return 0
	changeling.chem_charges -= 30

	var/mob/living/carbon/human/C = src
	for(var/i = 0, i<25, i++)

		C.reagents.add_reagent(/datum/reagent/changeling/synaptizine, 0.5)
		C.reagents.add_reagent(/datum/reagent/adrenaline, 1)

	feedback_add_details("changeling_powers","UNS")
	return 1

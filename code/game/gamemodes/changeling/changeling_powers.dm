var/global/list/possible_changeling_IDs = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")

/datum/changeling //stores changeling powers, changeling recharge thingie, changeling absorbed DNA and changeling ID (for changeling hivemind)
	var/list/datum/absorbed_dna/absorbed_dna = list()
	var/list/absorbed_languages = list()
	var/absorbedcount = 0
	var/chem_charges = 20
	var/chem_recharge_rate = 0.5
	var/list/chem_recharge_modifiers = list()
	var/list/chem_drain_rate = 0
	var/chem_storage = 50
	var/sting_range = 1
	var/changelingID = "Changeling"
	var/geneticdamage = 0
	var/isabsorbing = 0
	var/geneticpoints = 25
	var/max_geneticpoints
	var/list/purchasedpowers = list()
	var/mimicing = ""

	var/readapts = 2
	var/max_readapts = 3

	var/infested = 0
	var/infested_parent

	var/recursive_enhancement = 0
	var/armor_deployed = 0
	var/last_shriek = 0
	var/cloaked = 0

/datum/changeling/New()
	..()
	max_geneticpoints = geneticpoints
	if(possible_changeling_IDs.len)
		changelingID = pick(possible_changeling_IDs)
		possible_changeling_IDs -= changelingID
		changelingID = "[changelingID]"
	else
		changelingID = "[rand(1,999)]"

/datum/changeling/proc/regenerate()
	chem_charges = min(max(0, chem_charges+chem_recharge_rate), chem_storage)
	geneticdamage = max(0, geneticdamage-1)

/datum/changeling/proc/GetDNA(var/dna_owner)
	for(var/datum/absorbed_dna/DNA in absorbed_dna)
		if(dna_owner == DNA.name)
			return DNA

/mob/proc/absorbDNA(var/datum/absorbed_dna/newDNA)
	var/datum/changeling/changeling = null
	if(src.mind && src.mind.changeling)
		changeling = src.mind.changeling
	if(!changeling)
		return

	for(var/language in newDNA.languages)
		changeling.absorbed_languages |= language

	changeling_update_languages(changeling.absorbed_languages)

	if(!changeling.GetDNA(newDNA.name)) // Don't duplicate - I wonder if it's possible for it to still be a different DNA? DNA code could use a rewrite
		changeling.absorbed_dna += newDNA

//Restores our verbs. It will only restore verbs allowed during lesser (monkey) form if we are not human
/mob/proc/make_changeling()

	if(!mind)				return
	if(!mind.changeling)	mind.changeling = new /datum/changeling(gender)

	verbs += /datum/changeling/proc/EvolutionMenu
	add_language("Changeling")

	var/lesser_form = !ishuman(src)

	if(!powerinstances.len)
		for(var/P in powers)
			powerinstances += new P()

	// Code to auto-purchase free powers.
	for(var/datum/power/changeling/P in powerinstances)
		if(!P.genomecost) // Is it free?
			if(!(P in mind.changeling.purchasedpowers)) // Do we not have it already?
				mind.changeling.purchasePower(mind, P.name, 0)// Purchase it. Don't remake our verbs, we're doing it after this.

	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			if(lesser_form && !P.allowduringlesserform)	continue
			if(!(P in src.verbs))
				src.verbs += P.verbpath

	for(var/language in languages)
		mind.changeling.absorbed_languages |= language

	var/mob/living/carbon/human/H = src
	if(istype(H))
		var/datum/absorbed_dna/newDNA = new(H.real_name, H.dna, H.species.name, H.languages)
		absorbDNA(newDNA)

	return 1

//removes our changeling verbs
/mob/proc/remove_changeling_powers()
	if(!mind || !mind.changeling)	return
	for(var/datum/power/changeling/P in mind.changeling.purchasedpowers)
		if(P.isVerb)
			verbs -= P.verbpath


//Helper proc. Does all the checks and stuff for us to avoid copypasta
/mob/proc/changeling_power(var/required_chems=0, var/required_dna=0, var/max_genetic_damage=100, var/max_stat=0)

	if(!src.mind)		return
	if(!iscarbon(src))	return

	var/datum/changeling/changeling = src.mind.changeling
	if(!changeling)
		world.log << "[src] has the changeling_transform() verb but is not a changeling."
		return

	if(src.stat > max_stat)
		to_chat(src, "<span class='warning'>We are incapacitated.</span>")
		return

	if(changeling.absorbed_dna.len < required_dna)
		to_chat(src, "<span class='warning'>We require at least [required_dna] samples of compatible DNA.</span>")
		return

	if(changeling.chem_charges < required_chems)
		to_chat(src, "<span class='warning'>We require at least [required_chems] units of chemicals to do that!</span>")
		return

	if(changeling.geneticdamage > max_genetic_damage)
		to_chat(src, "<span class='warning'>Our genomes are still reassembling. We need time to recover first.</span>")
		return

	return changeling


//Used to dump the languages from the changeling datum into the actual mob.
/mob/proc/changeling_update_languages(var/updated_languages)

	languages = list()
	for(var/language in updated_languages)
		languages += language

	//This isn't strictly necessary but just to be safe...
	add_language("Changeling")

	return
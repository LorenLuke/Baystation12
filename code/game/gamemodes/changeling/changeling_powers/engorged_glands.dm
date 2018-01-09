
/datum/power/changeling/EngorgedGlands
	name = "Engorged Chemical Glands"
	desc = "Our chemical glands swell, permitting us to store more chemicals inside of them."
	helptext = "Allows us to store an more chemicals and regenerate them faster."
	genomecost = 4
	isVerb = 0
	verbpath = /mob/proc/changeling_engorgedglands

//Increases macimum chemical storage
/mob/proc/changeling_engorgedglands()
	src.mind.changeling.chem_storage = initial(src.mind.changeling.chem_storage) * 1.5
	src.mind.changeling.chem_recharge_rate = initial(src.mind.changeling.chem_recharge_rate) * 1.5
	return 1

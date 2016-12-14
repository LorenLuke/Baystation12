/datum/species/changeling/
	name = "Human"
	name_plural = "Humans"
	primitive_form = ""
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite)
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."

	appearance_flags = HAS_HAIR_COLOR | HAS_SKIN_TONE | HAS_LIPS | HAS_UNDERWEAR | HAS_EYE_COLOR


	inherent_verbs = list(
		/mob/living/carbon/human/proc/changeling_moult,
		/mob/living/carbon/human/proc/changeling_selectform,
		/mob/living/carbon/human/proc/changeling_regenerate,
		/mob/living/carbon/human/proc/changeling_dialysis,
		)

	oxy_mod =       0.05
	radiation_mod = 0
	gluttonous = GLUT_ANYTHING
	stomach_capacity = MOB_MEDIUM

	hazard_high_pressure = 650  // normally 550
	warning_high_pressure = 375 // normally 325.
	warning_low_pressure = 40   // normally 50
	hazard_low_pressure = 15    // normally 20

	breath_pressure = 0         // Minimum partial pressure safe for breathing, kPa
	breath_type = ""            // Non-oxygen gas breathed, if any.
	poison_type = ""            // Poisonous air.
	exhale_type = ""            // Exhaled gas type.

	cold_level_1 = 175 //Default 260 - Lower is better
	cold_level_2 = 125 //Default 200
	cold_level_3 = 65 //Default 120

	heat_level_1 = 430 //Default 360 - Higher is better
	heat_level_2 = 700 //Default 400
	heat_level_3 = 1200 //Default 1000

	heat_discomfort_level = 400
	cold_discomfort_level = 180

	metabolism_mod = 3	         // Reagent metabolism modifier
	hunger_factor = 0.75

	body_temperature = 325	     // Species will try to stabilize at this temperature.

	spawn_flags = SPECIES_IS_RESTRICTED

	blood_color = "#DD9922"

	vision_flags = SEE_SELF | SEE_MOBS  // has thermal vision

	siemens_coefficient = 0.1   // The lower, the thicker the skin and better the insulation.
	darksight = 4             // Native darksight distance.



/datum/species/human/changeling/impure/

/datum/species/human/changeling/pure/
	name = "Abomination"
	name_plural = "Abominations"

/datum/species/human/changeling/impure/stealth

/datum/species/human/changeling/pure/stealth
	icobase = 'icons/mob/human_races/subspecies/r_spacer.dmi'
	total_health = 125
	slowdown = -1
	has_fine_manipulation = 0


/datum/species/human/changeling/impure/defense
	brute_mod =     0.80
	burn_mod =      0.80
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/changeling_knockback)


/datum/species/human/changeling/pure/defense
	name = "Human"
	name_plural = "Humans"
	blurb = "Lithe and frail, these sickly folk were engineered for work in environments that \
	lack both light and atmosphere. As such, they're quite resistant to asphyxiation as well as \
	toxins, but they suffer from weakened bone structure and a marked vulnerability to bright lights."
	icobase = 'icons/mob/human_races/subspecies/r_spacer.dmi'

	brute_mod =     0.75
	burn_mod =      0.75
	warning_low_pressure = 0
	hazard_low_pressure = 0
	total_health = 175
	slowdown = 0.75

/datum/species/human/changeling/offense_impure


/datum/species/human/changeling/offense_pure

	slowdown = -0.25
	icobase = 'icons/mob/human_races/subspecies/r_spacer.dmi'


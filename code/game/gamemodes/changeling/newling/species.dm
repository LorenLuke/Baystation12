
/datum/species/changeling //pure_form
	// Descriptors and strings.
	name = "abomination"                                             // Species name.
	name_plural = "abominations"                                      // Pluralized name (since "[name]s" is not always valid)
	blurb = "A hideous creature."      // A brief lore summary for use in the chargen screen.

	// Icon/appearance vars.
	icobase = 'icons/mob/human_races/r_human.dmi'    // Normal icon set.
	deform = 'icons/mob/human_races/r_def_human.dmi' // Mutated icon set.

	// Damage overlay and masks.
	damage_overlays = 'icons/mob/human_races/masks/dam_human.dmi'
	damage_mask = 'icons/mob/human_races/masks/dam_mask_human.dmi'
	blood_mask = 'icons/mob/human_races/masks/blood_human.dmi'

	prone_icon                                       // If set, draws this from icobase when mob is prone.
	eyes = "eyes_s"                                  // Icon for eyes.
	has_floating_eyes                                // Eyes will overlay over darkness (glow)
	blood_color = "#A10808"                          // Red.
	flesh_color = "#FFC896"                          // Pink.
	base_color                                       // Used by changelings. Should also be used for icon previes..
	race_key = 0       	                             // Used for mob icon cache string.
	mob_size	= MOB_MEDIUM
	show_ssd = "fast asleep"
	virus_immune = true
	blood_volume = 560                               // Initial blood volume.
	hunger_factor = DEFAULT_HUNGER_FACTOR            // Multiplier for hunger.
	taste_sensitivity = TASTE_NORMAL                 // How sensitive the species is to minute tastes.

	// Combat vars.
	total_health = 100                   // Point at which the mob will enter crit.
	list/unarmed_types = list(           // Possible unarmed attacks that the mob will use in combat,
		/datum/unarmed_attack,
		/datum/unarmed_attack/bite
		)
	list/unarmed_attacks = null          // For empty hand harm-intent attack
	brute_mod =     1                    // Physical damage multiplier.
	burn_mod =      1                    // Burn damage multiplier.
	oxy_mod =       1                    // Oxyloss modifier
	toxins_mod =    1                    // Toxloss modifier
	radiation_mod = 1                    // Radiation modifier
	flash_mod =     1                    // Stun from blindness modifier.
	vision_flags = SEE_SELF              // Same flags as glasses.

	// Death vars.
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/human //Needs add changeling meat
	gibber_type = /obj/effect/gibspawner/human
	single_gib_type = /obj/effect/decal/cleanable/blood/gibs
	remains_type = /obj/item/remains/xeno
	gibbed_anim = "gibbed-h"
	dusted_anim = "dust-h"
	death_message = "seizes up and falls limp, their eyes dead and lifeless..."
	knockout_message = "has been knocked unconscious!"
	halloss_message = "slumps to the ground, too weak to continue fighting."
	halloss_message_self = "You're in too much pain to keep going..."

	spawns_with_stack = 0
	// Environment tolerance/life processes vars.
	reagent_tag                                   //Used for metabolizing reagents.
	breath_pressure = 16                          // Minimum partial pressure safe for breathing, kPa
	breath_type = "oxygen"                        // Non-oxygen gas breathed, if any.
	poison_type = "phoron"                        // Poisonous air.
	exhale_type = "carbon_dioxide"                // Exhaled gas type.
	cold_level_1 = 260                            // Cold damage level 1 below this point.
	cold_level_2 = 200                            // Cold damage level 2 below this point.
	cold_level_3 = 120                            // Cold damage level 3 below this point.
	heat_level_1 = 360                            // Heat damage level 1 above this point.
	heat_level_2 = 400                            // Heat damage level 2 above this point.
	heat_level_3 = 1000                           // Heat damage level 3 above this point.
	passive_temp_gain = 0		                  // Species will gain this much temperature every second
	hazard_high_pressure = HAZARD_HIGH_PRESSURE   // Dangerously high pressure.
	warning_high_pressure = WARNING_HIGH_PRESSURE // High pressure warning.
	warning_low_pressure = WARNING_LOW_PRESSURE   // Low pressure warning.
	hazard_low_pressure = HAZARD_LOW_PRESSURE     // Dangerously low pressure.
	light_dam                                     // If set, mob will be damaged in light over this value and heal in light below its negative.
	body_temperature = 310.15	                  // Non-IS_SYNTHETIC species will try to stabilize at this temperature.
	                                                  // (also affects temperature processing)

	heat_discomfort_level = 315                   // Aesthetic messages about feeling warm.
	cold_discomfort_level = 285                   // Aesthetic messages about feeling chilly.
	list/heat_discomfort_strings = list(
		"You feel sweat drip down your neck.",
		"You feel uncomfortably warm.",
		"Your skin prickles in the heat."
		)
	list/cold_discomfort_strings = list(
		"You feel chilly.",
		"You shiver suddenly.",
		"Your chilly flesh stands out in goosebumps."
		)

	// HUD data vars.
	datum/hud_data/hud
	hud_type
	health_hud_intensity = 1

	// Body/form vars.
	list/inherent_verbs 	  // Species-specific verbs.
	has_fine_manipulation = 1 // Can use small items.
	siemens_coefficient = 0.2   // The lower, the thicker the skin and better the insulation.
	darksight = 8             // Native darksight distance.
	flags = 0                 // Various specific features.
	appearance_flags = 0      // Appearance/display related features.
	spawn_flags = IS_RESTRICTED // Flags that specify who can spawn as this species
	slowdown = 0              // Passive movement speed malus (or boost, if negative)
	holder_type               // In-hand wrapper object, if any.
	gluttonous                // Can eat some mobs. Values can be GLUT_TINY, GLUT_SMALLER, GLUT_ANYTHING.
	rarity_value = 10          // Relative rarity/collector value for this species.
	                              // Determines the organs that the species spawns with and
	list/has_organ = list(    // which required-organ checks are conducted.
		"heart" =    /obj/item/organ/heart,
		"lungs" =    /obj/item/organ/lungs,
		"liver" =    /obj/item/organ/liver,
		"kidneys" =  /obj/item/organ/kidneys,
		"brain" =    /obj/item/organ/brain,
		"appendix" = /obj/item/organ/appendix,
		"eyes" =     /obj/item/organ/eyes
		)

	vision_organ              // If set, this organ is required for vision. Defaults to "eyes" if the species has them.

	list/has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest),
		"groin" =  list("path" = /obj/item/organ/external/groin),
		"head" =   list("path" = /obj/item/organ/external/head),
		"l_arm" =  list("path" = /obj/item/organ/external/arm),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right),
		"l_leg" =  list("path" = /obj/item/organ/external/leg),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right),
		"l_hand" = list("path" = /obj/item/organ/external/hand),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right),
		"l_foot" = list("path" = /obj/item/organ/external/foot),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right)
		)

	list/genders = list(MALE, FEMALE)

	// Bump vars
	bump_flag = HUMAN	// What are we considered to be when bumped?
	push_flags = ~HEAVY	// What can we push?
	swap_flags = ~HEAVY	// What can we swap place with?

	pass_flags = 0



/datum/species/changeling/stealth //pure_form
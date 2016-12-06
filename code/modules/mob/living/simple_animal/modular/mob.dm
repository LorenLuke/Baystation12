#define BEHAVIOR_DOCILE
#define BEHAVIOR_TERRITORIAL
#define BEHAVIOR_PREDATORY
#define BEHAVIOR_RETALIATORY
#defene BEHAVIOR_PASSIVE

#define STAGE_OBJECTIVE_NONE
#define STAGE_OBJECTIVE_FEED
#define STAGE_OBJECTIVE_GROW
#define STAGE_OBJECTIVE_NEST
#define STAGE_OBJECTIVE_RAISE
#define STAGE_OBJECTIVE_SPREAD
#define STAGE_OBJECTIVE_HUNT

#define REQUIRES_FOOD
#define REQUIRES_PARENT
#define REQUIRES_LIGHT




/datum/modmob/life_cycle
	name = ""
	var/list/life_stages = list()
	var/birth_stage

/datum/modmob/life_cycle/proc/generate_lifecycle()
	var/untils = 0
	while (!untils)
		var/list/stages = typesof(/datum/modmob/life_stage) - typesof(/datum/modmob/life_stage/reproductive) - typesof(/datum/modmob/life_stage/birth) - (/datum/modmob/life_stage)
		if(prob(life_stages.len*15))
			var/list/stages = typesof(/datum/modmob/life_stage/reproductive)
			untils = 1
		var/datum/modmob/life_stage/LS = pick(stages)
		var/datum/modmob/life_stage/LS = new()
		life_stages.Add(LS)
	return src



/datum/modmob/life_stage
	name = ""
	var/behavior
	var/list/behaviors=list()
	var/sexual = 0 //number of others needed to reproduce/advance to next stage
	var/growth
	var/growth_lower_bound
	var/stage_objective
	var/list/stage_objectives = list()
	var/reproductive = 0
	var/birth = 0
	var/anchored = 0
	var/list/grow_requirements = list()

/datum/modmob/life_stage/New()
	behavior = pick(behaviors)
	growth_lower_bound =
	growth_upper_bound =
	stage_objective = pick(stage_objectives)

/datum/modmob/life_stage/birth
	name = "birth"
	behaviors = list(BEHAVIOR_PASSIVE)
	stage_objectives = list(STAGE_OBJECTIVE_GROW)

/datum/modmob/life_stage/birth/egg_laid
	name = "laid egg"

/datum/modmob/life_stage/birth/egg_parasitic
	name = "parasitic eggs"

/datum/modmob/life_stage/birth/live_laid
	name = "live birth"
	behaviors=list(BEHAVIOR_PASSIVE, BEHAVIOR_DOCILE)
	stage_objectives = list(STAGE_OBJECTIVE_GROW)

/datum/modmob/life_stage/birth/live_parasitic
	name = "parasitic birth"
	behaviors=list(BEHAVIOR_PASSIVE, BEHAVIOR_DOCILE)
	stage_objectives = list(STAGE_OBJECTIVE_GROW)

/datum/modmob/life_stage/birth/spore_laid
	name = "spore"

/datum/modmob/life_stage/birth/spore_parasitic
	name = "parasitic spore"

/datum/modmob/life_stage/chrysalis
	name = "chrysalis"
	behaviors=list(BEHAVIOR_PASSIVE)
	stage_objectives = list(STAGE_OBJECTIVE_GROW)














/datum/modmob/life_stage/reproductive

/datum/modmob/life_stage/reproductive/fruiting
	behaviors = (BEHAVIOR_PASSIVE)
	behaviors = list(STAGE_OBJECTIVE_NONE,STAGE_OBJECTIVE_HUNT)


/datum/modmob/life_stage/death


/datum/modmob/life_stage/proc/handle_behavior()
	switch(behavior)
		if(BEHAVIOR_DOCILE)
			switch(stage_objective)
				if(STAGE_OBJECTIVE_FEED)
					find_food()
				if(STAGE_OBJECTIVE_NEST)

				if(STAGE_OBJECTIVE_RAISE)

				if(STAGE_OBJECTIVE_SPREAD)

		if(BEHAVIOR_TERRITORIAL)

		if(BEHAVIOR_PREDATORY)

		if(BEHAVIOR_RETALIATORY)

		if(BEHAVIOR_PASSIVE)
			if(wander)
				wander = 0



/mob/living/simple_animal/modular
	var/list/turf/territory = list()
	var/mob/living/target = null
	var/list/mob/living/simple_animal/modular/young = list()
	var/datum/modmob/life_stage/stage




/mob/living/simple_animal/modular/proc/establish_territory()

/mob/living/simple_animal/modular/proc/establish_nest()



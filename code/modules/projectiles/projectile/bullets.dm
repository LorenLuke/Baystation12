/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	check_armour = "bullet"
	var/puncture = 1 //
	var/caliber = 0.357 //in inches
	var/nose = 0.8 //diametral scalar or overall caliber
	var/nose_type = 0 // 0 round, 1 flat, 2 pointed (AP), 3 hollowpoint, 4 frangible
	var/velocity =  440//velocity in meters per second
	var/weight = 125 // weight in grains (15.4323584 grains to gram)
	var/projectile_length = 9 //mm
	var/energy = 0 //joules, calculated later
	var/momentum = 0

	var/mob_passthrough_check = 0

	muzzle_type = /obj/effect/projectile/bullet/muzzle

/obj/item/projectile/bullet/New()
	var/mass = (weight/15432.3584) //grains to kg
	momentum = velocity * mass
	energy = 0.5 * mass * velocity**2 //Joules


/obj/item/projectile/bullet/on_hit(var/atom/target, var/blocked = 0)

	var/pressure = energy/(area*6.

	if (..(target, blocked))
		var/mob/living/L = target
		shake_camera(L, 3, 2)

/obj/item/projectile/bullet/attack_mob(var/mob/living/target_mob, var/distance, var/miss_modifier)

	//a = v^2/(2*0.1) v^2/2d (d = 2 inches, because that' about how fast a vest would stop it, if it would)
	var/acceleration = (velocity**2)/(2*0.2)
	var/force = mass * acceleration
	var/area = (3.1415927*(nose*caliber/2)**2) * 0.00064516 //sq in * conversion to sq m
	var/pressure = force / area


	if(penetrating > 0 && damage > 20 && prob(damage))
		mob_passthrough_check = 1
	else
		mob_passthrough_check = 0
	. = ..()

	if(. == 1 && iscarbon(target_mob))
		damage *= 0.7 //squishy mobs absorb KE

/obj/item/projectile/bullet/can_embed()
	//prevent embedding if the projectile is passing through the mob
	if(mob_passthrough_check)
		return 0
	return ..()

/obj/item/projectile/bullet/check_penetrate(var/atom/A)
	if(!A || !A.density) return 1 //if whatever it was got destroyed when we hit it, then I guess we can just keep going

	if(istype(A, /obj/mecha))
		return 1 //mecha have their own penetration handling

	if(ismob(A))
		if(!mob_passthrough_check)
			return 0
		return 1

	var/chance = damage
	if(istype(A, /turf/simulated/wall))
		var/turf/simulated/wall/W = A
		chance = round(damage/W.material.integrity*180)
	else if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/D = A
		chance = round(damage/D.maxhealth*180)
		if(D.glass) chance *= 2
	else if(istype(A, /obj/structure/girder))
		chance = 100

	if(prob(chance))
		if(A.opacity)
			//display a message so that people on the other side aren't so confused
			A.visible_message("<span class='warning'>\The [src] pierces through \the [A]!</span>")
		return 1

	return 0

//For projectiles that actually represent clouds of projectiles
/obj/item/projectile/bullet/pellet
	name = "shrapnel" //'shrapnel' sounds more dangerous (i.e. cooler) than 'pellet'
	damage = 20
	//icon_state = "bullet" //TODO: would be nice to have it's own icon state
	var/pellets = 4			//number of pellets
	var/range_step = 2		//projectile will lose a fragment each time it travels this distance. Can be a non-integer.
	var/base_spread = 90	//lower means the pellets spread more across body parts. If zero then this is considered a shrapnel explosion instead of a shrapnel cone
	var/spread_step = 10	//higher means the pellets spread more across body parts with distance

/obj/item/projectile/bullet/pellet/Bumped()
	. = ..()
	bumped = 0 //can hit all mobs in a tile. pellets is decremented inside attack_mob so this should be fine.

/obj/item/projectile/bullet/pellet/proc/get_pellets(var/distance)
	var/pellet_loss = round((distance - 1)/range_step) //pellets lost due to distance
	return max(pellets - pellet_loss, 1)

/obj/item/projectile/bullet/pellet/attack_mob(var/mob/living/target_mob, var/distance, var/miss_modifier)
	if (pellets < 0) return 1

	var/total_pellets = get_pellets(distance)
	var/spread = max(base_spread - (spread_step*distance), 0)

	//shrapnel explosions miss prone mobs with a chance that increases with distance
	var/prone_chance = 0
	if(!base_spread)
		prone_chance = max(spread_step*(distance - 2), 0)

	var/hits = 0
	for (var/i in 1 to total_pellets)
		if(target_mob.lying && target_mob != original && prob(prone_chance))
			continue

		//pellet hits spread out across different zones, but 'aim at' the targeted zone with higher probability
		//whether the pellet actually hits the def_zone or a different zone should still be determined by the parent using get_zone_with_miss_chance().
		var/old_zone = def_zone
		def_zone = ran_zone(def_zone, spread)
		if (..()) hits++
		def_zone = old_zone //restore the original zone the projectile was aimed at

	pellets -= hits //each hit reduces the number of pellets left
	if (hits >= total_pellets || pellets <= 0)
		return 1
	return 0

/obj/item/projectile/bullet/pellet/get_structure_damage()
	var/distance = get_dist(loc, starting)
	return ..() * get_pellets(distance)

/obj/item/projectile/bullet/pellet/Move()
	. = ..()

	//If this is a shrapnel explosion, allow mobs that are prone to get hit, too
	if(. && !base_spread && isturf(loc))
		for(var/mob/living/M in loc)
			if(M.lying || !M.CanPass(src, loc)) //Bump if lying or if we would normally Bump.
				if(Bump(M)) //Bump will make sure we don't hit a mob multiple times
					return

/* short-casing projectiles, like the kind used in pistols or SMGs */

/obj/item/projectile/bullet/pistol
	fire_sound = 'sound/weapons/gunshot/gunshot_pistol.ogg'
	damage = 20

/obj/item/projectile/bullet/pistol/medium
	damage = 25

/obj/item/projectile/bullet/pistol/medium/smg
	fire_sound = 'sound/weapons/gunshot/gunshot_smg.ogg'

/obj/item/projectile/bullet/pistol/strong //revolvers and matebas
	fire_sound = 'sound/weapons/gunshot/gunshot_strong.ogg'
	damage = 60


/obj/item/projectile/bullet/pistol/rubber //"rubber" bullets
	name = "rubber bullet"
	check_armour = "melee"
	damage = 5
	agony = 25
	embed = 0
	sharp = 0

/* shotgun projectiles */

/obj/item/projectile/bullet/shotgun
	name = "slug"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 50
	armor_penetration = 15

/obj/item/projectile/bullet/shotgun/beanbag		//because beanbags are not bullets
	name = "beanbag"
	check_armour = "melee"
	damage = 20
	agony = 60
	embed = 0
	sharp = 0

//Should do about 80 damage at 1 tile distance (adjacent), and 50 damage at 3 tiles distance.
//Overall less damage than slugs in exchange for more damage at very close range and more embedding
/obj/item/projectile/bullet/pellet/shotgun
	name = "shrapnel"
	fire_sound = 'sound/weapons/gunshot/shotgun.ogg'
	damage = 13
	pellets = 6
	range_step = 1
	spread_step = 10


/* "Rifle" rounds */

/obj/item/projectile/bullet/rifle
	armor_penetration = 20
	penetrating = 1

/obj/item/projectile/bullet/rifle/a762
	fire_sound = 'sound/weapons/gunshot/gunshot2.ogg'
	damage = 25

/obj/item/projectile/bullet/rifle/a556
	fire_sound = 'sound/weapons/gunshot/gunshot3.ogg'
	damage = 30
	armor_penetration = 25

/obj/item/projectile/bullet/rifle/a145
	fire_sound = 'sound/weapons/gunshot/sniper.ogg'
	damage = 80
	stun = 3
	weaken = 3
	penetrating = 5
	armor_penetration = 80
	hitscan = 1 //so the PTR isn't useless as a sniper weapon

/* Miscellaneous */

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY

/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX

/obj/item/projectile/bullet/burstbullet
	name = "exploding bullet"
	damage = 20
	embed = 0
	edge = 1

/obj/item/projectile/bullet/gyro
	fire_sound = 'sound/effects/Explosion1.ogg'

/obj/item/projectile/bullet/gyro/on_hit(var/atom/target, var/blocked = 0)
	if(isturf(target))
		explosion(target, -1, 0, 2)
	..()

/obj/item/projectile/bullet/blank
	invisibility = 101
	damage = 1
	embed = 0

/* Practice */

/obj/item/projectile/bullet/pistol/practice
	damage = 5

/obj/item/projectile/bullet/rifle/a556/practice
	damage = 5

/obj/item/projectile/bullet/shotgun/practice
	name = "practice"
	damage = 5

/obj/item/projectile/bullet/pistol/cap
	name = "cap"
	invisibility = 101
	fire_sound = null
	damage_type = HALLOSS
	damage = 0
	nodamage = 1
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/pistol/cap/process()
	loc = null
	qdel(src)



///////////////////////// real ammo
/obj/item/projectile/bullet/b_22
	caliber = 0.22 //in inches
	velocity =  380//velocity in meters per second
	weight = 40 // weight in grains (15.4323584 grains to gram)
	nose = 0.7

/obj/item/projectile/bullet/b_22/hp //hollowpoint
	nose = 0.7
	nose_type = 3

/obj/item/projectile/bullet/b_223
	caliber = 0.223 //in inches
	velocity =  1140//velocity in meters per second
	weight = 36 // weight in grains (15.4323584 grains to gram)
	nose = 0.25
	nose_type = 0

/obj/item/projectile/bullet/b_556mm
	caliber = 0.223 //in inches
	velocity =  940//velocity in meters per second
	weight = 62 // weight in grains (15.4323584 grains to gram)
	nose = 0.1
	nose_type = 1

/obj/item/projectile/bullet/b_762mm
	caliber = 0.308 //in inches
	velocity =  833 //velocity in meters per second
	weight = 147 // weight in grains (15.4323584 grains to gram)
	nose_type = 2

/obj/item/projectile/bullet/b_300win
	caliber = 0.308 //in inches
	velocity =  959 //velocity in meters per second
	weight = 180 // weight in grains (15.4323584 grains to gram)
	nose = 0.3
	nose_type = 1

/obj/item/projectile/bullet/b_357magnum
	caliber = 0.357 //in inches
	velocity =  440//velocity in meters per second
	weight = 125 // weight in grains (15.4323584 grains to gram)
	nose_type = 1
	nose = 0.6

/obj/item/projectile/bullet/b_38 //ACP
	caliber = 0.357 //in inches
	velocity =  300//velocity in meters per second
	weight = 110 // weight in grains (15.4323584 grains to gram)
	nose = 0.4

/obj/item/projectile/bullet/b_38super
	caliber = 0.357 //in inches
	velocity =  475//velocity in meters per second
	weight = 90 // weight in grains (15.4323584 grains to gram)

/obj/item/projectile/bullet/b_9mm //makarov
	caliber = 0.357 //in inches
	velocity =  313//velocity in meters per second
	weight = 95 // weight in grains (15.4323584 grains to gram)
	nose = 0.5
	nose_type = 1

/obj/item/projectile/bullet/b_c9mm //9mm glisenti
	caliber = 0.357 //in inches
	velocity =  320//velocity in meters per second
	weight = 123 // weight in grains (15.4323584 grains to gram)
	nose = 0.5
	nose_type = 1

/obj/item/projectile/bullet/b_c10mm //10mm auto
	caliber = 0.4 //in inches
	velocity =  430//velocity in meters per second
	weight = 155 // weight in grains (15.4323584 grains to gram)
	nose = 0.6
	nose_type = 1


/obj/item/projectile/bullet/b_45acp
	caliber = 0.45 //in inches
	velocity =  373//velocity in meters per second
	weight = 185 // weight in grains (15.4323584 grains to gram)
	nose = 0.8

/obj/item/projectile/bullet/b_50ae //action express
	caliber = 0.5 //in inches
	velocity =  450//velocity in meters per second
	weight = 300 // weight in grains (15.4323584 grains to gram)
	nose_type = 1
	nose = 0.6

/obj/item/projectile/bullet/b_500 //.500 S&W
	caliber = 0.51 //in inches
	velocity =  550//velocity in meters per second
	weight = 400 // weight in grains (15.4323584 grains to gram)
	nose_type = 1
	nose = 0.6

/obj/item/projectile/bullet/b_145mm //14.5x114 (HOLY SHIT)
	caliber = 0.557 //in inches
	velocity =  1000//velocity in meters per second
	weight = 926 // weight in grains (15.4323584 grains to gram)
	nose_type = 2
	nose = 0.1


///Shotguns

/obj/item/projectile/bullet/sh_slug //slug
	caliber = 0.729 //in inches
	velocity =  549//velocity in meters per second
	weight = 432 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

/obj/item/projectile/bullet/sh_bean //beanbag
	piercing = 0
	caliber = 0.729 //in inches
	velocity =  90//velocity in meters per second
	weight = 605 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

/obj/item/projectile/bullet/pellet/000_buck //6 pellets
	caliber = 0.36 //in inches
	velocity =  1000//velocity in meters per second
	weight = 69.7 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

/obj/item/projectile/bullet/pellet/00_buck //8 pellets
	caliber = 0.33 //in inches
	velocity =  1000//velocity in meters per second
	weight = 54 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

/obj/item/projectile/bullet/pellet/0_buck //9 pellets
	caliber = 0.32 //in inches
	velocity =  1000//velocity in meters per second
	weight = 48 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later





/obj/item/projectile/bullet/sh_410 //
	caliber = 0.410 //in inches
	velocity =  390//velocity in meters per second
	weight = 926 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

/obj/item/projectile/bullet/sh_20ga //
	caliber = 0.614 //in inches
	velocity =  390//velocity in meters per second
	weight = 926 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

/obj/item/projectile/bullet/sh_12ga //
	caliber = 0.729 //in inches
	velocity =  425//velocity in meters per second
	weight = 926 // weight in grains (15.4323584 grains to gram)
	energy = 0 //joules, calculated later

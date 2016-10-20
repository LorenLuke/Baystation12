/obj/item/projectile/bullet/spine
	name = "bone spine"
	desc = "It looks like a sharp, bonelike-thing."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolt"
	item_state = "bolt"
	damage = 7
	sharp = 1
	embed = 1
	agony = 18


/obj/item/weapon/melee/lingblade
	name = "chitinous blade"
	desc = "Some sort of strange bonelike weapon"
	icon_state = "cultblade"
	item_state = "cultblade"
	edge = 1
	sharp = 1
	w_class = 4
	force = 5
	throw_speed = 75
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/wasthrown = 0

/obj/item/weapon/melee/lingblade/throw_at(atom/target, range, speed, var/mob/living/carbon/human/thrower)
	if(!wasthrown)
		wasthrown = 1
		var/obj/item/organ/external/hand/H
		var/handedness = "right hand"
		if(thrower.hand)
			handedness = "left hand"

		for(var/obj/item/organ/external/O in thrower.organs)
			if (O.name == handedness)
				H = O
				break

		H.droplimb(0, DROPLIMB_BLUNT)
		thrower:traumatic_shock = max(0, thrower.traumatic_shock - 60)
		..()
		spawn(10)
			src.throw_speed = 5
			src.force = 5
			src.wasthrown = 1

	else
		..()

/obj/item/weapon/melee/lingblade/dropped()
	if(!wasthrown)
		sleep(1)
		usr<< "You cannot drop that, only throw it!"
		return 0
	else
		..()


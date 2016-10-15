

/obj/item/device/bloodstone
	name = "Blood Stone"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A mysterious blood red stone that seems to pull in light, a dark crimson center pulses slowly."
	w_class = 2
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MATERIAL = 4)
	var/last_used
	var/stored_blood = 0
	var/shard_count = 1
	var/projectile = ""
	var/imprinted = "empty"


/obj/item/device/bloodstone/afterattack(atom/A, mob/living/user, adjacent, params)

	if (user.a_intent != I_HURT)
		return



/obj/item/device/soulstone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/human))//If target is not a human.
		return ..()
	if(!M.vessel)
		return ..()

	src.take_blood(M, 40)








/obj/item/device/soulstone/proc/take_blood(mob/living/carbon/T, var/amount)

	//bloodcheck

	var/datum/reagent/B
	if(istype(T, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = T
		if(!H.should_have_organ(BP_HEART))
			H.reagents.trans_to_obj(src, amount)
		else
			B = T.take_blood(src, amount)
	else
		B = T.take_blood(src,amount)

	if (B)
		reagents.reagent_list += B
		reagents.update_total()
		on_reagent_change()














	admin_attack_log(user, M, "Used \the [src] to capture the victim's soul.", "Had their soul captured with \a [src].", "captured the soul, using \a [src], of")
	transfer_soul("VICTIM", M, user)
	return








/obj/item/device/darkstone
	name = "Dark Stone"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "An strange and forboding onyx black stone that without sheen."
	w_class = 2
	slot_flags = SLOT_BELT
	origin_tech = list(TECH_BLUESPACE = 4, TECH_MATERIAL = 4)
	var/imprinted = "empty"



//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/human))//If target is not a human.
		return ..()
	if(istype(M, /mob/living/carbon/human/dummy))
		return..()
	if(jobban_isbanned(M, MODE_CULTIST))
		user << "<span class='warning'>This person's soul is too corrupt and cannot be captured!</span>"
		return..()

	admin_attack_log(user, M, "Used \the [src] to capture the victim's soul.", "Had their soul captured with \a [src].", "captured the soul, using \a [src], of")
	transfer_soul("VICTIM", M, user)
	return


///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/bloodstone/attack_self(mob/user)


	if(!iscultist(user))
//		conversion
	else

		if (!in_range(src, user))
			return
		user.set_machine(src)
		var/dat = "<TT><B>Blood Stone</B><BR>"
			dat += "Stored Blood: [src.stored_blood]<br>"
			dat += "Bloodstone Shards: [src.shard_count]<br>"
/*
			dat += "Spawn Robes: 100 blood"
			dat += "Spawn Shield: 250 blood"
			dat += "Spawn Sword: 400 blood"
			dat += "Create Void Artefact: 450"
			dat += "Spawn Bloodstone: 500 blood"
			dat += "Spawn Bloodstone: 1 shard"
			dat += "Spawn Darkstone: 500 blood, 1 shard"
			dat += "Revive: 1250 blood, 2 shards"
			dat += "Summon Mass: 2000 blood, 3 shards"

			dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Summon Shade</A>"}
			dat += "<br>"
*/
			dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}

		user << browse(dat, "window=bloodstone")
		onclose(user, "bloodstone")
		return




/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/U = usr
	if (!in_range(src, U)||U.machine!=src)
		U << browse(null, "window=bloodstone")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=bloodstone")
			U.unset_machine()
			return

		if ("Summon")
			for(var/mob/living/simple_animal/shade/A in src)
				A.status_flags &= ~GODMODE
				A.canmove = 1
				A << "<b>You have been released from your prison, but you are still bound to [U.name]'s will. Help them suceed in their goals at all costs.</b>"
				A.forceMove(U.loc)
				A.cancel_camera()
				src.icon_state = "soulstone"
attack_self(U)
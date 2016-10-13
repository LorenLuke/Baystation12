/mob/living/simple_animal/XC/say(var/message)
	return


/mob/living/simple_animal/XC/base/say(var/message)

	message = sanitize(message)
	message = capitalize(message)

	if(!message)
		return

	if (stat == DEAD)
		return say_dead(message)

	if (stat)
		return

	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			src << "\red You cannot speak in IC (muted)."
			return

	if (copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2))

/*
	var/datum/language/L = parse_language(message)
	if(L && L.flags & HIVEMIND)
		L.broadcast(src,trim(copytext(message,3)),src.truename)
		return
*/

	if(!host)
		src << "You have no host to speak to."
		return //No host, no audible speech.

	src << "You drop words into [host]'s mind: \"[message]\""
	host << "Your own thoughts speak: \"[message]\""

	for (var/mob/M in player_list)
		if (istype(M, /mob/new_player))
			continue
		else if(M.stat == DEAD && M.is_preference_enabled(/datum/client_preference/ghost_ears))
			M << "[src.truename] whispers to [host], \"[message]\""
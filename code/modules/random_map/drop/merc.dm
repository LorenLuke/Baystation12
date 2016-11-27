#define SD_FLOOR_TILE 0
#define SD_WALL_TILE 1
#define SD_DOOR_TILE 2
#define SD_EMPTY_TILE 3
#define SD_SUPPLY_TILE 7

/datum/random_map/droppod/merc
	descriptor = "mercenary infiltration pop"
	initial_wall_cell = 0
	limit_x = 5
	limit_y = 5
	preserve_map = 0

	wall_type = /turf/simulated/wall/titanium
	floor_type = /turf/simulated/floor/reinforced
	list/supplied_drop_types = list()
	door_type = /obj/structure/droppod_door
	drop_type = null
	auto_open_doors

	placement_explosion_dev =   0
	placement_explosion_heavy = 0
	placement_explosion_light = 2
	placement_explosion_flash = 4

/datum/random_map/droppod/merc/New(var/seed, var/tx, var/ty, var/tz, var/tlx, var/tly, var/do_not_apply, var/do_not_announce, var/supplied_drop, var/list/supplied_drops, var/automated)

	if(automated)
		auto_open_doors = 1

	//Make sure there is a clear midpoint.
	if(limit_x % 2 == 0) limit_x++
	if(limit_y % 2 == 0) limit_y++
	..()

/datum/random_map/droppod/merc/generate_map()

	// No point calculating these 200 times.
	var/x_midpoint = n_ceil(limit_x / 2)
	var/y_midpoint = n_ceil(limit_y / 2)

	// Draw walls/floors/doors.
	for(var/x = 1, x <= limit_x, x++)
		for(var/y = 1, y <= limit_y, y++)
			var/current_cell = get_map_cell(x,y)
			if(!current_cell)
				continue

			var/on_x_bound = (x == 1 || x == limit_x)
			var/on_y_bound = (y == 1 || y == limit_x)
			var/draw_corners = (limit_x < 5 && limit_y < 5)
			if(on_x_bound || on_y_bound)
				// Draw access points in midpoint of each wall.
				if(x == x_midpoint || y == y_midpoint)
					map[current_cell] = SD_DOOR_TILE
				// Draw the actual walls.
				else if(draw_corners || (!on_x_bound || !on_y_bound))
					map[current_cell] = SD_WALL_TILE
				//Don't draw the far corners on large pods.
				else
					map[current_cell] = SD_EMPTY_TILE
			else
				// Fill in the corners.
				if((x == 2 || x == (limit_x-1)) && (y == 2 || y == (limit_y-1)))
					map[current_cell] = SD_WALL_TILE
				// Fill in EVERYTHING ELSE.
				else
					map[current_cell] = SD_FLOOR_TILE

	// Draw the drop contents.
	var/current_cell = get_map_cell(x_midpoint,y_midpoint)
	if(current_cell)
		map[current_cell] = SD_SUPPLY_TILE
	return 1

/datum/random_map/droppod/merc/apply_to_map()
	if(placement_explosion_dev || placement_explosion_heavy || placement_explosion_light || placement_explosion_flash)
		var/turf/T = locate((origin_x + n_ceil(limit_x / 2)-1), (origin_y + n_ceil(limit_y / 2)-1), origin_z)
		if(istype(T))
			explosion(T, placement_explosion_dev, placement_explosion_heavy, placement_explosion_light, placement_explosion_flash)
			sleep(15) // Let the explosion finish proccing before we ChangeTurf(), otherwise it might destroy our spawned objects.
	return ..()

/datum/random_map/droppod/merc/get_appropriate_path(var/value)
	if(value == SD_FLOOR_TILE || value == SD_SUPPLY_TILE)
		return floor_type
	else if(value == SD_WALL_TILE)
		return wall_type
	else if(value == SD_DOOR_TILE )
		return wall_type
	return null

// Pods are circular. Get the direction this object is facing from the center of the pod.
/datum/random_map/droppod/merc/get_spawn_dir(var/x, var/y)
	var/x_midpoint = n_ceil(limit_x / 2)
	var/y_midpoint = n_ceil(limit_y / 2)
	if(x == x_midpoint && y == y_midpoint)
		return null
	var/turf/target = locate(origin_x+x-1, origin_y+y-1, origin_z)
	var/turf/middle = locate(origin_x+x_midpoint-1, origin_y+y_midpoint-1, origin_z)
	if(!istype(target) || !istype(middle))
		return null
	return get_dir(middle, target)

/datum/random_map/droppod/merc/get_additional_spawns(var/value, var/turf/T, var/spawn_dir)

	// Splatter anything under us that survived the explosion.
	if(value != SD_EMPTY_TILE && T.contents.len)
		for(var/atom/movable/AM in T)
			if(AM.simulated && !isobserver(AM))
				qdel(AM)

	// Also spawn doors and loot.
	if(value == SD_DOOR_TILE)
		var/obj/structure/S = new door_type(T, auto_open_doors)
		S.set_dir(spawn_dir)

	else if(value == SD_SUPPLY_TILE)
		get_spawned_drop(T)

/datum/random_map/droppod/merc/get_spawned_drop(var/turf/T)
	var/obj/structure/bed/chair/C = new(T)
	C.set_light(3, l_color = "#CC0000")
	var/mob/living/drop
	// This proc expects a list of mobs to be passed to the spawner.
	// Use the supply pod if you don't want to drop mobs.
	// Mobs will not double up; if you want multiple mobs, you
	// will need multiple drop tiles.
	if(ispath(drop_type))
		drop = new drop_type(T)
		if(istype(drop))
			if(drop.buckled)
				drop.buckled = null
			drop.forceMove(T)

/datum/admins/proc/call_merc_drop_pod()
	set category = "Fun"
	set desc = "Call a mercenary drop pod on your location."
	set name = "Call Merc Drop Pod"

	if(!check_rights(R_FUN)) return

	if(alert("Are you SURE you wish to deploy this drop pod? It will cause a sizable explosion and gib anyone underneath it.",,"No","Yes") == "No")
		return

	// Chuck them into the pod.

	new /datum/random_map/droppod(null, usr.x-1, usr.y-1, usr.z, supplied_drops = list(), automated = 0)
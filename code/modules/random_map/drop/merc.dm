#define SD_FLOOR_TILE 0
#define SD_WALL_TILE 1
#define SD_DOOR_TILE 2
#define SD_EMPTY_TILE 3
#define SD_SUPPLY_TILE 7

/*
/area/merc_pod
	name = "\improper Mercenary Pod"
	icon_state = "syndie-elite"
*/

/datum/random_map/droppod/merc
	descriptor = "drop pod"
	initial_wall_cell = 0
	limit_x = 3
	limit_y = 3
	preserve_map = 0

	wall_type = /turf/simulated/wall/titanium
	floor_type = /turf/simulated/floor/reinforced
	var/list/supplied_drop_types = list()
	var/door_type = /obj/structure/droppod_door
	var/auto_open_doors = 1
	var/door_open_direction = 1

	var/placement_explosion_dev =   1
	var/placement_explosion_heavy = 2
	var/placement_explosion_light = 3
	var/placement_explosion_flash = 2

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
//			var/draw_corners = (limit_x < 5 && limit_y < 5)
			var/draw_corners = 1
			if(on_x_bound || on_y_bound)
				// Draw access points in midpoint of each wall.

				if(x == x_midpoint || y == y_midpoint)
//					map[current_cell] = SD_DOOR_TILE

				// Draw the actual walls.
				else if(draw_corners || (!on_x_bound || !on_y_bound))
					map[current_cell] = SD_WALL_TILE
				//Don't draw the far corners on large pods.
				else
					map[current_cell] = SD_EMPTY_TILE
			else
/*
				// Fill in the corners.
				if((x == 2 || x == (limit_x-1)) && (y == 2 || y == (limit_y-1)))
					map[current_cell] = SD_WALL_TILE
				// Fill in EVERYTHING ELSE.
				else
					map[current_cell] = SD_FLOOR_TILE
*/
				map[current_cell] = SD_FLOOR_TILE


	// Draw the drop contents.
	var/current_cell = get_map_cell(x_midpoint,y_midpoint)
	if(current_cell)
		map[current_cell] = SD_SUPPLY_TILE
	return 1

/datum/random_map/droppod/apply_to_map()
	if(placement_explosion_dev || placement_explosion_heavy || placement_explosion_light || placement_explosion_flash)
		var/turf/T = locate((origin_x + n_ceil(limit_x / 2)-1), (origin_y + n_ceil(limit_y / 2)-1), origin_z)
		if(istype(T))
			explosion(T, placement_explosion_dev, placement_explosion_heavy, placement_explosion_light, placement_explosion_flash)
			sleep(15) // Let the explosion finish proccing before we ChangeTurf(), otherwise it might destroy our spawned objects.
	return ..()

/datum/random_map/droppod/get_appropriate_path(var/value)
	if(value == SD_FLOOR_TILE || value == SD_SUPPLY_TILE)
		return floor_type
	else if(value == SD_WALL_TILE)
		return wall_type
	else if(value == SD_DOOR_TILE )
		return wall_type
	return null

// Pods are circular. Get the direction this object is facing from the center of the pod.

/datum/proc/merc_pod(var/area/start, var/area/transition, var/area/target, var/direction)

	switch(direction)
		if(1)
		if(2)
		if(4)
		if(8)


/datum/admins/proc/call_merc_pod()
	set category = "Fun"
	set desc = "Call an immediate mercenary pod on your location."
	set name = "Call Merc Pod"
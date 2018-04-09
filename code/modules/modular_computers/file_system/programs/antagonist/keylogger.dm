/datum/computer_file/program/logger
	filename = "logger"
	filedesc = "Logger"
	program_icon_state = "word"
	program_menu_icon = "home"
	extended_desc = "When run this virus remains hidden in the background logging every action taken by a computer, including any keystrokes entered."
	size = 13
	requires_ntnet = 0
	available_on_ntnet = 0
	available_on_syndinet = 1
	nanomodule_path = /datum/nano_module/program/keylogger
	var/list/stored_data = list()


/datum/computer_file/program/logger/run_program(var/mob/living/user)
	. = ..(user)
	if(armed)
		hidden = 1
		activate()


// Unhides if the program gets killed. Be sure to cover your tracks! ~Luke
/datum/computer_file/program/logger/kill_program(var/forced = 0)
	hidden = 0
	..()

/datum/co
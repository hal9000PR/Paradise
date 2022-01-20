/proc/isvampirethrall(mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/mindslave/thrall)

/datum/vampire_passive/increment_thrall_cap/on_apply(datum/antagonist/vampire/V)
	V.subclass.thrall_cap += 1

/datum/vampire_passive/increment_thrall_cap/two

/datum/vampire_passive/increment_thrall_cap/three

/obj/effect/proc_holder/spell/vampire/enthrall
	name = "Enthrall (150)"
	desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
	gain_desc = "You have gained the ability to thrall people to your will."
	action_icon_state = "vampire_enthrall"
	required_blood = 150
	deduct_blood_on_cast = FALSE

/obj/effect/proc_holder/spell/vampire/enthrall/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 1
	T.click_radius = 0
	return T

/obj/effect/proc_holder/spell/vampire/enthrall/cast(list/targets, mob/user = usr)
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/target in targets)
		user.visible_message("<span class='warning'>[user] bites [target]'s neck!</span>", "<span class='warning'>You bite [target]'s neck and begin the flow of power.</span>")
		to_chat(target, "<span class='warning'>You feel the tendrils of evil invade your mind.</span>")
		if(do_mob(user, target, 5 SECONDS))
			if(can_enthrall(user, target) && vampire.subclass.thrall_cap > user.mind.som.serv.len)
				handle_enthrall(user, target)
				var/datum/spell_handler/vampire/V = custom_handler
				var/blood_cost = V.calculate_blood_cost(vampire)
				vampire.bloodusable -= blood_cost //we take the blood after enthralling, not before
			else
				revert_cast(user)
				to_chat(user, "<span class='warning'>You or your target either moved or you dont have enough usable blood.</span>")

/obj/effect/proc_holder/spell/vampire/enthrall/proc/can_enthrall(mob/living/user, mob/living/carbon/C)
	if(!C)
		log_runtime(EXCEPTION("something bad happened on enthralling a mob, attacker is [user] [user.key] \ref[user]"), user)
		return FALSE
	if(!ishuman(C))
		to_chat(user, "<span class='warning'>You can only enthrall sentient humanoids!</span>")
		return FALSE
	if(!C.mind)
		to_chat(user, "<span class='warning'>[C.name]'s mind is not there for you to enthrall.</span>")
		return FALSE

	var/enthrall_safe = FALSE
	for(var/obj/item/implant/mindshield/L in C)
		if(L && L.implanted)
			enthrall_safe = TRUE
			break
	var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(V.subclass.thrall_cap <= user.mind.som.serv.len)
		to_chat(user, "<span class='warning'>You don't have enough power to enthrall anymore people!</span>")
		return FALSE
	if(enthrall_safe || C.mind.has_antag_datum(/datum/antagonist/vampire) || C.mind.has_antag_datum(/datum/antagonist/mindslave))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>")
		return FALSE
	if(C.mind.isholy)
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>Your faith in [SSticker.Bible_deity_name] has kept your mind clear of all evil.</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/vampire/enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/H)
	if(!istype(H))
		return FALSE

	var/greet_text = "You have been Enthralled by [user.real_name]. Follow [user.p_their()] every command."
	H.mind.add_antag_datum(new /datum/antagonist/mindslave/thrall(user.mind, greet_text))
	H.Stun(2)
	add_attack_logs(user, H, "Vampire-thralled")

/obj/effect/proc_holder/spell/vampire/thrall_commune
	name = "Commune"
	desc = ":^ Thrall gang lmao"
	gain_desc = "You have gained the ability to commune with your thralls."

/datum/spell_targeting/select_vampire_master/choose_targets(mob/user, obj/effect/proc_holder/spell/spell, params, atom/clicked_atom) // finds the master of the thralls, returns the user if the vampire is using it
	var/list/mob/living/targets = list()
	var/datum/antagonist/vampire/V
	V = user.mind.has_antag_datum(/datum/antagonist/vampire) // if the user is a vampire

	if(!V)
		for(var/datum/mind/M in user.mind.som.masters) // if the user is a thrall
			V = M.has_antag_datum(/datum/antagonist/vampire)
			if(V)
				break

	if(!V)
		return

	for(var/datum/mind/thrall in V.owner.som.serv)
		targets += thrall.current
	targets += V.owner.current
	return targets

/obj/effect/proc_holder/spell/vampire/thrall_commune/create_new_targeting()
	var/datum/spell_targeting/select_vampire_master/T = new
	T.range = 500
	return T

/obj/effect/proc_holder/spell/vampire/thrall_commune/cast(list/targets, mob/user)
	var/input = stripped_input(user, "Please choose a message to tell to the other thralls.", "Thrall Commune", "")
	if(!input)
		revert_cast(user)
		return
	var/message = "[user.real_name]:[input]"

	for(var/mob/M in targets)
		to_chat(M, "<span class='shadowling'>[message] </span>")
	for(var/mob/M in GLOB.dead_mob_list)
		if(!M.client)
			continue
		to_chat(M, "<span class='shadowling'><a href='?src=[M.UID()];follow=[user.UID()]'>(F)</a> [message] </span>")
	log_say("(DANTALION) [input]", user)

/obj/effect/proc_holder/spell/vampire/pacify
	name = "Pacify (10)"
	desc = "Pacify a target temporarily, making them unable to cause harm."
	charge_max = 30 SECONDS
	required_blood = 10

/obj/effect/proc_holder/spell/vampire/pacify/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.range = 7
	T.click_radius = 1
	T.allowed_type = /mob/living/carbon/human
	return T

/obj/effect/proc_holder/spell/vampire/pacify/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		H.apply_status_effect(STATUS_EFFECT_PACIFIED)

/obj/effect/proc_holder/spell/vampire/self/decoy
	name = "Deploy Decoy (30)"
	desc = "Briefly turn invisible and deploy a decoy illusion to fool your prey."
	gain_desc = "You have gained the ability to turn invisible and create decoy illusions."
	required_blood = 30
	charge_max = 40 SECONDS

/obj/effect/proc_holder/spell/vampire/self/decoy/cast(list/targets, mob/user)
	var/mob/living/simple_animal/hostile/illusion/escape/E = new(get_turf(user))
	E.Copy_Parent(user, 20, 20)
	E.GiveTarget(user) //so it starts running right away
	E.Goto(user, E.move_to_delay, E.minimum_distance)
	user.invisibility = INVISIBILITY_OBSERVER
	user.alpha = 128
	addtimer(CALLBACK(user, /mob/living/.proc/reset_visibility), 6 SECONDS)

/obj/effect/proc_holder/spell/vampire/rally_thralls
	name = "Rally Thralls (100)"
	desc = "Removes all crowd control effects from your nearby thralls."
	gain_desc = "You have gained the ability to remove all CC effects from nearby thralls."
	required_blood = 100
	charge_max = 100 SECONDS

/obj/effect/proc_holder/spell/vampire/rally_thralls/create_new_targeting()
	var/datum/spell_targeting/aoe/thralls/A = new
	A.allowed_type = /mob/living/carbon/human
	A.range = 7
	return A

/datum/spell_targeting/aoe/thralls/valid_target(target, user, obj/effect/proc_holder/spell/spell, check_if_in_range)
	if(!isvampirethrall(target))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/vampire/rally_thralls/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		H.remove_CC()

/obj/effect/proc_holder/spell/vampire/hysteria
	name = "Mass Hysteria (70)"
	desc = "Casts a powerful illusion to make everyone nearby percieve others to looks like random animals after briefly blinding them."
	gain_desc = "You have gained the ability to make everyone nearby percieve others to looks like random animals after briefly blinding them."
	required_blood = 70
	charge_max = 180 SECONDS

/obj/effect/proc_holder/spell/vampire/hysteria/create_new_targeting()
	var/datum/spell_targeting/aoe/A = new
	A.range = 8
	A.allowed_type = /mob/living/carbon/human
	return A

/obj/effect/proc_holder/spell/vampire/hysteria/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H as anything in targets)
		H.flash_eyes(1, TRUE) // flash to give them a second to lose track of who is who
		new /obj/effect/hallucination/delusion/long(get_turf(user), H)

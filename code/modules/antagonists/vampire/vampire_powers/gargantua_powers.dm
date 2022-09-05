/obj/effect/proc_holder/spell/vampire/self/blood_swell
	name = "Blood Swell (30)"
	desc = "You infuse your body with blood, making you highly resistant to stuns and physical damage. However, this makes you unable to fire ranged weapons while it is active."
	gain_desc = "You have gained the ability to temporarly resist large amounts of stuns and physical damage."
	base_cooldown = 40 SECONDS
	required_blood = 30
	action_icon_state = "blood_swell"

/obj/effect/proc_holder/spell/vampire/self/blood_swell/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/obj/effect/proc_holder/spell/vampire/self/stomp
	name = "Siesmic Stomp (30)"
	desc = "You slam your foot into the ground sending a powerful shockwave through the stations hull, sending people flying away."
	gain_desc = "You have gained the ability to send a knock people back using a powerful stomp."
	base_cooldown = 60 SECONDS
	required_blood = 30
	var/max_range = 4

/obj/effect/proc_holder/spell/vampire/self/stomp/cast(list/targets, mob/user)
	var/turf/T = get_turf(user)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	hit_check(1, T, user)
	new /obj/effect/temp_visual/stomp(T)

/obj/effect/proc_holder/spell/vampire/self/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
	for(var/mob/living/L in view(range, start_turf) - view(range - 1, start_turf))
		if(L in safe_targets)
			continue
		if(L.throwing) // no double hits
			continue
		if(!L.affects_vampire(user))
			continue
		if(L.move_resist > MOVE_FORCE_VERY_STRONG)
			continue
		var/throw_target = get_edge_target_turf(L, get_dir(start_turf, L))
		INVOKE_ASYNC(L, /atom/movable/.proc/throw_at, throw_target, 3, 4)
		L.KnockDown(1 SECONDS)
		safe_targets += L
	var/new_range = range + 1
	if(new_range <= max_range)
		addtimer(CALLBACK(src, .proc/hit_check, new_range, start_turf, user, safe_targets), 0.2 SECONDS)

/obj/effect/temp_visual/stomp
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "stomp_effect"
	duration = 0.8 SECONDS

/obj/effect/temp_visual/stomp/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix() * 8, time = duration, alpha = 0)

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "While blood swell is active all of your melee attacks deal increased damage."

/obj/effect/proc_holder/spell/vampire/self/overwhelming_force
	name = "Overwhelming Force"
	desc = "When toggled you will automatically pry open doors that you bump into if you do not have access."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
	base_cooldown = 2 SECONDS
	action_icon_state = "OH_YEAAAAH"

/obj/effect/proc_holder/spell/vampire/self/overwhelming_force/cast(list/targets, mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(user, "<span class='warning'>You feel MIGHTY!</span>")
		ADD_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG
	else
		REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.move_resist = MOVE_FORCE_DEFAULT
		user.status_flags |= CANPUSH

/obj/effect/proc_holder/spell/vampire/self/blood_rush
	name = "Blood Rush (30)"
	desc = "Infuse yourself with blood magic to boost your movement speed."
	gain_desc = "You have gained the ability to temporarily move at high speeds."
	base_cooldown = 30 SECONDS
	required_blood = 30
	action_icon_state = "blood_rush"

/obj/effect/proc_holder/spell/vampire/self/blood_rush/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='notice'>You feel a rush of energy!</span>")
		H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)

/obj/effect/proc_holder/spell/fireball/demonic_grasp
	name = "Demonic Grasp (20)"
	desc = "Fire out a hand of demonic energy, snaring and throwing its target around, based on your intent. Disarm push, grab pull."
	gain_desc = "You have gained the ability to snare and disrupt people with demonic apendages."
	base_cooldown = 30 SECONDS
	fireball_type = /obj/item/projectile/magic/demonic_grasp

	selection_activated_message		= "<span class='notice'>You raise your hand, full of demonic energy! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You re-absorb the energy...for now.</span>"

	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	sound = null
	invocation_type = "none"
	invocation = null

/obj/effect/proc_holder/spell/fireball/demonic_grasp/create_new_handler()
	var/datum/spell_handler/vampire/V = new()
	V.required_blood = 20
	return V

/obj/item/projectile/magic/demonic_grasp
	name = "demonic grasp"
	// parry this you filthy casual
	reflectability = REFLECTABILITY_NEVER

/obj/item/projectile/magic/demonic_grasp/pixel_move(trajectory_multiplier)
	. = ..()
	if(prob(50))
		new /obj/effect/temp_visual/bubblegum_hands/rightpaw(loc)
		new /obj/effect/temp_visual/bubblegum_hands/rightthumb(loc)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(loc)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(loc)

/obj/item/projectile/magic/demonic_grasp/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/L = target
	L.Immobilize(1 SECONDS)
	var/throw_target
	if(!firer)
		return

	if(!L.affects_vampire(firer))
		return

	if(prob(50))
		new /obj/effect/temp_visual/bubblegum_hands/rightpaw(target.loc)
		new /obj/effect/temp_visual/bubblegum_hands/rightthumb(target.loc)
	else
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(target.loc)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(target.loc)


	switch(firer.a_intent)
		if(INTENT_DISARM)
			throw_target = get_edge_target_turf(L, get_dir(firer, L))
			L.throw_at(throw_target, 2, 5, spin = FALSE) // shove away
		if(INTENT_GRAB)
			throw_target = get_step(firer, get_dir(firer, L))
			L.throw_at(throw_target, 2, 5, spin = FALSE, diagonals_first = TRUE) // pull towards

/obj/effect/proc_holder/spell/vampire/charge
	name = "Charge (30)"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	required_blood = 30
	base_cooldown = 30 SECONDS
	action_icon_state = "vampire_charge"

/obj/effect/proc_holder/spell/vampire/charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/vampire/charge/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(IS_HORIZONTAL(L))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/vampire/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, targeting.range, 1, L, FALSE, callback = CALLBACK(L, /mob/living/.proc/remove_status_effect, STATUS_EFFECT_CHARGING))

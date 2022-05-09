/obj/effect/proc_holder/spell/vampire/self/blood_swell
	name = "Blood Swell (30)"
	desc = "You infuse your body with blood, making you highly resistant to stuns and physical damage. However, this makes you unable to fire ranged weapons while it is active."
	gain_desc = "You have gained the ability to temporarly resist large amounts of stuns and physical damage."
	charge_max = 40 SECONDS
	required_blood = 30
	action_icon_state = "blood_swell"

/obj/effect/proc_holder/spell/vampire/self/blood_swell/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "While blood swell is active all of your melee attacks deal increased damage."

/obj/effect/proc_holder/spell/vampire/self/overwhelming_force
	name = "Overwhelming Force"
	desc = "When toggled you will automatically pry open doors that you bump into if you do not have access."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
	charge_max = 2 SECONDS
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
	charge_max = 30 SECONDS
	required_blood = 30
	action_icon_state = "blood_rush"

/obj/effect/proc_holder/spell/vampire/self/blood_rush/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(H, "<span class='notice'>You feel a rush of energy!</span>")
		H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)

/obj/effect/proc_holder/spell/vampire/charge
	name = "Charge (30)"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	required_blood = 30
	charge_max = 30 SECONDS
	action_icon_state = "vampire_charge"

/obj/effect/proc_holder/spell/vampire/charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/vampire/charge/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(L.IsWeakened() || L.resting)
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/vampire/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, targeting.range, 1, L, FALSE, callback = CALLBACK(L, /mob/living/.proc/remove_status_effect, STATUS_EFFECT_CHARGING))

/mob/living/proc/zoom_in(factor = 2) //this breaks parallax cos fuck you
	if(hud_used)
		var/atom/movable/plane_master_controller/pm_controller = hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
		for(var/key in pm_controller.controlled_planes)
			animate(pm_controller.controlled_planes[key], transform = (matrix() * factor), time = 1 SECONDS, easing = QUAD_EASING)

/mob/living/proc/a()
	client.colour_transition(MATRIX_GOD_IS_DEAD, 1 SECONDS)

/mob/living/proc/b()
	client.colour_transition(MATRIX_I_AM_STARTING_TO_LOSE_IT, 1 SECONDS)

/mob/living/proc/c()
	client.colour_transition(MATRIX_GOD_IS_DEAD_FUCK, 1 SECONDS)
	ui_interact(src)

/mob/living/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Testing", "TESTING", 1500, 2000, master_ui, state)
		ui.set_autoupdate(FALSE)
		ui.open()

/mob/living/ui_data(mob/user)
	var/list/data = list()
	var/list/data_2 = list()
	for(var/i in 1 to 20)
		data_2 += list(list("num" = i, "value" = client.color[i]))
	data["matrix"] = data_2

	return data

/mob/living/ui_act(action, list/params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("volume")
			var/channel = text2num(params["channel"])
			var/value = text2num(params["volume"])
			var/list/temp1 = client.color
			var/list/temp2 = temp1.Copy()
			temp2[channel] = value
			client.color = temp2
		else
			return FALSE







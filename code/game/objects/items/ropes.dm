/obj/item/rope
	name = "rope"
	icon_state = "rope"
	icon = 'icons/obj/ropes.dmi'
	var/list/linked_to = list()

/atom/movable/proc/init_rope(rope_type = /obj/item/rope, length = 2)
	var/turf/T = get_turf(src)
	var/obj/item/rope/old_rope = new rope_type(T)
	var/obj/item/rope/new_rope
	old_rope.RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/move_linked_ropes)
	old_rope.linked_to += src
	length-- // we made 1 rope already
	if(!length)
		return
	for(var/i in 1 to length)
		new_rope = new rope_type(T)
		old_rope.linked_to += new_rope
		new_rope.linked_to += old_rope
		old_rope = new_rope


/obj/item/rope/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/move_ropes)

/obj/item/rope/proc/move_ropes()
	var/list/nearby_atoms = list()
	for(var/atom/movable/A in orange(1, src))
		if(A in linked_to)
			nearby_atoms += A
	var/list/unlinked_atoms = linked_to.Copy() - nearby_atoms
	for(var/atom/movable/A as anything in unlinked_atoms)
		var/move_dir = get_dir(A, src)
		var/turf/new_turf = get_step(get_turf(A), move_dir)
		A.Move(new_turf)

/atom/movable/proc/move_linked_ropes(datum/source, obj/item/rope)
	SIGNAL_HANDLER
	if(!ismovable(source))
		return
	var/turf/T = get_turf(src)
	var/atom/movable/linked_to = source
	if(linked_to in range(1, T))
		return
	var/move_dir = get_dir(src, linked_to)
	var/turf/new_turf = get_step(T, move_dir)
	Move(new_turf)

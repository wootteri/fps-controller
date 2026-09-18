class_name JumpAbility
extends PlayerAbility

## Only fires on the frame the jump action was pressed (not while held) and
## only when grounded (or within coyote time), so holding Space doesn't
## launch the player repeatedly mid-air.
##
## Coyote time: the grace period after stepping off a ledge where jumping is
## still allowed. Without it, players feel punished for perfectly-timed
## movement off edges — the frame where they "leave the floor" is the same
## frame they'd press jump, which feels unresponsive.
@export var jump_velocity: float = 4.5
@export var coyote_time: float = 0.1  # seconds after leaving the floor


func physics_update(player: Player, delta: float) -> void:
	var on_floor_or_coyote: bool = player.is_on_floor() or player.last_floor_contact_time < coyote_time

	if on_floor_or_coyote and not player.is_crouched and Input.is_action_just_pressed("jump"):
		player.velocity.y = jump_velocity

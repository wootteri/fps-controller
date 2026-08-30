class_name SprintAbility
extends PlayerAbility

## Raises player.current_speed for this frame while the sprint action is
## held; MovementAbility reads current_speed afterwards (see its sibling
## order in player.tscn) so it ends up moving faster without knowing sprint
## exists at all. This node mutates a shared working value instead of
## `player.speed` directly so the boost never "sticks" past the frame it was
## applied on.

@export var sprint_multiplier: float = 1.8


func physics_update(player: Player, delta: float) -> void:
	if Input.is_action_pressed("sprint"):
		player.current_speed *= sprint_multiplier

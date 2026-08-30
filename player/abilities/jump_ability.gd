class_name JumpAbility
extends PlayerAbility

## Only fires on the frame the jump action was pressed (not while held) and
## only when grounded, so holding Space doesn't launch the player repeatedly
## mid-air. Setting `enabled = false` on this node in the Inspector (or via
## code) disables jumping entirely without touching any other ability.

@export var jump_velocity: float = 4.5


func physics_update(player: Player, delta: float) -> void:
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		player.velocity.y = jump_velocity

class_name MovementAbility
extends PlayerAbility

## Converts WASD input into horizontal velocity, relative to which way the
## player is currently facing (yaw is applied to Player itself in player.gd,
## so `player.transform.basis` already points the right direction).
##
## Reads `player.current_speed` (not `player.speed` directly) so abilities
## like SprintAbility can raise it for this frame only — see player.gd's
## _physics_process, which resets current_speed to speed before any ability
## runs, and this node's sibling order in player.tscn (Sprint before
## Movement) so the boosted value is what actually gets read here.

func physics_update(player: Player, delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	player.velocity.x = direction.x * player.current_speed
	player.velocity.z = direction.z * player.current_speed

class_name GravityAbility
extends PlayerAbility

## Pulls the player down while airborne. Only applies when NOT on the floor:
## CharacterBody3D already zeroes out velocity into the ground on contact via
## move_and_slide(), so adding gravity while grounded would just fight that
## every frame for no visible effect — skipping it is a cheap early-out, not
## a correctness requirement.

func physics_update(player: Player, delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y -= player.gravity * delta

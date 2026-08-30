class_name PlayerAbility
extends Node

## Base contract every ability implements. Player.gd finds abilities via the
## "player_abilities" group (see player.tscn) and calls physics_update on each
## enabled one every physics frame, in scene-tree sibling order.

@export var enabled: bool = true


## Override in subclasses. `player` is passed explicitly rather than looked
## up via get_parent(), so an ability doesn't care where it sits in the tree.
func physics_update(player: Player, delta: float) -> void:
	pass

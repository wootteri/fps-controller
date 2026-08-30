class_name Player
extends CharacterBody3D

## Orchestrator, not a monolith: mouse-look and mouse capture live here since
## they're core FPS camera control (not a toggleable ability), but movement,
## gravity, jump and sprint are all delegated to ability nodes under
## "Abilities" in player.tscn — see player/abilities/ability.gd for the
## contract they implement.

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var pitch_limit_deg: float = 89.0

@onready var head: Node3D = $Head

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## Reset to `speed` at the top of every physics frame; abilities like
## SprintAbility may raise it before MovementAbility reads it later the same
## frame (order is controlled by sibling order in player.tscn).
var current_speed: float = speed


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-pitch_limit_deg), deg_to_rad(pitch_limit_deg))

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	current_speed = speed

	# "player_abilities" is a Godot group — a tag any node can carry, queried
	# here instead of hardcoding child names, so a new ability just needs to
	# be added to the group in the scene file, no orchestrator change needed.
	for ability in get_tree().get_nodes_in_group("player_abilities"):
		if ability.enabled:
			ability.physics_update(self, delta)

	# Only CharacterBody3D itself can call move_and_slide(), so this can't
	# live inside an ability node — it has to happen once, here, after every
	# ability has had a chance to set this frame's velocity.
	move_and_slide()

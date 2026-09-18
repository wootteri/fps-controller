class_name CrouchAbility
extends PlayerAbility

## Handles crouching: shrinks the player collider, lowers the camera, and
## checks headroom before standing back up.
##
## Uses a smooth lerp factor (0.0 = standing, 1.0 = fully crouched) so the
## transition feels polished rather than snapping instant.
##
## Key math for the collider: a CapsuleShape3D's local bottom is always at
## -height/2. The CollisionShape3D's origin.y offsets this. To keep the
## bottom anchored to the floor as height changes:
##
##   bottom_in_local = collision_shape.origin.y + (-height / 2)
##   We want bottom_in_local = 0, so:
##   collision_shape.origin.y = height / 2
##
## Headroom check: when crouch is released, raycast from the top of the
## crouched collider up to standing height + clearance. If the ray hits
## anything, the player stays crouched (they'd clip through a ceiling).

@export var standing_collider_height: float = 1.8
@export var crouched_collider_height: float = 0.5
@export var crouch_speed: float = 10.0
@export var crouch_speed_multiplier: float = 0.5
@export var headroom_distance: float = 0.3
@export var crouched_head_y: float = 0.5
@export var headroom_check: bool = true

var is_crouching: bool = false
var current_crouch_factor: float = 0.0  # 0.0 = standing, 1.0 = crouched

@onready var collision_shape: CollisionShape3D = null
@onready var head: Node3D = null


func _ready() -> void:
	# Player is the grandparent: Abilities -> CrouchAbility
	var player: Player = get_parent().get_parent() as Player
	if player == null:
		push_error("CrouchAbility must be a child of a Player node")
		enabled = false
		return

	# Find the CollisionShape3D and Head node on the player
	for child in player.get_children():
		if child is CollisionShape3D:
			collision_shape = child
		elif child.name == "Head":
			head = child

	if collision_shape == null or head == null:
		push_error("CrouchAbility could not find CollisionShape3D or Head on Player")
		enabled = false
		return

	# If starting under a ceiling, begin crouched
	if headroom_check:
		var space_state: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
		var ray_origin: Vector3 = player.global_transform.origin + Vector3.UP * crouched_collider_height
		var ray_end: Vector3 = player.global_transform.origin + Vector3.UP * (standing_collider_height + headroom_distance)
		var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
		var result: Dictionary = space_state.intersect_ray(query)

		if not result.is_empty():
			is_crouching = true
			current_crouch_factor = 1.0


func physics_update(player: Player, delta: float) -> void:
	if not enabled:
		return

	# --- State transitions ---

	# Start crouching when the action is pressed
	if Input.is_action_just_pressed("crouch") and not is_crouching:
		is_crouching = true

	# Stop crouching when released (with optional headroom check)
	if Input.is_action_just_released("crouch") and is_crouching:
		if not headroom_check:
			is_crouching = false
		else:
			# Raycast from top of crouched collider up to standing height + clearance
			var space_state: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
			var ray_origin: Vector3 = player.global_transform.origin + Vector3.UP * crouched_collider_height
			var ray_end: Vector3 = player.global_transform.origin + Vector3.UP * (standing_collider_height + headroom_distance)
			var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
			var result: Dictionary = space_state.intersect_ray(query)

			if result.is_empty():
				# No obstruction — stand up
				is_crouching = false

	# --- Smooth interpolation ---
	# Lerp toward the target factor (1.0 = crouching, 0.0 = standing)
	var target_factor: float = 1.0 if is_crouching else 0.0
	current_crouch_factor = lerp(current_crouch_factor, target_factor, crouch_speed * delta)

	# --- Apply to collider ---
	# The bottom of the capsule must stay anchored to the floor (y=0 in player-local space).
	var current_height: float = lerp(standing_collider_height, crouched_collider_height, current_crouch_factor)
	collision_shape.shape.height = current_height
	collision_shape.transform.origin.y = current_height / 2.0

	# --- Apply to camera height ---
	# Lerp the Head node's Y so the camera smoothly drops with the crouch.
	var standing_head_y: float = 1.6  # From player.tscn
	var target_head_y: float = lerp(standing_head_y, crouched_head_y, current_crouch_factor)
	head.transform.origin.y = target_head_y

	# --- Communicate state to other abilities ---
	# is_crouched is true when the player is mostly crouched (>50%) to avoid
	# flickering during transitions.
	player.is_crouched = current_crouch_factor > 0.5

	# Apply crouch speed modifier. During the lerp, the speed scales
	# proportionally so the transition feels smooth, not a sudden slowdown.
	var effective_multiplier: float = 1.0 - current_crouch_factor * (1.0 - crouch_speed_multiplier)
	player.current_speed = player.speed * effective_multiplier

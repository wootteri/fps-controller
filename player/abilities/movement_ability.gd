class_name MovementAbility
extends PlayerAbility

## Converts WASD input into horizontal velocity, relative to which way the
## player is currently facing (yaw is applied to Player itself in player.gd,
## so `player.transform.basis` already points the right direction).
##
## Momentum handling:
## - On ground: direct control when input is given, gradual deceleration when
##   no input is given (so stopping from sprint isn't instant)
## - In air: velocity is lerped toward target velocity, preserving momentum
##   but allowing some steering control (air strafing)
##
## The lerp factor controls responsiveness:
## - On ground: 1.0 = instant response (direct control)
## - In air: air_control (default 0.1) = slow response (momentum preservation)
##
## How the lerp works: each frame, velocity moves `air_control` fraction of
## the way toward the target. With air_control = 0.1, you're 10% closer to
## the target each frame. This is exponential approach, which feels smooth.

@export var air_control: float = 0.1
@export var ground_deceleration: float = 8.0
@export var air_drag: float = 0.01

func physics_update(player: Player, delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if input_dir != Vector2.ZERO:
		var direction: Vector3 = (player.transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
		var target_speed: float = player.current_speed

		if player.is_on_floor():
			# Direct control on ground — instant response to input
			player.velocity.x = direction.x * target_speed
			player.velocity.z = direction.z * target_speed
		else:
			# In air: lerp toward target to preserve momentum
			# Lower air_control = more momentum preserved, less steering control
			var target_vel: Vector3 = direction * target_speed
			player.velocity.x = lerp(player.velocity.x, target_vel.x, air_control)
			player.velocity.z = lerp(player.velocity.z, target_vel.z, air_control)
	else:
		# No input — decelerate
		if player.is_on_floor():
			# Gradual ground deceleration (preserves direction)
			var current_speed: float = player.velocity.length()
			if current_speed > 0.01:
				var new_speed: float = current_speed - ground_deceleration * delta
				if new_speed < 0:
					new_speed = 0
				var dir: Vector3 = player.velocity.normalized()
				player.velocity.x = dir.x * new_speed
				player.velocity.z = dir.z * new_speed
		else:
			# Slight air drag to prevent infinite momentum
			var drag_factor: float = 1.0 - air_drag
			player.velocity.x *= drag_factor
			player.velocity.z *= drag_factor

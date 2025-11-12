class_name Slingshot

extends RigidBody2D

@export var JUMP_VECTOR: float = 5.0 
@export var SLOW_MO_SCALE: float = 0.1

@onready var trajectory_line: Line2D = $Line2D

var enabled = true

signal slingshot(force: Vector2)
signal dead

var is_holding := false
var start := Vector2.ZERO
var end := Vector2.ZERO
var sling_vector := Vector2.ZERO
var gravity := Vector2.ZERO

func _ready() -> void:
	gravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale)
	if not trajectory_line:
		print_debug("Trajectory Line2D node not found! Please add a Line2D child.")

func _process(delta: float) -> void:
	# 1. When player first presses
	if enabled:
		if Input.is_action_just_pressed("touch"):
			is_holding = true
			start = get_global_mouse_position()
			Engine.time_scale = SLOW_MO_SCALE
			if trajectory_line:
				trajectory_line.clear_points()
		# 2. While player is holding
		if is_holding:
			end = get_global_mouse_position()
			sling_vector = end - start
			if trajectory_line:
				draw_trajectory(sling_vector)
		# 3. When player releases
		if Input.is_action_just_released("touch"):
			if is_holding:
				is_holding = false
				Engine.time_scale = 1.0 
				linear_velocity = Vector2.ZERO
				var jump = -sling_vector * JUMP_VECTOR
				slingshot.emit(jump)
				jump.x = 0
				apply_impulse(jump)
				if trajectory_line:
					trajectory_line.clear_points()
	if linear_velocity.x < 0 or position.y <-1 or position.y > 1081:
		enabled = false
		dead.emit()

func draw_trajectory(current_sling_vector: Vector2) -> void:
	trajectory_line.clear_points()
	var initial_velocity: Vector2 = (-current_sling_vector * JUMP_VECTOR) / mass
	var start_pos: Vector2 = global_position
	var time_step: float = 0.05
	var num_points: int = 30
	for i in range(num_points):
		var t: float = i * time_step
		var displacement: Vector2 = (initial_velocity * t) + (0.5 * gravity * t * t)
		var predicted_pos: Vector2 = start_pos + displacement
		trajectory_line.add_point(trajectory_line.to_local(predicted_pos))

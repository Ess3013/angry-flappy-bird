#extends RigidBody2D
#
#@export var JUMP_VECTOR = 0
#
#var is_holding := false
#var start : Vector2
#var end : Vector2
#var sling_vector : Vector2
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("touch"):
		#start = get_global_mouse_position()
	#if Input.is_action_just_released("touch"):
		#end = get_global_mouse_position()
		#sling_vector = end - start
		#apply_impulse(-sling_vector * JUMP_VECTOR)


extends RigidBody2D

# Adjust this in the inspector to get the right "power"
@export var JUMP_VECTOR = 5.0 

# Get a reference to the child Line2D node
# Make sure your Line2D node is named "Line2D"
@onready var trajectory_line: Line2D = $Line2D

var is_holding := false
var start: Vector2
var end: Vector2
var sling_vector: Vector2

# We'll store the project's gravity vector here
var gravity: Vector2

func _ready() -> void:
	# This gets the total gravity vector affecting this specific body
	# It accounts for project gravity and the body's gravity_scale
	gravity = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_scale)

	# Error check in case you forgot the Line2D node
	if not trajectory_line:
		print("Trajectory Line2D node not found! Please add a Line2D child.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# 1. When player first presses
	if Input.is_action_just_pressed("touch"):
		is_holding = true
		start = get_global_mouse_position()
		# Ensure line is clear when starting a new pull
		if trajectory_line:
			trajectory_line.clear_points()

	# 2. While player is holding
	if is_holding:
		# Continuously update the end position and vector
		end = get_global_mouse_position()
		sling_vector = end - start

		# Draw the predicted path if the line node exists
		if trajectory_line:
			draw_trajectory(sling_vector)

	# 3. When player releases
	if Input.is_action_just_released("touch"):
		# Only apply impulse if we were actually holding (to avoid mis-clicks)
		if is_holding:
			is_holding = false

			# Apply the calculated impulse
			apply_impulse(-sling_vector * JUMP_VECTOR)

			# Clear the line after launching
			if trajectory_line:
				trajectory_line.clear_points()


## --- New Trajectory Function ---

func draw_trajectory(current_sling_vector: Vector2) -> void:
	# Start by clearing the previous frame's line
	trajectory_line.clear_points()

	# 1. Calculate the initial velocity from the impulse
	# Impulse = mass * change_in_velocity  =>  change_in_velocity = Impulse / mass
	var initial_velocity: Vector2 = (-current_sling_vector * JUMP_VECTOR) / mass

	# 2. Get the starting position for the prediction
	var start_pos: Vector2 = global_position

	# 3. Set simulation parameters (you can tweak these)
	var time_step: float = 0.05  # How far apart in time each point is
	var num_points: int = 30     # How many points to draw for the line

	# 4. Loop to calculate and add points
	for i in range(num_points):
		var t: float = i * time_step

		# Projectile motion formula: 
		# position = start_pos + (velocity * time) + (0.5 * gravity * time^2)
		# We calculate the displacement (s = ut + 0.5at^2) and add it to the start
		var displacement: Vector2 = (initial_velocity * t) + (0.5 * gravity * t * t)
		var predicted_pos: Vector2 = start_pos + displacement

		# 5. Add the point to the Line2D
		# We must convert the global position back to the Line2D's local space
		trajectory_line.add_point(trajectory_line.to_local(predicted_pos))

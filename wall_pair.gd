class_name WallPair

extends RigidBody2D

@export var x_position = 2500
@export var starting_x_position = 2200

var y_position : float

func _ready() -> void:
	reset_position(starting_x_position)
	
func move_wall(force: Vector2):
	force.y = 0
	angular_velocity = 0
	apply_impulse(-force)

func _process(delta: float) -> void:
	position.y = y_position

func reset_position(x_position):
	## TODO Perlin Noise Y Position
	y_position = randf_range(1080/4, 1080*0.75)
	position.y = y_position
	global_position.x = x_position
	if linear_velocity.x < 0:
		linear_velocity.x *= 0.8

class_name WallPair

extends RigidBody2D

var y_position : float

func _ready() -> void:
	y_position = position.y

func move_wall(force: Vector2): # Good practice to type-hint the arg
	force.y = 0
	angular_velocity = 0
	apply_impulse(-force)

func _process(delta: float) -> void:
	position.y = y_position

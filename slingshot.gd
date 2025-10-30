extends RigidBody2D

@export var JUMP_VECTOR = 0

var is_holding := false
var start : Vector2
var end : Vector2
var sling_vector : Vector2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("touch"):
		start = get_global_mouse_position()
	if Input.is_action_just_released("touch"):
		end = get_global_mouse_position()
		sling_vector = end - start
		apply_impulse(-sling_vector * JUMP_VECTOR)

extends RigidBody2D

func _ready() -> void:
	Global.slingshot.connect(move)
	
func move(force):
	force.y = 0
	linear_velocity.y = 0
	angular_velocity = 0
	apply_impulse(-force)

func _process(delta: float) -> void:
	angular_velocity = 0

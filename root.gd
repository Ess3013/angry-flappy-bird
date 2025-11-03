extends Node2D

@onready var bird: Slingshot = $Bird
# I'm assuming $Node2D is the node with the wall_pair.gd script
@onready var node_2d: WallPair = $Node2D 

func _ready() -> void:
	# This connection is correct, but the function it calls is not
	bird.slingshot.connect(func(force): node_2d.move_wall(force))


func _on_area_2d_body_entered(body: Node2D) -> void:
	print_debug("Wall finished")
	node_2d.reset_position(node_2d.x_position)

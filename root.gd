extends Node2D

@onready var bird: Slingshot = $Bird
# I'm assuming $Node2D is the node with the wall_pair.gd script
@onready var node_2d: WallPair = $Node2D 

func _ready() -> void:
	# This connection is correct, but the function it calls is not
	bird.slingshot.connect(func(force): node_2d.move_wall(force))

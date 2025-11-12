extends Node2D

@onready var node_2d: WallPair = $Node2D



func _process(delta: float) -> void:
	await get_tree().create_timer(2).timeout
	$Node2D.move_wall(Vector2.RIGHT * 5)


func _on_area_2d_body_entered(body: Node2D) -> void:
	node_2d.reset_position(node_2d.x_position)

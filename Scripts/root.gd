##region Old
#extends Node2D
#
#@onready var bird: Slingshot = $Bird
#
#var all_walls
## I'm assuming $Node2D is the node with the wall_pair.gd script
#
#func _ready() -> void:
	## This connection is correct, but the function it calls is not
	##get_all_walls()
	#all_walls = get_tree().get_nodes_in_group("Wall")
	#
	#bird.slingshot.connect(func(force): for wall in all_walls: wall.move_wall(force))
	#bird.dead.connect(
		#func(): await get_tree().create_timer(1).timeout.connect(
		#func(): get_tree().reload_current_scene()))
#
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	##node_2d.reset_position(node_2d.x_position)
	#if body is WallPair:
		#body.reset_position(body.x_position)
		#
#func get_all_walls():
	#all_walls = get_children()
	#for wall in all_walls:
		#if wall is not WallPair:
			#all_walls.erase(wall)
##endregion

##region Old2
#extends Node2D
#
#@onready var bird: Slingshot = $Bird
#
### The distance (in pixels) to maintain between the two walls.
#@export var wall_spacing: float = 1000.0
#
#var all_walls: Array = []
#
#func _ready() -> void:
	## 1. Get all walls using the "walls" group
	#all_walls = get_tree().get_nodes_in_group("Wall")
	#
	## Safety check
	##if all_walls.size() != 2:
		##print_error("ERROR: Expected 2 nodes in 'walls' group, but found %s" % all_walls.size())
		##return
#
	## 2. Set up initial positions
	## We use the starting_x_position from the WallPair script for the first wall
	#var start_x = all_walls[0].starting_x_position
	#all_walls[0].reset_position(start_x)
	#
	## Position the second wall relative to the first
	#all_walls[1].reset_position(start_x + wall_spacing)
#
	## 3. Connect signals
	#bird.slingshot.connect(func(force): 
		#for wall in all_walls: 
			#wall.move_wall(force)
	#)
	#
	#bird.dead.connect(func(): 
		#await get_tree().create_timer(1).timeout
		#get_tree().reload_current_scene()
	#)
#
#
#func _on_area_2d_body_entered(body: Node2D) -> void:
	## Check if the body that entered is a wall
	#if body is not WallPair:
		#return
#
	## Find the *other* wall (the one that *didn't* just enter)
	#var other_wall = null
	#for wall in all_walls:
		#if wall != body:
			#other_wall = wall
			#break # Found it, stop looping
#
	##if other_wall == null:
		##print_error("Could not find the other wall!")
		##return
#
	## LEAPFROG LOGIC:
	## Calculate the new reset position based on the
	## *other* wall's current position plus the spacing.
	#var reset_x = other_wall.global_position.x + wall_spacing
	#
	## Tell the wall that just entered the trigger to reset
	## itself to this new leapfrog position.
	#body.reset_position(reset_x)
##endregion

extends Node2D

@onready var bird: Slingshot = $Bird

## The distance (in pixels) to maintain between each wall.
@export var wall_spacing: float = 1000.0

var all_walls: Array = []

func _ready() -> void:
	# 1. Get all walls using the "walls" group
	all_walls = get_tree().get_nodes_in_group("Wall")
	
	# Safety check
	#if all_walls.size() == 0:
		#print_error("ERROR: No nodes found in 'walls' group. Did you add them?")
		#return
	
	print("Found %s walls" % all_walls.size())

	# 2. Set up initial positions
	# Get the starting_x_position from the *first* wall to use as a base
	var start_x = all_walls[0].starting_x_position
	
	# Loop through all walls and place them one after another
	for i in all_walls.size():
		var wall = all_walls[i]
		# Position each wall relative to the start, multiplied by the spacing
		var pos_x = start_x + (i * wall_spacing)
		wall.reset_position(pos_x)


	# 3. Connect signals (This part is unchanged)
	bird.slingshot.connect(func(force): 
		for wall in all_walls: 
			wall.move_wall(force)
	)
	
	bird.dead.connect(func(): 
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()
	)


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Check if the body that entered is a wall
	if body is not WallPair:
		return

	# --- NEW LEAPFROG LOGIC ---
	
	# 1. Find the current right-most wall's position (the "leader")
	# We start with -infinity so any wall position will be greater.
	var max_x = -INF 
	
	for wall in all_walls:
		# The 'body' wall is on the far left, so it will
		# never be the one with the max_x. This loop
		# will correctly find the "leader" of the pack.
		if wall.global_position.x > max_x:
			max_x = wall.global_position.x
			
	# 2. Calculate the new reset position
	# It's the right-most wall's position plus our spacing.
	var reset_x = max_x + wall_spacing
	
	# 3. Tell the wall that just entered the trigger
	# to reset itself to this new leapfrog position.
	body.reset_position(reset_x)

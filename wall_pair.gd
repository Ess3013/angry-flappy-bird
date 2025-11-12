class_name WallPair
extends RigidBody2D

@export var x_position = 2500
@export var starting_x_position = 2200

## The min/max Y-position for the center of the wall gap
@export var min_y_position: float = 1080.0 / 4.0 # 270
@export var max_y_position: float = 1080.0 * 0.75 # 810

## --- Noise Configuration ---
## How "far" to step along the noise pattern each reset.
## Higher values = more drastic Y-position changes.
@export var noise_step: float = 1.5

## How "zoomed in" the noise is.
## Lower values = smoother, slower changes.
@export var noise_frequency: float = 0.1
## ------------------------------

var y_position : float

# Our noise generator
var noise = FastNoiseLite.new()
# Our current position on the 1D noise line
var noise_x_index: float = 0.0

func _ready() -> void:
	# Set up the noise generator
	noise.seed = randi() # Use a random seed for different patterns each game
	noise.noise_type = FastNoiseLite.TYPE_PERLIN # You can also try TYPE_SIMPLEX_SMOOTH
	noise.frequency = noise_frequency
	
	# Using fractal noise adds more detail and variation
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM # "Fractional Brownian Motion"
	noise.fractal_octaves = 3 # Number of noise layers to combine
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	
	noise_x_index = randf() * 1000.0
	
	reset_position(starting_x_position)
	
func move_wall(force: Vector2):
	force.y = 0
	angular_velocity = 0
	apply_impulse(-force)

func _process(delta: float) -> void:
	# This ensures the Y position is locked to what we set
	position.y = y_position

func reset_position(x_pos): # Renamed variable to avoid shadowing
	# 1. Get the raw noise value (ranges from -1.0 to 1.0)
	var noise_value = noise.get_noise_1d(noise_x_index)
	print(noise_value)
	
	# 2. Increment our position on the noise line for the *next* reset
	noise_x_index += noise_step
	print(noise_x_index)
	
	# 3. Map the noise value from [-1.0, 1.0] to your desired Y-range
	# We use the remap() function for this:
	# remap(value, from_min, from_max, to_min, to_max)
	y_position = remap(noise_value, -1.0, 1.0, min_y_position, max_y_position)
	print(y_position)
	
	# --- The rest of your function ---
	position.y = y_position
	global_position.x = x_pos
	if linear_velocity.x < 0:
		linear_velocity.x *= 0.8
	print_debug(position.y)

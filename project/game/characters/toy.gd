extends CharacterBody2D


## Sprite to display for the toy
@export_enum("dolly", "jack", "teddy") var toy_sprite := "dolly"
## Target for the toy to follow
@export var target: Node2D
## Distance from the target the toy will follow at (px)
@export var follow_distance := 40.0
## Speed of the toy (px/s)
@export var follow_speed := 200.0
## When the toy is farther than this distance from the target, it will temporarily disable collision 
## and speed up until it reaches the target again.
@export var catch_up_distance := 200.0

# Speed multiplier when in ghost mode
const GHOST_MODE_SPEED_MULT := 1.5

# When enabled, the toy has no collision
var ghost_mode := false

@onready var collision: CollisionShape2D = $Collision
@onready var interactable: Interactable = $Interactable


func _process(delta: float) -> void:
	var animation = toy_sprite
	# Determine look direction
	var dirs = [Vector2.DOWN, Vector2.UP, Vector2.LEFT, Vector2.RIGHT]
	dirs = dirs.map(func(elem): elem.dot(velocity))
	var facing = dirs.find(dirs.max())
	# Determine if moving
	# Apply appropriate animation
	pass


func _physics_process(_delta: float) -> void:
	var dist_to_target = (target.global_position - global_position).length()
	if dist_to_target > follow_distance:
		# Check if outside the catch up range
		if not ghost_mode and dist_to_target > catch_up_distance:
			ghost_mode = true
			collision.disabled = true
		# Move towards target
		velocity = (target.global_position - global_position).normalized() * follow_speed
		if ghost_mode:
			velocity *= GHOST_MODE_SPEED_MULT
	else:
		velocity = Vector2.ZERO
		# Re-enable collision after catching up
		if ghost_mode:
			ghost_mode = false
			collision.disabled = false
	
	move_and_slide()

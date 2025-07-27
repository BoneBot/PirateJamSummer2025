extends CharacterBody2D


@onready var sprite := $Sprite
@onready var interact_pivot := $InteractPivot
@onready var camera := $Camera
@onready var animation_player := $AnimationPlayer


const SPEED := 200					# Max walking speed (px/s)
const PLAYER_INTERACT_ROTATIONS := {
	"down": 0,
	"left": 90,
	"up": 180,
	"right": 270,
}

var facing := "down"		# The direction the player is currently facing. Can be "up", "down", "left", or "right".


func _process(_delta: float) -> void:
	# Change facing direction
	var facing_changed := false
	if Input.is_action_pressed("down"):
		# Facing down
		facing = "down"
		facing_changed = true
	elif Input.is_action_pressed("up"):
		# Facing up
		facing = "up"
		facing_changed = true

	if Input.is_action_pressed("right"):
		# Facing right
		facing = "right"
		facing_changed = true
	elif Input.is_action_pressed("left"):
		# Facing left
		facing = "left"
		facing_changed = true
	
	if facing_changed:
		interact_pivot.rotation_degrees = PLAYER_INTERACT_ROTATIONS[facing]
	
	# Update animation
	var animation := _get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func _physics_process(_delta: float) -> void:
	# Handle walking
	var h_dir := Input.get_axis("left", "right")
	var v_dir := Input.get_axis("up", "down")
	velocity = Vector2(h_dir, v_dir).normalized() * SPEED
	
	move_and_slide()


func set_camera_limits(pos:Vector2, size:Vector2):
	camera.limit_left = pos.x
	camera.limit_top = pos.y
	camera.limit_right = pos.x + size.x
	camera.limit_bottom = pos.y + size.y


func _get_new_animation() -> String:
	var new_animation: String
	
	# Determine next animation
	if velocity.length() > 0:
		new_animation = "walk_"
	else:
		new_animation = "idle_"
	
	# Apply direction and return
	new_animation += facing
	return new_animation

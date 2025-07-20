extends CharacterBody2D


@onready var sprite := $Sprite
@onready var interact_range := $InteractRange
@onready var camera := $Camera


const SPEED := 200					# Max walking speed (px/s)
const PLAYER_INTERACT_OFFSETS := {	# Offset positions for the interact range
	"down": Vector2(0, 18),
	"up": Vector2(0, -18),
	"right": Vector2(28, 0),
	"left": Vector2(-28, 0),
}


func _process(_delta: float) -> void:
	# Change facing direction
	if Input.is_action_pressed("down"):
		# Facing down
		interact_range.position = PLAYER_INTERACT_OFFSETS["down"]
	elif Input.is_action_pressed("up"):
		# Facing up
		interact_range.position = PLAYER_INTERACT_OFFSETS["up"]

	if Input.is_action_pressed("right"):
		# Facing right
		interact_range.position = PLAYER_INTERACT_OFFSETS["right"]
	elif Input.is_action_pressed("left"):
		# Facing left
		interact_range.position = PLAYER_INTERACT_OFFSETS["left"]


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

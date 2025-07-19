# demo.gd
extends Node2D


@onready var ding_sound := $Ding
@onready var player := $DemoPlayer
@onready var player_sprite := $DemoPlayer/Sprite2D
@onready var player_interact_range := $DemoPlayer/InteractRange
@onready var chest := $Chest
@onready var chest_interactable := $Chest/Interactable

const SPEED := 200		# Max walking speed (px/s)
const PLAYER_INTERACT_OFFSETS := {
	"down": Vector2(0, 46),
	"up": Vector2(0, -46),
	"right": Vector2(32, 0),
	"left": Vector2(-32, 0),
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chest_interactable.interact = _on_chest_interact


func _process(_delta: float) -> void:
	# Change facing direction
	if Input.is_action_pressed("down"):
		# Facing down
		player_interact_range.position = PLAYER_INTERACT_OFFSETS["down"]
	elif Input.is_action_pressed("up"):
		# Facing up
		player_interact_range.position = PLAYER_INTERACT_OFFSETS["up"]

	if Input.is_action_pressed("right"):
		# Facing right
		player_interact_range.position = PLAYER_INTERACT_OFFSETS["right"]
		player_sprite.flip_h = false
	elif Input.is_action_pressed("left"):
		# Facing left
		player_interact_range.position = PLAYER_INTERACT_OFFSETS["left"]
		player_sprite.flip_h = true



func _physics_process(_delta: float) -> void:
	# Handle walking
	var h_dir := Input.get_axis("left", "right")
	var v_dir := Input.get_axis("up", "down")
	player.velocity = Vector2(h_dir, v_dir).normalized() * SPEED
	
	player.move_and_slide()


func _on_demo_goal_body_entered(_body: Node2D) -> void:
	ding_sound.play()
	print("You found the goal!")

func _on_chest_interact() -> void:
	ding_sound.play()
	print("You opened the chest!")

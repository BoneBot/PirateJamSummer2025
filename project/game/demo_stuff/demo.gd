# demo.gd
extends Node2D


@onready var ding_sound := $Ding
@onready var player := $DemoPlayer
@onready var player_sprite := $DemoPlayer/Sprite2D
@onready var player_interact_range := $DemoPlayer/InteractRange
@onready var chest_1_interactable := $Chest1/Interactable
@onready var chest_2_interactable := $Chest2/Interactable
@onready var dialogue_manager := $CanvasLayer/DialogueManager

const SPEED := 200		# Max walking speed (px/s)
const PLAYER_INTERACT_OFFSETS := {
	"down": Vector2(0, 46),
	"up": Vector2(0, -46),
	"right": Vector2(32, 0),
	"left": Vector2(-32, 0),
}

var chest_1_dialogue_state = 0
var chest_2_dialogue_state = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chest_1_interactable.interact = _on_chest_1_interact
	chest_2_interactable.interact = _on_chest_2_interact


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


func _on_chest_1_interact() -> void:
	print("You opened chest 1!")
	await dialogue_manager.start_dialogue("chest_1", chest_1_dialogue_state)
	if chest_1_dialogue_state == 0:
		ding_sound.play()
	if chest_1_dialogue_state < 2:
		chest_1_dialogue_state += 1


func _on_chest_2_interact() -> void:
	print("You opened chest 2!")
	if chest_2_dialogue_state == 0:
		var result = await dialogue_manager.start_dialogue("chest_2", 0)
		if result == 0:
			await dialogue_manager.start_dialogue("chest_2", 1)
		elif result == 1:
			await dialogue_manager.start_dialogue("chest_2", 2)
		else:
			print("Didn't get a valid dialogue result: %d" % result)
		chest_2_dialogue_state += 1
	ding_sound.play()

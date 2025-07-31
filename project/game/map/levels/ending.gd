extends Node2D


## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)

@onready var background: Sprite2D = $Background
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var car_door: Interactable = $ObjectBounds/CarDoor
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# The current toy to display
var current_toy:String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	car_door.interact = _on_car_interact
	toy.toy_sprite = current_toy
	await dialogue_manager.start_dialogue("start", 0)


func _on_car_interact():
	player.visible = false
	player.can_move = false
	toy.visible = false
	await dialogue_manager.start_dialogue("car", 0)
	shadow.visible = true
	# Fade to black
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	level_exited.emit("bedroom")


func set_toy(toy_name:String):
	print("Set toy to %s" % toy_name)
	current_toy = toy_name
	if toy != null:
		toy.toy_sprite = current_toy

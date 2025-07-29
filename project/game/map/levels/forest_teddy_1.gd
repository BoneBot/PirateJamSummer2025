extends Node2D


## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)

@onready var background: Sprite2D = $Background
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager
@onready var vine_door: StaticBody2D = $Components/VineDoor
@onready var teddy_rose: Node2D = $Components/BushSingle/FadingRose

# Total number of roses in the level
var total_num_roses:int
# Current number of roses interacted with
var rose_count := 0
# Current dialogue state
# 0 - Beginning 
# 1 - Teddy is looking at a rose
# 2 - After Teddy looks at a rose
var dialogue_state := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	
	total_num_roses = len(get_tree().get_nodes_in_group("roses"))
	for rose in get_tree().get_nodes_in_group("roses"):
		rose.rose_interacted.connect(_on_rose_interacted)
	
	toy.interactable.interact = _on_toy_interact
	vine_door.interactable.interact = _on_vine_door_interact
	
	await dialogue_manager.start_dialogue("start", 0)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("bedroom")


func _on_rose_interacted() -> void:
	rose_count += 1
	
	# Check if first rose
	if rose_count == 1:
		await dialogue_manager.start_dialogue("rose", 0)
		toy.target = player
	# All roses found
	elif rose_count == total_num_roses:
		vine_door.open_door()
		await dialogue_manager.start_dialogue("rose", 2)
	else:
		await dialogue_manager.start_dialogue("rose", 1)


func _on_toy_interact() -> void:
	if dialogue_state == 1:
		await dialogue_manager.start_dialogue("teddy", 0)
		dialogue_state = 2
		get_tree().set_group("roses", "fades", true)
		teddy_rose._on_visibility_body_entered(player)


func _on_vine_door_interact() -> void:
	await dialogue_manager.start_dialogue("vine_door", 0)


func _on_dialogue_area_dialogue_triggered() -> void:
	toy.target = teddy_rose
	dialogue_state = 1

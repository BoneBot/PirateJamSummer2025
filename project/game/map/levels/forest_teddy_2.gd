extends Node2D


@onready var background: Sprite2D = $Background
@onready var vine_door: StaticBody2D = $Components/VineDoor
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)

# Total number of roses in the level
var total_num_roses:int
# Current number of roses interacted with
var rose_count := 0
# The current dialogue state
# 0 - Teddy is asleep and won't be woken up
# 1 - Teddy is asleep and can be woken up
# 2 - Teddy is awake
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
	
	play_music.emit("forest")


func _on_rose_interacted() -> void:
	rose_count += 1
	
	# All roses found
	if rose_count == total_num_roses:
		vine_door.open_door()
		shadow.visible = true
		play_music.emit("shadow")
		await dialogue_manager.start_dialogue("rose", 1)
		shadow.visible = false
		play_music.emit("")
	else:
		await dialogue_manager.start_dialogue("rose", 0)


func _on_toy_interact() -> void:
	if dialogue_state == 0:
		await dialogue_manager.start_dialogue("teddy", 0)
	elif dialogue_state == 1:
		await dialogue_manager.start_dialogue("teddy", 1)
		dialogue_state += 1
		toy.target = player
		get_tree().set_group("roses", "fades", true)


func _on_vine_door_interact() -> void:
	await dialogue_manager.start_dialogue("vine_door", 0)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("forest_teddy_3")


func _on_dialogue_area_dialogue_triggered() -> void:
	if dialogue_state == 0:
		dialogue_state += 1

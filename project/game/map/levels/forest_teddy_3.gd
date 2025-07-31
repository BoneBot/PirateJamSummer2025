extends Node2D


@onready var background: Sprite2D = $Background
@onready var vine_door: StaticBody2D = $Components/VineDoor
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var shadow_rose: Node2D = $ShadowRose
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)

# Total number of roses in the level
var total_num_roses:int
# Current number of roses interacted with
var rose_count := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	
	total_num_roses = len(get_tree().get_nodes_in_group("roses"))
	for rose in get_tree().get_nodes_in_group("roses"):
		rose.rose_interacted.connect(_on_rose_interacted)
	
	vine_door.interactable.interact = _on_vine_door_interact
	
	await dialogue_manager.start_dialogue("start", 0)
	
	play_music.emit("forest")


func _on_rose_interacted() -> void:
	rose_count += 1
	
	# All roses found
	if rose_count == total_num_roses:
		vine_door.open_door()
		await dialogue_manager.start_dialogue("rose", 1)
	else:
		await dialogue_manager.start_dialogue("rose", 0)


func _on_vine_door_interact() -> void:
	await dialogue_manager.start_dialogue("vine_door", 0)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	# Shadow appears
	shadow.visible = true
	play_music.emit("shadow")
	await dialogue_manager.start_dialogue("exit", 0)
	
	# Shadow offers a rose and leaves
	shadow_rose.visible = true
	await dialogue_manager.start_dialogue("exit", 1)
	
	# Teddy and Sol finish talking
	shadow.visible = false
	play_music.emit("")
	await dialogue_manager.start_dialogue("exit", 2)
	
	# Teddy picks up rose
	toy.target = toy
	player.can_move = false
	player.visible = false
	await get_tree().create_timer(2.0).timeout
	toy.target = shadow_rose
	await get_tree().create_timer(2.0).timeout
	shadow_rose.visible = false
	toy.target = vine_door
	await get_tree().create_timer(1.0).timeout
	
	# They leave
	level_exited.emit("ending")

extends Node2D


@onready var background: Sprite2D = $Background
@onready var vine_door: StaticBody2D = $Components/VineDoor
@onready var block: RigidBody2D = $Components/Block
@onready var button_interactable: Interactable = $Components/BlockButton/Interactable
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)

# The starting position of all blocks in the level
var block_starting_positions:Array[Vector2] = []
# The current dialogue state
# 0 - No one has tried to push the block
# 1 - Jack is trying to push the block on his own
# 2 - The block has been pushed, but is not on the button
# 3 - The block is on the button
var dialogue_state := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	
	for block_item in get_tree().get_nodes_in_group("blocks"):
		block_starting_positions.append(block_item.global_position)
	
	toy.interactable.interact = _on_toy_interact
	vine_door.interactable.interact = _on_vine_door_interacted
	button_interactable.interact = _on_block_button_interacted
	
	# Trigger starting dialogue
	await dialogue_manager.start_dialogue("start", 0)
	
	play_music.emit("forest")


func _on_toy_interact() -> void:
	print("Toy interact")
	if dialogue_state == 1:
		await dialogue_manager.start_dialogue("jack", 0)
		# Disable further interactable on Jack to avoid duplicate interactions
		toy.interactable.is_interactable = false


func _on_vine_door_interacted() -> void:
	if not vine_door.is_open:
		await dialogue_manager.start_dialogue("vine_door", 0)


func _on_block_button_interacted() -> void:
	if dialogue_state < 3:
		await dialogue_manager.start_dialogue("button", 0)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	player.can_move = false
	player.visible = false
	toy.visible = false
	await get_tree().create_timer(1.0).timeout
	shadow.visible = true
	play_music.emit("shadow")
	await dialogue_manager.start_dialogue("exit", 0)
	shadow.visible = false
	play_music.emit("")
	level_exited.emit("forest_jack_2")


func _on_block_button_body_entered(_body: Node2D) -> void:
	vine_door.open_door()
	dialogue_state = 3
	await dialogue_manager.start_dialogue("button", 1)


func _on_block_interacted() -> void:
	if dialogue_state == 0:
		# Trigger dialogue
		player.can_move = false
		await dialogue_manager.start_dialogue("block", 0)
		await get_tree().create_timer(2.0).timeout
		await dialogue_manager.start_dialogue("block", 1)
		player.can_move = true
		
		# Advance state
		toy.target = block
		block.can_push = true
		dialogue_state = 1
		print("Dialogue state 1")
	elif dialogue_state == 1:
		# Trigger dialogue
		await get_tree().create_timer(0.5).timeout
		await dialogue_manager.start_dialogue("block", 2)
		
		# Advance state
		toy.target = player
		dialogue_state = 2
		print("Dialogue state 2")

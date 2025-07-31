extends Node2D


@onready var background: Sprite2D = $Background
@onready var vine_door: StaticBody2D = $Components/VineDoor
@onready var block: RigidBody2D = $Components/Block
@onready var reset_point: Marker2D = $ResetPoint
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)

# The starting position of all blocks in the level
var block_starting_positions:Dictionary
# The state of buttons in the level. True indicates they are pressed.
var button_states := [false, false]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	
	for block_item in get_tree().get_nodes_in_group("blocks"):
		block_starting_positions[block_item] = Vector2(block_item.global_position)
	
	vine_door.interactable.interact = _on_vine_door_interacted
	
	# Trigger starting dialogue
	await dialogue_manager.start_dialogue("start", 0)
	
	play_music.emit("forest")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		# Change character positions
		var toy_offset = player.position - toy.position
		player.position = reset_point.position
		toy.position = player.position - toy_offset
		
		# Change block positions
		for blk in block_starting_positions:
			blk.linear_velocity = Vector2.ZERO
			PhysicsServer2D.body_set_state(
				blk.get_rid(),
				PhysicsServer2D.BODY_STATE_TRANSFORM,
				Transform2D.IDENTITY.translated(block_starting_positions[blk]))


func _on_vine_door_interacted() -> void:
	if not vine_door.is_open:
		await dialogue_manager.start_dialogue("vine_door", 0)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("ending")


func _check_buttons() -> void:
	if button_states[0] and button_states[1]:
		vine_door.open_door()
		shadow.visible = true
		play_music.emit("shadow")
		await dialogue_manager.start_dialogue("button", 0)
		play_music.emit("")
		shadow.visible = false


func _on_block_button_body_entered(_body: Node2D) -> void:
	button_states[0] = true
	_check_buttons()


func _on_block_button_body_exited(_body: Node2D) -> void:
	button_states[0] = false


func _on_block_button_2_body_entered(_body: Node2D) -> void:
	button_states[1] = true
	_check_buttons()


func _on_block_button_2_body_exited(_body: Node2D) -> void:
	button_states[1] = false

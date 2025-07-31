extends Node2D


@onready var background: Sprite2D = $Background
@onready var player: CharacterBody2D = $Player
@onready var toy: CharacterBody2D = $Toy
@onready var shadow: Node2D = $Shadow
@onready var reset_point: Marker2D = $ResetPoint
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	
	for sentry in get_tree().get_nodes_in_group("sentries"):
		sentry.body_entered.connect(_on_sentry_triggered)
	
	toy.interactable.interact = _on_toy_interact
	
	# Trigger starting dialogue
	player.can_move = false
	await dialogue_manager.start_dialogue("start", 0)
	await get_tree().create_timer(3.0).timeout
	await dialogue_manager.start_dialogue("start", 1)
	player.can_move = true
	
	play_music.emit("forest")


# Reset the player position to the reset point
func _reset_player() -> void:
	var toy_offset = player.position - toy.position
	# Pause scene
	get_tree().paused = true
	# Fade to black
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	# Change positions
	player.position = reset_point.position
	toy.position = player.position - toy_offset
	# Fade back in
	animation_player.play_backwards("fade_to_black")
	# Unpause scene
	get_tree().paused = false


func _on_sentry_triggered(_body: Node2D) -> void:
	_reset_player()


func _on_toy_interact() -> void:
	await dialogue_manager.start_dialogue("dolly", 0)
	get_tree().call_group("sentries", "flash_fov")


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	shadow.visible = true
	play_music.emit("shadow")
	await dialogue_manager.start_dialogue("exit", 0)
	shadow.visible = false
	
	play_music.emit("")
	level_exited.emit("forest_dolly_3")

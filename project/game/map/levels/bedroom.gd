extends Node2D

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)

@onready var background := $Background
@onready var player := $Player
@onready var dolly: CharacterBody2D = $Dolly
@onready var jack: CharacterBody2D = $Jack
@onready var teddy: CharacterBody2D = $Teddy
@onready var sexy_succulent: Interactable = $SexySucculent
@onready var dialogue_manager: Control = $CanvasLayer/DialogueManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	# Stop any music
	play_music.emit("")
	
	# Connect interactions
	dolly.interactable.interact = _on_dolly_interact
	jack.interactable.interact = _on_jack_interact
	teddy.interactable.interact = _on_teddy_interact
	sexy_succulent.interact = _on_succulent_interact
	
	# Trigger starting dialogue
	dialogue_manager.start_dialogue("start", 0)


func _on_dolly_interact():
	var result = await dialogue_manager.start_dialogue("dolly", 0)
	if result == 0:
		await dialogue_manager.start_dialogue("exit", 0)
		_exit_bedroom("forest_dolly_1")


func _on_jack_interact():
	var result = await dialogue_manager.start_dialogue("jack", 0)
	if result == 0:
		await dialogue_manager.start_dialogue("exit", 0)
		_exit_bedroom("forest_jack_1")


func _on_teddy_interact():
	var result = await dialogue_manager.start_dialogue("teddy", 0)
	if result == 0:
		await dialogue_manager.start_dialogue("exit", 0)
		_exit_bedroom("forest_teddy_1")


func _exit_bedroom(next_level:String):
	# Fade to black
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	level_exited.emit(next_level)


func _on_succulent_interact():
	await dialogue_manager.start_dialogue("succulent", 0)

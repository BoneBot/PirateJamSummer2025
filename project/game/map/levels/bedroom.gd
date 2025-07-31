extends Node2D

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)
## Emitted to play music in the level. Contains the name of the music track to play.
signal play_music(track:String)

@onready var background := $Background
@onready var player := $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())
	# Stop any music
	play_music.emit("")


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("forest_dolly_1")


func _on_forest_exit_2_body_entered(_body: Node2D) -> void:
	level_exited.emit("forest_teddy_1")

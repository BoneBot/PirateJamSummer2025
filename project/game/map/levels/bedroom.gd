extends Node2D

## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)

@onready var background := $Background
@onready var player := $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("forest_dolly_1")

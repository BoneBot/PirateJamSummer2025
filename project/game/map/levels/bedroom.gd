extends Node2D


@onready var background := $Background
@onready var player := $Player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.set_camera_limits(background.position, background.texture.get_size())

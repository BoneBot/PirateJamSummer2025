# level.gd
## A single level within the game.
class_name Level
extends Node2D


@export_group("Camera Boundaries")
@export var camera_bounds_pos:Vector2
@export var camera_bounds_size:Vector2

var player:CharacterBody2D = null


func _ready() -> void:
	if has_node("Player"):
		player = $Player
		player.set_camera_limits(camera_bounds_pos, camera_bounds_size)

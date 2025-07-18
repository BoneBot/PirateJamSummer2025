# game.gd
extends Node

## The current scene to display
@export var level: PackedScene

@onready var world = $World

var current_level

func _ready() -> void:
	# Create level
	current_level = level.instantiate()
	
	# Add level to game tree
	world.add_child(current_level)

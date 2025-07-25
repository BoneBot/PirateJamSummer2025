# game.gd
extends Node

## The current scene to display
@export var starting_level: PackedScene
## Path to the folder containing all game levels
@export_dir var level_directory: String

@onready var world = $World

var current_level

func _ready() -> void:
	# Create starting level
	current_level = starting_level.instantiate()
	_connect_level_signals(current_level)
	
	# Add starting level to game tree
	world.add_child(current_level)


func _advance_level(next_level_name:String) -> void:
	print("Advancing level to %s" % next_level_name)
	_unload_current_level()
	_load_level(next_level_name)


# Unloads the current game level 
func _unload_current_level() -> void:
	_disconnect_level_signals(current_level)
	world.call_deferred("remove_child", current_level)
	current_level.queue_free()


# Loads the specified level
func _load_level(level_name:String) -> void:
	# Construct the path to the level scene
	var path = level_directory + "/" + level_name + ".tscn"
	
	# Attempt to find the level scene
	var next_level_scene
	if ResourceLoader.exists(path):
		# Level scene found; load
		next_level_scene = load(path)
		current_level = next_level_scene.instantiate()
		_connect_level_signals(current_level)
		world.add_child(current_level)
	else:
		# Level scene not found
		print("ERROR: Could not find level scene located at: " + path)


# Connects all important signals to the given level instance
func _connect_level_signals(level_instance:Node):
	if level_instance.has_signal("level_exited"):
		level_instance.level_exited.connect(_advance_level)
	else:
		print("WARN: Level %s has no level_exited signal to connect" % level_instance.name)


# Disconnects all important signals from the given level instance
func _disconnect_level_signals(level_instance:Node):
	if level_instance.has_signal("level_exited") and level_instance.level_exited.is_connected(_advance_level):
		level_instance.level_exited.disconnect(_advance_level)

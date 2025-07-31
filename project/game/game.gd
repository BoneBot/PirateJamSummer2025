# game.gd
extends Node

## The current scene to display
@export var starting_level: PackedScene
## Path to the folder containing all game levels
@export_dir var level_directory: String

@onready var world = $World
@onready var mute_icon: Control = $UI/MuteIcon
@onready var forest_music: AudioStreamPlayer = $MusicPlayers/ForestMusic
@onready var shadow_music: AudioStreamPlayer = $MusicPlayers/ShadowMusic

var current_level
var current_toy := ""
var muted := false

func _ready() -> void:
	# Create starting level
	current_level = starting_level.instantiate()
	_connect_level_signals(current_level)
	
	# Add starting level to game tree
	world.add_child(current_level)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mute"):
		muted = not muted
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)
		mute_icon.set_muted(muted)


# Advances to the next specified level
func _advance_level(next_level_name:String) -> void:
	# Set current toy
	if next_level_name.contains("dolly"):
		current_toy = "dolly"
	elif next_level_name.contains("jack"):
		current_toy = "jack"
	elif next_level_name.contains("teddy"):
		current_toy = "teddy"
	
	# Advance level
	print("Advancing level to %s" % next_level_name)
	_unload_current_level()
	_load_level(next_level_name)
	
	# If we're at the ending, let the ending know what the current toy is
	if next_level_name == "ending":
		current_level.call_deferred("set_toy", current_toy)


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
		world.call_deferred("add_child", current_level)
	else:
		# Level scene not found
		print("ERROR: Could not find level scene located at: " + path)


# Plays the specified music track. If an empty string is passed in, all music is stopped. 
func _play_music(track:String):
	forest_music.stop()
	shadow_music.stop()
	
	if track == "forest":
		forest_music.play()
	elif track == "shadow":
		shadow_music.play()
	elif track != "":
		print("WARN: Unrecognized music track %s" % track)


# Connects all important signals to the given level instance
func _connect_level_signals(level_instance:Node):
	if level_instance.has_signal("level_exited"):
		level_instance.level_exited.connect(_advance_level)
	else:
		print("WARN: Level %s has no level_exited signal to connect" % level_instance.name)
	
	if level_instance.has_signal("play_music"):
		level_instance.play_music.connect(_play_music)
	else:
		print("WARN: Level %s has no play_music signal to connect" % level_instance.name)


# Disconnects all important signals from the given level instance
func _disconnect_level_signals(level_instance:Node):
	if level_instance.has_signal("level_exited") and level_instance.level_exited.is_connected(_advance_level):
		level_instance.level_exited.disconnect(_advance_level)
	if level_instance.has_signal("play_music") and level_instance.play_music.is_connected(_play_music):
		level_instance.play_music.disconnect(_play_music)

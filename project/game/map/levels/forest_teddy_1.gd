extends Node2D


## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)

@onready var vine_door: StaticBody2D = $Components/VineDoor

var total_num_roses:int
var rose_count := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make sure to set player camera limits!
	
	total_num_roses = len(get_tree().get_nodes_in_group("roses"))
	for rose in get_tree().get_nodes_in_group("roses"):
		rose.rose_interacted.connect(_on_rose_interacted)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("bedroom")


func _on_rose_interacted() -> void:
	rose_count += 1
	# All roses found
	if rose_count == total_num_roses:
		print("All roses found!")
		vine_door.open_door()

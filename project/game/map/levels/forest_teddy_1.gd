extends Node2D

signal level_exited(next_level:String)

var total_num_roses:int
var rose_count := 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make sure to set player camera limits!
	
	total_num_roses = len(get_tree().get_nodes_in_group("roses"))
	for rose in get_tree().get_nodes_in_group("roses"):
		rose.rose_interacted.connect(_on_rose_interacted)


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("forest_dolly_1")


func _on_rose_interacted() -> void:
	rose_count += 1
	if rose_count == total_num_roses:
		print("All roses found!")

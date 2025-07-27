extends Node2D


## Emitted when the level is exited. Contains the name of the next level to load.
signal level_exited(next_level:String)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_forest_exit_body_entered(_body: Node2D) -> void:
	level_exited.emit("forest_teddy_1")

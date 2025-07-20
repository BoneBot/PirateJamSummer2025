# interact_range.gd
## An area that allows for interacting with Interactables.
class_name InteractRange
extends Area2D

var current_interactions := []
var can_interact := true

func _ready() -> void:
	# Connect signals for detecting areas entered/exited
	area_entered.connect(_on_interact_range_area_entered)
	area_exited.connect(_on_interact_range_area_exited)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		if current_interactions:
			can_interact = false
			await current_interactions[0].interact.call()
			can_interact = true

func _process(_delta: float) -> void:
	if current_interactions and can_interact:
		current_interactions.sort_custom(_sort_by_nearest)

func _sort_by_nearest(area1: Area2D, area2: Area2D) -> bool:
	var dist1 = global_position.distance_to(area1.global_position)
	var dist2 = global_position.distance_to(area2.global_position)
	return dist1 < dist2

func _on_interact_range_area_entered(area: Area2D) -> void:
	current_interactions.push_back(area)

func _on_interact_range_area_exited(area: Area2D) -> void:
	current_interactions.erase(area)

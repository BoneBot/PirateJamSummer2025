extends RigidBody2D


@onready var interact_up: Interactable = $InteractRegions/InteractUp
@onready var interact_down: Interactable = $InteractRegions/InteractDown
@onready var interact_left: Interactable = $InteractRegions/InteractLeft
@onready var interact_right: Interactable = $InteractRegions/InteractRight

# The impulse applied each time the boulder is pushed
const PUSH_IMPULSE := 200


func _ready() -> void:
	interact_up.interact = _on_interact_up
	interact_down.interact = _on_interact_down
	interact_left.interact = _on_interact_left
	interact_right.interact = _on_interact_right


func _on_interact_up() -> void:
	apply_central_impulse(Vector2(0, PUSH_IMPULSE))


func _on_interact_down() -> void:
	apply_central_impulse(Vector2(0, -PUSH_IMPULSE))


func _on_interact_left() -> void:
	apply_central_impulse(Vector2(PUSH_IMPULSE, 0))


func _on_interact_right() -> void:
	apply_central_impulse(Vector2(-PUSH_IMPULSE, 0))

extends RigidBody2D


## Whether or not the boulder can be pushed. When set to false, it cannot be pushed.
@export var can_push := true

@onready var interactable: Interactable = $Interactable
@onready var contact_up: Area2D = $ContactRegions/ContactUp
@onready var contact_down: Area2D = $ContactRegions/ContactDown
@onready var contact_left: Area2D = $ContactRegions/ContactLeft
@onready var contact_right: Area2D = $ContactRegions/ContactRight

## Emitted when the block is interacted with
signal interacted

# The impulse applied each time the boulder is pushed
const PUSH_IMPULSE := 200


func _ready() -> void:
	interactable.interact = _on_block_interacted


func _on_block_interacted() -> void:
	interacted.emit()
	
	if not can_push:
		return
	
	var impulse := Vector2(0, 0)
	if contact_up.has_overlapping_bodies():
		impulse.y += PUSH_IMPULSE
	elif contact_down.has_overlapping_bodies():
		impulse.y -= PUSH_IMPULSE
	elif contact_left.has_overlapping_bodies():
		impulse.x += PUSH_IMPULSE
	elif contact_right.has_overlapping_bodies():
		impulse.x -= PUSH_IMPULSE
	
	apply_central_impulse(impulse)

extends StaticBody2D

## Whether or not the door is currently open
@export var is_open := false
## The forest exit tied to the door
@export var forest_exit: Area2D

@onready var collision: CollisionShape2D = $Collision
@onready var sprite_closed: Sprite2D = $SpriteClosed
@onready var sprite_open: Sprite2D = $SpriteOpen
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	forest_exit.monitoring = false
	if is_open:
		is_open = false  # Setting to false so open_door() will actually run
		open_door()


func open_door() -> void:
	if is_open:
		return
	is_open = true
	sprite_closed.visible = false
	sprite_open.visible = true
	collision.set_deferred("disabled", true)
	interactable.is_interactable = false
	forest_exit.monitoring = true


func close_door() -> void:
	if not is_open:
		return
	is_open = false
	sprite_closed.visible = true
	sprite_open.visible = false
	collision.set_deferred("disabled", false)
	interactable.is_interactable = true
	forest_exit.monitoring = false

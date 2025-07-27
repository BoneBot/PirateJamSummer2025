extends Node2D

## Whether or not the rose will fade. When set false, it is always visible.
@export var fades := true
## Multiplier for the fade duration. E.g. if set to 2, the fade animation plays twice as fast.
@export var fade_speed_scale := 1.0

## Emitted when the rose is interacted with.
signal rose_interacted

@onready var sprite := $Sprite
@onready var interactable := $Interactable
@onready var animation_player := $AnimationPlayer

var has_interacted := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interact = _on_fading_rose_interact
	
	if fades:
		sprite.modulate = Color(sprite.modulate, 0)
		interactable.is_interactable = false
	
	animation_player.speed_scale = fade_speed_scale


func _on_visibility_body_entered(_body: Node2D) -> void:
	if fades:
		animation_player.play("fade")
		#animation_player.play("fade", -1, fade_speed_scale)


func _on_visibility_body_exited(_body: Node2D) -> void:
	if fades:
		animation_player.play_backwards("fade")
		#animation_player.play("fade", -1, -fade_speed_scale)


func _on_fading_rose_interact() -> void:
	if not has_interacted:
		sprite.self_modulate = Color(1, 0, 0)
		rose_interacted.emit()
	has_interacted = true

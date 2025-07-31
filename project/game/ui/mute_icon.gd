extends Control


@export var unmuted_img:Texture2D
@export var muted_img:Texture2D

@onready var texture_rect: TextureRect = $TextureRect


func set_muted(muted:bool):
	if muted:
		texture_rect.texture = muted_img
	else:
		texture_rect.texture = unmuted_img

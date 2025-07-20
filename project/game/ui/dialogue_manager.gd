extends Control


@export_file("*.json") var dialogue_path

@onready var text_box = $TextBox
@onready var dialogue_text = $TextBox/MarginContainer/DialogueText

signal advance_dialogue

var scene_dialogue: Dictionary
var current_interaction := []
var in_progress = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Parse JSON at dialogue_path for dialogue options
	var file_text = FileAccess.get_file_as_string(dialogue_path)
	scene_dialogue = JSON.parse_string(file_text)
	if scene_dialogue == null:
		print("ERROR: Unable to parse scene dialogue at: %s" % dialogue_path)


func _input(event: InputEvent) -> void:
	if in_progress and event.is_action_pressed("interact"):
		advance_dialogue.emit()
		get_viewport().set_input_as_handled()


# Initiates dialogue from the specified source and interaction index
# source (String) - The name of the interactable that is causing the dialogue
# interaction (int) - Specifies which dialogue interaction to execute
func start_dialogue(source:String, interaction:int):
	if scene_dialogue == null:
		return
	
	get_tree().paused = true
	current_interaction = scene_dialogue[source][str(interaction)].duplicate()
	text_box.show()
	in_progress = true
	
	_next_dialogue()
	while in_progress:
		await advance_dialogue
		_next_dialogue()


func _end_dialogue():
	in_progress = false
	text_box.hide()
	get_tree().paused = false


# Displays the next dialogue text in the current interaction
func _next_dialogue():
	if len(current_interaction) == 0:
		_end_dialogue()
	else:
		var line = current_interaction.pop_front()
		if line.has("speaker") and line["speaker"]:
			dialogue_text.text = "%s: %s" % [line["speaker"].to_upper(), line["text"]]
		else:
			dialogue_text.text = line["text"]

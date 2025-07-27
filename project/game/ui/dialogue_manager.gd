extends Control

## The path to the dialogue file for this specific scene
@export_file("*.json") var dialogue_file
## The directory containing all character portraits
@export_dir var portrait_directory

@onready var dialogue_manager: Control = $"."
@onready var text_box = $TextBox
@onready var dialogue_text = $TextBox/MarginContainer/DialogueText
@onready var portrait: TextureRect = $Portrait
@onready var option_box: Control = $OptionBox
@onready var option_labels: Array[Label] = [
	$OptionBox/MarginContainer/VBoxContainer/Option0,
	$OptionBox/MarginContainer/VBoxContainer/Option1,
	$OptionBox/MarginContainer/VBoxContainer/Option2,
	$OptionBox/MarginContainer/VBoxContainer/Option3,
]

## Emits when dialogue text is advanced to the next line.
signal advance_dialogue

# Text prepended to an option to indicate it is currently selected
const SELECTOR_PREFIX = "> "

# Parsed json of the dialogue config
var dialogue_config: Dictionary
# Parsed json of the scene dialogue
var dialogue: Dictionary
# Atlases of the character portraits. Dict[speaker:String, emotions:Dict[emotion:String, texture:Texture2D]]
var portrait_textures: Dictionary = {}
# Dialogue of the current interaction
var current_interaction := []
# The index of the currently selected option
var selected_option:int = 0
# Whether or not dialogue is currently in progress
var in_progress = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Parse scene dialogue file
	dialogue = JSON.parse_string(FileAccess.get_file_as_string(dialogue_file))
	if dialogue == null:
		print("ERROR: Unable to parse scene dialogue at: %s" % dialogue_file)
		return


# Handles input events
func _input(event: InputEvent) -> void:
	if not in_progress:
		return
	
	if event.is_action_pressed("interact"):
		advance_dialogue.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("down"):
		_select_option(selected_option + 1)
	elif event.is_action_pressed("up"):
		_select_option(selected_option - 1)


# Initiates dialogue from the specified source and interaction index
# source (String) - The name of the interactable that is causing the dialogue
# interaction (int) - Specifies which dialogue interaction to execute
# returns an int corresponding to the option selected, if any.
func start_dialogue(source:String, interaction:int):
	# Do not start if there is no valid dialogue
	if dialogue == null:
		return
	
	# Pause game and set up for the current dialogue interaction
	get_tree().paused = true
	current_interaction = dialogue[source][str(interaction)].duplicate()
	dialogue_manager.show()
	in_progress = true
	
	# Continue triggering dialogue until no more remains
	_next_dialogue()
	while in_progress:
		await advance_dialogue
		_next_dialogue()
	
	# Return the last selected option value
	return selected_option


# Triggers the end of dialogue
func _end_dialogue():
	in_progress = false
	option_box.hide()
	dialogue_manager.hide()
	get_tree().paused = false


# Displays the next dialogue text in the current interaction
func _next_dialogue():
	if len(current_interaction) == 0:
		_end_dialogue()
	else:
		# Clear the character portrait
		portrait.texture = null
		
		# Get the next line of dialogue
		var line = current_interaction.pop_front()
		if line.has("speaker") and line["speaker"]:
			# Line specifies a speaker, append it to the dialogue text
			dialogue_text.text = "%s: %s" % [line["speaker"].to_upper(), line["text"]]
			
			# Check for an emotion to apply a character portrait
			if line.has("emotion") and line["emotion"]:
				_set_portrait(line["speaker"], line["emotion"])
		else:
			dialogue_text.text = line["text"]
		
		if line.has("options"):
			_set_options(line["options"])
			_select_option(0)
			option_box.show()
		else:
			option_box.hide()


# Populates the options from an array of strings
func _set_options(options:Array) -> void:
	if len(options) > len(option_labels):
		print("WARN: More options were provided than there is space for. Omitting some options.")
	
	for indx in len(option_labels):
		if indx < len(options):
			option_labels[indx].show()
			option_labels[indx].text = options[indx]
		else:
			option_labels[indx].hide()


# Selects a new option from the list of options in the option box and
# sets the selected_option with the new option index
# index (int) - The index of the option to select
func _select_option(index:int) -> void:
	var visible_options = option_labels.filter(func(lbl): return lbl.visible)
	# Return immediately if desired index is out of bounds
	if index >= len(visible_options) or index < 0:
		return
	
	# Un-select current option
	if option_labels[selected_option].text.begins_with(SELECTOR_PREFIX):
		option_labels[selected_option].text = option_labels[selected_option].text.erase(0, len(SELECTOR_PREFIX))
	
	# Select new option
	option_labels[index].text = SELECTOR_PREFIX + option_labels[index].text
	selected_option = index


# Sets the current dialogue portrait based on the speaker and emotion
func _set_portrait(speaker:String, emotion:String) -> void:
	# Check if we already have a portrait resource for the given speaker and emotion
	if not (speaker in portrait_textures and emotion in portrait_textures[speaker]):
		if not _get_portrait_texture(speaker, emotion):
			# Failed to get portrait texture
			return
	
	portrait.texture = portrait_textures[speaker][emotion]


# Loads the image resource for a portrait texture and adds it to the portrait_textures dict
# Returns true if the load was successful, false otherwise
func _get_portrait_texture(speaker:String, emotion:String) -> bool:
	# Attempt to find the portrait resource for the given speaker and emotion
	var new_texture = load(portrait_directory + "/%s_%s.png" % [speaker, emotion])
	if new_texture == null:
		# No texture found
		print("WARN: Could not load portrait with emotion %s for speaker %s" % [emotion, speaker])
		return false
	
	# Add to list of portrait textures
	if speaker not in portrait_textures:
		portrait_textures[speaker] = {}
	portrait_textures[speaker][emotion] = new_texture
	
	return true

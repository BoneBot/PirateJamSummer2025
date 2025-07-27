extends Control

## The dialogue configuration file path.
@export_file("*.json") var dialogue_config_file
## The path to the dialogue file for this specific scene
@export_file("*.json") var dialogue_file
## The directory containing all character portraits
@export_dir var portrait_directory

@onready var text_box = $TextBox
@onready var dialogue_text = $TextBox/MarginContainer/DialogueText
@onready var portrait: TextureRect = $TextBox/Portrait


## Emits when dialogue text is advanced to the next line.
signal advance_dialogue

# Parsed json of the dialogue config
var dialogue_config: Dictionary
# Parsed json of the scene dialogue
var dialogue: Dictionary
# Atlases of the character portraits. Dict[speaker:String, emotions:Dict[emotion:String, texture:Texture2D]]
var portrait_textures: Dictionary = {}
# Dialogue of the current interaction
var current_interaction := []
# Whether or not dialogue is currently in progress
var in_progress = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Parse dialogue config file
	dialogue_config = JSON.parse_string(FileAccess.get_file_as_string(dialogue_config_file))
	if dialogue_config == null:
		print("ERROR: Unable to parse dialogue config file at: %s" % dialogue_config_file)
		return
	
	# Parse scene dialogue file
	dialogue = JSON.parse_string(FileAccess.get_file_as_string(dialogue_file))
	if dialogue == null:
		print("ERROR: Unable to parse scene dialogue at: %s" % dialogue_file)
		return
	
	# Parse character portrait files
	_get_portrait_textures()


# Populates the portrait_textures Dictionary from the contents of the dialogue_config
func _get_portrait_textures() -> void:
	for character in dialogue_config["speakers"]:
		portrait_textures[character] = {}
		for emotion in dialogue_config["speakers"][character]["emotions"]:
			portrait_textures[character][emotion] = load(portrait_directory + "/%s_%s.png" % [character, emotion])


# Handles input events
func _input(event: InputEvent) -> void:
	if in_progress and event.is_action_pressed("interact"):
		advance_dialogue.emit()
		get_viewport().set_input_as_handled()


# Initiates dialogue from the specified source and interaction index
# source (String) - The name of the interactable that is causing the dialogue
# interaction (int) - Specifies which dialogue interaction to execute
func start_dialogue(source:String, interaction:int):
	if dialogue == null:
		return
	
	get_tree().paused = true
	current_interaction = dialogue[source][str(interaction)].duplicate()
	text_box.show()
	in_progress = true
	
	_next_dialogue()
	while in_progress:
		await advance_dialogue
		_next_dialogue()


# Triggers the end of dialogue
func _end_dialogue():
	in_progress = false
	text_box.hide()
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


# Sets the current dialogue portrait based on the speaker and emotion
func _set_portrait(speaker:String, emotion:String) -> void:
	if speaker not in portrait_textures:
		print("WARN: No portraits for speaker %s" % speaker)
		return
	elif emotion not in portrait_textures[speaker]:
		print("WARN: No emotion %s for speaker %s" % [emotion, speaker])
		return
	
	portrait.texture = portrait_textures[speaker][emotion]

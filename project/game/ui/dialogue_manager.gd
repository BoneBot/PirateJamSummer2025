extends CanvasLayer

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
	# Parse scene dialogue file
	dialogue = JSON.parse_string(FileAccess.get_file_as_string(dialogue_file))
	if dialogue == null:
		print("ERROR: Unable to parse scene dialogue at: %s" % dialogue_file)
		return


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

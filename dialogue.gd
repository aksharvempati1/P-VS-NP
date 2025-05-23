extends Control

signal choice_made

var answer: int
var folder: String = "res://audio//meow" #
var max_time: float = 0.05 # Represents time in seconds to wait before playing next dialogue
var timer: float = max_time
var audio_skip: int = 3 # Plays sound effect every X times a character is said
var characters_since_audio: int = audio_skip # Keeps track of how many characters have been played since last sound effect
var global_delta: float = 0. # Save delta so it can be used to update timer
@onready var text_label: RichTextLabel = $ColorRect/RichTextLabel
@onready var choices: Control = $ColorRect/Choices
@onready var choice1: Button = $ColorRect/Choices/Choice1
@onready var choice2: Button = $ColorRect/Choices/Choice2
var sounds: Array[AudioStreamPlayer]

func update_timer():
	timer -= global_delta

func display_dialogue(text: String, pitch: float = 1.0):
	set_pitch(pitch)
	for i in text.length(): # Cycle through every character in the text
		while timer > 0: # Stall until timer is up
			update_timer()
			await get_tree().process_frame
		var sound: AudioStreamPlayer
		#Add to text
		text_label.text = text.substr(0, i + 1) + "[color=#0000]" + text.substr(i + 1)
		characters_since_audio += 1
		if characters_since_audio >= audio_skip:
			characters_since_audio = 0
			sounds.pick_random().play()
		timer = max_time
		
func get_choice(text: String, c1: String, c2: String, correct_choice: int, pitch: float = 1.0):
	visible = true # Show self
	choice1.text = c1
	choice2.text = c2
	await display_dialogue(text, pitch)
	choices.visible = true
	await choice_made # Wait until the question has been answered
	choices.visible = false
	visible = false
	text_label.text = ""
	return answer == correct_choice # Returns a boolean, false if the player answered incorrectly, true if correct

func play_dialogue(text: String, pitch: float = 1.0):
	visible = true
	await display_dialogue(text, pitch)
	while !Input.is_action_pressed("Accept"):
		await get_tree().process_frame # Stall until user input
	visible = false
	text_label.text = ""
	

func set_pitch(pitch:float):
	for sound in sounds:
		sound.pitch_scale = pitch

func _on_choice_1_pressed() -> void:
	answer = 1
	emit_signal("choice_made")

func _on_choice_2_pressed() -> void:
	answer = 2
	emit_signal("choice_made")

func sound_init():
	var dir: DirAccess = DirAccess.open(folder) # Access folder with audio
	var audio_files: PackedStringArray = dir.get_files()
	for file in audio_files: # Cycle through files
		if len(file) < 7 or file.substr(len(file) - 7) != ".import": # If the file ends with .import, it's not readable
			var player: AudioStreamPlayer = AudioStreamPlayer.new() 
			print(file)
			player.stream = load(folder + '/' + file) # Create new player per audio file so it doesn't have to load every time
			add_child(player)
			sounds.append(player)

func _physics_process(delta: float) -> void:
	global_delta = delta

func _ready() -> void:
	sound_init()

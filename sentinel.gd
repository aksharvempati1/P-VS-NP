extends Node2D

var dialogue: Control
var question: String
var choice1: String = "True"
var choice2: String = "False"
var correct_choice: int

var max_dialogue_end_timer: float = 0.3
var dialogue_end_timer: float = 0.05 # Makes sure player does not immediately interact with sentinel after talking

var is_active: bool = true
var player_in_range: bool = false
var player: CharacterBody2D

@export var pitch: float = 1

@onready var speech_bubble: Sprite2D = $SpeechBubble

func _ready() -> void:
	dialogue = get_tree().get_first_node_in_group("Dialogue")
	player = get_tree().get_first_node_in_group("Player")
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and is_active:
		speech_bubble.visible = true
		player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and is_active:
		speech_bubble.visible = false
		player_in_range = false

func _process(delta: float) -> void:
	if dialogue_end_timer > 0:
		dialogue_end_timer -= delta # Subtract from timer until timer is 0
	if player_in_range and is_active and Input.is_action_just_pressed("Accept") and dialogue_end_timer <= 0:
		is_active = false
		speech_bubble.visible = false
		player.can_move = false # Don't let player move while talking to them
		var choice_correct: bool = await dialogue.get_choice(question, choice1, choice2, correct_choice, pitch)
		
		if choice_correct == true:
			await dialogue.play_dialogue("Correct.", pitch)
			GameState.correct_answer() # Add to the amount of questions the user has answered correctly
		else:
			await dialogue.play_dialogue("Incorrect.", pitch)
			await player.teleport()
			player_in_range = false # Since the player teleported away, script doesn't know player left
			GameState.incorrect_answer()
			GameState.get_new_statement(self) # Reassign question so player can retry
			dialogue_end_timer = max_dialogue_end_timer # Reset timer
			is_active = true # Allow player to retry if they get the question wrong
		
		player.can_move = true

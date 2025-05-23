extends Node

var number_correct: int = 0
var questions_answered: int = 0
var correct_needed_to_win: int = 5
var end_screen: Control
var number_ui: Control
var player: CharacterBody2D

func assignTruth(sentinel: Node2D, person: int) -> void:
	sentinel.question = Questions.trueQuestions[person]
	sentinel.correct_choice = 1 # 1 represents true

func assignLie(sentinel: Node2D, person: int) -> void:
	sentinel.question = Questions.falseQuestions[person]
	sentinel.correct_choice = 2 # 2 represents false

func sentinel_setup():
	var sentinels : Array
	while len(sentinels) == 0:
		sentinels = get_tree().get_nodes_in_group("Sentinel")
		await get_tree().process_frame
		print(sentinels)
	print(sentinels)
	print("The number of sentinels is correct: ", len(sentinels) == Questions.numOfPeople)
	print("Sentinel number: ", len(sentinels))
	var range_index: int
	var peopleToInclude = range(Questions.numOfPeople) # Cycle through every person, represented by a number in the range
	var numOfLies : int = Questions.numOfPeople / 2 # Integer divide so either numOfLies == numOfTruths or numOfLies + 1 == numOfTruths
	var numOfTruths: int = Questions.numOfPeople - numOfLies
	for sentinel in sentinels:
		range_index = randi_range(0, len(peopleToInclude) - 1) # Store index so it can be removed
		var person: int = peopleToInclude[range_index]
		var question: String
		
		if numOfLies > 0 and numOfTruths > 0: # Choose random if possible
			if randi() % 2 == 0: # Effectively a random boolean, returns if random number is odd or even
				assignTruth(sentinel, person)
			else:
				assignLie(sentinel, person)
		elif numOfTruths > 0:
			assignTruth(sentinel, person)
		elif numOfLies > 0:
			assignLie(sentinel, person)
		peopleToInclude.remove_at(range_index) # Make sure every person is represented at the beginning

func get_nodes() -> void:
	#Nodes load at different times, its possible some may not be loaded when get_first_node_in_group is called
	while !end_screen:
		end_screen = get_tree().get_first_node_in_group("EndScreen")
	while !number_ui:
		number_ui = get_tree().get_first_node_in_group("NumberUI")
	while !player:
		player = get_tree().get_first_node_in_group("Player")

func correct_answer():
	number_correct += 1
	questions_answered += 1
	number_ui.update_number(number_correct, correct_needed_to_win)
	if number_correct >= correct_needed_to_win:
		win()

func incorrect_answer():
	questions_answered += 1

func get_new_statement(sentinel: Node2D):
	var person: int = randi_range(0, Questions.numOfPeople - 1) # Get random person number
	if sentinel.correct_choice == 1: # If the sentinel tells truths, add a truth
		assignTruth(sentinel, person)
	else: # Else, it must lie
		assignLie(sentinel, person)

func win():
	player.can_move = false
	var time_elapsed: float = Stopwatch.stop()
	end_screen.win(questions_answered, time_elapsed)

func _ready() -> void:
	get_nodes()
	sentinel_setup()
	Stopwatch.start() # Start the timer as soon as run starts
	number_ui.update_number(number_correct, correct_needed_to_win)

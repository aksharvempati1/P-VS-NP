extends Control

var questions_answered_text: String = "Questions answered: "
var time_text: String = "Time: "

@onready var questions_answered_text_label: RichTextLabel = $ColorRect2/ColorRect/QuestionsAnswered
@onready var time_text_label: RichTextLabel = $ColorRect2/ColorRect/Time

func get_time_string(time: float) -> String:
	var seconds: int = int(time) # Time variable is seconds including milliseconds, so they must be seperated
	var milliseconds = time - seconds # Milliseconds is equal to the amount of time not included when truncated into an integer
	var displayed_milliseconds = int(milliseconds * 100) # Save milliseconds to the first 2 digits, then truncated
	var str_time: String = ""
	if seconds >= 60: # Check if over a minute has passed
		var minutes: int = int(seconds / 60)
		str_time += str(minutes) + ':'
		seconds -= 60 * (minutes) # Removes anything over 60 from seconds
	else:
		str_time += "00:" # Use if there are 0 minutes
	if seconds < 10:
		str_time += '0' + str(seconds) # Saves 1:03 rather than 1:3
	else: 
		str_time += str(seconds)
	if displayed_milliseconds < 10:
		str_time += '.0' + str(displayed_milliseconds)
	else:
		str_time += '.' + str(displayed_milliseconds)
	
	return str_time

func win(questions_answered: int, time: float) -> void:
	visible = true
	print("Time: ", time)
	questions_answered_text_label.text = questions_answered_text + str(questions_answered)
	time_text_label.text = time_text + get_time_string(time)

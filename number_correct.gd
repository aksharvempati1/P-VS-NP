extends Control

@onready var label: RichTextLabel = $ColorRect2/ColorRect/RichTextLabel

func update_number(amountCorrect: int, amount_needed_to_win: int) -> void:
	while !label:
		await get_tree().process_frame # If the label has not loaded yet, wait
	label.text = str(amountCorrect) + "/" + str(amount_needed_to_win)

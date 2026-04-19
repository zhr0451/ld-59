extends Node2D

signal answered(success: bool)

@onready var problem_label: Label = $QuestPanel/Panel/MarginContainer/VBoxContainer/ProblemLabel
@onready var result_label: Label = $QuestPanel/Panel/MarginContainer/VBoxContainer/ResultLabel
@onready var answer_buttons: Array[Button] = [
	$QuestPanel/Panel2/AnswerButton1,
	$QuestPanel/Panel3/AnswerButton2,
	$QuestPanel/Panel4/AnswerButton3,
]

var correct_answer: int = 0
var input_locked := false


func _ready() -> void:
	randomize()

	for button in answer_buttons:
		button.pressed.connect(_on_answer_pressed.bind(button))

	_generate_task()


func _generate_task() -> void:
	var a := randi_range(1, 9)
	var b := randi_range(1, 9)
	var operation := randi_range(0, 1)

	if operation == 0:
		correct_answer = a + b
		problem_label.text = "Stabilize the route: %d + %d = ?" % [a, b]
	else:
		if b > a:
			var temp := a
			a = b
			b = temp

		correct_answer = a - b
		problem_label.text = "Stabilize the route: %d - %d = ?" % [a, b]

	var answers := _build_answers()
	answers.shuffle()

	for i in range(answer_buttons.size()):
		var button := answer_buttons[i]
		var answer_value: int = answers[i]
		button.text = str(answer_value)
		button.set_meta("answer_value", answer_value)
		button.disabled = false

	result_label.text = "Choose the correct answer."
	input_locked = false


func _build_answers() -> Array[int]:
	var answers: Array[int] = [correct_answer]

	while answers.size() < 3:
		var candidate := correct_answer + randi_range(-4, 4)
		if candidate < 0:
			continue
		if answers.has(candidate):
			continue

		answers.append(candidate)

	return answers


func _on_answer_pressed(button: Button) -> void:
	if input_locked:
		return

	input_locked = true

	for answer_button in answer_buttons:
		answer_button.disabled = true

	var chosen_answer := int(button.get_meta("answer_value"))
	var is_correct := chosen_answer == correct_answer

	if is_correct:
		result_label.text = "Correct. The route is stable."
	else:
		result_label.text = "Incorrect. Correct answer: %d" % correct_answer

	answered.emit(is_correct)
	await get_tree().create_timer(1.0).timeout
	_generate_task()

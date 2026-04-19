extends Node

var counter: Counters = preload("uid://cs5lr50tom8xo")

@onready var quest_panel: Panel = %QuestPanel
@onready var teleport_panel: Panel = %TeleportPanel
@onready var title_label: Label = $"../Panel/MarginContainer/VBoxContainer/TitleLabel"
@onready var problem_label: Label = $"../Panel/MarginContainer/VBoxContainer/ProblemLabel"
@onready var result_label: Label = $"../Panel/MarginContainer/VBoxContainer/ResultLabel"
@onready var answer_buttons: Array[Button] = [
	$"../Panel2/AnswerButton1",
	$"../Panel3/AnswerButton2",
	$"../Panel4/AnswerButton3",
]

var correct_answer := 0
var input_locked := false
var current_target_name := "Traveler"


func _ready() -> void:
	randomize()

	for button in answer_buttons:
		button.pressed.connect(_on_answer_pressed.bind(button))

	_reset_labels()


func start_puzzle(target_name: String) -> void:
	current_target_name = target_name
	title_label.text = "Route for %s" % current_target_name
	teleport_panel.set_open(false)
	quest_panel.set_open(true)
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
		counter.good += 1
		result_label.text = "Correct. Teleport window unlocked."
		await get_tree().create_timer(0.8).timeout
		quest_panel.set_open(false)
		teleport_panel.set_open(true)
		_reset_labels()
	else:
		counter.chaos += 1
		result_label.text = "Incorrect. The route destabilized."
		await get_tree().create_timer(1.0).timeout
		_generate_task()


func _reset_labels() -> void:
	title_label.text = "Quest Puzzle"
	problem_label.text = "Awaiting a traveler."
	result_label.text = "Use the loupe and select a character."

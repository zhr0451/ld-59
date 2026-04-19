extends Node

const BAD_ENDING = preload("res://scenes/endings/bad_ending.tscn")

var counter = preload("uid://cs5lr50tom8xo")

@export var base_tasks_required := 1
@export var max_tasks_required := 6
@export var attempts_per_difficulty_step := 2
@export var initial_timer_seconds := 30.0
@export var solved_task_time_bonus := 15.0
@export_node_path("Label") var timer_label_path: NodePath = NodePath("../../TimerPanel/Timer")

@onready var quest_panel: Panel = %QuestPanel
@onready var teleport_panel: Panel = %TeleportPanel
@onready var timer_label: Label = get_node_or_null(timer_label_path) as Label
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
var teleport_attempts := 0
var tasks_required := 1
var tasks_solved := 0
var puzzle_in_progress := false
var timer_started := false
var timer_remaining := 0.0


func _ready() -> void:
	randomize()

	for button in answer_buttons:
		button.pressed.connect(_on_answer_pressed.bind(button))

	_reset_labels()
	_reset_timer_label()


func _process(delta: float) -> void:
	if not timer_started:
		return

	timer_remaining -= delta
	_update_timer_label()

	if timer_remaining <= 0.0:
		timer_started = false
		get_tree().change_scene_to_packed(BAD_ENDING)


func start_puzzle(target_name: String) -> void:
	if puzzle_in_progress and target_name == current_target_name:
		return

	current_target_name = target_name
	teleport_attempts += 1
	tasks_required = _get_tasks_required_for_attempt()
	tasks_solved = 0
	puzzle_in_progress = true

	title_label.text = "Route for %s" % current_target_name
	teleport_panel.set_open(false)
	quest_panel.set_open(true)
	_generate_task()


func _generate_task() -> void:
	var task := _build_task()
	correct_answer = task.answer
	problem_label.text = "Stabilize the route: %s = ?" % task.expression

	var answers := _build_answers()
	answers.shuffle()

	for i in range(answer_buttons.size()):
		var button := answer_buttons[i]
		var answer_value: int = answers[i]
		button.text = str(answer_value)
		button.set_meta("answer_value", answer_value)
		button.disabled = false

	result_label.text = _get_progress_text()
	input_locked = false


func _build_task() -> Dictionary:
	var operation := randi_range(0, 3)
	var a := 0
	var b := 0
	var expression := ""
	var answer := 0

	match operation:
		0:
			a = randi_range(1, 20)
			b = randi_range(1, 20)
			answer = a + b
			expression = "%d + %d" % [a, b]
		1:
			a = randi_range(1, 20)
			b = randi_range(1, 20)
			if b > a:
				var temp := a
				a = b
				b = temp

			answer = a - b
			expression = "%d - %d" % [a, b]
		2:
			a = randi_range(2, 9)
			b = randi_range(2, 9)
			answer = a * b
			expression = "%d x %d" % [a, b]
		3:
			b = randi_range(2, 9)
			answer = randi_range(2, 9)
			a = b * answer
			expression = "%d / %d" % [a, b]

	return {
		"expression": expression,
		"answer": answer,
	}


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
		_apply_correct_answer_timer_reward()
		tasks_solved += 1

		if tasks_solved < tasks_required:
			result_label.text = "Correct. %s" % _get_progress_text()
			await get_tree().create_timer(0.8).timeout
			_generate_task()
			return

		counter.good += 1
		puzzle_in_progress = false
		result_label.text = "Correct. Teleport window unlocked."
		await get_tree().create_timer(0.8).timeout
		quest_panel.set_open(false)
		teleport_panel.set_open(true)
		_reset_labels()
	else:
		counter.evil += 1
		puzzle_in_progress = false
		tasks_solved = 0
		result_label.text = "Incorrect. Teleport failed."
		await get_tree().create_timer(1.0).timeout
		quest_panel.set_open(false)
		_reset_labels()


func _reset_labels() -> void:
	title_label.text = "Quest Puzzle"
	problem_label.text = "Awaiting a traveler."
	result_label.text = "Use the loupe and select a character."


func _get_progress_text() -> String:
	return "Solve route %d/%d." % [tasks_solved + 1, tasks_required]


func _get_tasks_required_for_attempt() -> int:
	var safe_step := maxi(attempts_per_difficulty_step, 1)
	var difficulty_level := int((teleport_attempts - 1) / safe_step)
	var required := base_tasks_required + difficulty_level

	return mini(required, max_tasks_required)


func _apply_correct_answer_timer_reward() -> void:
	if not timer_started:
		timer_started = true
		timer_remaining = initial_timer_seconds
	else:
		timer_remaining += solved_task_time_bonus

	_update_timer_label()


func _reset_timer_label() -> void:
	timer_remaining = initial_timer_seconds
	_update_timer_label()


func _update_timer_label() -> void:
	if timer_label == null:
		return

	var seconds_left := maxi(ceili(timer_remaining), 0)
	timer_label.text = "Time: %02d" % seconds_left

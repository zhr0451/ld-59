extends Node

const BAD_ENDING = preload("res://scenes/endings/bad_ending.tscn")

var counter = preload("uid://cs5lr50tom8xo")

@export var initial_timer_seconds := 60.0
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

var correct_answer_index := -1
var input_locked := false
var current_target_name := "Traveler"
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


func start_puzzle(target_name: String, questions_config: CharacterQuestions = null) -> void:
	if puzzle_in_progress and target_name == current_target_name:
		return

	current_target_name = target_name
	puzzle_in_progress = true

	title_label.text = "Question for %s" % current_target_name
	teleport_panel.set_open(false)
	quest_panel.set_open(true)
	_show_random_question(questions_config)


func _show_random_question(questions_config: CharacterQuestions) -> void:
	var question := _pick_valid_question(questions_config)
	if question == null:
		_show_unavailable_question()
		return

	correct_answer_index = question.correct_answer_index
	problem_label.text = question.question_text

	for i in range(answer_buttons.size()):
		var button := answer_buttons[i]
		button.text = question.answers[i]
		button.set_meta("answer_index", i)
		button.disabled = false

	result_label.text = "Choose an answer."
	input_locked = false


func _pick_valid_question(questions_config: CharacterQuestions) -> NarrativeQuestion:
	if questions_config == null:
		return null

	var valid_questions: Array[NarrativeQuestion] = []
	for question_resource in questions_config.questions:
		var question := question_resource as NarrativeQuestion
		if _is_valid_question(question):
			valid_questions.append(question)

	if valid_questions.is_empty():
		return null

	return valid_questions[randi_range(0, valid_questions.size() - 1)]


func _is_valid_question(question: NarrativeQuestion) -> bool:
	if question == null:
		return false
	if question.question_text.strip_edges().is_empty():
		return false
	if question.answers.size() != answer_buttons.size():
		return false

	return question.correct_answer_index >= 0 and question.correct_answer_index < question.answers.size()


func _show_unavailable_question() -> void:
	correct_answer_index = -1
	input_locked = true
	problem_label.text = "No narrative question is configured for this character."
	result_label.text = "Add questions to the character resource."

	for button in answer_buttons:
		button.text = "-"
		button.disabled = true

	push_warning("main_quest_logic.gd: no valid questions for %s." % current_target_name)


func _on_answer_pressed(button: Button) -> void:
	if input_locked:
		return

	input_locked = true

	for answer_button in answer_buttons:
		answer_button.disabled = true

	var chosen_answer_index := int(button.get_meta("answer_index", -1))
	var is_correct := chosen_answer_index == correct_answer_index

	if is_correct:
		_apply_correct_answer_timer_reward()
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
		result_label.text = "Incorrect. Teleport failed."
		await get_tree().create_timer(1.0).timeout
		quest_panel.set_open(false)
		_reset_labels()


func _reset_labels() -> void:
	title_label.text = "Narrative Puzzle"
	problem_label.text = "Awaiting a traveler."
	result_label.text = "Use the loupe and select a character."


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

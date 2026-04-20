extends Node

const META_WAS_INPUT_PICKABLE = "quest_was_input_pickable"
const META_WAS_PROCESSING = "quest_was_processing"
const META_WAS_PHYSICS_PROCESSING = "quest_was_physics_processing"
const META_WAS_ANIMATION_PLAYING = "quest_was_animation_playing"

var counter = preload("uid://cs5lr50tom8xo")

@onready var quest_panel: Control = %QuestPanel
@onready var teleport_panel: Control = %TeleportPanel
@onready var scene_changer: Node = %SceneChanger
@onready var pop_up_panel: Control = get_node_or_null("../../PopUpPanel") as Control
@onready var outcome_panel: Node = get_node_or_null("../../OutcomePanel")
@onready var title_label: Label = get_node_or_null("../Panel/MarginContainer/VBoxContainer/TitleLabel") as Label
@onready var problem_label: Label = get_node_or_null("../Panel/MarginContainer/VBoxContainer/ProblemLabel") as Label
@onready var result_label: Label = get_node_or_null("../Panel/MarginContainer/VBoxContainer/ResultLabel") as Label
@onready var close_button: Control = get_node_or_null("../TextureRect") as Control
@onready var answer_buttons: Array[Button] = [
	get_node_or_null("../Panel2/AnswerButton1") as Button,
	get_node_or_null("../Panel3/AnswerButton2") as Button,
	get_node_or_null("../Panel4/AnswerButton3") as Button,
]

var correct_answer_index := -1
var input_locked := false
var current_target_name := "Traveler"
var current_character: Area2D = null
var current_question: NarrativeQuestion = null
var puzzle_in_progress := false


func _ready() -> void:
	randomize()

	for button in answer_buttons:
		if button == null:
			push_warning("main_quest_logic.gd: answer button node not found.")
			continue

		button.pressed.connect(_on_answer_pressed.bind(button))

	if close_button != null:
		close_button.mouse_filter = Control.MOUSE_FILTER_STOP
		close_button.gui_input.connect(_on_close_button_gui_input)
	else:
		push_warning("main_quest_logic.gd: close button TextureRect node not found.")

	_reset_labels()


func start_puzzle(target_name: String, questions_config: CharacterQuestions = null, character: Area2D = null) -> void:
	if puzzle_in_progress and target_name == current_target_name:
		current_character = character
		_set_character_frozen(current_character, true)
		_restore_current_question()
		return

	_release_current_character()
	current_target_name = target_name
	current_character = character
	puzzle_in_progress = true
	_set_character_frozen(current_character, true)

	_set_label_text(title_label, "Question for %s" % current_target_name)
	teleport_panel.set_open(false)
	quest_panel.set_open(true)
	_show_random_question(questions_config)


func _show_random_question(questions_config: CharacterQuestions) -> void:
	var question := _pick_valid_question(questions_config)
	if question == null:
		_show_unavailable_question()
		return

	current_question = question
	correct_answer_index = question.correct_answer_index
	_set_label_text(problem_label, question.question_text)

	for i in range(answer_buttons.size()):
		var button := answer_buttons[i]
		if button == null:
			continue

		button.text = question.answers[i]
		button.set_meta("answer_index", i)
		button.disabled = false

	_set_label_text(result_label, "Choose an answer.")
	input_locked = false


func _restore_current_question() -> void:
	if current_question == null:
		return

	correct_answer_index = current_question.correct_answer_index
	_set_label_text(title_label, "Question for %s" % current_target_name)
	_set_label_text(problem_label, current_question.question_text)
	_set_label_text(result_label, "Choose an answer.")

	for i in range(answer_buttons.size()):
		var button := answer_buttons[i]
		if button == null:
			continue

		button.text = current_question.answers[i]
		button.set_meta("answer_index", i)
		button.disabled = false

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
	current_question = null
	input_locked = true
	puzzle_in_progress = false
	_set_label_text(problem_label, "No narrative question is configured for this character.")
	_set_label_text(result_label, "Add questions to the character resource.")

	for button in answer_buttons:
		if button == null:
			continue

		button.text = "-"
		button.disabled = true

	_release_current_character()
	push_warning("main_quest_logic.gd: no valid questions for %s." % current_target_name)


func _on_answer_pressed(button: Button) -> void:
	if input_locked:
		return

	input_locked = true

	for answer_button in answer_buttons:
		if answer_button == null:
			continue

		answer_button.disabled = true

	var chosen_answer_index := int(button.get_meta("answer_index", -1))
	var is_correct := chosen_answer_index == correct_answer_index

	if is_correct:
		counter.good += 1
		puzzle_in_progress = false
		_set_label_text(result_label, "Correct. Teleport started.")
		var showed_outcome := await _show_outcome_banner(chosen_answer_index)
		if not showed_outcome:
			await get_tree().create_timer(0.8).timeout
			quest_panel.set_open(false)
		_hide_pop_up_panel()
		_release_current_character()
		_show_success_character_portal()
		_reset_labels()
	else:
		counter.evil += 1
		puzzle_in_progress = false
		_set_label_text(result_label, "Incorrect. Teleport failed.")
		var failed_character := current_character
		var showed_outcome := await _show_outcome_banner(chosen_answer_index)
		if not showed_outcome:
			await get_tree().create_timer(1.0).timeout
			quest_panel.set_open(false)
		_hide_pop_up_panel()
		_release_current_character()
		_show_failed_character_portal(failed_character)
		_reset_labels()


func _on_close_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if input_locked:
			return

		_hide_active_question_window()


func _hide_active_question_window() -> void:
	quest_panel.set_open(false)
	_hide_pop_up_panel()
	_release_current_character()


func _show_outcome_banner(answer_index: int) -> bool:
	var banner := _get_banner_for_answer(answer_index)
	if banner == null:
		return false
	if outcome_panel == null:
		return false
	if not outcome_panel.has_method("show_banner") or not outcome_panel.has_method("wait_until_closed"):
		return false

	quest_panel.set_open(false)
	var was_shown: bool = bool(outcome_panel.call("show_banner", banner))
	if not was_shown:
		return false

	await outcome_panel.call("wait_until_closed")
	return true


func _get_banner_for_answer(answer_index: int) -> Texture2D:
	if current_question == null:
		return null
	if answer_index < 0 or answer_index >= current_question.answer_banners.size():
		return null

	return current_question.answer_banners[answer_index]


func _reset_labels() -> void:
	_set_label_text(title_label, "Narrative Puzzle")
	_set_label_text(problem_label, "Awaiting a traveler.")
	_set_label_text(result_label, "Use the loupe and select a character.")


func _set_label_text(label: Label, text: String) -> void:
	if label == null:
		return

	label.text = text


func _release_current_character() -> void:
	_set_character_frozen(current_character, false)
	current_character = null


func _show_success_character_portal() -> void:
	if scene_changer != null and scene_changer.has_method("show_random_character"):
		scene_changer.call("show_random_character")


func _show_failed_character_portal(character: Area2D) -> void:
	if scene_changer != null and scene_changer.has_method("show_failed_character"):
		scene_changer.call("show_failed_character", character)


func _hide_pop_up_panel() -> void:
	if pop_up_panel != null and pop_up_panel.has_method("set_open"):
		pop_up_panel.call("set_open", false)


func _set_character_frozen(character: Area2D, value: bool) -> void:
	if character == null:
		return

	if value:
		character.set_meta(META_WAS_INPUT_PICKABLE, character.input_pickable)
		character.input_pickable = false
	else:
		if character.has_meta(META_WAS_INPUT_PICKABLE):
			character.input_pickable = bool(character.get_meta(META_WAS_INPUT_PICKABLE))
			character.remove_meta(META_WAS_INPUT_PICKABLE)

	_set_process_tree_frozen(character, value)
	_set_animated_sprites_paused(character, value)


func _set_process_tree_frozen(node: Node, value: bool) -> void:
	if value:
		node.set_meta(META_WAS_PROCESSING, node.is_processing())
		node.set_meta(META_WAS_PHYSICS_PROCESSING, node.is_physics_processing())
		node.set_process(false)
		node.set_physics_process(false)
	else:
		if node.has_meta(META_WAS_PROCESSING):
			node.set_process(bool(node.get_meta(META_WAS_PROCESSING)))
			node.remove_meta(META_WAS_PROCESSING)
		if node.has_meta(META_WAS_PHYSICS_PROCESSING):
			node.set_physics_process(bool(node.get_meta(META_WAS_PHYSICS_PROCESSING)))
			node.remove_meta(META_WAS_PHYSICS_PROCESSING)

	for child in node.get_children():
		_set_process_tree_frozen(child, value)


func _set_animated_sprites_paused(node: Node, value: bool) -> void:
	if node is AnimatedSprite2D:
		var animated_sprite := node as AnimatedSprite2D
		if value:
			animated_sprite.set_meta(META_WAS_ANIMATION_PLAYING, animated_sprite.is_playing())
			animated_sprite.pause()
		else:
			if animated_sprite.has_meta(META_WAS_ANIMATION_PLAYING):
				if bool(animated_sprite.get_meta(META_WAS_ANIMATION_PLAYING)):
					animated_sprite.play()
				animated_sprite.remove_meta(META_WAS_ANIMATION_PLAYING)

	for child in node.get_children():
		_set_animated_sprites_paused(child, value)

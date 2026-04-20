extends Resource
class_name NarrativeQuestion

@export_multiline var question_text: String = ""
@export var answers: Array[String] = []
@export_range(0, 2) var correct_answer_index: int = 0

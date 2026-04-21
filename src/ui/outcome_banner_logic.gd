extends Control

signal closed

@export var fade_duration := 0.15

@onready var banner_texture: TextureRect = get_node_or_null("BannerTextureRect") as TextureRect
@onready var continue_button: Button = get_node_or_null("ContinueButton") as Button

var fade_tween: Tween


func _ready() -> void:
	visible = false
	modulate.a = 0.0

	if continue_button == null:
		push_warning("outcome_banner_logic.gd: ContinueButton node not found.")
		return

	continue_button.pressed.connect(_on_continue_pressed)


func show_banner(texture: Texture2D) -> bool:
	if texture == null:
		return false
	if banner_texture == null:
		push_warning("outcome_banner_logic.gd: BannerTextureRect node not found.")
		return false
	if continue_button == null:
		push_warning("outcome_banner_logic.gd: ContinueButton node not found.")
		return false

	banner_texture.texture = texture
	visible = true
	_fade_to(1.0)

	return true


func wait_until_closed() -> void:
	await closed


func _on_continue_pressed() -> void:
	_fade_to(0.0)

	if fade_tween != null:
		await fade_tween.finished

	visible = false
	closed.emit()


func _fade_to(alpha: float) -> void:
	if fade_tween != null:
		fade_tween.kill()

	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_CUBIC)
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(self, "modulate:a", alpha, fade_duration)

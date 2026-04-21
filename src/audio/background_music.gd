extends AudioStreamPlayer2D

@export var persistent_node_name := "BackgroundMusic"
@export var music_volume_db := -6.0


func _ready() -> void:
	var root := get_tree().root
	var existing := root.get_node_or_null(persistent_node_name)
	if existing != null and existing != self:
		queue_free()
		return

	name = persistent_node_name
	volume_db = music_volume_db
	_enable_stream_loop()

	if not finished.is_connected(_on_finished):
		finished.connect(_on_finished)

	call_deferred("_persist_and_play")


func _persist_and_play() -> void:
	if not is_inside_tree():
		return

	var root := get_tree().root
	if get_parent() != root:
		reparent(root)

	if not playing:
		play()


func _enable_stream_loop() -> void:
	if stream == null:
		return

	if stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD


func _on_finished() -> void:
	play()


func _exit_tree() -> void:
	stop()

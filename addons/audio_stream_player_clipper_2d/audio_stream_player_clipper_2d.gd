@tool
extends Node2D

@export_group("AudioStreamPlayerClipper2D")
@export_subgroup("Clipper")
@export_range(0.0, 1000.0, 0.0001, "suffix:seconds", "hide_slider") var start_time: float = 0.0:
	set(value):
		start_time = value
		if duration_cut:
			duration_cut = (end_time - start_time) / pitch_scale
		start_time_change()
		editor_start_time_change()

@export_range(0.0, 1000.0, 0.0001, "suffix:seconds", "hide_slider") var end_time: float = 0.0:
	set(value):
		end_time = value
		if duration_cut:
			duration_cut = (end_time - start_time) / pitch_scale
		end_time_change()
		editor_end_time_change()

@export var apply_cut: bool = false:
	set(value):
		apply_cut = value
		cut_change()
		editor_cut_change()

@export_subgroup("AudioStreamPlayer2D")
@export var audio_stream: AudioStream:
	set(value):
		audio_stream = value

		if value == null:
			return

		duration_audio = audio_stream.get_length() / pitch_scale
		if audio_stream_player_2d:
			audio_stream_player_2d.set_stream(audio_stream)
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.set_stream(audio_stream)
		audio_stream_change()
		editor_audio_stream_change()

@export var auto_play: bool = false:
	set(value):
		auto_play = value
		auto_play_change()

@export var loop: bool = false:
	set(value):
		loop = value
		loop_change()
		editor_loop_change()

@export_range(-80, 24, ) var volume_db: float = 0.0:
	set(value):
		volume_db = value
		if audio_stream_player_2d:
			audio_stream_player_2d.volume_db = value
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.volume_db = value

@export_range(0.01, 4.0, 0.01, "or_greater") var pitch_scale: float = 1.0:
	set(value):
		pitch_scale = value
		if audio_stream_player_2d:
			audio_stream_player_2d.pitch_scale = value
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.pitch_scale = value
		pitch_scale_change()
		editor_pitch_scale_change()

@export_range(0.0, 9999.0, 0.01, "or_greater") var max_distance: float = 2000.0:
	set(value):
		max_distance = value
		if audio_stream_player_2d:
			audio_stream_player_2d.max_distance = value
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.max_distance = value
		max_distance_change()
		max_distance_scale_change()

@export_exp_easing("positive_only") var attenuation: float = 1.0:
	set(value):
		attenuation = value
		if audio_stream_player_2d:
			audio_stream_player_2d.attenuation = value
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.attenuation = value
		attenuation_change()
		editor_attenuation_change()

@export_range(0.0, 4.0, 0.01, "or_greater") var panning_strength: float = 1.0:
	set(value):
		panning_strength = value
		if audio_stream_player_2d:
			audio_stream_player_2d.panning_strength = value
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.panning_strength = value
		panning_strength_change()
		editor_panning_strength_change()

@export var editor_play_test: bool = false:
	set(value):
		editor_play_test = value
		editor_play_test_change()

var timer_with_cut: Timer = null
var timer_with_out_cut: Timer = null

var editor_timer_with_cut: Timer = null
var editor_timer_with_out_cut: Timer = null

var audio_stream_player_2d: AudioStreamPlayer2D = null
var editor_audio_stream_player_2d: AudioStreamPlayer2D = null

var duration_audio: float = 0.0
var duration_cut: float = 0.0

var can_change: bool = false
var editor_can_change: bool = false

func _ready():
	game_ready()
	editor_ready()
	pass

#
# GAME
#
func game_ready() -> void:
	if Engine.is_editor_hint():
		return

	if audio_stream == null:
		push_error("Parameter Audio Stream cannot be null")
		return

	timer_with_cut = Timer.new()
	timer_with_out_cut = Timer.new()
	audio_stream_player_2d = AudioStreamPlayer2D.new()
	audio_stream_player_2d.set_stream(audio_stream)
	duration_audio = audio_stream.get_length() / pitch_scale
	audio_stream_player_2d.volume_db = volume_db
	audio_stream_player_2d.pitch_scale = pitch_scale
	duration_cut = (end_time - start_time) / pitch_scale
	add_child(audio_stream_player_2d)
	if auto_play:
		game_play_audio()

	can_change = true
	pass

func game_play_audio() -> void:
	if Engine.is_editor_hint():
		return

	if apply_cut:
		play_audio_with_cut()
	else:
		play_audio_with_out_cut()
	pass

func play_audio_with_cut() -> void:
	if Engine.is_editor_hint():
		return

	if duration_cut <= 0:
		timer_with_cut.stop()
		push_warning("the subtraction of End Time with Start Time cannot be zero or less than zero when the Apply Cut parameter is checked")
		return

	timer_with_cut.stop()
	timer_with_cut.wait_time = duration_cut
	timer_with_cut.one_shot = !loop

	if timer_with_cut.timeout.is_connected(_on_timer_with_cut_timeout):
		timer_with_cut.timeout.disconnect(_on_timer_with_cut_timeout)

	timer_with_cut.timeout.connect(_on_timer_with_cut_timeout)

	if timer_with_cut.get_parent() == null:
		add_child(timer_with_cut)

	timer_with_cut.start()
	audio_stream_player_2d.play(start_time)
	pass

func play_audio_with_out_cut() -> void:
	if Engine.is_editor_hint():
		return

	timer_with_out_cut.stop()
	audio_stream_player_2d.play()
	if loop:
		timer_with_out_cut.wait_time = duration_audio
		timer_with_out_cut.one_shot = !loop

		if timer_with_out_cut.timeout.is_connected(_on_timer_with_out_cut_timeout):
			timer_with_out_cut.timeout.disconnect(_on_timer_with_out_cut_timeout)

		timer_with_out_cut.timeout.connect(_on_timer_with_out_cut_timeout)

		if timer_with_out_cut.get_parent() == null:
			add_child(timer_with_out_cut)

		timer_with_out_cut.start()
	pass

func _on_timer_with_cut_timeout() -> void:
	if Engine.is_editor_hint():
		return

	audio_stream_player_2d.stop()

	if loop:
		play_audio_with_cut()

func _on_timer_with_out_cut_timeout() -> void:
	if Engine.is_editor_hint():
		return

	play_audio_with_out_cut()

func start() -> void:
	if Engine.is_editor_hint():
		return

	game_play_audio()
	pass

func stop() -> void:
	if Engine.is_editor_hint():
		return

	audio_stream_player_2d.stop()
	pass

func start_time_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change and apply_cut and auto_play:
		timer_with_cut.stop()
		timer_with_out_cut.stop()
		audio_stream_player_2d.set_stream(audio_stream)
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		game_play_audio()
	pass

func end_time_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change and apply_cut and auto_play:
		timer_with_cut.stop()
		timer_with_out_cut.stop()
		audio_stream_player_2d.set_stream(audio_stream)
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		game_play_audio()
	pass

func cut_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change and auto_play:
		timer_with_cut.stop()
		timer_with_out_cut.stop()
		audio_stream_player_2d.set_stream(audio_stream)
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		game_play_audio()
	pass

func auto_play_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change and auto_play:
		timer_with_cut.stop()
		timer_with_out_cut.stop()
		audio_stream_player_2d.set_stream(audio_stream)
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		game_play_audio()
	pass

func loop_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change and auto_play:
		timer_with_cut.stop()
		timer_with_out_cut.stop()
		audio_stream_player_2d.set_stream(audio_stream)
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		game_play_audio()
		
	pass

func audio_stream_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change and auto_play:
		timer_with_cut.stop()
		timer_with_out_cut.stop()
		audio_stream_player_2d.set_stream(audio_stream)
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		game_play_audio()
	pass

func pitch_scale_change() -> void:
	if Engine.is_editor_hint():
		return

	if can_change:
		duration_audio = audio_stream.get_length() / pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
	pass

func max_distance_change() -> void:
	if Engine.is_editor_hint():
		return
	pass

func attenuation_change() -> void:
	if Engine.is_editor_hint():
		return
	pass

func panning_strength_change() -> void:
	if Engine.is_editor_hint():
		return
	pass


# ************************************************************************************************

#
# EDITOR
#
func editor_ready() -> void:
	if Engine.is_editor_hint():
		if editor_play_test:
				editor_play_test = false

		editor_timer_with_cut = Timer.new()
		editor_timer_with_out_cut = Timer.new()
		editor_audio_stream_player_2d = AudioStreamPlayer2D.new()
		editor_audio_stream_player_2d.set_stream(audio_stream)
		if audio_stream:
			duration_audio = audio_stream.get_length() / pitch_scale
		editor_audio_stream_player_2d.volume_db = volume_db
		editor_audio_stream_player_2d.pitch_scale = pitch_scale
		duration_cut = (end_time - start_time) / pitch_scale
		add_child(editor_audio_stream_player_2d)

		editor_can_change = true
	pass

func editor_play_audio() -> void:
	if Engine.is_editor_hint():
		pass

	if apply_cut:
		editor_play_audio_with_cut()
	else:
		editor_play_audio_with_out_cut()
	pass

func editor_play_audio_with_cut() -> void:
	if Engine.is_editor_hint():
		pass

	if duration_cut <= 0:
		editor_timer_with_cut.stop()
		push_warning("the subtraction of End Time with Start Time cannot be zero or less than zero when the Apply Cut parameter is checked")
		return

	editor_timer_with_cut.stop()
	editor_timer_with_cut.wait_time = duration_cut
	editor_timer_with_cut.one_shot = !loop

	if editor_timer_with_cut.timeout.is_connected(_on_editor_timer_with_cut_timeout):
		editor_timer_with_cut.timeout.disconnect(_on_editor_timer_with_cut_timeout)

	editor_timer_with_cut.timeout.connect(_on_editor_timer_with_cut_timeout)

	if editor_timer_with_cut.get_parent() == null:
		add_child(editor_timer_with_cut)

	editor_timer_with_cut.start()
	editor_audio_stream_player_2d.play(start_time)
	pass

func editor_play_audio_with_out_cut() -> void:
	if Engine.is_editor_hint():
		if editor_timer_with_out_cut:
			editor_timer_with_out_cut.stop()
		if editor_audio_stream_player_2d:
			editor_audio_stream_player_2d.play()
		if loop:
			if editor_timer_with_out_cut == null:
				return

			editor_timer_with_out_cut.wait_time = duration_audio
			editor_timer_with_out_cut.one_shot = !loop

			if editor_timer_with_out_cut.timeout.is_connected(_on_editor_timer_with_out_cut_timeout):
				editor_timer_with_out_cut.timeout.disconnect(_on_editor_timer_with_out_cut_timeout)

			editor_timer_with_out_cut.timeout.connect(_on_editor_timer_with_out_cut_timeout)

			if editor_timer_with_out_cut.get_parent() == null:
				add_child(editor_timer_with_out_cut)

			editor_timer_with_out_cut.start()

		var timer = get_tree().create_timer(duration_audio)
		timer.timeout.connect(Callable(func():
			if not loop:
				editor_play_test = false
			))
	pass

func _on_editor_timer_with_cut_timeout() -> void:
	if Engine.is_editor_hint():
		pass

	editor_audio_stream_player_2d.stop()
	if loop:
		editor_play_audio_with_cut()
	else:
		editor_play_test = false

func _on_editor_timer_with_out_cut_timeout() -> void:
	if Engine.is_editor_hint():
		editor_play_audio_with_out_cut()
	pass

func editor_start_time_change() -> void:
	if Engine.is_editor_hint():
		if editor_can_change and editor_play_test and apply_cut:
			editor_timer_with_cut.stop()
			editor_timer_with_out_cut.stop()
			editor_audio_stream_player_2d.set_stream(audio_stream)
			duration_audio = audio_stream.get_length() / pitch_scale
			duration_cut = (end_time - start_time) / pitch_scale
			editor_play_audio()
	pass

func editor_end_time_change() -> void:
	if Engine.is_editor_hint():
		if editor_can_change and editor_play_test and apply_cut:
			editor_timer_with_cut.stop()
			editor_timer_with_out_cut.stop()
			editor_audio_stream_player_2d.set_stream(audio_stream)
			duration_audio = audio_stream.get_length() / pitch_scale
			duration_cut = (end_time - start_time) / pitch_scale
			editor_play_audio()
	pass

func editor_cut_change() -> void:
	if Engine.is_editor_hint():
		if editor_can_change and editor_play_test:
			editor_timer_with_cut.stop()
			editor_timer_with_out_cut.stop()
			editor_audio_stream_player_2d.set_stream(audio_stream)
			duration_audio = audio_stream.get_length() / pitch_scale
			duration_cut = (end_time - start_time) / pitch_scale
			editor_play_audio()
	pass

func editor_loop_change() -> void:
	if Engine.is_editor_hint():
		if editor_can_change and editor_play_test:
			editor_timer_with_cut.stop()
			editor_timer_with_out_cut.stop()
			editor_audio_stream_player_2d.set_stream(audio_stream)
			duration_audio = audio_stream.get_length() / pitch_scale
			duration_cut = (end_time - start_time) / pitch_scale
			editor_play_audio()
	pass

func editor_audio_stream_change() -> void:
	if Engine.is_editor_hint():
		if editor_can_change and editor_play_test:
			editor_timer_with_cut.stop()
			editor_timer_with_out_cut.stop()
			editor_audio_stream_player_2d.set_stream(audio_stream)
			duration_audio = audio_stream.get_length() / pitch_scale
			duration_cut = (end_time - start_time) / pitch_scale
			editor_play_audio()
	pass

func editor_play_test_change() -> void:
	if Engine.is_editor_hint():
		if editor_play_test:
			if audio_stream == null:
				push_warning("Parameter Audio Stream cannot be null")
				return

			duration_audio = audio_stream.get_length() / pitch_scale
			duration_cut = (end_time - start_time) / pitch_scale

			if apply_cut and duration_cut <= 0:
				push_warning("the subtraction of End Time with Start Time cannot be zero or less than zero when the Apply Cut parameter is checked")
				return
			editor_play_audio()
		else:
			if editor_audio_stream_player_2d:
				editor_audio_stream_player_2d.stop()
			if editor_timer_with_cut:
				editor_timer_with_cut.stop()
			if editor_timer_with_out_cut:
				editor_timer_with_out_cut.stop()
	pass

func editor_pitch_scale_change() -> void:
	if Engine.is_editor_hint():
		pass
	pass

func max_distance_scale_change() -> void:
	if Engine.is_editor_hint():
		pass
	pass

func editor_attenuation_change() -> void:
	if Engine.is_editor_hint():
		pass
	pass

func editor_panning_strength_change() -> void:
	if Engine.is_editor_hint():
		pass
	pass

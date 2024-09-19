@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("AudioStreamPlayerClipper2D", "Node2D", preload("res://addons/audio_clipper/audio_stream_player_clipper_2d"), preload("res://addons/audio_clipper/icon_plugin.png"))
	pass


func _exit_tree() -> void:
	remove_custom_type("AudioStreamPlayerClipper2D")
	pass

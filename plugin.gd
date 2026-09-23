@tool
extends EditorPlugin

const AUTOLOAD_AUDIO_MANAGER: String = "AudioManager"

func _enable_plugin():
	add_autoload_singleton(AUTOLOAD_AUDIO_MANAGER, "res://addons/foxyg3n_audio/AudioManager.tscn")


func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_AUDIO_MANAGER)
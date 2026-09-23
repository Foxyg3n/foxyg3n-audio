@tool
extends EditorPlugin

const PLUGIN_NAME: String = "foxyg3n-audio"
const PLUGIN_PATH: String = "res://addons/%s/" % PLUGIN_NAME
const AUTOLOAD_AUDIO_MANAGER: String = "AudioManager"

func _enable_plugin():
	add_autoload_singleton(AUTOLOAD_AUDIO_MANAGER, "%s/AudioManager.tscn" % PLUGIN_PATH)


func _disable_plugin():
	remove_autoload_singleton(AUTOLOAD_AUDIO_MANAGER)
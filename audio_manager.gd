extends Node

const MAIN_AUDIO_CHANNEL: String = "Master"

var channels: Array[String] = [] # Useless so far
var audio_instances: Dictionary[String, Array] = {} #Dictionary[String, Array[AudioInstance]]

@onready var audio_instance_scene: PackedScene = load("res://addons/foxyg3n_audio/AudioInstance.tscn")
@onready var audio_bus_layout: AudioBusLayout = load("res://addons/foxyg3n_audio/audio_bus_layout.tres")

func _ready() -> void:
	initialize()

## Initializes the audio manager
## - `bus_layout`: (Optional) The [AudioBusLayout] to use, defaults to the current bus layout
func initialize(bus_layout: AudioBusLayout = null):
	channels.clear()
	audio_instances.clear()
	
	if bus_layout:
		AudioServer.set_bus_layout(bus_layout)
	else:
		AudioServer.set_bus_layout(audio_bus_layout)
	
	for i in range(AudioServer.bus_count):
		var channel_name: String = AudioServer.get_bus_name(i)
		channels.append(channel_name)
		audio_instances[channel_name] = []

## Plays an [AudioStream] through an audio channel
func play(sound: AudioStream, channel: String = MAIN_AUDIO_CHANNEL, local_volume: float = 1.0, pitch: float = 1.0) -> AudioInstance:
	if not audio_instances.has(channel):
		printerr("AudioManager: Audio channel '" + channel + "' does not exist")
		return null
	
	return builder(sound, channel)\
		.volume_linear(local_volume)\
		.pitch(pitch)\
		.build()

## Creates an [AudioBuilder] to build an [AudioInstance][br]
## - `sound`: (Optional) The [AudioStream] to play[br]
## - `channel`: (Optional) The audio channel to play the audio instance on, defaults to the main audio channel
func builder(sound: AudioStream = null, channel: String = MAIN_AUDIO_CHANNEL) -> AudioBuilder:
	return AudioBuilder.new(sound, channel)

## Removes an [AudioInstance] from the audio manager and destroys it
func remove_audio_instance(audio_instance: AudioInstance):
	var channel_instances: Array = audio_instances.get(audio_instance.channel)
	channel_instances.erase(audio_instance)
	audio_instance.queue_free()

## Pauses all audio instances
func pause_all_audio_instances():
	for audio_instance in get_all_audio_instances():
		audio_instance.pause()

## Unpauses all audio instances
func unpause_all_audio_instances():
	for audio_instance in get_all_audio_instances():
		audio_instance.unpause()

## Returns all audio instances
func get_all_audio_instances() -> Array:
	return flatten_dictionary(audio_instances)

# TODO: Implement
## Returns all audio instances playing a specific sound
func get_audio_instances_by_sound(sound: AudioStream) -> Array:
	return []

## Sets the volume of an audio channel[br]
## Volume is linear, not dB (from 0.0 to 1.0)
func set_channel_volume(channel: String, volume: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(channel), volume)

## Creates an [AudioInstance] without adding it as the child of audio manager
func _create_audio_instance(sound: AudioStream = null, channel: String = MAIN_AUDIO_CHANNEL) -> AudioInstance:
	var audio_instance: AudioInstance = audio_instance_scene.instantiate()
	if sound: audio_instance.stream = sound
	audio_instance.channel = channel

	audio_instances[channel].append(audio_instance)
	return audio_instance

# Temp dictionary util

## Flattens a dictionary into a single array[br]
## Requires the dictionary to have [Array] as value type
func flatten_dictionary(dictionary: Dictionary) -> Array:
	if dictionary.size() == 0: return []
	
	if typeof(dictionary.get(dictionary.keys()[0])) != Variant.Type.TYPE_ARRAY:
		printerr("flatten_dictionary: Dictionary values are not an array")
		return []
	
	var flattened_dictionary: Array = []
	for key in dictionary:
		var value: Array = dictionary[key]
		flattened_dictionary.append_array(value)
	
	return flattened_dictionary

class AudioBuilder:
	var audio_instance: AudioInstance

	func _init(sound: AudioStream = null, channel: String = AudioManager.MAIN_AUDIO_CHANNEL):
		audio_instance = AudioManager._create_audio_instance(sound, channel)
		audio_instance.autoplay = true
	
	func sound(sound: AudioStream) -> AudioBuilder:
		audio_instance.stream = sound
		return self
	
	func channel(channel: String) -> AudioBuilder:
		audio_instance.channel = channel
		return self
	
	func autoplay(autoplay: bool) -> AudioBuilder:
		audio_instance.autoplay = autoplay
		return self
	
	func autodestroy(autodestroy: bool) -> AudioBuilder:
		audio_instance.autodestroy = autodestroy
		return self
	
	func volume_db(volume: float) -> AudioBuilder:
		audio_instance.volume_db = volume
		return self
	
	func volume_linear(volume: float) -> AudioBuilder:
		audio_instance.volume_linear = volume
		return self
	
	func pitch(pitch: float) -> AudioBuilder:
		audio_instance.pitch_scale = pitch
		return self
	
	func fade_in(duration: float, start_volume: float = 0.0) -> AudioBuilder:
		audio_instance.interpolate_volume(1.0, duration, start_volume)
		return self
	
	func build() -> AudioInstance:
		AudioManager.add_child(audio_instance)
		return audio_instance
	
	func cook() -> AudioInstance:
		return build()
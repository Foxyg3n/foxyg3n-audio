class_name AudioInstance extends AudioStreamPlayer

var channel: String
var autodestroy: bool = true

var pitch_scale_tween: Tween
var volume_tween: Tween

# TODO: Add fadein/out functionality

func _ready():
	if autodestroy: finished.connect(destroy)

## Creates an [AudioBuilder] to build an [AudioInstance][br]
## - `sound`: (Optional) The [AudioStream] to play[br]
## - `channel`: (Optional) The audio channel to play the audio instance on, defaults to the main audio channel
static func builder(sound: AudioStream = null, channel: String = AudioManager.MAIN_AUDIO_CHANNEL) -> AudioManager.AudioBuilder:
	return AudioManager.builder(sound, channel)

## Interpolates the pitch of the audio instance[br]
## - `to`: The pitch to interpolate to[br]
## - `duration`: The duration in seconds to interpolate for[br]
## - `from`: (Optional) The pitch to interpolate from, defaults to the current pitch[br]
func interpolate_pitch(to: float, duration: float, from: float = pitch_scale) -> Tween:
	if pitch_scale == to: return
	
	pitch_scale_tween = create_tween()
	pitch_scale_tween.tween_property(self, "pitch_scale", to, duration).from(from)
	
	if get_stream_paused():
		pitch_scale_tween.pause()
		
	return pitch_scale_tween

func interpolate_volume(to: float, duration: float, from: float = volume_db) -> Tween:
	if volume_db == to: return
	
	volume_tween = create_tween()
	volume_tween.tween_property(self, "volume_linear", to, duration).from(from)
	
	if get_stream_paused():
		volume_tween.pause()
		
	return volume_tween

func pause():
	set_stream_paused(true)
	if pitch_scale_tween and pitch_scale_tween.is_valid(): pitch_scale_tween.pause()
	if volume_tween and volume_tween.is_valid(): volume_tween.pause()

func unpause():
	set_stream_paused(false)
	if pitch_scale_tween and pitch_scale_tween.is_valid(): pitch_scale_tween.play()
	if volume_tween and volume_tween.is_valid(): volume_tween.play()
	
func resume():
	unpause()

func destroy():
	AudioManager.remove_audio_instance(self)

func set_bus(channel: StringName) -> void:
	super(channel)
	# TODO: Change channel in AudioManager to "channel"
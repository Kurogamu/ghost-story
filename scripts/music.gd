extends Node

@export var fade_in_speed = 1.0
@export var fade_out_speed = 5.0

var _fade_in_tracks = {}
var _fade_out_tracks = {}

const MIN_VOLUME = -64

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for track_name in _fade_in_tracks:
		var track = get_node(track_name)
		var next_volume = track.get_volume_db() + fade_in_speed * delta
		track.set_volume_db(max(0, next_volume))

	for track_name in _fade_out_tracks:
		var track = get_node(track_name)
		var next_volume = track.get_volume_db() - fade_out_speed * delta
		track.set_volume_db(min(MIN_VOLUME, next_volume))


func fade_in_track(track_name: String) -> void:
	if track_name in _fade_out_tracks:
		_fade_out_tracks.erase(track_name)

	_fade_in_tracks.merge({track_name: null})


func fade_out_track(track_name: String) -> void:
	if track_name in _fade_in_tracks:
		_fade_in_tracks.erase(track_name)

	_fade_out_tracks.merge({track_name: null})

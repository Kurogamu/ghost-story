extends Node2D

signal heard

var _emitting: bool = false

@export var _circle_radius: float:
	set(value):
		_circle_radius = value
		queue_redraw()
@export var _circle_color: Color:
	set(value):
		_circle_color = value
		queue_redraw()


func _ready() -> void:
	$AnimationPlayer.animation_finished.connect(_on_end_animation)
	$Area2D.connect("body_entered", _on_body_entered)
	$ChainDelay.connect("timeout", _delayed_interaction)
	$Duration.connect("timeout", _reset)


func _draw() -> void:
	draw_arc(Vector2(0,0), _circle_radius, 0, 2*PI, 32, _circle_color, 1.0, true)
	$Area2D/CollisionShape2D.get_shape().radius = _circle_radius


func run() -> void:
	if not _emitting:
		_emitting = true
		$ChainDelay.start()
		$AnimationPlayer.play("soundwave")


func _delayed_interaction() -> void:
	$Area2D/CollisionShape2D.disabled = false
	$Duration.start()


func _reset() -> void:
	_emitting = false
	$Area2D/CollisionShape2D.disabled = true


func _on_end_animation(animation_name: String) -> void:
	match animation_name:
		"soundwave": $AnimationPlayer.play("RESET")


func _on_body_entered(node: Node2D) -> void:
	heard.emit(node)

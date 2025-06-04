extends StaticBody2D

signal possessable_enter
signal possessable_exit

signal emit_noise

enum States {DEFAULT, POSSESS_READY, POSSESSED, BROKEN}
var state: States = States.DEFAULT


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Interaction.body_entered.connect(_on_body_entered)
	$Interaction.body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body):
	if state != States.BROKEN and body.get("IS_MAIN"):
		_set_state(States.POSSESS_READY)


func _on_body_exited(body):
	if state in [States.DEFAULT, States.POSSESS_READY] and body.get("IS_MAIN"):
		possessable_exit.emit(self)

	if state == States.POSSESS_READY:
		_set_state(States.DEFAULT)


func _set_state(next_state: States) -> void:
	match next_state:
		States.POSSESS_READY:
			$Interaction/GPUParticles2D.set_emitting(true)
			possessable_enter.emit(self)
		States.BROKEN:
			$Interaction/GPUParticles2D.set_emitting(false)
			$CollisionShape2D.set_disabled(true)
			$Sprite.set_region_rect(Rect2(64, 0, 64, 64)) # TODO: figure out spritemap
			emit_noise.emit()
		States.POSSESSED:
			$Interaction/GPUParticles2D.set_emitting(false)
			$Sprite.set_region_rect(Rect2(128, 0, 64, 64)) # TODO: figure out spritemap
		_:
			$Interaction/GPUParticles2D.set_emitting(false)
	state = next_state


func is_interactable() -> bool:
	return state in [States.POSSESS_READY, States.POSSESSED]


func set_possessed(do_possess: bool) -> void:
	if state == States.BROKEN:
		return

	if do_possess:
		_set_state(States.POSSESSED)
	else:
		_set_state(States.BROKEN)

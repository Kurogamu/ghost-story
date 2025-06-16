extends StaticBody2D

signal chaser_enter
signal chaser_exit
signal light_enter

enum States {DEFAULT, SCARED, FLEEING, SPOOKED}
var state: States = States.DEFAULT

var scare_level: int = 0
@export var scare_threshold: int = 3

@onready var _follow :PathFollow2D = get_parent()
@onready var _prev_position: Vector2 = self.global_position

@export var base_speed: float = 100
@export var scared_speed: float = 30


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Interaction.body_entered.connect(_on_interact_enter)
	$Interaction.body_exited.connect(_on_interact_exit)
	$CharSprite.play("default")
	$CharSprite.animation_finished.connect(_on_end_animation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed = base_speed
	if state == States.SCARED:
		speed = scared_speed

	if state in [States.SPOOKED, States.FLEEING]:
		$Flashlight.visible = false
		return
	elif not $Flashlight.visible:
		$Flashlight.visible = true

	if _follow:
		_follow.set_progress(_follow.get_progress() + speed * delta)
		var angle = _prev_position.angle_to_point(self.global_position)
		$Flashlight.set_rotation(angle)
		$CharSprite.flip_h = abs(angle) > PI * 0.51
		_prev_position = self.global_position

	var seen_object = $Flashlight.get_collider()
	if seen_object:
		_on_light_entered(seen_object)


func _on_interact_enter(body):
	if state != States.FLEEING and body.get("IS_MAIN"):
		chaser_enter.emit(self)


func _on_interact_exit(body):
	if state != States.FLEEING and body.get("IS_MAIN"):
		chaser_exit.emit(self)


func _on_light_entered(body):
	if body.get("IS_MAIN") \
			and state in [States.DEFAULT, States.SCARED]:
		light_enter.emit(self)


func _set_state(next_state: States) -> void:
	match next_state:
		States.DEFAULT: $CharSprite.play("default")
		States.SCARED: $CharSprite.play("scared")
		States.SPOOKED:
			$SoundWave.run()
			$CharSprite.play("spooked")
			$ReactionSprite.visible = true
			$ReactionSprite.play("spooked")
		States.FLEEING:
			$SoundWave.run()
			$CharSprite.play("fleeing")
	state = next_state


func is_interactable():
	return state == States.SCARED


func scare():
	if state in [States.DEFAULT, States.SCARED]:
		scare_level += 1
		_set_state(States.SPOOKED)


func flee():
	_set_state(States.FLEEING)


func _on_end_animation():
	$ReactionSprite.visible = false
	match state:
		States.SPOOKED:
			if scare_level >= scare_threshold:
				_set_state(States.SCARED)
			else:
				_set_state(States.DEFAULT)
		States.DEFAULT: $CharSprite.play("default")
		States.SCARED: $CharSprite.play("scared")
		States.FLEEING: self.queue_free()

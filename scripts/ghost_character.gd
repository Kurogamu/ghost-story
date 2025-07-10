extends CharacterBody2D

@export var max_speed: float = 200.0
@export var acceleration: float = 1500.0
@export var deceleration: float = 1000.0
@export var start_pos: Vector2 = Vector2(0, 0)
@export var camera_limits: Dictionary = {
	"top": 0, "right": 1000, "bottom": 1000, "left": 0
}
const IS_MAIN = true

enum States {NORMAL, INVISIBLE, MOVING, POSSESSING, SCARED, SPOOKING}
var state: States = States.NORMAL
var last_velocity = Vector2(0,0)

func _ready():
	$CharSprite.play("idle")
	$CharSprite.animation_finished.connect(_on_end_animation)
	$InvisibilityTimeout.connect("timeout", _on_invisibility_end)
	start_pos = self.position

	$Camera.limit_top = camera_limits["top"]
	$Camera.limit_right = camera_limits["right"]
	$Camera.limit_bottom = camera_limits["bottom"]
	$Camera.limit_left = camera_limits["left"]
	$Camera/AnimationPlayer.play("camera_zoom_out")


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	if state in [States.NORMAL, States.MOVING, States.INVISIBLE]:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

		var some_x = abs(direction.x) > 0.1
		var some_y = abs(direction.y) > 0.1

		var normalized_speed = max_speed
		if some_x and some_y:
			normalized_speed = max_speed * 0.707

		if direction.x > 0.1:
			velocity.x = min(normalized_speed, velocity.x + delta * acceleration)
		elif direction.x < -0.1:
			velocity.x = max(-normalized_speed, velocity.x - delta * acceleration)
		elif velocity.x > 0.1:
			velocity.x = max(0, velocity.x - deceleration * delta)
		else:
			velocity.x = min(0, velocity.x + deceleration * delta)

		if direction.y > 0.1:
			velocity.y = min(normalized_speed, velocity.y + delta * acceleration)
		elif direction.y < -0.1:
			velocity.y = max(-normalized_speed, velocity.y - delta * acceleration)
		elif velocity.y > 0.1:
			velocity.y = max(0, velocity.y - deceleration * delta)
		else:
			velocity.y = min(0, velocity.y + deceleration * delta)

		move_and_slide()


func _set_state(next_state: States) -> void:
	match next_state:
		States.POSSESSING:
			$CharSprite.visible = false
			$Camera/AnimationPlayer.play("camera_zoom_in")
		States.NORMAL:
			$CharSprite.play("idle")
			$CharSprite.visible = true
			if state == States.POSSESSING:
				$Camera/AnimationPlayer.play("camera_zoom_out")
		States.SCARED:
			$CharSprite.play("scared")
			$ReactionSprite.visible = true
			$ReactionSprite.play("spooked")
		States.SPOOKING:
			$CharSprite.play("spooking")
			$ReactionSprite.visible = true
			$ReactionSprite.play("boo")
		States.INVISIBLE:
			$CharSprite.visible = true # heh
			$CharSprite.play("idle")
			self.set_modulate(Color(1.0, 1.0, 1.0, 0.2))
			$InvisibilityTimeout.start()

	state = next_state


func set_possessing(do_possess: bool) -> void:
	if do_possess:
		_set_state(States.POSSESSING)
	else:
		_set_state(States.INVISIBLE)


func get_possessing() -> bool:
	return state == States.POSSESSING


func scare() -> void:
	if state not in [States.SCARED, States.INVISIBLE, States.POSSESSING]:
		_set_state(States.SCARED)


func spook() -> void:
	if state in [States.NORMAL, States.MOVING]:
		_set_state(States.SPOOKING)


func get_hidden() -> bool:
	return state in [States.SCARED, States.POSSESSING, States.INVISIBLE]


func _on_end_animation():
	match state:
		States.SCARED:
			$ReactionSprite.visible = false
			_set_state(States.INVISIBLE)
		States.SPOOKING:
			_set_state(States.NORMAL)


func _on_invisibility_end():
	self.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
	if state == States.INVISIBLE:
		_set_state(States.NORMAL)

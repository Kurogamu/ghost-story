extends CharacterBody2D

@export var max_speed: float = 200.0
@export var acceleration: float = 1000.0
@export var deceleration: float = 800.0
@export var start_pos: Vector2 = Vector2(0, 0)
const IS_MAIN = true

enum States {IDLE, MOVING, POSSESSING, SCARED, SPOOKING}
var state: States = States.IDLE
var last_velocity = Vector2(0,0)

func _ready():
	$CharSprite.play("idle")
	$CharSprite.animation_finished.connect(_on_end_animation)
	start_pos = self.position


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	if state in [States.IDLE, States.MOVING]:
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

func set_possessing(do_possess: bool) -> void:
	if do_possess:
		state = States.POSSESSING
		$CharSprite.visible = false
	else:
		state = States.IDLE
		$CharSprite.visible = true


func get_possessing() -> bool:
	return state == States.POSSESSING


func scare() -> void:
	if state != States.SCARED:
		state = States.SCARED
		$CharSprite.play("scared")
		$ReactionSprite.visible = true
		$ReactionSprite.play("spooked")


func spook() -> void:
	if state in [States.IDLE, States.MOVING]:
		state = States.SPOOKING
		$CharSprite.play("spooking")
		$ReactionSprite.visible = true
		$ReactionSprite.play("boo")


func get_hidden() -> bool:
	return state in [States.SCARED, States.POSSESSING]


func _on_end_animation():
	$ReactionSprite.visible = false
	match state:
		States.SCARED:
			self.position = start_pos
			state = States.IDLE
			$CharSprite.play("idle")
		States.SPOOKING:
			state = States.IDLE
			$CharSprite.play("idle")

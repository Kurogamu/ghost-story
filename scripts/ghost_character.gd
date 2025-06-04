extends CharacterBody2D

@export var speed: float = 500.0
@export var start_pos: Vector2 = Vector2(0, 0)
const IS_MAIN = true

enum States {IDLE, MOVING, POSSESSING, SCARED, SPOOKING}
var state: States = States.IDLE

func _ready():
	$CharSprite.play("idle")
	$CharSprite.animation_finished.connect(_on_end_animation)
	start_pos = self.position


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	if state in [States.IDLE, States.MOVING]:
		var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		velocity.x = direction.x * speed
		velocity.y = direction.y * speed

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


func spook() -> void:
	if state in [States.IDLE, States.MOVING]:
		state = States.SPOOKING
		$CharSprite.play("spooking")


func get_hidden() -> bool:
	return state in [States.SCARED, States.POSSESSING]


func _on_end_animation():
	match state:
		States.SCARED:
			self.position = start_pos
			state = States.IDLE
			$CharSprite.play("idle")
		States.SPOOKING:
			state = States.IDLE
			$CharSprite.play("idle")

extends Node2D

var interaction_target: Node = null
enum States {DEFAULT, POSSESSING}
var state: States = States.DEFAULT

@export var default_zoom = Vector2(1.0, 1.0)
@export var possessed_zoom =  Vector2(1.5, 1.5)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in self.get_tree().get_nodes_in_group("Possessable"):
		node.possessable_enter.connect(_on_possessable)
		node.possessable_exit.connect(_on_interactable_exit)
		node.emit_noise.connect(_on_emit_noise)

	for node in self.get_tree().get_nodes_in_group("Chaser"):
		node.chaser_enter.connect(_on_chaser_enter)
		node.chaser_exit.connect(_on_interactable_exit)
		node.light_enter.connect(_on_chaser_light_enter)

		%Camera/AnimationPlayer.play("camera_zoom_out")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_possessable(target):
	interaction_target = target


func _on_chaser_enter(chaser):
	if not $Ghost.get_hidden():
		interaction_target = chaser


func _on_chaser_light_enter(chaser):
	if not $Ghost.get_hidden():
		$Ghost.scare()
		chaser.scare()


func _on_interactable_exit(node):
	if interaction_target == node:
		interaction_target = null


func _on_emit_noise():
	for node in self.get_tree().get_nodes_in_group("Chaser"):
		node.scare()


func _input(event):
	if event.is_action_pressed("interact"):
		_handle_interact()


func _handle_interact():
	if interaction_target == null or not interaction_target.is_interactable():
		return

	if interaction_target.is_in_group("Possessable"):
		if state != States.POSSESSING:
			interaction_target.set_possessed(true)
			$Ghost.global_position = interaction_target.global_position
			_set_state(States.POSSESSING)
		else:
			interaction_target.set_possessed(false)
			_set_state(States.DEFAULT)

	if interaction_target.is_in_group("Chaser"):
		interaction_target.flee()
		$Ghost.spook()


func _set_state(next_state: States) -> void:
	match next_state:
		States.DEFAULT:
			%Camera/AnimationPlayer.play("camera_zoom_out")
			$Ghost.set_possessing(false)
		States.POSSESSING:
			%Camera/AnimationPlayer.play("camera_zoom_in")
			$Ghost.set_possessing(true)
	state = next_state

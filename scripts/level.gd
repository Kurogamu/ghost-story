extends Node2D

var interaction_target: Node = null
enum States {DEFAULT, POSSESSING}
var state: States = States.DEFAULT

@export var default_zoom = Vector2(1.0, 1.0)
@export var possessed_zoom =  Vector2(1.5, 1.5)


var _interaction_target_stack: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in self.get_tree().get_nodes_in_group("Possessable"):
		node.possessable_enter.connect(_on_possessable_enter)
		node.possessable_exit.connect(_on_interactable_exit)
		node.get_node("SoundWave").heard.connect(_on_heard)

	for node in self.get_tree().get_nodes_in_group("Enemy"):
		node.chaser_enter.connect(_on_chaser_enter)
		node.chaser_exit.connect(_on_interactable_exit)
		node.light_enter.connect(_on_chaser_light_enter)
		node.get_node("SoundWave").heard.connect(_on_heard)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_possessable_enter(target):
	_interaction_target_stack.append(target)


func _on_chaser_enter(chaser):
	_interaction_target_stack.append(chaser)


func _on_chaser_light_enter(chaser):
	if not %PlayerGhost.get_hidden():
		%PlayerGhost.scare()
		chaser.scare()


func _on_interactable_exit(node):
	if node in _interaction_target_stack:
		_interaction_target_stack.erase(node)


func _on_heard(node: Node2D):
	if "Enemy" in node.get_groups():
		node.scare()
		$Music.fade_in_track("Melody")


func _input(event):
	if event.is_action_pressed("interact"):
		_handle_interact()


func _handle_interact():
	var _interactable_filter = func (node): return node.is_interactable()
	var interaction_targets = _interaction_target_stack.filter(_interactable_filter)
	if interaction_targets.is_empty():
		return
	var interaction_target = interaction_targets.back()

	if interaction_target.is_in_group("Possessable"):
		if state != States.POSSESSING:
			interaction_target.set_possessed(true)
			%PlayerGhost.global_position = interaction_target.global_position
			_set_state(States.POSSESSING)
		else:
			interaction_target.set_possessed(false)
			_set_state(States.DEFAULT)

	elif interaction_target.is_in_group("Enemy"):
		interaction_target.flee()
		_interaction_target_stack.erase(interaction_target)
		$Music.fade_in_track("Bass")
		%PlayerGhost.spook()

		if self.get_tree().get_nodes_in_group("Enemy").size() <= 1:
			$Music.fade_in_track("Drums")



func _set_state(next_state: States) -> void:
	match next_state:
		States.DEFAULT:
			%PlayerGhost.set_possessing(false)
		States.POSSESSING:
			%PlayerGhost.set_possessing(true)
	state = next_state

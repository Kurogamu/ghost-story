extends CanvasLayer

signal resume


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$PauseControl/ResumeBtn.pressed.connect(_on_resume_pressed)


func _on_resume_pressed() -> void:
	resume.emit()

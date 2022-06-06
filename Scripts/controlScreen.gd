extends Control

func _ready():
	$returnBtn.grab_focus()

func _on_returnBtn_pressed():
	queue_free()
	Global.controllOff = false

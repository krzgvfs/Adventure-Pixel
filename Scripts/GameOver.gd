extends CanvasLayer

func _ready():
	$BtnRetry.grab_focus()

func _on_BtnRetry_pressed():
	get_tree().change_scene("res://Prefabs/StartScreen.tscn")
	if Global.is_dead:
		Global.player_health = 3

extends StaticBody2D

signal DoorClosed

func _ready():
	pass

func _on_Trigger_PlayerEntered():
	$anim.play("enable")
	yield(get_tree().create_timer(1), "timeout")
	emit_signal("DoorClosed")


func _on_Boss_BossDead():
	$anim.play("inactive")

extends Node

var checkpoint_pos = 0

func  _ready():
	Global.fruits = 0
	if Global.is_dead:
		Global.player_health = 3
	print(Global.player_life)

func _on_Trigger_PlayerEntered_Camera():
	$BossCamera.current = true


func _on_Boss_BossDead():
	$BossCamera.current = false

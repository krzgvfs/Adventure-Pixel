extends Area2D

var fruits = 1

func _on_items_body_entered(_body):
	$collectedFx.play()
	$anim.play("collected")
	Global.fruits += fruits
	


func _on_anim_animation_finished(anim_name):
	if anim_name == "collected":
		queue_free()

extends RigidBody2D



func _on_clearNode_screen_exited():
	queue_free()

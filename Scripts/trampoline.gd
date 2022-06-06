extends Area2D



func _on_trampoline_body_entered(body):
	print("colidiu")
	body.velocity.y = body.jump_force
	$anim.play("jump")

extends Area2D

const SPEED = 300
var velocity = Vector2.ZERO
var direction = 1

func set_direction(dir):
	direction = dir
	if direction == 1:
		$anim.flip_h = false
	else:
		$anim.flip_h = true

func _physics_process(delta):
	velocity.x = SPEED * direction * delta
	translate(velocity)


func _on_notifier_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	queue_free()

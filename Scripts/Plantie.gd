extends KinematicBody2D

var facing_left = true
var hitted = false
var health = 5
onready var bullet_instance = preload("res://Scene/Seed.tscn")
onready var player = Global.get("player")

# warning-ignore:unused_argument
func _physics_process(delta: float) -> void:
	_set_animation()
	if player:
		var distance = player.global_position.x - self.position.x
		facing_left = true if distance < 0 else false
	
	if facing_left:
		self.scale.x = 1
	else:
		self.scale.x = -1

func _set_animation():
	var anim = "idle"
	
	if $playerDetector.overlaps_body(player):
		anim = "attack"
	else:
		anim = "idle"

	if hitted:
		anim = "hit"
	
	if $anim.assigned_animation != anim:
		$anim.play(anim)
	
	
func shoot():
	var bullet = bullet_instance.instance()
	get_parent().add_child(bullet)
	bullet.global_position = $spawnShoot.global_position
	
	if facing_left:
		bullet.direction = 1
	else: 
		bullet.direction = -1
	

func _on_playerDetector_body_entered(body: Node) -> void:
	$anim.play("attack")

func _on_playerDetector_body_exited(body: Node) -> void:
	$anim.play("idle")

func _on_hitbox_body_entered(body: Node) -> void:
	hitted = true
	$hitFx.play()
	health -= 1
	body.velocity.y = body.jump_force / 2
	yield(get_tree().create_timer(0.7), "timeout")
	hitted = false
	
	if health < 1:
		queue_free()
		get_node("hitbox/collision").set_deferred("disable", true)



func _on_hitbox_area_entered(area):
	hitted = true
	$hitFx.play()
	health -= 1
	hitted = false
	if health < 1:
		get_node("hitbox/collision").set_deferred("disabled", true)
		set_physics_process(false)
		get_node("collision").set_deferred("disabled", true)
		yield(get_tree().create_timer(.7), "timeout")
		queue_free()
	else:
		yield(get_tree().create_timer(.2), "timeout")
		queue_free()

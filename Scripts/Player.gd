extends KinematicBody2D

const SHOT = preload("res://Prefabs/Bullet.tscn")

# Variaveis.
var UP = Vector2.UP
var velocity = Vector2.ZERO
var move_speed = 120
var gravity = 1200
var jump_force = -820
var is_grounded
var is_shoting = false

var max_health = 3

var player_life = 3

var hurted = false
var is_pushing = false

var knockback_dir = 1
var knockback_int = 800

onready var raycasts = $raycasts

signal change_life(player_health)

func _ready() -> void:
	$texture.play("idle")
	velocity.x = 0
	
	Global.set("player", self)
	connect("change_life", get_parent().get_node("HUD/HBoxContainer/Holder"), "on_change_life")	
	emit_signal("change_life", max_health)
	if Global.checkpoint_pos != null:
		position.x = 10
		self.global_position.x = Global.checkpoint_pos * position.x
	
# Função principal.
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	velocity.x = 0 
	
	if !hurted:
		_get_input()

	velocity = move_and_slide(velocity, UP)
	
	is_grounded = _check_is_ground()
	
	if is_grounded:
		$shadow.visible = true
	else:
		$shadow.visible = false
		
	tiro()
	_set_animation()
	
	for platforms in get_slide_count():
		var collision = get_slide_collision(platforms)
		if collision.collider.has_method("collide_with"):
			collision.collider.collide_with(collision, self)

# Função de movimentação do jogador.
func _get_input():
	if Input.is_action_pressed("move_right"):
		velocity.x += move_speed
		
		if sign($bullet_point.position.x) == -1:
			$bullet_point.position.x *= -1
		$texture.flip_h = false
	
	if Input.is_action_pressed("move_left"):
		velocity.x -= move_speed
	
		if sign($bullet_point.position.x) == 1:
			$bullet_point.position.x *= -1
		$texture.flip_h = true

func tiro():
	if Input.is_action_just_pressed("bullet"):
		is_shoting = true
		castBullet()


func castBullet():
	var bullet_instance = SHOT.instance()
	if sign($bullet_point.position.x) == 1:
		bullet_instance.set_direction(1)
	else:
		bullet_instance.set_direction(-1)
	get_parent().add_child(bullet_instance)
	bullet_instance.position = $bullet_point.global_position
	yield($texture, "animation_finished")
	is_shoting = false

# Função de pulo.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") and is_grounded:
		velocity.y = jump_force / 2
		$jumpFx.play()
	
# Verificando colisão nos nos reycasts.
func _check_is_ground():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false

func _set_animation():
	var anim
	
	if velocity.x == 0:
		anim = "idle"
	elif !is_grounded:
		anim = "jump"
	elif velocity.x != 0:
		anim = "run"
		if is_grounded:
			$steps_fx.set_emitting(true)
	elif is_pushing:
		anim = "run"
	
	if is_shoting and is_grounded:
		anim = "shoot"
	
	if velocity.y > 0 and !is_grounded:
		anim = "fall"
	
	if hurted:
		anim = "hit"
	
	if $texture.animation != anim:
		$texture.play(anim)

func knockback():
	if $right.is_colliding():
		velocity.x = -knockback_dir * knockback_int
		
	if $left.is_colliding():
		velocity.x = knockback_dir * knockback_int

	velocity = move_and_slide(velocity)

func _on_hurtbox_body_entered(body: Node) -> void:
	playerDamage()
		
func playerDamage():
	Global.player_health -= 1
	hurted = true
	emit_signal("change_life", Global.player_health)
	knockback()
	get_node("hurtbox/collision").set_deferred("disabled", true)
	yield(get_tree().create_timer(0.5), "timeout")
	get_node("hurtbox/collision").set_deferred("disabled", false)
	hurted = false
	gameOver()

func gameOver() -> void:
	if Global.player_health < 1:
		queue_free()
		Global.is_dead = true
		Global.player_life -= 1
		Global.player_health = 3
		get_tree().reload_current_scene()
	if Global.player_life < 1:	
		if get_tree().change_scene("res://Prefabs/GameOver.tscn") != OK:
			print("Algo deu errado!")

func hit_checkpoint():
	Global.checkpoint_pos = position.x 

func _on_headCollider_body_entered(body):
	if body.has_method("destroy"):
		body.destroy()

func _on_hurtbox_area_entered(area):
	playerDamage()

func _on_Trigger_PlayerEntered():
	$camera.current = false


func _on_Boss_BossDead():
	$camera.current = true

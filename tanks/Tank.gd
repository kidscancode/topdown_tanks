extends KinematicBody2D

signal shoot
signal health_changed
signal ammo_changed
signal dead

export (PackedScene) var Bullet
export (int) var max_speed
export (float) var rotation_speed
export (float) var gun_cooldown
export (int) var max_health
export (float) var offroad_friction

export (int) var gun_shots = 1
export (float, 0, 1.5) var gun_spread = 0.2
export (int) var max_ammo = 20
export (int) var ammo = -1 setget set_ammo

var velocity = Vector2()
var can_shoot = true
var alive = true
var health
var map

func _ready():
	health = max_health
	$Smoke.emitting = false
	emit_signal('health_changed', health * 100/max_health)
	emit_signal('ammo_changed', ammo * 100/max_ammo)
	$GunTimer.wait_time = gun_cooldown

func control(delta):
	pass

func shoot(num, spread, target=null):
	if can_shoot and ammo != 0:
		self.ammo -= 1
		can_shoot = false
		$GunTimer.start()
		var dir = Vector2(1, 0).rotated($Turret.global_rotation)
		if num > 1:
			for i in range(num):
				var a = -spread + i * (2*spread)/(num-1)
				emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir.rotated(a), target)
		else:
			emit_signal('shoot', Bullet, $Turret/Muzzle.global_position, dir, target)
		$AnimationPlayer.play('muzzle_flash')

func _physics_process(delta):
	if not alive:
		return
	control(delta)
	if map:
		var tile = map.get_cellv(map.world_to_map(position))
		if tile in GLOBALS.slow_terrain:
			velocity *= offroad_friction
	move_and_slide(velocity)

func take_damage(amount):
	health -= amount
	emit_signal('health_changed', health * 100/max_health)
	if health < max_health / 2:
		$Smoke.emitting = true
	if health <= 0:
		explode()

func heal(amount):
	health += amount
	health = clamp(health, 0, max_health)
	emit_signal('health_changed', health * 100/max_health)
	if health >= max_health / 2:
		$Smoke.emitting = false
	
func explode():
	$CollisionShape2D.disabled = true
	alive = false
	$Turret.hide()
	$Body.hide()
	$Explosion.show()
	$Explosion.play()
	emit_signal('dead')

func _on_GunTimer_timeout():
	can_shoot = true
	
func _on_Explosion_animation_finished():
	queue_free()
	
func set_ammo(value):
	if value > max_ammo:
		value = max_ammo
	ammo = value
	emit_signal('ammo_changed', ammo * 100/max_ammo)

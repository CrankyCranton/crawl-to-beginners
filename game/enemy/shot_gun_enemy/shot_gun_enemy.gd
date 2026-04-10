class_name ShotGunEnemy extends Enemy


func _get_target() -> Node2D:
	if gun is Fists:
		return hero

	var target: Enemy = null
	for enemy: Enemy in get_tree().get_nodes_in_group(&"enemies"):
		if enemy != self and (target == null or enemy.global_position.distance_squared_to(
				self.global_position) < target.global_position.distance_squared_to(
				self.global_position)):
			target = enemy

	if target == null:
		drop_gun()
	return target


func _extra_shoot_conds() -> bool:
	var target: Node2D = _get_target()
	return target is Hero or target.health < target.max_health


func drop_gun() -> void:
	gun.queue_free()
	var fists: Fists = preload("uid://cap0tc1j8ohhe").instantiate()
	fists.collision_mask = gun.collision_mask
	const ENEMY_HIT_BOX: int = 11
	const HERO_HIT_BOX: int = 12
	fists.set_collision_mask_value(ENEMY_HIT_BOX,
			not fists.get_collision_mask_value(ENEMY_HIT_BOX))
	fists.set_collision_mask_value(HERO_HIT_BOX,
			not fists.get_collision_mask_value(HERO_HIT_BOX))


	hand.add_child(fists)
	gun = fists

class_name BossRoom extends Room


@onready var boss: Boss = $Boss


func _on_enemy_removed() -> void:
	pass
	#for enemy: Enemy in enemies.get_children():
		#if not enemy.dead:
			#return
	#boss.rampaging = true


func _on_boss_died() -> void:
	#for enemy: Enemy in enemies.get_children():
		#enemy.die()
	unlock()
	get_parent().add_child(preload("uid://6k3a6jrklndg").instantiate())


func _on_hero_set() -> void:
	boss.hero = hero

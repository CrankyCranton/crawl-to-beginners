@tool class_name Door extends Area2D


signal entered(direction: Vector2i)

@export var direction: Vector2i:
	set(value):
		direction = value
		var float_dir := Vector2(direction)
		if not is_node_ready():
			await ready
		animation_tree.set(&"parameters/locked/blend_position", float_dir)
		animation_tree.set(&"parameters/open/blend_position", float_dir)
@export var locked := true # Exported so it can be set through the animation player.

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get(
		&"parameters/playback")
@onready var spawn_point: Marker2D = $SpawnPoint


func unlock() -> void:
	playback.travel(&"open")


func _on_body_entered(_body: Node2D) -> void:
	if not locked:
		entered.emit(direction)

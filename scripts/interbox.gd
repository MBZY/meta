extends Area2D
class_name Interbox

@export var father_entity:CharacterBody2D

func _on_mouse_entered() -> void:
	if(not gmng.player):
		return
	gmng.player.now_interact_box = self
	pass # Replace with function body.

func _on_mouse_exited() -> void:
	if(not gmng.player):
		return
	if(gmng.player.now_interact_box == self):
		gmng.player.now_interact_box = null
	pass # Replace with function body.

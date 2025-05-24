extends Control
@onready var ip: LineEdit = %IP


func _on_join_pressed() -> void:
	var err:Error
	if(ip.text!=""):
		err=gmng.client_do(ip.text)
	else:
		err=gmng.client_do()
	if(err==OK):
		gmng.game_scene.server_layer.init_game()
		self.queue_free()
	pass # Replace with function body.


func _on_create_pressed() -> void:
	gmng.server_do()
	gmng.game_scene.server_layer.init_game()
	gmng.game_scene.server_layer.generate_cars()
	self.queue_free()
	pass # Replace with function body.

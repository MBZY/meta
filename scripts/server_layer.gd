extends CanvasLayer
@onready var ip_text: TextEdit = %ip_text


func _on_server_do_pressed() -> void:
	gmng.server_do()
	pass # Replace with function body.


func _on_server_join_pressed() -> void:
	if(ip_text.text!=""):
		gmng.client_do(ip_text.text)
	else:
		gmng.client_do()
	pass # Replace with function body.

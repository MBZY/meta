extends Node2D
class_name GameScene
@onready var players: Node2D = %Players
@onready var vehicles: Node2D = %Vehicles
const PLAYER = preload("res://scenes/player.tscn")
func _ready():
	gmng.game_scene = self
	pass

func add_player(id:int) -> Player:
	var temp_player = PLAYER.instantiate()
	temp_player.name = str(id)
	temp_player.global_position = Vector2.ZERO
	players.add_child(temp_player)
	print(id)
	#temp_player.camera_2d.make_current()
	return temp_player
	pass

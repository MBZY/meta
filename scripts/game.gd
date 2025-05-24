extends Node2D
class_name GameScene
@onready var players: Node2D = %Players
@onready var vehicles: Node2D = %Vehicles
const PLAYER = preload("res://scenes/player.tscn")
const CAR = preload("res://scenes/car.tscn")
@onready var server_layer: CanvasLayer = %ServerLayer

var sprites:Array[SpriteFrames]
var sprites_names:Array[String]

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
	
@rpc("authority","call_local")
func add_car(id:int,car_id:int,pos:Vector2):
	var car_scene:Car = CAR.instantiate()
	car_scene.name = str(id)
	vehicles.add_child(car_scene)
	car_scene.animated_sprite_2d.sprite_frames = sprites[car_id]
	car_scene.global_position = pos
	car_scene.obj_sprite_sheet_id = car_id
	#temp_player.camera_2d.make_current()
	return car_scene
	pass

func _physics_process(delta: float) -> void:
	if(not multiplayer.is_server()):
		return
	for i:Car in vehicles.get_children():
		i.set_sprite.rpc()
	pass

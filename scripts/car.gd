extends CharacterBody2D
class_name Car

@export var driven:bool = false

@export var max_speed := 600.0      # 最大移动速度
@export var acceleration := 30.0   # 加速度
@export var steer_speed:float = 1      # 转向灵敏度
@export var friction := 0.5        # 地面摩擦系数


@export var current_speed := 0.0
@export var current_frame := 0  # 当前显示的精灵图帧

@onready var sprite := $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export var taking_players:Array[int]
@export var obj_sprite_sheet_id:int
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@rpc("authority","call_local")
func set_sprite():
	if(gmng.game_scene.sprites.size()>obj_sprite_sheet_id):
		sprite.sprite_frames = gmng.game_scene.sprites[obj_sprite_sheet_id]
	pass

func _enter_tree() -> void:
	set_multiplayer_authority(1)
	pass

#@rpc("authority","call_local")
func interact(obj_player:Player):
	#print(gmng.player,":",obj_player)
	if(not taking_players.has(obj_player.name.to_int())):
		obj_player.is_able_to_move = false
		obj_player.camera_2d.enabled = false
		self.camera_2d.enabled = true
		self.camera_2d.make_current()
		obj_player.hide()
		append_player.rpc(obj_player.name.to_int())
	else:
		obj_player.is_able_to_move = true
		obj_player.camera_2d.enabled = true
		self.camera_2d.enabled = false
		obj_player.show()
		obj_player.camera_2d.make_current()
		obj_player.global_position = self.global_position+Vector2(0,20).rotated(deg_to_rad(current_frame * 7.5))
		erase_player.rpc(obj_player.name.to_int())
	
	if(taking_players.size()==0):
		driven = false
	else:
		driven = true
	
	pass

@rpc("any_peer","call_local")
func append_player(obj_player:int):
	taking_players.append(obj_player)
	pass
@rpc("any_peer","call_local")
func erase_player(obj_player:int):
	taking_players.erase(obj_player)
	pass


var last_refresh:int = 0
var last_refresh2:int = 0
@rpc("any_peer","call_local")
func move_the_car(steer:float,throttle:float):
	if(not multiplayer.is_server()):
		return
	#print(multiplayer.get_unique_id())
	# 转向控制
	current_frame = wrapi(current_frame + int(steer * steer_speed), 0, 48)
	# 速度控制
	current_speed = lerp(current_speed, throttle * max_speed, acceleration*(Time.get_ticks_usec()-last_refresh)/1000000)
	
	# 应用运动方向（根据当前帧计算角度）
	var move_angle = deg_to_rad(current_frame * 7.5)  # 每帧7.5度
	velocity = Vector2(cos(move_angle), sin(move_angle)) * current_speed
	
	# 应用摩擦
	if abs(throttle) < 0.1:
		current_speed *= friction
	
	# 更新精灵显示
	sprite.frame = current_frame
	#
	#if(velocity.length()!=0):
		#print(velocity.length())
	#if(Time.get_ticks_msec()-last_refresh2>=1000):
		#print((Time.get_ticks_usec()-last_refresh)/1000000)
	move_and_collide(velocity*(Time.get_ticks_usec()-last_refresh)/1000000)
		#global_position+=Vector2(50,0)
		#print("A",self)
		#last_refresh2 = Time.get_ticks_msec()
		#print(current_speed)
		#print(velocity)
		#print(Time.get_ticks_usec()-last_refresh)
		#print(get_last_slide_collision())
		#print()
	last_refresh = Time.get_ticks_usec()
	pass

func _physics_process(delta: float) -> void:
	#if not is_multiplayer_authority():
		#return
	if(not driven):
		return
	# 获取输入
	
	var throttle = Input.get_axis("DOWN", "UP")  # 建议设置：W上油门，S刹车
	var steer = Input.get_axis( "LEFT","RIGHT")  # 建议设置：A左转，D右转
	#print(taking_players)
	if(taking_players.size()>0 and gmng.player == gmng.game_scene.players.get_node(str(taking_players[0]))):
		#print("AAA")
		move_the_car.rpc_id(1,steer,throttle)
		#
#@rpc("any_peer","call_local")
#func to_move_the_car(steer:float,throttle:float):
	#if(not multiplayer.is_server()):
		#return
	#move_the_car(steer,throttle)
	#pass

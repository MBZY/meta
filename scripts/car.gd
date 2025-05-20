extends CharacterBody2D
class_name Car

@export var driven:bool = false

@export var max_speed := 600.0      # 最大移动速度
@export var acceleration := 30.0   # 加速度
@export var steer_speed:float = 1      # 转向灵敏度
@export var friction := 0.5        # 地面摩擦系数


var current_speed := 0.0
var current_frame := 0  # 当前显示的精灵图帧

@onready var sprite := $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D

@export var taking_players:Array[Player]
func _enter_tree() -> void:
	set_multiplayer_authority(multiplayer.get_unique_id())
	pass

@rpc("authority","call_local")
func interact(obj_player:Player):
	print(gmng.player,":",obj_player)
	if(not taking_players.has(obj_player)):
		obj_player.is_able_to_move = false
		obj_player.camera_2d.enabled = false
		self.camera_2d.enabled = true
		taking_players.append(obj_player)
		obj_player.hide()
	else:
		obj_player.is_able_to_move = true
		obj_player.camera_2d.enabled = true
		self.camera_2d.enabled = false
		taking_players.erase(obj_player)
		obj_player.show()
		obj_player.global_position = self.global_position+Vector2(0,20).rotated(deg_to_rad(current_frame * 7.5))
	
	if(taking_players.size()==0):
		driven = false
	else:
		driven = true
	
	pass

@rpc("authority","call_local")
func move_the_car(steer:float,throttle:float,delta:float):
	# 转向控制
	current_frame = wrapi(current_frame + int(steer * steer_speed), 0, 48)
	# 速度控制
	current_speed = lerp(current_speed, throttle * max_speed, acceleration * delta)
	
	# 应用运动方向（根据当前帧计算角度）
	var move_angle = deg_to_rad(current_frame * 7.5)  # 每帧7.5度
	velocity = Vector2(cos(move_angle), sin(move_angle)) * current_speed
	
	# 应用摩擦
	if abs(throttle) < 0.1:
		current_speed *= friction
	
	# 更新精灵显示
	sprite.frame = current_frame
	
	move_and_slide()
	pass

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	if(not driven):
		return
	# 获取输入
	
	for i in taking_players:
		i.global_position = self.global_position
	
	var throttle = Input.get_axis("DOWN", "UP")  # 建议设置：W上油门，S刹车
	var steer = Input.get_axis( "LEFT","RIGHT")  # 建议设置：A左转，D右转
	move_the_car.rpc(steer,throttle,delta)
	

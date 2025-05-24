extends CharacterBody2D
class_name Player
@export var move_speed: float = 200.0     # 移动速度
@export var rotation_speed: float = 10.0  # 转向速度

@onready var sprite := $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var speaking: PanelContainer = %Speaking

@export var is_able_to_move:bool = true

var now_interact_box:Interbox
#func try_show_speaking():
	#if(speaking.visible and speaking.modulate==Color(0,0,0,1)):
		#return
	#
	#pass
@onready var words: Label = %Words

@rpc("any_peer","call_local")
func speak(str:String):
	speaking.show()
	
	words.text = str
	
	await get_tree().create_timer(3).timeout
	speaking.hide()
	pass

func _ready():
	if(int(name) == multiplayer.get_unique_id()):
		gmng.player = self
		self.camera_2d.make_current()
		print(gmng.player)
	pass

func _enter_tree() -> void:
	set_multiplayer_authority(self.name.to_int())
	pass

func button_do():
	
	if(Input.is_action_just_pressed("INTERACT") and now_interact_box != null):
		if(now_interact_box.father_entity.has_method("interact")):
			now_interact_box.father_entity.interact(self)
		else:
			print("No Interact Method")
		pass
	
	if(not is_able_to_move):
		return
	
	# 获取输入方向
	var input_dir := Input.get_vector("LEFT", "RIGHT", "UP", "DOWN")
	
	# 移动处理
	velocity = input_dir.normalized() * move_speed
	
	# 鼠标朝向
	var mouse_pos := get_global_mouse_position()
	sprite.flip_h = bool((global_position-mouse_pos).x<0)
	
	
	# 应用运动
	move_and_slide()
	
	sprite.speed_scale = move_speed/100
	# 动画控制
	if velocity.length() > 5:
		update_animation.rpc("run")
	else:
		update_animation.rpc("idle")
	pass
	
@rpc("authority","call_local")
func update_animation(obj_animation:String):
	sprite.play(obj_animation)
	pass

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority():
		return
	button_do()
	pass

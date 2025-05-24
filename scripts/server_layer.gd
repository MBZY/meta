extends CanvasLayer
@onready var ip_text: TextEdit = %ip_text
@onready var save_when_generate: CheckButton = $HBoxContainer/SaveWhenGenerate


func _on_server_do_pressed() -> void:
	gmng.server_do()
	init_game()
	pass # Replace with function body.

func init_game():
	car_sprite_contents("res://assets/cars_sprite_frames/")
	pass

func _on_server_join_pressed() -> void:
	if(ip_text.text!=""):
		gmng.client_do(ip_text.text)
	else:
		gmng.client_do()
	init_game()
	pass # Replace with function body.
	
const CAR = preload("res://scenes/car.tscn")
var count:int = 0
func load_car_pic(dir:String,the_name:String):
	if(not dir.ends_with(".png")):
		print("Not PNG")
		return
	var temp_sprites:SpriteFrames = SpriteFrames.new()
	var temp_pic:Texture2D = load(dir)
	for i in range(7):
		for j in range(7):
			var temp_atlas:AtlasTexture = AtlasTexture.new()
			temp_atlas.atlas = temp_pic
			temp_atlas.region = Rect2(j*temp_pic.get_width()/7,i*temp_pic.get_width()/7,temp_pic.get_width()/7,temp_pic.get_width()/7)
			temp_sprites.add_frame("default",temp_atlas)
	print(ResourceSaver.save(temp_sprites,"res://assets/cars_sprite_frames/"+the_name+".tres"))
	count+=1
	pass

func car_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("发现目录：" + file_name)
				car_contents(dir.get_current_dir()+"/"+file_name)
			else:
				print("发现文件" + file_name)
				load_car_pic(dir.get_current_dir()+"/"+file_name,file_name)
				
			file_name = dir.get_next()
	else:
		print("尝试访问路径时出错。")
		
func _on_load_cars_pressed() -> void:
	car_contents("res://assets/cars/")
	pass # Replace with function body.



func car_sprite_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("发现目录：" + file_name)
				car_sprite_contents(dir.get_current_dir()+"/"+file_name)
			else:
				print("发现文件" + file_name)
				gmng.game_scene.sprites.append(ResourceLoader.load(dir.get_current_dir()+"/"+file_name))
				gmng.game_scene.sprites_names.append(file_name)
			file_name = dir.get_next()
	else:
		print("尝试访问路径时出错。")

func get_all_children(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		result.append(child)
		result += get_all_children(child)  # 递归调用
	return result



@export var car_count:int = 0
@rpc("any_peer","call_local")
func car_count_set(x):
	car_count = x
	pass
func generate_cars():
	for i in range(gmng.game_scene.sprites.size()):
		var temp_car = CAR.instantiate()
		gmng.game_scene.add_car.rpc_id(1,car_count,i,Vector2(-2340,1700)+Vector2(150,0)*(i%6)+Vector2(0,50)*floori(i/6))
		car_count_set.rpc_id(1,car_count+1)
		if(save_when_generate.button_pressed):
			var scene = PackedScene.new()
			var dup = temp_car.duplicate()
			for k in get_all_children(dup):
				k.owner = dup
			var result = scene.pack(dup)
			if(result == OK):
				ResourceSaver.save(scene,"res://assets/car_scenes/"+gmng.game_scene.sprites_names[i]+".tscn")
			
	pass
func _on_generate_cars_pressed() -> void:
	generate_cars()
	pass # Replace with function body.

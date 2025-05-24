extends Node
class_name GameManager
var player:Player
var game_scene:GameScene
var peer:ENetMultiplayerPeer

const classic_port:int = 12366
func network():
	pass
	
func server_do(port:int = classic_port,max_clients:int = 16):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_clients)
	if(error!=OK):
		print("!",error)
		return
		
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	gmng.player = gmng.game_scene.add_player(multiplayer.get_unique_id())
	pass

func client_do(address:String="127.0.0.1",port:int = classic_port)->Error:
	if(address.find(":")!=-1):
		var ts = address.split(":")
		address = ts[0]
		port = int(ts[1])
		print(address)
		print(port)
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if(error!=OK):
		print("!",error)
		return error
	#print("AAA")
	multiplayer.multiplayer_peer = peer
	return OK
	pass

func _on_peer_connected(id:int):
	gmng.game_scene.add_player(id)
	pass

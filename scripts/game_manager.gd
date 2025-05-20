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

func client_do(address:String="127.0.0.1",port:int = classic_port):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if(error!=OK):
		print("!",error)
		return
	#print("AAA")
	multiplayer.multiplayer_peer = peer
	pass

func _on_peer_connected(id:int):
	gmng.game_scene.add_player(id)
	pass
